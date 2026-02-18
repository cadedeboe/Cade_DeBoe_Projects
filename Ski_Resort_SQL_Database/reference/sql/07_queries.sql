-- ============================================================================
-- Event Ticketing & Seating System - Query Workload
-- COMP 345 Final Project Reference Implementation
-- ============================================================================

USE event_ticketing;

-- ============================================================================
-- QUERY 1: Revenue by Event and Ticket Tier (Multi-table JOIN + Aggregation)
-- Purpose: Financial reporting - show revenue breakdown by event and tier
-- Complexity: 4-table JOIN, GROUP BY, aggregation functions
-- ============================================================================
SELECT 
    e.event_id,
    e.event_name,
    e.event_date,
    v.venue_name,
    v.city AS venue_city,
    tt.tier_name,
    tt.tier_level,
    tt.base_price,
    COUNT(t.ticket_id) AS tickets_sold,
    SUM(t.purchase_price) AS total_revenue,
    AVG(t.purchase_price) AS avg_ticket_price,
    SUM(t.purchase_price) - (COUNT(t.ticket_id) * tt.base_price) AS price_variance
FROM events e
JOIN venues v ON e.venue_id = v.venue_id
JOIN ticket_tiers tt ON e.event_id = tt.event_id
LEFT JOIN tickets t ON tt.tier_id = t.tier_id 
    AND t.ticket_status IN ('purchased', 'used')
WHERE e.event_status != 'cancelled'
GROUP BY e.event_id, e.event_name, e.event_date, v.venue_name, v.city,
         tt.tier_name, tt.tier_level, tt.base_price
HAVING total_revenue > 0
ORDER BY e.event_date, total_revenue DESC;

-- ============================================================================
-- QUERY 2: Seat Map Heatmap - Occupancy Visualization
-- Purpose: Show seat occupancy status for venue management
-- Complexity: 5-table JOIN, CASE expressions, spatial grouping
-- ============================================================================
SELECT 
    e.event_name,
    e.event_date,
    sec.section_name,
    s.row_label,
    COUNT(DISTINCT s.seat_id) AS total_seats,
    COUNT(DISTINCT CASE WHEN esa.assignment_status = 'sold' THEN s.seat_id END) AS seats_sold,
    COUNT(DISTINCT CASE WHEN esa.assignment_status = 'held' THEN s.seat_id END) AS seats_held,
    COUNT(DISTINCT CASE WHEN esa.assignment_status = 'available' OR esa.assignment_status IS NULL 
                        THEN s.seat_id END) AS seats_available,
    ROUND(
        COUNT(DISTINCT CASE WHEN esa.assignment_status = 'sold' THEN s.seat_id END) * 100.0 / 
        COUNT(DISTINCT s.seat_id), 
        2
    ) AS occupancy_percentage,
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN esa.assignment_status = 'sold' THEN s.seat_id END) * 100.0 / 
             COUNT(DISTINCT s.seat_id) >= 90 THEN 'Hot'
        WHEN COUNT(DISTINCT CASE WHEN esa.assignment_status = 'sold' THEN s.seat_id END) * 100.0 / 
             COUNT(DISTINCT s.seat_id) >= 50 THEN 'Warm'
        ELSE 'Cold'
    END AS heat_level
FROM events e
JOIN sections sec ON e.venue_id = sec.venue_id
JOIN seats s ON sec.section_id = s.section_id
LEFT JOIN event_seat_assignments esa ON e.event_id = esa.event_id AND s.seat_id = esa.seat_id
WHERE e.event_id = 1  -- Taylor Swift concert
  AND s.is_active = TRUE
GROUP BY e.event_name, e.event_date, sec.section_name, s.row_label
ORDER BY sec.section_name, s.row_label;

