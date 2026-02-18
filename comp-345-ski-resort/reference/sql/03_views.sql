-- ============================================================================
-- Event Ticketing & Seating System - Views
-- COMP 345 Final Project Reference Implementation
-- ============================================================================

USE event_ticketing;

-- ============================================================================
-- REPORTING VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 1: Event Revenue Summary
-- Purpose: Aggregate revenue by event and ticket tier for financial reporting
-- ----------------------------------------------------------------------------

SELECT * FROM vw_event_revenue_summary

CREATE OR REPLACE VIEW vw_event_revenue_summary AS
SELECT 
    e.event_id,
    e.event_name,
    e.event_date,
    e.event_type,
    v.venue_name,
    tt.tier_name,
    tt.tier_level,
    tt.base_price,
    tt.quantity_available,
    tt.quantity_sold,
    tt.quantity_held,
    (tt.quantity_available - tt.quantity_sold - tt.quantity_held) AS quantity_remaining,
    ROUND((tt.quantity_sold * 100.0 / tt.quantity_available), 2) AS sell_through_percentage,
    COUNT(DISTINCT t.ticket_id) AS tickets_issued,
    SUM(t.purchase_price) AS total_revenue,
    AVG(t.purchase_price) AS avg_ticket_price,
    MIN(t.purchase_price) AS min_ticket_price,
    MAX(t.purchase_price) AS max_ticket_price
FROM events e
JOIN venues v ON e.venue_id = v.venue_id
JOIN ticket_tiers tt ON e.event_id = tt.event_id
LEFT JOIN tickets t ON tt.tier_id = t.tier_id AND t.ticket_status IN ('purchased', 'used')
GROUP BY e.event_id, e.event_name, e.event_date, e.event_type, v.venue_name, 
         tt.tier_name, tt.tier_level, tt.base_price, tt.quantity_available, 
         tt.quantity_sold, tt.quantity_held
ORDER BY e.event_date, e.event_name, tt.base_price DESC;

-- ----------------------------------------------------------------------------
-- View 2: Customer Purchase History (Security View - Restricted PII)
-- Purpose: Show customer purchase history without exposing sensitive data
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_customer_purchase_history AS
SELECT 
    c.customer_id,
    CONCAT(LEFT(c.first_name, 1), '***') AS first_name_masked,
    CONCAT(LEFT(c.last_name, 1), '***') AS last_name_masked,
    CONCAT(LEFT(c.email, 3), '***@', SUBSTRING_INDEX(c.email, '@', -1)) AS email_masked,
    c.loyalty_tier,
    c.total_lifetime_spend,
    c.account_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT t.ticket_id) AS total_tickets_purchased,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    MAX(o.order_date) AS last_purchase_date,
    MIN(o.order_date) AS first_purchase_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status IN ('confirmed', 'partially_refunded')
LEFT JOIN tickets t ON o.order_id = t.order_id AND t.ticket_status IN ('purchased', 'used')
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.loyalty_tier, 
         c.total_lifetime_spend, c.account_status;

-- ----------------------------------------------------------------------------
-- View 3: Seat Map Heatmap Data
-- Purpose: Visualize seat occupancy for events (for heatmap generation)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_seat_map_heatmap AS
SELECT 
    e.event_id,
    e.event_name,
    e.event_date,
    v.venue_name,
    sec.section_name,
    sec.section_type,
    s.seat_id,
    s.row_label,
    s.seat_number,
    s.accessibility_features,
    esa.assignment_status,
    CASE 
        WHEN esa.assignment_status = 'sold' THEN 'Sold'
        WHEN esa.assignment_status = 'held' THEN 'Held'
        WHEN esa.assignment_status = 'blocked' THEN 'Blocked'
        ELSE 'Available'
    END AS seat_status_display,
    tt.tier_name,
    tt.base_price,
    t.purchase_price,
    t.ticket_status
FROM events e
JOIN venues v ON e.venue_id = v.venue_id
JOIN sections sec ON v.venue_id = sec.venue_id
JOIN seats s ON sec.section_id = s.section_id
LEFT JOIN event_seat_assignments esa ON e.event_id = esa.event_id AND s.seat_id = esa.seat_id
LEFT JOIN tickets t ON esa.ticket_id = t.ticket_id
LEFT JOIN ticket_tiers tt ON t.tier_id = tt.tier_id
WHERE s.is_active = TRUE
ORDER BY e.event_id, sec.section_name, s.row_label, s.seat_number;

-- ----------------------------------------------------------------------------
-- View 4: Order Conversion Metrics (Holds to Purchases)
-- Purpose: Track conversion rates from held to purchased tickets
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_order_conversion_metrics AS
SELECT 
    DATE(o.order_date) AS order_date,
    e.event_name,
    e.event_type,
    COUNT(DISTINCT CASE WHEN o.order_status = 'held' THEN o.order_id END) AS orders_held,
    COUNT(DISTINCT CASE WHEN o.order_status = 'confirmed' THEN o.order_id END) AS orders_confirmed,
    COUNT(DISTINCT CASE WHEN o.order_status = 'cancelled' THEN o.order_id END) AS orders_cancelled,
    COUNT(DISTINCT CASE WHEN t.ticket_status = 'held' THEN t.ticket_id END) AS tickets_held,
    COUNT(DISTINCT CASE WHEN t.ticket_status = 'purchased' THEN t.ticket_id END) AS tickets_purchased,
    COUNT(DISTINCT CASE WHEN t.ticket_status = 'cancelled' THEN t.ticket_id END) AS tickets_cancelled,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.order_status = 'confirmed' THEN o.order_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT o.order_id), 0), 
        2
    ) AS order_conversion_rate,
    ROUND(
        COUNT(DISTINCT CASE WHEN t.ticket_status = 'purchased' THEN t.ticket_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT t.ticket_id), 0), 
        2
    ) AS ticket_conversion_rate,
    SUM(CASE WHEN o.order_status = 'confirmed' THEN o.total_amount ELSE 0 END) AS confirmed_revenue
