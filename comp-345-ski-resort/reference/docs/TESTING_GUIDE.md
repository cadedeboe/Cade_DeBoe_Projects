# Testing & Validation Guide

**Event Ticketing & Seating System - COMP 345 Final Project**

---

## Table of Contents

1. [Pre-Testing Setup](#1-pre-testing-setup)
2. [Database Setup Testing](#2-database-setup-testing)
3. [Data Integrity Testing](#3-data-integrity-testing)
4. [Business Logic Testing](#4-business-logic-testing)
5. [Performance Testing](#5-performance-testing)
6. [Security Testing](#6-security-testing)
7. [Backup & Restore Testing](#7-backup--restore-testing)
8. [Grading Rubric Validation](#8-grading-rubric-validation)

---

## 1. Pre-Testing Setup

### 1.1 Verify MySQL Installation

```bash
# Check MySQL version (should be 8.0+)
mysql --version

# Test MySQL connection
mysql -u root -p -e "SELECT VERSION();"
```

**Expected Output:**
```
mysql  Ver 8.0.x for macos13 on arm64 (MySQL Community Server - GPL)
```

### 1.2 Set Environment Variables

```bash
# For shell scripts
export MYSQL_USER=root
export MYSQL_PASSWORD=your_password
export MYSQL_HOST=localhost
export MYSQL_PORT=3306

# Verify
echo $MYSQL_USER
```

### 1.3 Install Python Dependencies (for Python scripts)

```bash
# Install required packages
pip install -r requirements.txt

# Verify installation
python3 -c "import mysql.connector; print('MySQL connector installed')"
python3 -c "import tabulate; print('Tabulate installed')"
```

---

## 2. Database Setup Testing

### 2.1 Test Shell Script Setup

```bash
# Run the load script
./scripts/load.sh

# Expected output should show:
# ✓ Schema creation completed
# ✓ Sample data insertion completed
# ✓ View creation completed
# ✓ Functions and stored procedures completed
# ✓ Trigger creation completed
# ✓ Index creation completed
```

**Validation:**
```bash
# Check database exists
mysql -u root -p -e "SHOW DATABASES LIKE 'event_ticketing';"

# Check table count (should be 12)
mysql -u root -p event_ticketing -e "SHOW TABLES;" | wc -l

# Check row counts
mysql -u root -p event_ticketing -e "
SELECT 
    (SELECT COUNT(*) FROM venues) AS venues,
    (SELECT COUNT(*) FROM customers) AS customers,
    (SELECT COUNT(*) FROM events) AS events,
    (SELECT COUNT(*) FROM tickets) AS tickets;
"
```

**Expected Results:**
- venues: 5
- customers: 50
- events: 10
- tickets: 107

### 2.2 Test Python Script Setup

```bash
# Drop database first (if exists)
mysql -u root -p -e "DROP DATABASE IF EXISTS event_ticketing;"

# Run Python load script
python3 scripts/load.py

# Verify same results as shell script
mysql -u root -p event_ticketing -e "SELECT COUNT(*) FROM customers;"
```

**Expected Output:** 50

### 2.3 Test Idempotency

```bash
# Run load script twice - should not error
./scripts/load.sh
./scripts/load.sh

# Verify data is not duplicated
mysql -u root -p event_ticketing -e "SELECT COUNT(*) FROM customers;"
```

**Expected Output:** Still 50 (not 100)

---

## 3. Data Integrity Testing

### 3.1 Test Foreign Key Constraints

```sql
-- Test 1: Try to insert order with non-existent customer
-- Expected: ERROR 1452 (23000): Cannot add or update a child row
INSERT INTO orders (customer_id, order_number, order_date, total_amount, order_status)
VALUES (99999, 'TEST-001', NOW(), 100.00, 'pending');

-- Test 2: Try to delete venue with existing events
-- Expected: ERROR 1451 (23000): Cannot delete or update a parent row
DELETE FROM venues WHERE venue_id = 1;

-- Test 3: Delete promo code with SET NULL behavior
-- Expected: Success, orders.promo_id set to NULL
DELETE FROM promo_codes WHERE promo_id = 1;
SELECT promo_id FROM orders WHERE order_id = 1;  -- Should be NULL
```

### 3.2 Test CHECK Constraints

```sql
-- Test 1: Invalid venue capacity (too low)
-- Expected: ERROR 3819 (HY000): Check constraint 'chk_venue_capacity' is violated
INSERT INTO venues (venue_name, city, total_capacity)
VALUES ('Test Venue', 'Test City', 0);

-- Test 2: Invalid event date (past date)
-- Expected: ERROR 3819 (HY000): Check constraint 'chk_event_datetime' is violated
INSERT INTO events (venue_id, event_name, event_date, event_time)
VALUES (1, 'Past Event', '2020-01-01', '19:00:00');

-- Test 3: Invalid ticket price (negative)
-- Expected: ERROR 3819 (HY000): Check constraint 'chk_tier_price' is violated
INSERT INTO ticket_tiers (event_id, tier_name, base_price)
VALUES (1, 'Test Tier', -10.00);
```

### 3.3 Test UNIQUE Constraints

```sql
-- Test 1: Duplicate customer email
-- Expected: ERROR 1062 (23000): Duplicate entry
INSERT INTO customers (email, first_name, last_name)
VALUES ('alice.johnson@email.com', 'Test', 'User');

-- Test 2: Duplicate ticket number
-- Expected: ERROR 1062 (23000): Duplicate entry
INSERT INTO tickets (order_id, event_id, tier_id, ticket_number, ticket_status, purchase_price)
VALUES (1, 1, 1, 'TKT-000001', 'purchased', 100.00);
```

---

## 4. Business Logic Testing

### 4.1 Test Triggers

#### Test 1: Prevent Double-Booking

```sql
-- Insert first seat assignment (should succeed)
INSERT INTO event_seat_assignments (event_id, seat_id, assignment_status)
VALUES (1, 50, 'sold');

-- Try to insert duplicate (should fail)
-- Expected: ERROR 1062 (23000): Duplicate entry
INSERT INTO event_seat_assignments (event_id, seat_id, assignment_status)
VALUES (1, 50, 'sold');
```

#### Test 2: Auto-Update Loyalty Tier

```sql
-- Check current tier
SELECT customer_id, loyalty_tier, total_lifetime_spend 
FROM customers WHERE customer_id = 1;

-- Update spend to trigger tier upgrade
UPDATE customers SET total_lifetime_spend = 5500.00 WHERE customer_id = 1;

-- Verify tier upgraded to Platinum
SELECT customer_id, loyalty_tier, total_lifetime_spend 
FROM customers WHERE customer_id = 1;
-- Expected: loyalty_tier = 'Platinum'
```

#### Test 3: Audit Logging

```sql
-- Check current audit log count
SELECT COUNT(*) FROM audit_log;

-- Make a change to an order
UPDATE orders SET order_status = 'cancelled' WHERE order_id = 1;

-- Verify audit log entry created
SELECT * FROM audit_log ORDER BY changed_at DESC LIMIT 1;
-- Expected: New entry with action = 'UPDATE', table_name = 'orders'
```

### 4.2 Test Stored Functions

#### Test 1: Dynamic Pricing

```sql
-- Test dynamic pricing function
SELECT fn_calculate_dynamic_price(
    100.00,           -- base_price
    '2025-12-15',     -- event_date
    800,              -- tickets_sold
    1000              -- total_capacity
) AS dynamic_price;

-- Expected: Price > 100.00 (increased due to high demand)
```

#### Test 2: Seat Availability

```sql
-- Test seat availability check
SELECT fn_check_seat_availability(1, 1) AS is_available;
-- Expected: 0 (false) if seat 1 is already assigned to event 1
```

#### Test 3: Refund Calculation

```sql
-- Test refund calculation (>14 days before event)
SELECT fn_calculate_refund_amount(
    100.00,           -- purchase_price
    '2025-12-15',     -- event_date
    CURRENT_DATE      -- refund_date
) AS refund_amount;

-- Expected: 100.00 (100% refund)

-- Test refund calculation (<3 days before event)
SELECT fn_calculate_refund_amount(
    100.00,
    DATE_ADD(CURRENT_DATE, INTERVAL 2 DAY),
    CURRENT_DATE
) AS refund_amount;

-- Expected: 0.00 (no refund)
```

### 4.3 Test Stored Procedures

#### Test 1: Ticket Purchase

```sql
-- Test ticket purchase procedure
CALL sp_process_ticket_purchase(
    1,                -- p_customer_id
    1,                -- p_event_id
    3,                -- p_tier_id
    NULL,             -- p_seat_id (general admission)
    2,                -- p_quantity
    'SUMMER2025',     -- p_promo_code
    'credit_card',    -- p_payment_method
    @order_id,        -- OUT parameter
    @status           -- OUT parameter
);

-- Check results
SELECT @order_id AS order_id, @status AS status;
-- Expected: order_id > 0, status = 'success'

-- Verify order created
SELECT * FROM orders WHERE order_id = @order_id;

-- Verify tickets created
SELECT * FROM tickets WHERE order_id = @order_id;
```

#### Test 2: Refund Processing

```sql
-- Test refund procedure
CALL sp_process_refund_request(
    1,                -- p_ticket_id
    'Changed plans',  -- p_reason
    @refund_amount,   -- OUT parameter
    @status           -- OUT parameter
);

-- Check results
SELECT @refund_amount AS refund_amount, @status AS status;

-- Verify refund record created
SELECT * FROM refunds WHERE ticket_id = 1;

-- Verify ticket status updated
SELECT ticket_status FROM tickets WHERE ticket_id = 1;
-- Expected: 'refunded'
```

---

## 5. Performance Testing

### 5.1 Run EXPLAIN Analysis

```bash
# Using shell script
./scripts/explain.sh

# Using Python script
python3 scripts/explain.py
```

**Validation Checklist:**
- [ ] EXPLAIN output shows index usage (type = 'ref' or 'eq_ref')
- [ ] Covering indexes show "Using index" in Extra column
- [ ] Before/after comparison shows performance improvement
- [ ] No full table scans on large tables (type != 'ALL')

### 5.2 Test Index Impact

```sql
-- Test 1: Query without index
DROP INDEX idx_order_customer_date ON orders;

EXPLAIN SELECT * FROM orders 
WHERE customer_id = 1 
ORDER BY order_date DESC;
-- Expected: type = 'ALL' (full table scan)

-- Test 2: Query with index
CREATE INDEX idx_order_customer_date ON orders(customer_id, order_date DESC);

EXPLAIN SELECT * FROM orders 
WHERE customer_id = 1 
ORDER BY order_date DESC;
-- Expected: type = 'ref' (index scan)
```

### 5.3 Test Query Performance

```sql
-- Enable profiling
SET profiling = 1;

-- Run complex query
SELECT 
    e.event_id, e.event_name,
    COUNT(t.ticket_id) AS tickets_sold,
    SUM(t.purchase_price) AS total_revenue
FROM events e
LEFT JOIN tickets t ON e.event_id = t.event_id
WHERE e.event_status = 'on_sale'
GROUP BY e.event_id, e.event_name;

-- Show profile
SHOW PROFILES;
SHOW PROFILE FOR QUERY 1;

-- Expected: Query duration < 0.1 seconds for sample data
```

---

## 6. Security Testing

### 6.1 Test Role-Based Access

```sql
-- Create test users
CREATE USER 'test_admin'@'localhost' IDENTIFIED BY 'admin_pass';
CREATE USER 'test_app'@'localhost' IDENTIFIED BY 'app_pass';
CREATE USER 'test_analyst'@'localhost' IDENTIFIED BY 'analyst_pass';

-- Grant privileges
GRANT ALL PRIVILEGES ON event_ticketing.* TO 'test_admin'@'localhost';
GRANT SELECT, INSERT, UPDATE ON event_ticketing.* TO 'test_app'@'localhost';
GRANT SELECT ON event_ticketing.* TO 'test_analyst'@'localhost';

FLUSH PRIVILEGES;
```

**Test Admin Access:**
```bash
mysql -u test_admin -padmin_pass event_ticketing -e "DELETE FROM audit_log WHERE log_id = 1;"
# Expected: Success
```

**Test App Access:**
```bash
mysql -u test_app -papp_pass event_ticketing -e "DELETE FROM audit_log WHERE log_id = 1;"
# Expected: ERROR 1142 (42000): DELETE command denied
```

**Test Analyst Access:**
```bash
mysql -u test_analyst -panalyst_pass event_ticketing -e "INSERT INTO customers (email, first_name, last_name) VALUES ('test@test.com', 'Test', 'User');"
# Expected: ERROR 1142 (42000): INSERT command denied
```

### 6.2 Test Security Views

```sql
-- Test PII masking
SELECT * FROM vw_customer_purchase_history LIMIT 5;
-- Expected: Email and names should be masked (e.g., "a***@email.com")

-- Compare with full access view
SELECT * FROM vw_customer_contact_secure LIMIT 5;
-- Expected: Full email and names visible
```

---

## 7. Backup & Restore Testing (Optional - Best Practice)

> **Note**: Backup and restore functionality is **not a graded requirement** for the COMP 345 final project. However, understanding database backup and recovery is an important professional skill. The following tests demonstrate best practices for database reliability.

### 7.1 Test Backup Creation

**Using DBeaver (Recommended):**
1. Right-click on `event_ticketing` database in Database Navigator
2. Select **Tools** → **Backup Database**
3. Choose backup location (e.g., `backups/event_ticketing_backup.sql`)
4. Select options:
   - Include structure and data
   - Include routines, triggers, and events
5. Click **Start**
6. Verify backup file created

**Using mysqldump (Command Line):**
```bash
# Create backup directory
mkdir -p backups

# Create backup
mysqldump -u root -p --single-transaction --routines --triggers \
  --events event_ticketing > backups/event_ticketing_backup.sql

# Verify backup file created
ls -lh backups/
# Expected: event_ticketing_backup.sql
```

### 7.2 Test Restore

**Using DBeaver (Recommended):**
1. Make a change to test restore:
   ```sql
   DELETE FROM customers WHERE customer_id = 50;
   SELECT COUNT(*) FROM customers;  -- Expected: 49
   ```
2. Right-click on `event_ticketing` database
3. Select **Tools** → **Restore Database**
4. Choose the backup file created in 7.1
5. Click **Start**
6. Verify restoration:
   ```sql
   SELECT COUNT(*) FROM customers;  -- Expected: 50 (restored)
   ```

**Using mysql (Command Line):**
```bash
# Make a change to the database
mysql -u root -p event_ticketing -e "DELETE FROM customers WHERE customer_id = 50;"

# Verify deletion
mysql -u root -p event_ticketing -e "SELECT COUNT(*) FROM customers;"
# Expected: 49

# Restore from backup
mysql -u root -p event_ticketing < backups/event_ticketing_backup.sql

# Verify restoration
mysql -u root -p event_ticketing -e "SELECT COUNT(*) FROM customers;"
# Expected: 50 (restored)
```

---

## 8. Grading Rubric Validation

### 8.1 Conceptual & Logical Design (30 pts)

**Requirements (5 pts):**
- [ ] Scenario #3 (Event Ticketing) fully implemented
- [ ] All business rules documented

**ERD (10 pts):**
- [ ] 12 entities shown
- [ ] Crow's Foot notation used
- [ ] Cardinalities correct
- [ ] Bridge tables identified

**Normalization (10 pts):**
- [ ] Functional dependencies documented (see design_rationale.md)
- [ ] 3NF achieved
- [ ] No update/delete/insert anomalies

**Mapping (5 pts):**
- [ ] ERD correctly maps to schema
- [ ] All relationships implemented as FKs

### 8.2 Physical Implementation & Workload (40 pts)

**DDL & Constraints (10 pts):**
```sql
-- Verify table count
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'event_ticketing';
-- Expected: 12

-- Verify CHECK constraints
SELECT COUNT(*) FROM information_schema.check_constraints 
WHERE constraint_schema = 'event_ticketing';
-- Expected: >= 3

-- Verify foreign keys
SELECT COUNT(*) FROM information_schema.key_column_usage 
WHERE table_schema = 'event_ticketing' 
AND referenced_table_name IS NOT NULL;
-- Expected: >= 10
```

**Data Loading (5 pts):**
```sql
-- Verify total row count
SELECT 
    (SELECT COUNT(*) FROM venues) +
    (SELECT COUNT(*) FROM sections) +
    (SELECT COUNT(*) FROM seats) +
    (SELECT COUNT(*) FROM customers) +
    (SELECT COUNT(*) FROM events) +
    (SELECT COUNT(*) FROM ticket_tiers) +
    (SELECT COUNT(*) FROM promo_codes) +
    (SELECT COUNT(*) FROM orders) +
    (SELECT COUNT(*) FROM tickets) +
    (SELECT COUNT(*) FROM event_seat_assignments) +
    (SELECT COUNT(*) FROM refunds) AS total_rows;
-- Expected: >= 100

-- Verify customers table has >= 50 rows
SELECT COUNT(*) FROM customers;
-- Expected: >= 50
```

**Views/Functions/Triggers (10 pts):**
```sql
-- Verify views
SELECT COUNT(*) FROM information_schema.views 
WHERE table_schema = 'event_ticketing';
-- Expected: 8

-- Verify functions
SELECT COUNT(*) FROM information_schema.routines 
WHERE routine_schema = 'event_ticketing' 
AND routine_type = 'FUNCTION';
-- Expected: 3

-- Verify procedures
SELECT COUNT(*) FROM information_schema.routines 
WHERE routine_schema = 'event_ticketing' 
AND routine_type = 'PROCEDURE';
-- Expected: 2

-- Verify triggers
SELECT COUNT(*) FROM information_schema.triggers 
WHERE trigger_schema = 'event_ticketing';
-- Expected: 10
```

**Queries (15 pts):**
- [ ] 12 queries in sql/07_queries.sql
- [ ] Multi-table JOINs (4+ tables)
- [ ] Window functions used
- [ ] CTEs used
- [ ] Correlated subqueries used
- [ ] Report query included

### 8.3 Performance & Indexing (15 pts)

**Index Choices (6 pts):**
```sql
-- Verify index count
SELECT COUNT(*) FROM information_schema.statistics 
WHERE table_schema = 'event_ticketing' 
AND index_name != 'PRIMARY';
-- Expected: >= 40
```

**EXPLAIN Evidence (6 pts):**
- [ ] explain.sh or explain.py runs without errors
- [ ] Shows before/after comparisons
- [ ] Demonstrates index usage

**Discussion (3 pts):**
- [ ] Trade-offs documented in sql/06_indexes.sql
- [ ] Rationale for each index provided

### 8.4 Security, Integrity, Reliability (10 pts)

**Roles & Privileges (5 pts):**
- [ ] Admin role created
- [ ] App-writer role created
- [ ] Read-only role created
- [ ] Proper privilege separation implemented
- [ ] Security views demonstrate access control

**Integrity Rules (5 pts):**
- [ ] CHECK constraints implemented (minimum 3)
- [ ] Triggers enforce business rules
- [ ] Foreign keys enforce relationships
- [ ] Data validation in stored procedures
- [ ] Audit logging for critical operations

### 8.5 Documentation & Presentation (5 pts)

- [ ] README.md complete with setup instructions
- [ ] design_rationale.md explains design decisions
- [ ] ERD provided (erd.pdf or ERD_INSTRUCTIONS.md)
- [ ] All SQL files have inline comments
- [ ] Scripts have usage instructions

---

## Final Validation Checklist

Before submission, verify:

- [ ] All scripts run without errors
- [ ] Database can be set up from scratch in one command
- [ ] All 100 rubric points are addressed
- [ ] Documentation is complete and clear
- [ ] Sample data is realistic and sufficient
- [ ] All business rules are enforced
- [ ] Performance is acceptable (queries < 1 second)
- [ ] Role-based access control is properly configured
- [ ] Integrity constraints are enforced (CHECK, FK, triggers)

---

**Last Updated**: 2025-10-20