-- ============================================================================
-- QUERY 3: Conversion Rates - Holds to Purchases (Window Function)
-- Purpose: Analyze ticket hold-to-purchase conversion for sales optimization
-- Complexity: Window functions, CTEs, conversion rate calculation
-- ============================================================================
WITH daily_metrics AS (
    SELECT 
        DATE(o.order_date) AS order_date,
        e.event_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT CASE WHEN o.order_status = 'held' THEN o.order_id END) AS held_orders,
        COUNT(DISTINCT CASE WHEN o.order_status = 'confirmed' THEN o.order_id END) AS confirmed_orders,
        COUNT(DISTINCT CASE WHEN o.order_status = 'cancelled' THEN o.order_id END) AS cancelled_orders,
        SUM(CASE WHEN o.order_status = 'confirmed' THEN o.total_amount ELSE 0 END) AS daily_revenue
    FROM orders o
    LEFT JOIN tickets t ON o.order_id = t.order_id
    LEFT JOIN events e ON t.event_id = e.event_id
    GROUP BY DATE(o.order_date), e.event_name
)
SELECT 
    order_date,
    event_name,
    total_orders,
    held_orders,
    confirmed_orders,
    cancelled_orders,
    ROUND(confirmed_orders * 100.0 / NULLIF(total_orders, 0), 2) AS conversion_rate,
    daily_revenue,
    SUM(daily_revenue) OVER (PARTITION BY event_name ORDER BY order_date) AS cumulative_revenue,
    AVG(confirmed_orders) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7day_avg_orders,
    RANK() OVER (ORDER BY daily_revenue DESC) AS revenue_rank
FROM daily_metrics
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
ORDER BY order_date DESC, daily_revenue DESC;

-- ============================================================================
-- QUERY 4: Fraud Pattern Detection - Suspicious Orders
-- Purpose: Identify potentially fraudulent purchasing patterns
-- Complexity: Correlated subquery, aggregation, pattern matching
-- ============================================================================
SELECT 
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.ip_address) AS unique_ips,
    SUM(o.total_amount) AS total_spent,
    MAX(o.order_date) AS last_order_date,
    -- Subquery: Count orders in last 24 hours
    (SELECT COUNT(*) 
     FROM orders o2 
     WHERE o2.customer_id = c.customer_id 
       AND o2.order_date >= DATE_SUB(NOW(), INTERVAL 24 HOUR)) AS orders_last_24h,
    -- Subquery: Count high-value orders
    (SELECT COUNT(*) 
     FROM orders o3 
     WHERE o3.customer_id = c.customer_id 
       AND o3.total_amount > 1000) AS high_value_orders,
    -- Subquery: Check for rapid-fire orders (within 5 minutes)
    (SELECT COUNT(DISTINCT o4.order_id)
     FROM orders o4
     WHERE o4.customer_id = c.customer_id
       AND EXISTS (
           SELECT 1 FROM orders o5
           WHERE o5.customer_id = o4.customer_id
             AND o5.order_id != o4.order_id
             AND ABS(TIMESTAMPDIFF(MINUTE, o4.order_date, o5.order_date)) <= 5
       )) AS rapid_fire_orders,
    CASE 
        WHEN COUNT(DISTINCT o.order_id) >= 3 
             AND MAX(o.order_date) >= DATE_SUB(NOW(), INTERVAL 24 HOUR) THEN 'High Risk'
        WHEN SUM(o.total_amount) > 5000 
             AND COUNT(DISTINCT o.order_id) >= 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS fraud_risk_level
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'confirmed'
  AND o.order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY c.customer_id, c.email, c.first_name, c.last_name
HAVING order_count >= 2 
   AND (orders_last_24h >= 3 OR total_spent > 5000 OR rapid_fire_orders > 0)
ORDER BY fraud_risk_level DESC, total_spent DESC;

-- ============================================================================
-- QUERY 5: Customer Lifetime Value Analysis (Complex Aggregation)
-- Purpose: Segment customers by value for marketing campaigns
-- Complexity: Multiple aggregations, CASE expressions, percentile calculation
-- ============================================================================
SELECT 
    c.customer_id,
    c.email,
    c.loyalty_tier,
    c.total_lifetime_spend,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT t.ticket_id) AS total_tickets,
    COUNT(DISTINCT t.event_id) AS unique_events_attended,
    AVG(o.total_amount) AS avg_order_value,
    MAX(o.order_date) AS last_purchase_date,
    DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_purchase,
    SUM(CASE WHEN o.promo_id IS NOT NULL THEN 1 ELSE 0 END) AS promo_usage_count,
    ROUND(SUM(o.discount_amount), 2) AS total_discounts_received,
    CASE 
        WHEN c.total_lifetime_spend >= 5000 AND COUNT(DISTINCT o.order_id) >= 10 THEN 'VIP'
        WHEN c.total_lifetime_spend >= 2000 AND COUNT(DISTINCT o.order_id) >= 5 THEN 'High Value'
        WHEN c.total_lifetime_spend >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    CASE 
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) <= 30 THEN 'Active'
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) <= 90 THEN 'At Risk'
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) <= 180 THEN 'Dormant'
        ELSE 'Churned'
    END AS engagement_status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_status IN ('confirmed', 'partially_refunded')
