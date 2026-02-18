-- ============================================================================
-- Event Ticketing & Seating System - Database Schema
-- COMP 345 Final Project Reference Implementation
-- DBMS: MySQL 8.0+
-- ============================================================================

-- Drop existing database if it exists and create fresh
DROP DATABASE IF EXISTS event_ticketing;
CREATE DATABASE event_ticketing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE event_ticketing;

-- ============================================================================
-- CORE ENTITIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Venues: Physical locations where events are held
-- ----------------------------------------------------------------------------
CREATE TABLE venues (
    venue_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    venue_name VARCHAR(200) NOT NULL,
    address VARCHAR(500) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'USA',
    postal_code VARCHAR(20) NOT NULL,
    total_capacity INT NOT NULL,
    venue_type ENUM('theater', 'stadium', 'arena', 'concert_hall', 'conference_center', 'outdoor') NOT NULL,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_venue_capacity CHECK (total_capacity > 0 AND total_capacity <= 200000),
    UNIQUE KEY uk_venue_name_city (venue_name, city)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Sections: Logical divisions within a venue (e.g., Orchestra, Balcony, Floor)
-- ----------------------------------------------------------------------------
CREATE TABLE sections (
    section_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    venue_id BIGINT NOT NULL,
    section_name VARCHAR(100) NOT NULL,
    section_type ENUM('floor', 'lower_level', 'upper_level', 'balcony', 'box', 'vip', 'general_admission') NOT NULL,
    total_seats INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_section_venue FOREIGN KEY (venue_id) REFERENCES venues(venue_id) ON DELETE CASCADE,
    CONSTRAINT chk_section_seats CHECK (total_seats > 0),
    UNIQUE KEY uk_section_venue (venue_id, section_name)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Seats: Individual seats within sections
-- ----------------------------------------------------------------------------
CREATE TABLE seats (
    seat_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    section_id BIGINT NOT NULL,
    row_label VARCHAR(10) NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    accessibility_features ENUM('none', 'wheelchair', 'companion', 'aisle') DEFAULT 'none',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_seat_section FOREIGN KEY (section_id) REFERENCES sections(section_id) ON DELETE CASCADE,
    UNIQUE KEY uk_seat_location (section_id, row_label, seat_number)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Customers: People who purchase tickets
-- ----------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    address VARCHAR(500),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'USA',
    loyalty_tier ENUM('standard', 'silver', 'gold', 'platinum') DEFAULT 'standard',
    total_lifetime_spend DECIMAL(12, 2) DEFAULT 0.00,
    account_status ENUM('active', 'suspended', 'closed') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_customer_spend CHECK (total_lifetime_spend >= 0)
    -- Note: Date of birth validation moved to trigger (CURDATE() not allowed in CHECK constraints)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Events: Performances, concerts, games, etc.
-- ----------------------------------------------------------------------------
CREATE TABLE events (
    event_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    venue_id BIGINT NOT NULL,
    event_name VARCHAR(300) NOT NULL,
    event_type ENUM('concert', 'sports', 'theater', 'comedy', 'conference', 'festival', 'other') NOT NULL,
    event_description TEXT,
    event_date DATE NOT NULL,
    event_time TIME NOT NULL,
    doors_open_time TIME,
    event_status ENUM('scheduled', 'on_sale', 'sold_out', 'cancelled', 'postponed', 'completed') DEFAULT 'scheduled',
    total_tickets_available INT NOT NULL,
    tickets_sold INT DEFAULT 0,
    tickets_held INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_event_venue FOREIGN KEY (venue_id) REFERENCES venues(venue_id) ON DELETE RESTRICT,
    CONSTRAINT chk_event_tickets CHECK (total_tickets_available > 0),
    CONSTRAINT chk_event_sold CHECK (tickets_sold >= 0 AND tickets_sold <= total_tickets_available),
    CONSTRAINT chk_event_held CHECK (tickets_held >= 0 AND tickets_held <= total_tickets_available),
    -- Note: Event date validation moved to trigger (CURDATE() not allowed in CHECK constraints)
    INDEX idx_event_date (event_date),
    INDEX idx_event_status (event_status)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Ticket Tiers: Pricing levels for events (VIP, Premium, Standard, etc.)
-- ----------------------------------------------------------------------------
CREATE TABLE ticket_tiers (
    tier_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT NOT NULL,
    section_id BIGINT NOT NULL,
    tier_name VARCHAR(100) NOT NULL,
    tier_level ENUM('vip', 'premium', 'standard', 'budget', 'general_admission') NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    quantity_available INT NOT NULL,
    quantity_sold INT DEFAULT 0,
    quantity_held INT DEFAULT 0,
    sales_start_date TIMESTAMP NOT NULL,
    sales_end_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tier_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_tier_section FOREIGN KEY (section_id) REFERENCES sections(section_id) ON DELETE RESTRICT,
    CONSTRAINT chk_tier_price CHECK (base_price >= 0),
    CONSTRAINT chk_tier_quantity CHECK (quantity_available > 0),
    CONSTRAINT chk_tier_sold CHECK (quantity_sold >= 0 AND quantity_sold <= quantity_available),
    CONSTRAINT chk_tier_held CHECK (quantity_held >= 0 AND quantity_held <= quantity_available),
    CONSTRAINT chk_tier_dates CHECK (sales_end_date > sales_start_date),
    UNIQUE KEY uk_tier_event_section (event_id, section_id, tier_name)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Promo Codes: Discount codes for ticket purchases
-- ----------------------------------------------------------------------------
CREATE TABLE promo_codes (
    promo_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    promo_code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(500),
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    max_uses INT,
    current_uses INT DEFAULT 0,
    valid_from TIMESTAMP NOT NULL,
    valid_until TIMESTAMP NOT NULL,
    min_purchase_amount DECIMAL(10, 2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_promo_discount CHECK (discount_value > 0),
    CONSTRAINT chk_promo_uses CHECK (max_uses IS NULL OR (current_uses >= 0 AND current_uses <= max_uses)),
    CONSTRAINT chk_promo_dates CHECK (valid_until > valid_from),
    INDEX idx_promo_code (promo_code),
    INDEX idx_promo_active (is_active, valid_from, valid_until)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Orders: Customer purchase transactions
-- ----------------------------------------------------------------------------
CREATE TABLE orders (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    order_status ENUM('pending', 'held', 'confirmed', 'cancelled', 'refunded', 'partially_refunded') DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hold_expires_at TIMESTAMP NULL,
    confirmed_at TIMESTAMP NULL,
    subtotal DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(12, 2) DEFAULT 0.00,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    promo_id BIGINT NULL,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'apple_pay', 'google_pay') NULL,
    payment_status ENUM('pending', 'authorized', 'captured', 'failed', 'refunded') DEFAULT 'pending',
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_promo FOREIGN KEY (promo_id) REFERENCES promo_codes(promo_id) ON DELETE SET NULL,
    CONSTRAINT chk_order_amounts CHECK (subtotal >= 0 AND discount_amount >= 0 AND tax_amount >= 0 AND total_amount >= 0),
    INDEX idx_order_customer (customer_id),
    INDEX idx_order_status (order_status),
    INDEX idx_order_date (order_date)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Tickets: Individual tickets within orders (bridge table: orders <-> seats)
-- ----------------------------------------------------------------------------
CREATE TABLE tickets (
    ticket_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    event_id BIGINT NOT NULL,
    tier_id BIGINT NOT NULL,
    seat_id BIGINT NULL,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    ticket_status ENUM('held', 'purchased', 'cancelled', 'refunded', 'used', 'transferred') DEFAULT 'held',
    purchase_price DECIMAL(10, 2) NOT NULL,
    face_value DECIMAL(10, 2) NOT NULL,
    refund_amount DECIMAL(10, 2) DEFAULT 0.00,
    refund_policy_deadline TIMESTAMP NULL,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_ticket_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_ticket_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE RESTRICT,
    CONSTRAINT fk_ticket_tier FOREIGN KEY (tier_id) REFERENCES ticket_tiers(tier_id) ON DELETE RESTRICT,
    CONSTRAINT fk_ticket_seat FOREIGN KEY (seat_id) REFERENCES seats(seat_id) ON DELETE RESTRICT,
    CONSTRAINT chk_ticket_prices CHECK (purchase_price >= 0 AND face_value >= 0),
    CONSTRAINT chk_ticket_refund CHECK (refund_amount >= 0 AND refund_amount <= purchase_price),
    INDEX idx_ticket_event (event_id),
    INDEX idx_ticket_status (ticket_status)
    -- Note: idx_ticket_order removed - composite index in 06_indexes.sql is superior
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Event Seat Assignments: Ensures seat uniqueness per event (bridge table)
-- ----------------------------------------------------------------------------
CREATE TABLE event_seat_assignments (
    assignment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT NOT NULL,
    seat_id BIGINT NOT NULL,
    ticket_id BIGINT NULL,
    assignment_status ENUM('available', 'held', 'sold', 'blocked') DEFAULT 'available',
    held_until TIMESTAMP NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_esa_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_esa_seat FOREIGN KEY (seat_id) REFERENCES seats(seat_id) ON DELETE CASCADE,
    CONSTRAINT fk_esa_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) ON DELETE SET NULL,
    UNIQUE KEY uk_event_seat (event_id, seat_id),
    INDEX idx_esa_status (assignment_status)
    -- Note: idx_esa_held_until removed - composite index in 06_indexes.sql is superior
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Refunds: Track refund transactions
-- ----------------------------------------------------------------------------
CREATE TABLE refunds (
    refund_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    refund_amount DECIMAL(10, 2) NOT NULL,
    refund_reason ENUM('customer_request', 'event_cancelled', 'event_postponed', 'duplicate_purchase', 'fraud', 'other') NOT NULL,
    refund_status ENUM('pending', 'approved', 'processed', 'rejected') DEFAULT 'pending',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    notes TEXT,
    CONSTRAINT fk_refund_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) ON DELETE RESTRICT,
    CONSTRAINT fk_refund_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_refund_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    CONSTRAINT chk_refund_amount CHECK (refund_amount > 0),
    INDEX idx_refund_customer (customer_id)
    -- Note: idx_refund_status removed - composite index in 06_indexes.sql is superior
) ENGINE=InnoDB;

-- ============================================================================
-- AUDIT & LOGGING
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Audit Log: Track important system events
-- ----------------------------------------------------------------------------
CREATE TABLE audit_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON,
    new_values JSON,
    changed_by VARCHAR(255),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    INDEX idx_audit_table (table_name, record_id)
    -- Note: idx_audit_timestamp removed - composite index with DESC in 06_indexes.sql is superior
) ENGINE=InnoDB;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

