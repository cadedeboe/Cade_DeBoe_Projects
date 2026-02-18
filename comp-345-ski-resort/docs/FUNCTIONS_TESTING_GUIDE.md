# Testing & Validation Guide - Functions & Procedures

**Ski Resort Management System - COMP 345 Final Project**

---

## Table of Contents

1. [Pre-Testing Setup](#1-pre-testing-setup)
2. [Function Testing](#2-function-testing)
3. [Stored Procedure Testing](#3-stored-procedure-testing)
4. [Integration Testing](#4-integration-testing)
5. [Error Handling Testing](#5-error-handling-testing)
6. [Business Logic Validation](#6-business-logic-validation)

---

## 1. Pre-Testing Setup

### 1.1 Verify Database Setup

```sql
USE ski_resort;

-- Verify functions exist
SELECT 
    ROUTINE_NAME,
    ROUTINE_TYPE,
    CREATED,
    LAST_ALTERED
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'ski_resort'
AND ROUTINE_TYPE = 'FUNCTION'
ORDER BY ROUTINE_NAME;

-- Expected: 3 functions
--   - fn_calculate_rental_price
--   - fn_check_equipment_availability
--   - fn_calculate_ticket_refund

-- Verify procedures exist
SELECT 
    ROUTINE_NAME,
    ROUTINE_TYPE,
    CREATED,
    LAST_ALTERED
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'ski_resort'
AND ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;

-- Expected: 2 procedures
--   - sp_process_equipment_rental
--   - sp_process_ticket_purchase
```

### 1.2 Verify Seed Data

```sql
USE ski_resort;

-- Check available equipment
SELECT COUNT(*) AS available_equipment_count
FROM Equipment
WHERE Status = 'Available';

-- Expected: Multiple available equipment items

-- Check customers exist
SELECT COUNT(*) AS customer_count
FROM Customers;

-- Expected: >= 20 customers

-- Check pass types exist
SELECT PassTypeID, PassName, CurrentPrice
FROM Pass_Types
ORDER BY PassTypeID;

-- Expected: Multiple pass types with different prices
```

---

## 2. Function Testing

### 2.1 Test `fn_calculate_rental_price`

#### Test 1: Basic Rental Price Calculation

```sql
USE ski_resort;

-- Test Ski rental (5 days)
SELECT fn_calculate_rental_price('Ski', 5, 1) AS ski_rental_price;
-- Expected: 125.00 (25.00/day × 5 days)

-- Test Snowboard rental (3 days)
SELECT fn_calculate_rental_price('Snowboard', 3, 1) AS snowboard_rental_price;
-- Expected: 90.00 (30.00/day × 3 days)

-- Test Boots rental (2 days)
SELECT fn_calculate_rental_price('Boots', 2, 1) AS boots_rental_price;
-- Expected: 30.00 (15.00/day × 2 days)

-- Test Poles rental (7 days)
SELECT fn_calculate_rental_price('Poles', 7, 1) AS poles_rental_price;
-- Expected: 31.50 (5.00/day × 7 days × 0.90 discount)

-- Test Helmet rental (4 days)
SELECT fn_calculate_rental_price('Helmet', 4, 1) AS helmet_rental_price;
-- Expected: 32.00 (8.00/day × 4 days)

-- Test Goggles rental (3 days)
SELECT fn_calculate_rental_price('Goggles', 3, 1) AS goggles_rental_price;
-- Expected: 30.00 (10.00/day × 3 days)
```

#### Test 2: Long-Term Discount (7+ days)

```sql
USE ski_resort;

-- Test 7-day rental (should get 10% discount)
SELECT fn_calculate_rental_price('Ski', 7, 1) AS seven_day_price;
-- Expected: 157.50 (25.00/day × 7 days × 0.90)

-- Test 10-day rental (should get 10% discount)
SELECT fn_calculate_rental_price('Ski', 10, 1) AS ten_day_price;
-- Expected: 225.00 (25.00/day × 10 days × 0.90)

-- Test 6-day rental (should NOT get discount)
SELECT fn_calculate_rental_price('Ski', 6, 1) AS six_day_price;
-- Expected: 150.00 (25.00/day × 6 days, no discount)
```

#### Test 3: Multiple Quantity

```sql
USE ski_resort;

-- Test 2 skis for 5 days
SELECT fn_calculate_rental_price('Ski', 5, 2) AS two_skis_price;
-- Expected: 250.00 (25.00/day × 5 days × 2 skis)

-- Test 3 snowboards for 7 days (with discount)
SELECT fn_calculate_rental_price('Snowboard', 7, 3) AS three_snowboards_price;
-- Expected: 567.00 (30.00/day × 7 days × 3 boards × 0.90)
```

#### Test 4: Invalid Equipment Type

```sql
USE ski_resort;

-- Test unknown equipment type (should use default rate)
SELECT fn_calculate_rental_price('Unknown', 5, 1) AS unknown_price;
-- Expected: 100.00 (20.00/day × 5 days)
```

### 2.2 Test `fn_check_equipment_availability`

#### Test 1: Available Equipment

```sql
USE ski_resort;

-- First, find available equipment IDs
SELECT EquipmentID, EquipmentType, Status
FROM Equipment
WHERE Status = 'Available'
ORDER BY EquipmentID
LIMIT 5;

-- Test availability check (use EquipmentID from above query)
SELECT fn_check_equipment_availability(1) AS is_available;
-- Expected: 1 (TRUE) if Equipment ID 1 is Available

SELECT fn_check_equipment_availability(2) AS is_available;
-- Expected: 1 (TRUE) if Equipment ID 2 is Available
```

#### Test 2: Unavailable Equipment

```sql
USE ski_resort;

-- Find rented equipment
SELECT EquipmentID, EquipmentType, Status
FROM Equipment
WHERE Status = 'Rented'
LIMIT 5;

-- Test availability check (use EquipmentID from above query)
SELECT fn_check_equipment_availability(3) AS is_available;
-- Expected: 0 (FALSE) if Equipment ID 3 is Rented

-- Test maintenance equipment
SELECT EquipmentID, EquipmentType, Status
FROM Equipment
WHERE Status = 'Maintenance'
LIMIT 1;

-- Test availability check
SELECT fn_check_equipment_availability(10) AS is_available;
-- Expected: 0 (FALSE) if Equipment ID 10 is Maintenance
```

#### Test 3: Non-Existent Equipment

```sql
USE ski_resort;

-- Test with invalid equipment ID
SELECT fn_check_equipment_availability(99999) AS is_available;
-- Expected: 0 (FALSE)
```

### 2.3 Test `fn_calculate_ticket_refund`

#### Test 1: Full Refund (>7 days before)

```sql
USE ski_resort;

-- Test Ticket ID 1 (ValidDate: 2024-12-15, SalePrice: 89.00)
-- Refund date: 2024-12-05 (10 days before)
SELECT fn_calculate_ticket_refund(1, '2024-12-05') AS refund_amount;
-- Expected: 89.00 (100% refund)

-- Test Ticket ID 7 (ValidDate: 2024-12-15, SalePrice: 240.00)
-- Refund date: 2024-12-05 (10 days before)
SELECT fn_calculate_ticket_refund(7, '2024-12-05') AS refund_amount;
-- Expected: 240.00 (100% refund)
```

#### Test 2: 50% Refund (3-7 days before)

```sql
USE ski_resort;

-- Test Ticket ID 1 (ValidDate: 2024-12-15, SalePrice: 89.00)
-- Refund date: 2024-12-10 (5 days before)
SELECT fn_calculate_ticket_refund(1, '2024-12-10') AS refund_amount;
-- Expected: 44.50 (50% refund)

-- Test Ticket ID 7 (ValidDate: 2024-12-15, SalePrice: 240.00)
-- Refund date: 2024-12-10 (5 days before)
SELECT fn_calculate_ticket_refund(7, '2024-12-10') AS refund_amount;
-- Expected: 120.00 (50% refund)
```

#### Test 3: 25% Refund (1-3 days before)

```sql
USE ski_resort;

-- Test Ticket ID 1 (ValidDate: 2024-12-15, SalePrice: 89.00)
-- Refund date: 2024-12-13 (2 days before)
SELECT fn_calculate_ticket_refund(1, '2024-12-13') AS refund_amount;
-- Expected: 22.25 (25% refund)

-- Test Ticket ID 1 (ValidDate: 2024-12-15, SalePrice: 89.00)
-- Refund date: 2024-12-14 (1 day before)
SELECT fn_calculate_ticket_refund(1, '2024-12-14') AS refund_amount;
-- Expected: 22.25 (25% refund)
```

#### Test 4: No Refund (same day or past)

```sql
USE ski_resort;

-- Test Ticket ID 1 (ValidDate: 2024-12-15, SalePrice: 89.00)
-- Refund date: 2024-12-15 (same day)
SELECT fn_calculate_ticket_refund(1, '2024-12-15') AS refund_amount;
-- Expected: 0.00 (no refund)

-- Test Ticket ID 1 (ValidDate: 2024-12-15, SalePrice: 89.00)
-- Refund date: 2024-12-16 (past valid date)
SELECT fn_calculate_ticket_refund(1, '2024-12-16') AS refund_amount;
-- Expected: 0.00 (no refund)
```

#### Test 5: Edge Cases

```sql
USE ski_resort;

-- Test exactly 7 days before (should be 50%, not 100%)
SELECT fn_calculate_ticket_refund(1, '2024-12-08') AS refund_amount;
-- Expected: 44.50 (50% refund, since >3 but not >7)

-- Test exactly 3 days before (should be 25%, not 50%)
SELECT fn_calculate_ticket_refund(1, '2024-12-12') AS refund_amount;
-- Expected: 22.25 (25% refund, since >0 but not >3)
```

---

## 3. Stored Procedure Testing

### 3.1 Test `sp_process_equipment_rental`

#### Test 1: Successful Rental

```sql
USE ski_resort;

-- First, verify equipment is available
SELECT EquipmentID, EquipmentType, Status
FROM Equipment
WHERE EquipmentID = 1;

-- Execute rental procedure
CALL sp_process_equipment_rental(
    1,      -- Customer ID 1 (John Smith)
    1,      -- Equipment ID 1 (Ski - Available)
    5,      -- Rental days
    @rental_id,
    @total_price,
    @status
);

-- Check results
SELECT @rental_id AS rental_id, @total_price AS total_price, @status AS status;
-- Expected: rental_id > 0, total_price = 125.00, status = 'success'

-- Verify rental was created
SELECT * FROM Rentals WHERE RentalID = @rental_id;

-- Verify rental items were created
SELECT * FROM Rental_Items WHERE RentalID = @rental_id;

-- Verify equipment status updated
SELECT EquipmentID, Status FROM Equipment WHERE EquipmentID = 1;
-- Expected: Status = 'Rented'
```

#### Test 2: Multiple Rentals (Different Equipment)

```sql
USE ski_resort;

-- Test 1: Rent Equipment ID 1
CALL sp_process_equipment_rental(1, 1, 5, @r1, @p1, @s1);

-- Test 2: Rent Equipment ID 2 (different equipment!)
CALL sp_process_equipment_rental(2, 2, 3, @r2, @p2, @s2);

-- Test 3: Rent Equipment ID 4 (different equipment!)
CALL sp_process_equipment_rental(3, 4, 7, @r3, @p3, @s3);

-- Test 4: Rent Equipment ID 11 (Snowboard)
CALL sp_process_equipment_rental(4, 11, 4, @r4, @p4, @s4);

-- View all results
SELECT 'Test 1' AS test, @r1 AS rental_id, @p1 AS price, @s1 AS status
UNION ALL
SELECT 'Test 2', @r2, @p2, @s2
UNION ALL
SELECT 'Test 3', @r3, @p3, @s3
UNION ALL
SELECT 'Test 4', @r4, @p4, @s4;
```

#### Test 3: Unavailable Equipment (Error Case)

```sql
USE ski_resort;

-- First, rent equipment ID 1
CALL sp_process_equipment_rental(1, 1, 5, @r1, @p1, @s1);

-- Try to rent the same equipment again (should fail)
CALL sp_process_equipment_rental(2, 1, 3, @r2, @p2, @s2);

-- Check results
SELECT @r2 AS rental_id, @p2 AS total_price, @s2 AS status;
-- Expected: rental_id = 0, total_price = 0.00, status = 'error: equipment not available'
```

#### Test 4: Long-Term Rental (Discount Applied)

```sql
USE ski_resort;

-- Rent equipment for 10 days (should get 10% discount)
CALL sp_process_equipment_rental(
    5,      -- Customer ID 5
    5,      -- Equipment ID 5 (Ski - Available)
    10,     -- Rental days (qualifies for discount)
    @rental_id,
    @total_price,
    @status
);

SELECT @rental_id AS rental_id, @total_price AS total_price, @status AS status;
-- Expected: rental_id > 0, total_price = 225.00 (25.00/day × 10 days × 0.90), status = 'success'
```

### 3.2 Test `sp_process_ticket_purchase`

#### Test 1: Single Ticket Purchase

```sql
USE ski_resort;

-- Purchase 1 ticket
CALL sp_process_ticket_purchase(
    1,              -- Customer ID 1 (John Smith)
    1,              -- Pass Type ID 1 (Adult Full Day - $89.00)
    '2025-01-15',   -- Valid date
    1,              -- Quantity
    @ticket_ids,
    @total_amount,
    @status
);

-- Check results
SELECT @ticket_ids AS ticket_ids, @total_amount AS total_amount, @status AS status;
-- Expected: ticket_ids = single ticket ID, total_amount = 89.00, status = 'success'

-- Verify ticket was created
SELECT * FROM Lift_Tickets WHERE TicketID = CAST(@ticket_ids AS UNSIGNED);
```

#### Test 2: Multiple Ticket Purchase

```sql
USE ski_resort;

-- Purchase 3 tickets
CALL sp_process_ticket_purchase(
    2,              -- Customer ID 2 (Sarah Johnson)
    1,              -- Pass Type ID 1 (Adult Full Day - $89.00)
    '2025-01-20',   -- Valid date
    3,              -- Quantity
    @ticket_ids,
    @total_amount,
    @status
);

-- Check results
SELECT @ticket_ids AS ticket_ids, @total_amount AS total_amount, @status AS status;
-- Expected: ticket_ids = comma-separated IDs (e.g., "25,26,27"), total_amount = 267.00, status = 'success'

-- Verify all tickets were created
SELECT TicketID, CustomerID, PassTypeID, ValidDate, SalePrice
FROM Lift_Tickets
WHERE TicketID IN (
    SELECT CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(@ticket_ids, ',', numbers.n), ',', -1) AS UNSIGNED)
    FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3) numbers
    WHERE CHAR_LENGTH(@ticket_ids) - CHAR_LENGTH(REPLACE(@ticket_ids, ',', '')) >= numbers.n - 1
);
```

#### Test 3: Different Pass Types

```sql
USE ski_resort;

-- Purchase Child ticket
CALL sp_process_ticket_purchase(3, 2, '2025-01-15', 1, @t1, @p1, @s1);
SELECT 'Child Ticket' AS type, @t1 AS ticket_ids, @p1 AS total, @s1 AS status;

-- Purchase Senior ticket
CALL sp_process_ticket_purchase(4, 3, '2025-01-15', 1, @t2, @p2, @s2);
SELECT 'Senior Ticket' AS type, @t2 AS ticket_ids, @p2 AS total, @s2 AS status;

-- Purchase Multi-day ticket
CALL sp_process_ticket_purchase(5, 4, '2025-01-15', 1, @t3, @p3, @s3);
SELECT 'Multi-day Ticket' AS type, @t3 AS ticket_ids, @p3 AS total, @s3 AS status;
```

#### Test 4: Invalid Customer (Error Case)

```sql
USE ski_resort;

-- Try to purchase ticket with non-existent customer
CALL sp_process_ticket_purchase(
    99999,          -- Invalid Customer ID
    1,              -- Pass Type ID 1
    '2025-01-15',   -- Valid date
    1,              -- Quantity
    @ticket_ids,
    @total_amount,
    @status
);

-- Check results
SELECT @ticket_ids AS ticket_ids, @total_amount AS total_amount, @status AS status;
-- Expected: ticket_ids = '', total_amount = 0.00, status = 'error: customer not found'
```

#### Test 5: Invalid Pass Type (Error Case)

```sql
USE ski_resort;

-- Try to purchase ticket with invalid pass type
CALL sp_process_ticket_purchase(
    1,              -- Customer ID 1
    99999,          -- Invalid Pass Type ID
    '2025-01-15',   -- Valid date
    1,              -- Quantity
    @ticket_ids,
    @total_amount,
    @status
);

-- Check results
SELECT @ticket_ids AS ticket_ids, @total_amount AS total_amount, @status AS status;
-- Expected: ticket_ids = '', total_amount = 0.00, status = 'error: invalid pass type'
```

---

## 4. Integration Testing

### 4.1 Test Complete Rental Workflow

```sql
USE ski_resort;

-- Step 1: Check equipment availability
SELECT EquipmentID, EquipmentType, Status
FROM Equipment
WHERE EquipmentID = 1;

-- Step 2: Process rental
CALL sp_process_equipment_rental(1, 1, 5, @rental_id, @total_price, @status);

-- Step 3: Verify rental record
SELECT r.*, c.FirstName, c.LastName, e.EquipmentType, e.Brand, e.Model
FROM Rentals r
JOIN Customers c ON r.CustomerID = c.CustomerID
JOIN Equipment e ON r.EquipmentID = e.EquipmentID
WHERE r.RentalID = @rental_id;

-- Step 4: Verify rental items
SELECT ri.*, e.EquipmentType, e.Brand, e.Model
FROM Rental_Items ri
JOIN Equipment e ON ri.EquipmentID = e.EquipmentID
WHERE ri.RentalID = @rental_id;

-- Step 5: Verify equipment status updated
SELECT EquipmentID, Status FROM Equipment WHERE EquipmentID = 1;
-- Expected: Status = 'Rented'
```

### 4.2 Test Complete Ticket Purchase Workflow

```sql
USE ski_resort;

-- Step 1: Check customer exists
SELECT CustomerID, FirstName, LastName, Email
FROM Customers
WHERE CustomerID = 1;

-- Step 2: Check pass type exists
SELECT PassTypeID, PassName, CurrentPrice
FROM Pass_Types
WHERE PassTypeID = 1;

-- Step 3: Process ticket purchase
CALL sp_process_ticket_purchase(1, 1, '2025-01-15', 2, @ticket_ids, @total_amount, @status);

-- Step 4: Verify tickets created
SELECT t.*, c.FirstName, c.LastName, pt.PassName, pt.CurrentPrice
FROM Lift_Tickets t
JOIN Customers c ON t.CustomerID = c.CustomerID
JOIN Pass_Types pt ON t.PassTypeID = pt.PassTypeID
WHERE t.TicketID IN (
    SELECT CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(@ticket_ids, ',', numbers.n), ',', -1) AS UNSIGNED)
    FROM (SELECT 1 n UNION SELECT 2) numbers
    WHERE CHAR_LENGTH(@ticket_ids) - CHAR_LENGTH(REPLACE(@ticket_ids, ',', '')) >= numbers.n - 1
);
```

---

## 5. Error Handling Testing

### 5.1 Test Equipment Rental Error Cases

```sql
USE ski_resort;

-- Test 1: Unavailable equipment
CALL sp_process_equipment_rental(1, 3, 5, @r1, @p1, @s1);
SELECT 'Unavailable Equipment' AS test, @r1 AS rental_id, @p1 AS price, @s1 AS status;
-- Expected: rental_id = 0, price = 0.00, status = 'error: equipment not available'

-- Test 2: Equipment in maintenance
CALL sp_process_equipment_rental(1, 10, 5, @r2, @p2, @s2);
SELECT 'Maintenance Equipment' AS test, @r2 AS rental_id, @p2 AS price, @s2 AS status;
-- Expected: rental_id = 0, price = 0.00, status = 'error: equipment not available'

-- Test 3: Non-existent equipment
CALL sp_process_equipment_rental(1, 99999, 5, @r3, @p3, @s3);
SELECT 'Non-existent Equipment' AS test, @r3 AS rental_id, @p3 AS price, @s3 AS status;
-- Expected: rental_id = 0, price = 0.00, status = 'error: equipment not available'
```

### 5.2 Test Ticket Purchase Error Cases

```sql
USE ski_resort;

-- Test 1: Invalid customer
CALL sp_process_ticket_purchase(99999, 1, '2025-01-15', 1, @t1, @p1, @s1);
SELECT 'Invalid Customer' AS test, @t1 AS ticket_ids, @p1 AS total, @s1 AS status;
-- Expected: ticket_ids = '', total = 0.00, status = 'error: customer not found'

-- Test 2: Invalid pass type
CALL sp_process_ticket_purchase(1, 99999, '2025-01-15', 1, @t2, @p2, @s2);
SELECT 'Invalid Pass Type' AS test, @t2 AS ticket_ids, @p2 AS total, @s2 AS status;
-- Expected: ticket_ids = '', total = 0.00, status = 'error: invalid pass type'
```

---

## 6. Business Logic Validation

### 6.1 Verify Rental Pricing Logic

```sql
USE ski_resort;

-- Verify pricing matches function calculation
CALL sp_process_equipment_rental(1, 1, 5, @r1, @p1, @s1);

-- Calculate expected price using function
SELECT 
    @p1 AS procedure_price,
    fn_calculate_rental_price('Ski', 5, 1) AS function_price,
    CASE 
        WHEN @p1 = fn_calculate_rental_price('Ski', 5, 1) THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS validation;
-- Expected: MATCH
```

### 6.2 Verify Refund Policy Logic

```sql
USE ski_resort;

-- Test refund calculation for different scenarios
SELECT 
    '>7 days (100%)' AS scenario,
    fn_calculate_ticket_refund(1, '2024-12-05') AS refund_amount,
    89.00 AS expected_amount,
    CASE 
        WHEN fn_calculate_ticket_refund(1, '2024-12-05') = 89.00 THEN 'CORRECT'
        ELSE 'INCORRECT'
    END AS validation
UNION ALL
SELECT 
    '5 days (50%)',
    fn_calculate_ticket_refund(1, '2024-12-10'),
    44.50,
    CASE 
        WHEN fn_calculate_ticket_refund(1, '2024-12-10') = 44.50 THEN 'CORRECT'
        ELSE 'INCORRECT'
    END
UNION ALL
SELECT 
    '2 days (25%)',
    fn_calculate_ticket_refund(1, '2024-12-13'),
    22.25,
    CASE 
        WHEN fn_calculate_ticket_refund(1, '2024-12-13') = 22.25 THEN 'CORRECT'
        ELSE 'INCORRECT'
    END
UNION ALL
SELECT 
    'Same day (0%)',
    fn_calculate_ticket_refund(1, '2024-12-15'),
    0.00,
    CASE 
        WHEN fn_calculate_ticket_refund(1, '2024-12-15') = 0.00 THEN 'CORRECT'
        ELSE 'INCORRECT'
    END;
```

### 6.3 Verify Equipment Status Updates

```sql
USE ski_resort;

-- Test that equipment status changes after rental
SELECT EquipmentID, Status AS status_before
FROM Equipment
WHERE EquipmentID = 1;

CALL sp_process_equipment_rental(1, 1, 5, @rental_id, @total_price, @status);

SELECT EquipmentID, Status AS status_after
FROM Equipment
WHERE EquipmentID = 1;
-- Expected: Status changed from 'Available' to 'Rented'
```

---

## Quick Test Script

Run this complete test suite:

```sql
USE ski_resort;

-- ============================================================================
-- QUICK TEST SUITE - Functions & Procedures
-- ============================================================================

-- Test Functions
SELECT '=== FUNCTION TESTS ===' AS test_section;

SELECT 'fn_calculate_rental_price (Ski, 5 days)' AS test, 
       fn_calculate_rental_price('Ski', 5, 1) AS result,
       125.00 AS expected;

SELECT 'fn_calculate_rental_price (Ski, 10 days with discount)' AS test,
       fn_calculate_rental_price('Ski', 10, 1) AS result,
       225.00 AS expected;

SELECT 'fn_check_equipment_availability (Available)' AS test,
       fn_check_equipment_availability(1) AS result,
       1 AS expected;

SELECT 'fn_calculate_ticket_refund (>7 days)' AS test,
       fn_calculate_ticket_refund(1, '2024-12-05') AS result,
       89.00 AS expected;

-- Test Procedures
SELECT '=== PROCEDURE TESTS ===' AS test_section;

-- Test 1: Equipment Rental
CALL sp_process_equipment_rental(1, 1, 5, @r1, @p1, @s1);
SELECT 'sp_process_equipment_rental' AS test, @r1 AS rental_id, @p1 AS price, @s1 AS status;

-- Test 2: Ticket Purchase
CALL sp_process_ticket_purchase(2, 1, '2025-01-15', 1, @t1, @a1, @s2);
SELECT 'sp_process_ticket_purchase' AS test, @t1 AS ticket_ids, @a1 AS total, @s2 AS status;

-- Verify Results
SELECT '=== VERIFICATION ===' AS test_section;
SELECT COUNT(*) AS rental_count FROM Rentals WHERE RentalID = @r1;
SELECT COUNT(*) AS ticket_count FROM Lift_Tickets WHERE TicketID = CAST(@t1 AS UNSIGNED);
```

---

## Testing Checklist

Before submission, verify:

- [ ] All 3 functions execute without errors
- [ ] All 2 procedures execute without errors
- [ ] Function calculations match expected business logic
- [ ] Procedures handle error cases correctly
- [ ] Equipment status updates correctly after rental
- [ ] Ticket purchases create correct number of tickets
- [ ] Refund calculations follow the policy (>7 days = 100%, 3-7 days = 50%, 1-3 days = 25%, same day = 0%)
- [ ] Long-term rental discount (7+ days) applies correctly
- [ ] Invalid inputs return appropriate error messages
- [ ] Integration tests pass (complete workflows)

---

**Last Updated**: 2025-01-XX