LEFT JOIN tickets t ON o.order_id = t.order_id 
    AND t.ticket_status IN ('purchased', 'used')
GROUP BY c.customer_id, c.email, c.loyalty_tier, c.total_lifetime_spend
HAVING total_orders > 0
ORDER BY c.total_lifetime_spend DESC, total_orders DESC
LIMIT 100;

-- ============================================================================
-- QUERY 6: Event Performance Dashboard (Report Query with KPIs)
-- Purpose: Executive dashboard showing key performance indicators
-- Complexity: Multiple CTEs, complex calculations, KPI aggregation
-- ============================================================================
WITH event_stats AS (
    SELECT 
        e.event_id,
        e.event_name,
        e.event_date,
        e.event_type,
        v.venue_name,
        e.total_tickets_available,
        e.tickets_sold,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT o.customer_id) AS unique_customers,
        SUM(t.purchase_price) AS gross_revenue,
        SUM(o.discount_amount) AS total_discounts,
        AVG(o.total_amount) AS avg_order_value,
        COUNT(DISTINCT CASE WHEN t.ticket_status = 'refunded' THEN t.ticket_id END) AS refunded_tickets
    FROM events e
    JOIN venues v ON e.venue_id = v.venue_id
    LEFT JOIN tickets t ON e.event_id = t.event_id
    LEFT JOIN orders o ON t.order_id = o.order_id AND o.order_status IN ('confirmed', 'partially_refunded', 'refunded')
    WHERE e.event_status != 'cancelled'
    GROUP BY e.event_id, e.event_name, e.event_date, e.event_type, v.venue_name, 
             e.total_tickets_available, e.tickets_sold
),
tier_stats AS (
    SELECT 
        event_id,
        COUNT(DISTINCT tier_id) AS tier_count,
        MIN(base_price) AS min_price,
        MAX(base_price) AS max_price
    FROM ticket_tiers
    GROUP BY event_id
)
SELECT 
    es.event_name,
    es.event_date,
    es.event_type,
    es.venue_name,
    es.total_tickets_available,
    es.tickets_sold,
    ROUND((es.tickets_sold * 100.0 / es.total_tickets_available), 2) AS sell_through_pct,
    es.total_orders,
    es.unique_customers,
    ROUND(es.tickets_sold * 1.0 / NULLIF(es.total_orders, 0), 2) AS avg_tickets_per_order,
    CONCAT('$', FORMAT(es.gross_revenue, 2)) AS gross_revenue,
    CONCAT('$', FORMAT(es.total_discounts, 2)) AS total_discounts,
    CONCAT('$', FORMAT(es.gross_revenue - es.total_discounts, 2)) AS net_revenue,
    CONCAT('$', FORMAT(es.avg_order_value, 2)) AS avg_order_value,
    es.refunded_tickets,
    ROUND((es.refunded_tickets * 100.0 / NULLIF(es.tickets_sold, 0)), 2) AS refund_rate_pct,
    ts.tier_count,
    CONCAT('$', FORMAT(ts.min_price, 2), ' - $', FORMAT(ts.max_price, 2)) AS price_range,
    DATEDIFF(es.event_date, CURDATE()) AS days_until_event,
    CASE 
        WHEN es.tickets_sold * 100.0 / es.total_tickets_available >= 95 THEN 'Excellent'
        WHEN es.tickets_sold * 100.0 / es.total_tickets_available >= 75 THEN 'Good'
        WHEN es.tickets_sold * 100.0 / es.total_tickets_available >= 50 THEN 'Fair'
        ELSE 'Poor'
    END AS performance_rating
FROM event_stats es
LEFT JOIN tier_stats ts ON es.event_id = ts.event_id
ORDER BY es.event_date, es.gross_revenue DESC;

-- ============================================================================
-- QUERY 7: Venue Utilization Analysis (Multi-table JOIN)
-- Purpose: Analyze venue usage patterns and capacity utilization
-- Complexity: 3-table JOIN, date functions, capacity calculations
-- ============================================================================
SELECT 
    v.venue_id,
    v.venue_name,
    v.city,
    v.venue_type,
    v.total_capacity,
    COUNT(DISTINCT e.event_id) AS total_events,
    COUNT(DISTINCT CASE WHEN e.event_date >= CURDATE() THEN e.event_id END) AS upcoming_events,
    COUNT(DISTINCT CASE WHEN e.event_status = 'sold_out' THEN e.event_id END) AS sold_out_events,
    SUM(e.tickets_sold) AS total_tickets_sold,
    AVG(e.tickets_sold * 100.0 / e.total_tickets_available) AS avg_capacity_utilization,
    SUM(t.purchase_price) AS total_venue_revenue,
    AVG(t.purchase_price) AS avg_ticket_price,
    COUNT(DISTINCT YEAR(e.event_date)) AS years_active,
    MIN(e.event_date) AS first_event_date,
    MAX(e.event_date) AS last_event_date
