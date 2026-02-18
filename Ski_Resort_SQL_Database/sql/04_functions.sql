-- ============================================================================
-- Ski Resort Management System - Functions & Stored Procedures
-- COMP 345 Final Project
-- ============================================================================

USE ski_resort;

-- Change delimiter for procedure/function definitions
DELIMITER $$

-- ============================================================================
-- STORED FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Function 1: Calculate Rental Price
-- Purpose: Calculate rental price based on equipment type, duration, and quantity
-- Business Logic: Different equipment types have different daily rates
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_calculate_rental_price$$

CREATE FUNCTION fn_calculate_rental_price(
    p_equipment_type VARCHAR(50),
    p_duration_days INT,
    p_quantity INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_daily_rate DECIMAL(10,2);
    DECLARE v_total_price DECIMAL(10,2);
    
    -- Set daily rates based on equipment type
    SET v_daily_rate = CASE
        WHEN p_equipment_type = 'Ski' THEN 25.00
        WHEN p_equipment_type = 'Snowboard' THEN 30.00
        WHEN p_equipment_type = 'Boots' THEN 15.00
        WHEN p_equipment_type = 'Poles' THEN 5.00
        WHEN p_equipment_type = 'Helmet' THEN 8.00
        WHEN p_equipment_type = 'Goggles' THEN 10.00
        ELSE 20.00  -- Default rate
    END;
    
    -- Calculate total: daily rate * duration * quantity
    -- Apply discount for longer rentals (7+ days gets 10% off)
    SET v_total_price = v_daily_rate * p_duration_days * p_quantity;
    
    IF p_duration_days >= 7 THEN
        SET v_total_price = v_total_price * 0.90;  -- 10% discount
    END IF;
    
    RETURN ROUND(v_total_price, 2);
END$$

-- ----------------------------------------------------------------------------
-- Function 2: Check Equipment Availability
-- Purpose: Check if equipment is available for rental
-- Returns: 1 if available, 0 if not available
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_check_equipment_availability$$

CREATE FUNCTION fn_check_equipment_availability(
    p_equipment_id INT
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;
    
    -- Count equipment with this ID that is Available
    SELECT COUNT(*) INTO v_count
    FROM Equipment
    WHERE EquipmentID = p_equipment_id
    AND Status = 'Available';
    
    -- Return TRUE if count > 0, FALSE otherwise
    RETURN v_count > 0;
END$$

-- ----------------------------------------------------------------------------
-- Function 3: Calculate Lift Ticket Refund
-- Purpose: Calculate refund amount for lift ticket cancellation
-- Business Logic: Full refund if >7 days before valid date, 
--                 50% if 3-7 days, 25% if 1-3 days, no refund if same day
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_calculate_ticket_refund$$

CREATE FUNCTION fn_calculate_ticket_refund(
    p_ticket_id INT,
    p_refund_date DATE
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_refund_amount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_sale_price DECIMAL(10,2);
    DECLARE v_valid_date DATE;
    DECLARE v_days_until_valid INT;
    
    -- Get ticket details
    SELECT SalePrice, ValidDate
    INTO v_sale_price, v_valid_date
    FROM Lift_Tickets
    WHERE TicketID = p_ticket_id;
    
    -- Calculate days until valid date
    SET v_days_until_valid = DATEDIFF(v_valid_date, p_refund_date);
    
    -- Apply refund policy based on days until valid date
    SET v_refund_amount = CASE
        WHEN v_days_until_valid > 7 THEN v_sale_price * 1.00  -- 100% refund
        WHEN v_days_until_valid > 3 THEN v_sale_price * 0.50  -- 50% refund
        WHEN v_days_until_valid > 0 THEN v_sale_price * 0.25  -- 25% refund
        ELSE 0.00                                                -- No refund (same day or past)
    END;
    
    RETURN ROUND(v_refund_amount, 2);
END$$

-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Procedure 1: Process Equipment Rental
-- Purpose: Complete end-to-end equipment rental transaction
-- Business Logic: Validates availability, creates rental record, 
--                 updates equipment status, calculates total price
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_process_equipment_rental$$

CREATE PROCEDURE sp_process_equipment_rental(
    IN p_customer_id INT,
    IN p_equipment_id INT,  -- Single equipment ID (simplified)
    IN p_rental_days INT,
    OUT p_rental_id INT,
    OUT p_total_price DECIMAL(10,2),
    OUT p_status VARCHAR(50)
)
proc_label: BEGIN
    DECLARE v_equipment_type VARCHAR(50);
    DECLARE v_item_price DECIMAL(10,2);
    DECLARE v_available BOOLEAN;
    
    -- Initialize
    SET p_total_price = 0.00;
    SET p_status = 'success';
    
    -- Check if equipment is available
    SET v_available = fn_check_equipment_availability(p_equipment_id);
    
    IF NOT v_available THEN
        SET p_status = 'error: equipment not available';
        SET p_rental_id = 0;
        SET p_total_price = 0.00;
        LEAVE proc_label;
    END IF;
    
    -- Get equipment type
    SELECT EquipmentType INTO v_equipment_type
    FROM Equipment
    WHERE EquipmentID = p_equipment_id;
    
    -- Calculate rental price
    SET v_item_price = fn_calculate_rental_price(v_equipment_type, p_rental_days, 1);
    
    -- Create rental record
    INSERT INTO Rentals (
        CustomerID,
        RentalDate,
        ExpectedReturnDate,
        TotalPrice,
        RentalStatus
    ) VALUES (
        p_customer_id,
        NOW(),
        DATE_ADD(NOW(), INTERVAL p_rental_days DAY),
        v_item_price,
        'Active'
    );
    
    SET p_rental_id = LAST_INSERT_ID();
    SET p_total_price = v_item_price;
    
    -- Create rental items record
    INSERT INTO Rental_Items (RentalID, EquipmentID, Quantity, UnitPrice)
    VALUES (
        p_rental_id,
        p_equipment_id,
        1,
        v_item_price
    );
    
    -- Update equipment status to 'Rented'
    UPDATE Equipment
    SET Status = 'Rented'
    WHERE EquipmentID = p_equipment_id;
    
    SET p_status = 'success';
    
END$$

-- ----------------------------------------------------------------------------
-- Procedure 2: Process Lift Ticket Purchase
-- Purpose: Complete lift ticket purchase transaction
-- Business Logic: Validates customer, creates ticket, applies pricing
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_process_ticket_purchase$$

CREATE PROCEDURE sp_process_ticket_purchase(
    IN p_customer_id INT,
    IN p_pass_type_id INT,
    IN p_valid_date DATE,
    IN p_quantity INT,
    OUT p_ticket_ids TEXT,  -- Comma-separated ticket IDs
    OUT p_total_amount DECIMAL(10,2),
    OUT p_status VARCHAR(50)
)
proc_label: BEGIN
    DECLARE v_base_price DECIMAL(10,2);
    DECLARE v_sale_price DECIMAL(10,2);
    DECLARE v_ticket_id INT;
    DECLARE v_counter INT DEFAULT 0;
    DECLARE v_ticket_id_list TEXT DEFAULT '';
    
    -- Initialize
    SET p_total_amount = 0.00;
    SET p_status = 'success';
    
    -- Validate customer exists
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustomerID = p_customer_id) THEN
        SET p_status = 'error: customer not found';
        SET p_ticket_ids = '';
        SET p_total_amount = 0.00;
        LEAVE proc_label;
    END IF;
    
    -- Get base price from pass type
    SELECT CurrentPrice INTO v_base_price
    FROM Pass_Types
    WHERE PassTypeID = p_pass_type_id;
    
    IF v_base_price IS NULL THEN
        SET p_status = 'error: invalid pass type';
        SET p_ticket_ids = '';
        SET p_total_amount = 0.00;
        LEAVE proc_label;
    END IF;
    
    -- Create tickets
    WHILE v_counter < p_quantity DO
        -- Calculate sale price (could apply discounts here)
        SET v_sale_price = v_base_price;
        
        -- Create ticket
        INSERT INTO Lift_Tickets (
            CustomerID,
            PassTypeID,
            PurchaseDate,
            ValidDate,
            ExpirationDate,
            SalePrice,
            TicketStatus
        ) VALUES (
            p_customer_id,
            p_pass_type_id,
            NOW(),
            p_valid_date,
            DATE_ADD(p_valid_date, INTERVAL 1 DAY),  -- Valid for the specified date
            v_sale_price,
            'Active'
        );
        
        SET v_ticket_id = LAST_INSERT_ID();
        SET p_total_amount = p_total_amount + v_sale_price;
        
        -- Add to ticket ID list
        IF v_ticket_id_list = '' THEN
            SET v_ticket_id_list = CAST(v_ticket_id AS CHAR);
        ELSE
            SET v_ticket_id_list = CONCAT(v_ticket_id_list, ',', CAST(v_ticket_id AS CHAR));
        END IF;
        
        SET v_counter = v_counter + 1;
    END WHILE;
    
    SET p_ticket_ids = v_ticket_id_list;
    SET p_status = 'success';
    
END$$

-- Reset delimiter
DELIMITER ;

-- ============================================================================
-- Function/Procedure Summary
-- ============================================================================
-- Functions Created:
--   1. fn_calculate_rental_price - Calculates rental price based on equipment type and duration
--   2. fn_check_equipment_availability - Checks if equipment is available for rental
--   3. fn_calculate_ticket_refund - Calculates refund amount for ticket cancellation
--
-- Stored Procedures Created:
--   1. sp_process_equipment_rental - Processes complete equipment rental transaction
--   2. sp_process_ticket_purchase - Processes lift ticket purchase transaction
--
-- Total: 3 Functions + 2 Procedures = 5 stored routines (exceeds requirement of ≥2)

