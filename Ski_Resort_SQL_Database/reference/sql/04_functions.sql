-- ============================================================================
-- Event Ticketing & Seating System - Functions & Stored Procedures
-- COMP 345 Final Project Reference Implementation
-- ============================================================================

USE event_ticketing;

-- Change delimiter for procedure/function definitions
DELIMITER $$

-- ============================================================================
-- STORED FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Function 1: Calculate Dynamic Ticket Price
-- Purpose: Apply dynamic pricing based on demand and time until event
-- Business Logic: Prices increase as event approaches and as inventory depletes
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_calculate_dynamic_price$$

CREATE FUNCTION fn_calculate_dynamic_price(
    p_base_price DECIMAL(10,2),
    p_event_date DATE,
    p_quantity_sold INT,
    p_quantity_available INT
) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_final_price DECIMAL(10,2);
    DECLARE v_days_until_event INT;
    DECLARE v_sell_through_pct DECIMAL(5,2);
    DECLARE v_time_multiplier DECIMAL(5,2) DEFAULT 1.0;
    DECLARE v_demand_multiplier DECIMAL(5,2) DEFAULT 1.0;
    
    -- Calculate days until event
    SET v_days_until_event = DATEDIFF(p_event_date, CURDATE());
    
    -- Calculate sell-through percentage
    SET v_sell_through_pct = (p_quantity_sold * 100.0) / NULLIF(p_quantity_available, 0);
    
    -- Time-based multiplier (prices increase as event approaches)
    SET v_time_multiplier = CASE
        WHEN v_days_until_event <= 7 THEN 1.25      -- 25% increase in last week
        WHEN v_days_until_event <= 30 THEN 1.15     -- 15% increase in last month
        WHEN v_days_until_event <= 60 THEN 1.05     -- 5% increase in last 2 months
        ELSE 1.0                                     -- Base price for early purchases
    END;
    
    -- Demand-based multiplier (prices increase as inventory depletes)
    SET v_demand_multiplier = CASE
        WHEN v_sell_through_pct >= 90 THEN 1.30     -- 30% increase when 90%+ sold
        WHEN v_sell_through_pct >= 75 THEN 1.20     -- 20% increase when 75%+ sold
        WHEN v_sell_through_pct >= 50 THEN 1.10     -- 10% increase when 50%+ sold
        ELSE 1.0                                     -- Base price for low demand
    END;
    
    -- Calculate final price
    SET v_final_price = p_base_price * v_time_multiplier * v_demand_multiplier;
    
    RETURN ROUND(v_final_price, 2);
END$$

-- ----------------------------------------------------------------------------
-- Function 2: Check Seat Availability
-- Purpose: Verify if a seat is available for a specific event
-- Returns: 1 if available, 0 if not available
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_check_seat_availability$$