FROM venues v
LEFT JOIN events e ON v.venue_id = e.venue_id
LEFT JOIN tickets t ON e.event_id = t.event_id AND t.ticket_status IN ('purchased', 'used')
GROUP BY v.venue_id, v.venue_name, v.city, v.venue_type, v.total_capacity
ORDER BY total_venue_revenue DESC;

-- ============================================================================
-- QUERY 8: Promo Code ROI Analysis (Subquery + Aggregation)
-- Purpose: Evaluate return on investment for promotional campaigns
-- Complexity: Correlated subquery, ROI calculation, effectiveness metrics
-- ============================================================================
SELECT 
    pc.promo_code,
    pc.description,
    pc.discount_type,
    pc.discount_value,
    pc.current_uses,
    pc.max_uses,
    COUNT(DISTINCT o.order_id) AS orders_with_promo,
    COUNT(DISTINCT o.customer_id) AS unique_customers_reached,
    SUM(o.subtotal) AS gross_sales,
    SUM(o.discount_amount) AS total_discount_given,
    SUM(o.total_amount) AS net_revenue,
    AVG(o.total_amount) AS avg_order_value_with_promo,
    -- Compare to average order value without promo
    (SELECT AVG(total_amount) 
     FROM orders 
     WHERE promo_id IS NULL 
       AND order_status = 'confirmed') AS avg_order_value_without_promo,
    ROUND(
        (SUM(o.total_amount) - SUM(o.discount_amount)) / NULLIF(SUM(o.discount_amount), 0),
        2
    ) AS roi_ratio,
    CASE 
        WHEN SUM(o.total_amount) > SUM(o.discount_amount) * 3 THEN 'Highly Effective'
        WHEN SUM(o.total_amount) > SUM(o.discount_amount) * 2 THEN 'Effective'
        WHEN SUM(o.total_amount) > SUM(o.discount_amount) THEN 'Marginally Effective'
        ELSE 'Ineffective'
    END AS effectiveness_rating
FROM promo_codes pc
LEFT JOIN orders o ON pc.promo_id = o.promo_id AND o.order_status IN ('confirmed', 'partially_refunded')
WHERE pc.current_uses > 0
GROUP BY pc.promo_code, pc.description, pc.discount_type, pc.discount_value, 
         pc.current_uses, pc.max_uses
ORDER BY net_revenue DESC;

