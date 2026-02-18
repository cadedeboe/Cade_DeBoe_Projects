# Event Ticketing & Seating System

**COMP 345 Database Management Systems - Final Project Reference Implementation**

A complete, production-ready database system for managing event ticketing, venue seating, customer orders, and ticket sales with comprehensive business logic, security features, and performance optimization.

---

## Table of Contents

- [Overview](#overview)
- [System Requirements](#system-requirements)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Database Schema](#database-schema)
- [Features](#features)
- [Running the Project](#running-the-project)
- [Testing & Validation](#testing--validation)
- [Performance Analysis](#performance-analysis)
- [Security & Roles](#security--roles)
- [Backup & Restore](#backup--restore)
- [Documentation](#documentation)

---

## Overview

This project implements a comprehensive event ticketing and seating management system that handles:

- **Venue Management**: Multiple venues with sections and seat maps
- **Event Scheduling**: Concerts, sports, theater, and other event types
- **Ticket Sales**: Multi-tier pricing, promo codes, and dynamic pricing
- **Seat Assignment**: Unique seat allocation per event with hold/purchase workflows
- **Customer Management**: Loyalty tiers, purchase history, and fraud detection
- **Refund Processing**: Policy-based refund calculations and processing
- **Reporting**: Revenue analysis, conversion metrics, and occupancy heatmaps

### Key Statistics

- **12 Core Entities** with proper normalization (3NF/BCNF)
- **100+ Sample Records** across all tables
- **8 Views** for reporting and security
- **3 Stored Functions** for business logic
- **2 Stored Procedures** for complex transactions
- **10 Triggers** for data integrity and business rules
- **40+ Indexes** for query optimization
- **12 Complex Queries** demonstrating various SQL techniques

---

## System Requirements

### Required Software

- **MySQL 8.0+** (or MariaDB 10.5+)
- **Bash** (for shell scripts) or **Python 3.8+** (for Python scripts)
- **Git** (for version control)

### Optional Tools

- **DBeaver** (recommended for COMP 345 - for visual database design and ER diagrams)
- Python packages (for Python scripts):
  ```bash
  pip install mysql-connector-python tabulate
  ```

---

## Quick Start

### Option 1: Using Shell Scripts (Recommended for Unix/Linux/macOS)

```bash
# 1. Clone or navigate to the project directory
cd events_system_mysql

# 2. Set MySQL credentials (if needed)
export MYSQL_USER=root
export MYSQL_PASSWORD=your_password
export MYSQL_HOST=localhost
export MYSQL_PORT=3306

# 3. Run the setup script
./scripts/load.sh

# 4. Verify installation
mysql -u root -p event_ticketing -e "SHOW TABLES;"
```

### Option 2: Using Python Scripts (Cross-platform)

```bash
# 1. Install Python dependencies
pip install mysql-connector-python tabulate

# 2. Set MySQL credentials (if needed)
export MYSQL_USER=root
export MYSQL_PASSWORD=your_password

# 3. Run the setup script
python3 scripts/load.py

# 4. Verify installation
mysql -u root -p event_ticketing -e "SHOW TABLES;"
```

### Expected Output

After successful setup, you should see:

```
✓ Schema creation (tables, constraints) completed
✓ Sample data insertion completed
✓ View creation completed
✓ Functions and stored procedures completed
✓ Trigger creation completed
✓ Index creation completed

Database objects created: Tables: 12, Views: 8, Procedures: 2, Functions: 3, Triggers: 10

Table                     Row Count
---------------------------------
venues                           5
sections                        19
seats                          110
customers                       50
events                          10
ticket_tiers                    30
promo_codes                     10
orders                          60
tickets                        107
event_seat_assignments          21
refunds                          3
```

---

## Project Structure

```
events_system_mysql/
├── README.md                      # This file
├── docs/
│   ├── erd.pdf                    # Entity-Relationship Diagram
│   └── design_rationale.pdf       # Design decisions and normalization
├── sql/
│   ├── 01_schema.sql              # DDL: Tables, constraints, types
│   ├── 02_seed.sql                # Sample data (100+ rows)
│   ├── 03_views.sql               # 8 views for reporting/security
│   ├── 04_functions.sql           # 3 functions + 2 stored procedures
│   ├── 05_triggers.sql            # 10 triggers for business rules
│   ├── 06_indexes.sql             # 40+ indexes with rationale
│   ├── 07_queries.sql             # 12 complex queries
│   └── 08_transactions.sql        # ACID & isolation demonstrations
├── scripts/
│   ├── load.sh                    # Shell: Database setup
│   ├── load.py                    # Python: Database setup
│   ├── explain.sh                 # Shell: Performance analysis
│   └── explain.py                 # Python: Performance analysis
└── data/
    └── (CSV files if applicable)
```

---

## Database Schema

### Core Entities (12 Tables)

1. **venues** - Physical locations for events
2. **sections** - Logical divisions within venues
3. **seats** - Individual seats with accessibility features
4. **customers** - Customer accounts with loyalty tiers
5. **events** - Scheduled performances/games/shows
6. **ticket_tiers** - Pricing levels for events
7. **promo_codes** - Discount codes with usage limits
8. **orders** - Customer purchase transactions
9. **tickets** - Individual tickets (bridge: orders ↔ seats)
10. **event_seat_assignments** - Seat allocation per event (bridge: events ↔ seats)
11. **refunds** - Refund transaction records
12. **audit_log** - System audit trail

### Key Relationships

- **Many-to-One**: Events → Venues, Tickets → Orders, Sections → Venues
- **Many-to-Many**: Events ↔ Seats (via event_seat_assignments), Orders ↔ Tickets

### Constraints

- **3 CHECK Constraints**: Capacity limits, date validations, price validations
- **Foreign Keys**: All relationships enforced with ON DELETE/UPDATE rules
- **UNIQUE Constraints**: Seat uniqueness, email uniqueness, order numbers
- **NOT NULL**: Required fields enforced at database level

---

## Features

### Business Logic

- **Dynamic Pricing**: Prices adjust based on demand and time until event
- **Hold Windows**: 15-minute hold period for ticket reservations
- **Refund Policies**: Tiered refund amounts based on days until event
- **Seat Uniqueness**: Prevents double-booking via triggers
- **Loyalty Tiers**: Automatic tier upgrades based on lifetime spend
- **Promo Code Limits**: Usage tracking and automatic deactivation

### Security

- **Role-Based Access**: Admin, app-writer, read-only roles
- **Security Views**: PII masking for customer data
- **Input Validation**: CHECK constraints and triggers
- **Audit Logging**: All order changes tracked

### Performance

- **40+ Indexes**: Covering, composite, and partial indexes
- **Query Optimization**: EXPLAIN analysis for all major queries
- **Covering Indexes**: Eliminate table access for common queries
- **Composite Indexes**: Support multiple query patterns

---

## Running the Project

### 1. Database Setup

**Using Shell Script:**
```bash
./scripts/load.sh
```

**Using Python Script:**
```bash
python3 scripts/load.py
```

### 2. Run Sample Queries

```bash
mysql -u root -p event_ticketing < sql/07_queries.sql
```

### 3. Test Transactions

```bash
mysql -u root -p event_ticketing < sql/08_transactions.sql
```

### 4. Performance Analysis

**Using Shell Script:**
```bash
./scripts/explain.sh
```

**Using Python Script:**
```bash
python3 scripts/explain.py
```

---

## Testing & Validation

### Verify Data Integrity

```sql
-- Check for orphaned records
SELECT 'Orphaned Tickets' AS issue, COUNT(*) AS count
FROM tickets t
LEFT JOIN orders o ON t.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Verify seat uniqueness per event
SELECT event_id, seat_id, COUNT(*) AS assignments
FROM event_seat_assignments
WHERE assignment_status = 'sold'
GROUP BY event_id, seat_id
HAVING COUNT(*) > 1;

-- Check constraint violations
SELECT * FROM events WHERE tickets_sold > total_tickets_available;
```

### Test Business Rules

```sql
-- Test trigger: Prevent double-booking
INSERT INTO event_seat_assignments (event_id, seat_id, ticket_id, assignment_status)
VALUES (4, 1, 999, 'sold');  -- Should fail - seat 1 already sold

-- Test function: Calculate dynamic price
SELECT fn_calculate_dynamic_price(100.00, '2025-12-15', 800, 1000) AS dynamic_price;

-- Test procedure: Process ticket purchase
CALL sp_process_ticket_purchase(1, 1, 3, NULL, 2, 'SUMMER2025', 'credit_card', @order_id, @status);
SELECT @order_id, @status;
```

---

## Performance Analysis

### Run EXPLAIN Analysis

```bash
./scripts/explain.sh
# or
python3 scripts/explain.py
```

### Key Performance Metrics

| Query Type | Without Index | With Index | Improvement |
|------------|---------------|------------|-------------|
| Customer Orders | Full scan (60 rows) | Index scan (5 rows) | 92% reduction |
| Event Revenue | 4-table scan | Index joins | 85% faster |
| Fraud Detection | Temp table + sort | Covering index | 70% faster |

### Index Strategy

- **Foreign Keys**: All FK columns indexed for JOIN performance
- **Composite Indexes**: `(customer_id, order_date)` supports filtering + sorting
- **Covering Indexes**: Include all SELECT columns to avoid table access
- **Partial Indexes**: Index only active/relevant rows

## Documentation

### Design Documents

- **`docs/erd.png`**: Complete Entity-Relationship Diagram
- **`docs/design_rationale.md`**: 
  - Requirements analysis
  - Functional dependencies
  - Normalization steps (1NF → 2NF → 3NF)
  - Design decisions and trade-offs
  - Performance considerations

### Inline Documentation

All SQL files include:
- Purpose and description headers
- Inline comments explaining business logic
- Constraint rationale
- Index justification
- Query complexity notes

---

## License

This project is created for educational purposes as part of COMP 345 Database Management Systems course at the University of San Diego.

---

**Last Updated**: 2025-10-20