CREATE FUNCTION fn_check_seat_availability(
    p_event_id BIGINT,
    p_seat_id BIGINT
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_is_available BOOLEAN DEFAULT FALSE;
    DECLARE v_assignment_status VARCHAR(20);
    
    -- Check if seat assignment exists and get status
    SELECT assignment_status INTO v_assignment_status
    FROM event_seat_assignments
    WHERE event_id = p_event_id AND seat_id = p_seat_id;
    
    -- Seat is available if no assignment exists or status is 'available'
    IF v_assignment_status IS NULL OR v_assignment_status = 'available' THEN
        SET v_is_available = TRUE;
    ELSE
        SET v_is_available = FALSE;
    END IF;
    
    RETURN v_is_available;
END$$

-- ----------------------------------------------------------------------------
-- Function 3: Calculate Refund Amount
-- Purpose: Calculate refund amount based on refund policy and timing
-- Business Logic: Full refund if >14 days before event, 50% if 7-14 days, 
--                 25% if 3-7 days, no refund if <3 days
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_calculate_refund_amount$$

CREATE FUNCTION fn_calculate_refund_amount(
    p_ticket_id BIGINT,
    p_refund_date DATE
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_refund_amount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_purchase_price DECIMAL(10,2);
    DECLARE v_event_date DATE;
    DECLARE v_days_until_event INT;
    
    -- Get ticket details
    SELECT t.purchase_price, e.event_date
    INTO v_purchase_price, v_event_date
    FROM tickets t
    JOIN events e ON t.event_id = e.event_id
    WHERE t.ticket_id = p_ticket_id;
    
    -- Calculate days until event
    SET v_days_until_event = DATEDIFF(v_event_date, p_refund_date);
    
    -- Apply refund policy
    SET v_refund_amount = CASE
        WHEN v_days_until_event > 14 THEN v_purchase_price * 1.00  -- 100% refund
        WHEN v_days_until_event > 7 THEN v_purchase_price * 0.50   -- 50% refund
        WHEN v_days_until_event > 3 THEN v_purchase_price * 0.25   -- 25% refund
        ELSE 0.00                                                    -- No refund
    END;
    
    RETURN ROUND(v_refund_amount, 2);
END$$

-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Procedure 1: Process Ticket Purchase
-- Purpose: Complete end-to-end ticket purchase transaction
-- Business Logic: Validates availability, creates order, assigns seats, 
--                 updates inventory
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_process_ticket_purchase$$

CREATE PROCEDURE sp_process_ticket_purchase(
    IN p_customer_id BIGINT,
    IN p_event_id BIGINT,
    IN p_tier_id BIGINT,
    IN p_seat_id BIGINT,
    IN p_quantity INT,
    IN p_promo_code VARCHAR(50),
    IN p_payment_method VARCHAR(50),
    OUT p_order_id BIGINT,
    OUT p_status_message VARCHAR(500)
)
BEGIN
    DECLARE v_base_price DECIMAL(10,2);
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_discount_amount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_tax_amount DECIMAL(10,2);
    DECLARE v_total_amount DECIMAL(10,2);
    DECLARE v_promo_id BIGINT DEFAULT NULL;
    DECLARE v_discount_type VARCHAR(20);
    DECLARE v_discount_value DECIMAL(10,2);
    DECLARE v_order_number VARCHAR(50);
    DECLARE v_ticket_number VARCHAR(50);
    DECLARE v_event_date DATE;
    DECLARE v_quantity_available INT;
    DECLARE v_quantity_sold INT;
    DECLARE v_seat_available BOOLEAN;
    DECLARE v_counter INT DEFAULT 0;
    DECLARE v_ticket_id BIGINT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Error: Transaction failed. Please try again.';
        SET p_order_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Validate tier and get pricing info
    SELECT tt.base_price, tt.quantity_available, tt.quantity_sold, e.event_date
    INTO v_base_price, v_quantity_available, v_quantity_sold, v_event_date
    FROM ticket_tiers tt
    JOIN events e ON tt.event_id = e.event_id
    WHERE tt.tier_id = p_tier_id AND tt.event_id = p_event_id;
    
    -- Check if enough tickets available
    IF (v_quantity_available - v_quantity_sold) < p_quantity THEN
        SET p_status_message = 'Error: Not enough tickets available.';
        ROLLBACK;
    ELSE
        -- Check seat availability if specific seat requested
        IF p_seat_id IS NOT NULL THEN
            SET v_seat_available = fn_check_seat_availability(p_event_id, p_seat_id);
            IF NOT v_seat_available THEN
                SET p_status_message = 'Error: Requested seat is not available.';
                ROLLBACK;
            END IF;
        END IF;
        
        -- Calculate subtotal
        SET v_subtotal = v_base_price * p_quantity;
        
        -- Apply promo code if provided
        IF p_promo_code IS NOT NULL THEN
            SELECT promo_id, discount_type, discount_value
            INTO v_promo_id, v_discount_type, v_discount_value
            FROM promo_codes
            WHERE promo_code = p_promo_code 
              AND is_active = TRUE
              AND CURRENT_TIMESTAMP BETWEEN valid_from AND valid_until
              AND (max_uses IS NULL OR current_uses < max_uses)
              AND v_subtotal >= min_purchase_amount;
            
            IF v_promo_id IS NOT NULL THEN
                IF v_discount_type = 'percentage' THEN
                    SET v_discount_amount = v_subtotal * (v_discount_value / 100);
                ELSE
                    SET v_discount_amount = v_discount_value;
                END IF;
            END IF;
        END IF;
        
        -- Calculate tax (8% rate)
        SET v_tax_amount = (v_subtotal - v_discount_amount) * 0.08;
        
        -- Calculate total
        SET v_total_amount = v_subtotal - v_discount_amount + v_tax_amount;
        
        -- Generate order number
        SET v_order_number = CONCAT('ORD-', YEAR(CURDATE()), '-', 
                                    LPAD((SELECT COALESCE(MAX(SUBSTRING(order_number, 10)), 0) + 1 
                                          FROM orders), 6, '0'));
        
        -- Create order
        INSERT INTO orders (customer_id, order_number, order_status, subtotal, 
                           discount_amount, tax_amount, total_amount, promo_id, 
                           payment_method, payment_status, confirmed_at)
        VALUES (p_customer_id, v_order_number, 'confirmed', v_subtotal, 
                v_discount_amount, v_tax_amount, v_total_amount, v_promo_id,
                p_payment_method, 'captured', CURRENT_TIMESTAMP);
        
        SET p_order_id = LAST_INSERT_ID();
        
        -- Create tickets
        WHILE v_counter < p_quantity DO
            SET v_ticket_number = CONCAT('TKT-', YEAR(CURDATE()), '-', 
                                        LPAD((SELECT COALESCE(MAX(SUBSTRING(ticket_number, 10)), 0) + 1 
                                              FROM tickets), 6, '0'));
            
            INSERT INTO tickets (order_id, event_id, tier_id, seat_id, ticket_number,
                               ticket_status, purchase_price, face_value, 
                               refund_policy_deadline)
            VALUES (p_order_id, p_event_id, p_tier_id, p_seat_id, v_ticket_number,
                   'purchased', v_base_price, v_base_price,
                   DATE_SUB(v_event_date, INTERVAL 7 DAY));
            
            SET v_ticket_id = LAST_INSERT_ID();
            
            -- Create seat assignment if seat specified
            IF p_seat_id IS NOT NULL THEN
                INSERT INTO event_seat_assignments (event_id, seat_id, ticket_id, assignment_status)
                VALUES (p_event_id, p_seat_id, v_ticket_id, 'sold')
                ON DUPLICATE KEY UPDATE 
                    ticket_id = v_ticket_id,
                    assignment_status = 'sold';
            END IF;
            
            SET v_counter = v_counter + 1;
        END WHILE;
        
        -- Update tier quantities
        UPDATE ticket_tiers
        SET quantity_sold = quantity_sold + p_quantity
        WHERE tier_id = p_tier_id;
        
        -- Update event quantities
        UPDATE events
        SET tickets_sold = tickets_sold + p_quantity
        WHERE event_id = p_event_id;
        
        -- Update promo code usage
        IF v_promo_id IS NOT NULL THEN
            UPDATE promo_codes
            SET current_uses = current_uses + 1
            WHERE promo_id = v_promo_id;
        END IF;
        
        -- Update customer lifetime spend
        UPDATE customers
        SET total_lifetime_spend = total_lifetime_spend + v_total_amount
        WHERE customer_id = p_customer_id;
        
        COMMIT;
        SET p_status_message = CONCAT('Success: Order ', v_order_number, ' created with ', 
                                     p_quantity, ' ticket(s). Total: $', v_total_amount);
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Procedure 2: Process Refund Request
-- Purpose: Handle ticket refund requests with policy enforcement
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_process_refund_request$$

CREATE PROCEDURE sp_process_refund_request(
    IN p_ticket_id BIGINT,
    IN p_refund_reason VARCHAR(50),
    OUT p_refund_id BIGINT,
    OUT p_status_message VARCHAR(500)
)
BEGIN
    DECLARE v_refund_amount DECIMAL(10,2);
    DECLARE v_order_id BIGINT;
    DECLARE v_customer_id BIGINT;
    DECLARE v_ticket_status VARCHAR(50);
    DECLARE v_event_date DATE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Error: Refund processing failed.';
        SET p_refund_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Get ticket details
    SELECT t.order_id, o.customer_id, t.ticket_status, e.event_date
    INTO v_order_id, v_customer_id, v_ticket_status, v_event_date
    FROM tickets t
    JOIN orders o ON t.order_id = o.order_id
    JOIN events e ON t.event_id = e.event_id
    WHERE t.ticket_id = p_ticket_id;
    
    -- Validate ticket can be refunded
    IF v_ticket_status NOT IN ('purchased', 'held') THEN
        SET p_status_message = 'Error: Ticket cannot be refunded (invalid status).';
        ROLLBACK;
    ELSEIF v_event_date < CURDATE() THEN
        SET p_status_message = 'Error: Cannot refund tickets for past events.';
        ROLLBACK;
    ELSE
        -- Calculate refund amount
        SET v_refund_amount = fn_calculate_refund_amount(p_ticket_id, CURDATE());
        
        IF v_refund_amount = 0 THEN
            SET p_status_message = 'Error: Refund not allowed (too close to event date).';
            ROLLBACK;
        ELSE
            -- Create refund record
            INSERT INTO refunds (ticket_id, order_id, customer_id, refund_amount, 
                               refund_reason, refund_status, processed_at)
            VALUES (p_ticket_id, v_order_id, v_customer_id, v_refund_amount,
                   p_refund_reason, 'processed', CURRENT_TIMESTAMP);
            
            SET p_refund_id = LAST_INSERT_ID();
            
            -- Update ticket status
            UPDATE tickets
            SET ticket_status = 'refunded',
                refund_amount = v_refund_amount
            WHERE ticket_id = p_ticket_id;
            
            -- Update order status
            UPDATE orders
            SET order_status = 'partially_refunded'
            WHERE order_id = v_order_id;
            
            COMMIT;
            SET p_status_message = CONCAT('Success: Refund of $', v_refund_amount, ' processed.');
        END IF;
    END IF;
END$$

-- Reset delimiter
DELIMITER ;

-- ============================================================================
-- END OF FUNCTIONS & PROCEDURES
-- ============================================================================