FROM orders o
LEFT JOIN tickets t ON o.order_id = t.order_id
LEFT JOIN events e ON t.event_id = e.event_id
GROUP BY DATE(o.order_date), e.event_name, e.event_type
ORDER BY order_date DESC, e.event_name;

-- ----------------------------------------------------------------------------
-- View 5: Promo Code Performance
-- Purpose: Analyze effectiveness of promotional codes
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_promo_code_performance AS
SELECT 
    pc.promo_id,
    pc.promo_code,
    pc.description,
    pc.discount_type,
    pc.discount_value,
    pc.max_uses,
    pc.current_uses,
    CASE 
        WHEN pc.max_uses IS NULL THEN 'Unlimited'
        ELSE CONCAT(ROUND((pc.current_uses * 100.0 / pc.max_uses), 2), '%')
    END AS usage_percentage,
    pc.valid_from,
    pc.valid_until,
    pc.is_active,
    COUNT(DISTINCT o.order_id) AS orders_using_promo,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    SUM(o.discount_amount) AS total_discount_given,
    SUM(o.total_amount) AS total_revenue_with_promo,
    AVG(o.total_amount) AS avg_order_value,
    SUM(o.subtotal) AS total_subtotal,
    ROUND(SUM(o.discount_amount) * 100.0 / NULLIF(SUM(o.subtotal), 0), 2) AS avg_discount_percentage
FROM promo_codes pc
LEFT JOIN orders o ON pc.promo_id = o.promo_id AND o.order_status IN ('confirmed', 'partially_refunded')
GROUP BY pc.promo_id, pc.promo_code, pc.description, pc.discount_type, 
         pc.discount_value, pc.max_uses, pc.current_uses, pc.valid_from, 
         pc.valid_until, pc.is_active
ORDER BY total_revenue_with_promo DESC;

-- ============================================================================
-- OPERATIONAL VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 6: Upcoming Events Dashboard
-- Purpose: Quick overview of upcoming events for operations team
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_upcoming_events_dashboard AS
SELECT 
    e.event_id,
    e.event_name,
    e.event_type,
    e.event_date,
    e.event_time,
    e.doors_open_time,
    v.venue_name,
    v.city,
    v.state_province,
    e.event_status,
    e.total_tickets_available,
    e.tickets_sold,
    e.tickets_held,
    (e.total_tickets_available - e.tickets_sold - e.tickets_held) AS tickets_remaining,
    ROUND((e.tickets_sold * 100.0 / e.total_tickets_available), 2) AS capacity_percentage,
    COUNT(DISTINCT tt.tier_id) AS number_of_tiers,
    MIN(tt.base_price) AS min_price,
    MAX(tt.base_price) AS max_price,
    SUM(CASE WHEN t.ticket_status IN ('purchased', 'used') THEN t.purchase_price ELSE 0 END) AS current_revenue,
    DATEDIFF(e.event_date, CURDATE()) AS days_until_event
FROM events e
JOIN venues v ON e.venue_id = v.venue_id
LEFT JOIN ticket_tiers tt ON e.event_id = tt.event_id
LEFT JOIN tickets t ON e.event_id = t.event_id
WHERE e.event_date >= CURDATE() AND e.event_status NOT IN ('cancelled', 'completed')
GROUP BY e.event_id, e.event_name, e.event_type, e.event_date, e.event_time, 
         e.doors_open_time, v.venue_name, v.city, v.state_province, e.event_status,
         e.total_tickets_available, e.tickets_sold, e.tickets_held
ORDER BY e.event_date, e.event_time;

-- ----------------------------------------------------------------------------
-- View 7: Refund Analysis
-- Purpose: Track refund patterns and financial impact
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_refund_analysis AS
SELECT 
    DATE(r.requested_at) AS refund_date,
    e.event_name,
    e.event_date,
    r.refund_reason,
    r.refund_status,
    COUNT(DISTINCT r.refund_id) AS refund_count,
    COUNT(DISTINCT r.customer_id) AS unique_customers,
    SUM(r.refund_amount) AS total_refund_amount,
    AVG(r.refund_amount) AS avg_refund_amount,
    MIN(r.refund_amount) AS min_refund_amount,
    MAX(r.refund_amount) AS max_refund_amount,
    AVG(TIMESTAMPDIFF(HOUR, r.requested_at, r.processed_at)) AS avg_processing_hours
FROM refunds r
JOIN tickets t ON r.ticket_id = t.ticket_id
JOIN events e ON t.event_id = e.event_id
GROUP BY DATE(r.requested_at), e.event_name, e.event_date, r.refund_reason, r.refund_status
ORDER BY refund_date DESC, total_refund_amount DESC;

-- ============================================================================
-- SECURITY VIEW
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 8: Customer Contact Info (Restricted - Admin Only)
-- Purpose: Secure view for customer PII - should have restricted access
-- Note: In production, this would be granted only to admin role
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_customer_contact_secure AS
SELECT 
    customer_id,
    email,
    first_name,
    last_name,
    phone,
    CONCAT(address, ', ', city, ', ', state_province, ' ', postal_code) AS full_address,
    loyalty_tier,
    account_status,
    created_at
FROM customers
WHERE account_status = 'active';

-- ============================================================================
-- END OF VIEWS
-- ============================================================================