-- ============================================================================
-- QUERY 9: Refund Trend Analysis (Time-series with Window Functions)
-- Purpose: Track refund patterns over time for policy optimization
-- Complexity: Window functions, time-series analysis, trend calculation
-- ============================================================================
WITH monthly_refunds AS (
    SELECT
        DATE_FORMAT(r.requested_at, '%Y-%m') AS refund_month,
        r.refund_reason,
        COUNT(DISTINCT r.refund_id) AS refund_count,
        SUM(r.refund_amount) AS total_refund_amount,
        AVG(r.refund_amount) AS avg_refund_amount,
        COUNT(DISTINCT r.customer_id) AS unique_customers
    FROM refunds r
    WHERE r.refund_status = 'processed'
    GROUP BY DATE_FORMAT(r.requested_at, '%Y-%m'), r.refund_reason
)
SELECT
    refund_month,
    refund_reason,
    refund_count,
    total_refund_amount,
    avg_refund_amount,
    unique_customers,
    SUM(refund_count) OVER (PARTITION BY refund_reason ORDER BY refund_month) AS cumulative_refunds,
    SUM(total_refund_amount) OVER (PARTITION BY refund_reason ORDER BY refund_month) AS cumulative_amount,
    AVG(refund_count) OVER (PARTITION BY refund_reason ORDER BY refund_month
                            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3month,
    LAG(refund_count, 1) OVER (PARTITION BY refund_reason ORDER BY refund_month) AS prev_month_count,
    ROUND(
        (refund_count - LAG(refund_count, 1) OVER (PARTITION BY refund_reason ORDER BY refund_month)) * 100.0 /
        NULLIF(LAG(refund_count, 1) OVER (PARTITION BY refund_reason ORDER BY refund_month), 0),
        2
    ) AS month_over_month_change_pct
FROM monthly_refunds
ORDER BY refund_month DESC, total_refund_amount DESC;

-- ============================================================================
-- QUERY 10: Seat Accessibility Compliance Report (EXISTS subquery)
-- Purpose: Ensure ADA compliance by tracking accessible seat availability
-- Complexity: EXISTS clause, compliance calculation, regulatory reporting
-- ============================================================================
SELECT
    v.venue_name,
    v.city,
    sec.section_name,
    COUNT(DISTINCT s.seat_id) AS total_seats,
    COUNT(DISTINCT CASE WHEN s.accessibility_features != 'none' THEN s.seat_id END) AS accessible_seats,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.accessibility_features != 'none' THEN s.seat_id END) * 100.0 /
        COUNT(DISTINCT s.seat_id),
        2
    ) AS accessible_seat_percentage,
    COUNT(DISTINCT CASE WHEN s.accessibility_features = 'wheelchair' THEN s.seat_id END) AS wheelchair_seats,
    COUNT(DISTINCT CASE WHEN s.accessibility_features = 'companion' THEN s.seat_id END) AS companion_seats,
    COUNT(DISTINCT CASE WHEN s.accessibility_features = 'aisle' THEN s.seat_id END) AS aisle_seats,
    -- Check if venue has events with accessible seats sold
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM event_seat_assignments esa
            JOIN events e ON esa.event_id = e.event_id
            WHERE esa.seat_id = s.seat_id
              AND e.venue_id = v.venue_id
              AND esa.assignment_status = 'sold'
              AND s.accessibility_features != 'none'
        ) THEN 'Yes'
        ELSE 'No'
    END AS has_accessible_sales,
    CASE
        WHEN COUNT(DISTINCT CASE WHEN s.accessibility_features != 'none' THEN s.seat_id END) * 100.0 /
             COUNT(DISTINCT s.seat_id) >= 5 THEN 'Compliant'
        ELSE 'Non-Compliant'
    END AS ada_compliance_status
FROM venues v
JOIN sections sec ON v.venue_id = sec.venue_id
JOIN seats s ON sec.section_id = s.section_id
WHERE s.is_active = TRUE
GROUP BY v.venue_name, v.city, sec.section_name, v.venue_id, s.seat_id
ORDER BY v.venue_name, sec.section_name;

-- ============================================================================
-- ADDITIONAL ANALYTICAL QUERIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 11: Peak Sales Time Analysis
-- Purpose: Identify optimal times for marketing campaigns
-- ----------------------------------------------------------------------------
SELECT
    HOUR(o.order_date) AS hour_of_day,
    DAYNAME(o.order_date) AS day_of_week,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM orders o
WHERE o.order_status = 'confirmed'
  AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY HOUR(o.order_date), DAYNAME(o.order_date)
ORDER BY total_revenue DESC
LIMIT 20;

-- ----------------------------------------------------------------------------
-- QUERY 12: Customer Retention Cohort Analysis
-- Purpose: Track customer retention by signup cohort
-- ----------------------------------------------------------------------------
WITH customer_cohorts AS (
    SELECT
        c.customer_id,
        DATE_FORMAT(c.created_at, '%Y-%m') AS cohort_month,
        MIN(o.order_date) AS first_purchase_date,
        MAX(o.order_date) AS last_purchase_date,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
        AND o.order_status IN ('confirmed', 'partially_refunded')
    GROUP BY c.customer_id, DATE_FORMAT(c.created_at, '%Y-%m')
)
SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_size,
    COUNT(DISTINCT CASE WHEN total_orders > 0 THEN customer_id END) AS customers_with_purchases,
    COUNT(DISTINCT CASE WHEN total_orders > 1 THEN customer_id END) AS repeat_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN total_orders > 1 THEN customer_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN total_orders > 0 THEN customer_id END), 0),
        2
    ) AS repeat_purchase_rate,
    AVG(total_spent) AS avg_lifetime_value,
    AVG(total_orders) AS avg_orders_per_customer
FROM customer_cohorts
GROUP BY cohort_month
ORDER BY cohort_month DESC;

-- ============================================================================
-- END OF QUERIES
-- ============================================================================

