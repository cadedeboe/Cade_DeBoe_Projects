-- ============================================================================
-- Event Ticketing & Seating System - Triggers
-- COMP 345 Final Project Reference Implementation
-- ============================================================================

USE event_ticketing;

DELIMITER $$

-- ============================================================================
-- DATA VALIDATION TRIGGERS (Replace CHECK constraints with non-deterministic functions)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Trigger: Validate Customer Date of Birth
-- Purpose: Ensure date_of_birth is in the past (CURDATE() not allowed in CHECK)
-- Fires: BEFORE INSERT and BEFORE UPDATE on customers
-- Business Rule: Customers cannot have a future date of birth
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_validate_customer_dob_insert$$

CREATE TRIGGER trg_validate_customer_dob_insert
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    IF NEW.date_of_birth IS NOT NULL AND NEW.date_of_birth >= CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Date of birth must be in the past';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_validate_customer_dob_update$$

CREATE TRIGGER trg_validate_customer_dob_update
BEFORE UPDATE ON customers
FOR EACH ROW
BEGIN
    IF NEW.date_of_birth IS NOT NULL AND NEW.date_of_birth >= CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Date of birth must be in the past';
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger: Validate Event Date
-- Purpose: Ensure event_date is not in the past for new/upcoming events
-- Fires: BEFORE INSERT and BEFORE UPDATE on events
-- Business Rule: New events must be scheduled for future dates
--                (unless status is 'completed' or 'cancelled')
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_validate_event_date_insert$$

CREATE TRIGGER trg_validate_event_date_insert
BEFORE INSERT ON events
FOR EACH ROW
BEGIN
    IF NEW.event_date < CURDATE()
       AND NEW.event_status NOT IN ('completed', 'cancelled') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Event date cannot be in the past for upcoming events';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_validate_event_date_update$$

CREATE TRIGGER trg_validate_event_date_update
BEFORE UPDATE ON events
FOR EACH ROW
BEGIN
    IF NEW.event_date < CURDATE()
       AND NEW.event_status NOT IN ('completed', 'cancelled') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Event date cannot be in the past for upcoming events';
    END IF;
END$$

-- ============================================================================
-- BUSINESS RULE ENFORCEMENT TRIGGERS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Trigger 1: Prevent Double-Booking of Seats
-- Purpose: Ensure seat uniqueness per event (cannot sell same seat twice)
-- Fires: BEFORE INSERT on event_seat_assignments
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_prevent_double_booking$$

CREATE TRIGGER trg_prevent_double_booking
BEFORE INSERT ON event_seat_assignments
FOR EACH ROW
BEGIN
    DECLARE v_existing_status VARCHAR(20);
    
    -- Check if seat is already assigned for this event
    SELECT assignment_status INTO v_existing_status
    FROM event_seat_assignments
    WHERE event_id = NEW.event_id 
      AND seat_id = NEW.seat_id
      AND assignment_status IN ('sold', 'held');
    
    -- If seat is already sold or held, prevent the insert
    IF v_existing_status IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Seat is already assigned for this event';
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 2: Validate Hold Expiration Time
-- Purpose: Ensure hold expiration is set correctly (15 minutes from order)
-- Fires: BEFORE INSERT on orders
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_set_hold_expiration$$

CREATE TRIGGER trg_set_hold_expiration
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    -- If order status is 'held', set expiration to 15 minutes from now
    IF NEW.order_status = 'held' THEN
        SET NEW.hold_expires_at = DATE_ADD(NOW(), INTERVAL 15 MINUTE);
    ELSE
        SET NEW.hold_expires_at = NULL;
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 3: Audit Trail for Order Changes
-- Purpose: Log all changes to orders for compliance and fraud detection
-- Fires: AFTER UPDATE on orders
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_order_changes$$

CREATE TRIGGER trg_audit_order_changes
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Log the change to audit_log table
    INSERT INTO audit_log (table_name, record_id, action_type, old_values, new_values, changed_at)
    VALUES (
        'orders',
        NEW.order_id,
        'UPDATE',
        JSON_OBJECT(
            'order_status', OLD.order_status,
            'payment_status', OLD.payment_status,
            'total_amount', OLD.total_amount
        ),
        JSON_OBJECT(
            'order_status', NEW.order_status,
            'payment_status', NEW.payment_status,
            'total_amount', NEW.total_amount
        ),
        CURRENT_TIMESTAMP
    );
END$$

-- ----------------------------------------------------------------------------
-- Trigger 4: Update Customer Loyalty Tier
-- Purpose: Automatically upgrade customer loyalty tier based on lifetime spend
-- Fires: AFTER UPDATE on customers
-- Business Rules:
--   - Platinum: $5000+
--   - Gold: $2000+
--   - Silver: $1000+
--   - Standard: < $1000
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_update_loyalty_tier$$

CREATE TRIGGER trg_update_loyalty_tier
BEFORE UPDATE ON customers
FOR EACH ROW
BEGIN
    -- Update loyalty tier based on total lifetime spend
    IF NEW.total_lifetime_spend >= 5000 THEN
        SET NEW.loyalty_tier = 'platinum';
    ELSEIF NEW.total_lifetime_spend >= 2000 THEN
        SET NEW.loyalty_tier = 'gold';
    ELSEIF NEW.total_lifetime_spend >= 1000 THEN
        SET NEW.loyalty_tier = 'silver';
    ELSE
        SET NEW.loyalty_tier = 'standard';
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 5: Validate Ticket Tier Capacity
-- Purpose: Prevent overselling by ensuring quantity_sold doesn't exceed available
-- Fires: BEFORE UPDATE on ticket_tiers
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_validate_tier_capacity$$

CREATE TRIGGER trg_validate_tier_capacity
BEFORE UPDATE ON ticket_tiers
FOR EACH ROW
BEGIN
    -- Check if sold + held exceeds available
    IF (NEW.quantity_sold + NEW.quantity_held) > NEW.quantity_available THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Cannot exceed available ticket quantity';
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 6: Auto-Update Event Status
-- Purpose: Automatically update event status based on ticket sales
-- Fires: AFTER UPDATE on events
-- Business Rules:
--   - Set to 'sold_out' when tickets_sold = total_tickets_available
--   - Set to 'on_sale' when tickets become available
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_auto_update_event_status$$

CREATE TRIGGER trg_auto_update_event_status
BEFORE UPDATE ON events
FOR EACH ROW
BEGIN
    -- Auto-update status to sold_out if all tickets sold
    IF NEW.tickets_sold >= NEW.total_tickets_available 
       AND OLD.event_status != 'sold_out' 
       AND NEW.event_status NOT IN ('cancelled', 'completed') THEN
        SET NEW.event_status = 'sold_out';
    END IF;
    
    -- Auto-update status to on_sale if tickets become available
    IF NEW.tickets_sold < NEW.total_tickets_available 
       AND OLD.event_status = 'sold_out' THEN
        SET NEW.event_status = 'on_sale';
    END IF;
END$$

-- ============================================================================
-- DATA INTEGRITY TRIGGERS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Trigger 7: Validate Promo Code Usage Limit
-- Purpose: Prevent promo code usage beyond max_uses limit
-- Fires: BEFORE UPDATE on promo_codes
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_validate_promo_usage$$

CREATE TRIGGER trg_validate_promo_usage
BEFORE UPDATE ON promo_codes
FOR EACH ROW
BEGIN
    -- Check if usage exceeds max_uses
    IF NEW.max_uses IS NOT NULL AND NEW.current_uses > NEW.max_uses THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Promo code usage limit exceeded';
    END IF;
    
    -- Auto-deactivate promo code if max uses reached
    IF NEW.max_uses IS NOT NULL AND NEW.current_uses >= NEW.max_uses THEN
        SET NEW.is_active = FALSE;
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 8: Prevent Modification of Completed Orders
-- Purpose: Ensure data integrity by preventing changes to completed orders
-- Fires: BEFORE UPDATE on orders
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_prevent_completed_order_modification$$

CREATE TRIGGER trg_prevent_completed_order_modification
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Prevent modification of refunded orders (except for partial refunds)
    IF OLD.order_status = 'refunded' AND NEW.order_status != 'refunded' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Cannot modify refunded orders';
    END IF;
    
    -- Prevent changing confirmed_at timestamp once set
    IF OLD.confirmed_at IS NOT NULL AND NEW.confirmed_at != OLD.confirmed_at THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Cannot modify order confirmation timestamp';
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 9: Validate Refund Amount
-- Purpose: Ensure refund amount doesn't exceed purchase price
-- Fires: BEFORE INSERT on refunds
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_validate_refund_amount$$

CREATE TRIGGER trg_validate_refund_amount
BEFORE INSERT ON refunds
FOR EACH ROW
BEGIN
    DECLARE v_purchase_price DECIMAL(10,2);
    
    -- Get the original purchase price
    SELECT purchase_price INTO v_purchase_price
    FROM tickets
    WHERE ticket_id = NEW.ticket_id;
    
    -- Ensure refund doesn't exceed purchase price
    IF NEW.refund_amount > v_purchase_price THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Refund amount cannot exceed purchase price';
    END IF;
END$$

-- ----------------------------------------------------------------------------
-- Trigger 10: Release Seat on Ticket Cancellation
-- Purpose: Free up seat when ticket is cancelled or refunded
-- Fires: AFTER UPDATE on tickets
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_release_seat_on_cancellation$$

CREATE TRIGGER trg_release_seat_on_cancellation
AFTER UPDATE ON tickets
FOR EACH ROW
BEGIN
    -- If ticket status changed to cancelled or refunded, release the seat
    IF NEW.ticket_status IN ('cancelled', 'refunded') 
       AND OLD.ticket_status NOT IN ('cancelled', 'refunded')
       AND NEW.seat_id IS NOT NULL THEN
        
        -- Update seat assignment to available
        UPDATE event_seat_assignments
        SET assignment_status = 'available',
            ticket_id = NULL
        WHERE event_id = NEW.event_id 
          AND seat_id = NEW.seat_id
          AND ticket_id = NEW.ticket_id;
        
        -- Decrement tickets_sold count for the event
        UPDATE events
        SET tickets_sold = tickets_sold - 1
        WHERE event_id = NEW.event_id;
        
        -- Decrement quantity_sold for the tier
        UPDATE ticket_tiers
        SET quantity_sold = quantity_sold - 1
        WHERE tier_id = NEW.tier_id;
    END IF;
END$$

-- Reset delimiter
DELIMITER ;

-- ============================================================================
-- END OF TRIGGERS
-- ============================================================================

