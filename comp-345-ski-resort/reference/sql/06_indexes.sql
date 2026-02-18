-- ============================================================================
-- Event Ticketing & Seating System - Indexes
-- COMP 345 Final Project Reference Implementation
-- ============================================================================

USE event_ticketing;

-- ============================================================================
-- PERFORMANCE INDEXES
-- Note: Primary keys and unique constraints already have indexes
-- These are additional indexes for query optimization
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CUSTOMERS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Index for customer lookup by email (login, password reset)
-- Already created as UNIQUE in schema, but documenting here
-- CREATE INDEX idx_customer_email ON customers(email);

-- Index for customer filtering by loyalty tier and status
CREATE INDEX idx_customer_loyalty_status 
ON customers(loyalty_tier, account_status);

-- Index for customer search by name
CREATE INDEX idx_customer_name 
ON customers(last_name, first_name);

-- Index for customer lifetime spend analysis
CREATE INDEX idx_customer_spend 
ON customers(total_lifetime_spend DESC);

-- ----------------------------------------------------------------------------
-- EVENTS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for event listing and filtering
-- Supports queries filtering by date range and status
CREATE INDEX idx_event_date_status 
ON events(event_date, event_status);

-- Index for event type analysis
CREATE INDEX idx_event_type 
ON events(event_type, event_date);

-- Index for venue-based event queries
CREATE INDEX idx_event_venue_date 
ON events(venue_id, event_date);

-- Index for event capacity analysis
CREATE INDEX idx_event_capacity 
ON events(tickets_sold, total_tickets_available);

-- ----------------------------------------------------------------------------
-- ORDERS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for customer order history
-- Supports queries: "Show all orders for customer X ordered by date"
CREATE INDEX idx_order_customer_date
ON orders(customer_id, order_date DESC);

-- Note: idx_order_status_date removed from here - enhanced version with total_amount
--       is defined later in the "ADDITIONAL COMPOSITE INDEXES" section (line 273)

-- Index for payment processing queries
CREATE INDEX idx_order_payment
ON orders(payment_status, payment_method);

-- Index for promo code effectiveness analysis
CREATE INDEX idx_order_promo 
ON orders(promo_id, order_status);

-- Composite index for fraud detection (IP-based analysis)
CREATE INDEX idx_order_ip_date 
ON orders(ip_address, order_date);

-- Index for hold expiration cleanup jobs
CREATE INDEX idx_order_hold_expires 
ON orders(hold_expires_at, order_status);

-- ----------------------------------------------------------------------------
-- TICKETS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for event ticket lookup
-- Supports queries: "Show all tickets for event X"
CREATE INDEX idx_ticket_event_status 
ON tickets(event_id, ticket_status);

-- Index for order ticket details
CREATE INDEX idx_ticket_order 
ON tickets(order_id, ticket_status);

-- Index for tier-based ticket analysis
CREATE INDEX idx_ticket_tier 
ON tickets(tier_id, ticket_status);

-- Index for seat-based queries
CREATE INDEX idx_ticket_seat 
ON tickets(seat_id, event_id);

-- Index for refund policy deadline monitoring
CREATE INDEX idx_ticket_refund_deadline 
ON tickets(refund_policy_deadline, ticket_status);

-- Index for ticket usage tracking
CREATE INDEX idx_ticket_used 
ON tickets(used_at, ticket_status);

-- Composite index for revenue analysis
CREATE INDEX idx_ticket_event_price 
ON tickets(event_id, ticket_status, purchase_price);

-- ----------------------------------------------------------------------------
-- TICKET_TIERS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for event tier lookup
CREATE INDEX idx_tier_event_section 
ON ticket_tiers(event_id, section_id);

-- Index for tier availability queries
CREATE INDEX idx_tier_availability 
ON ticket_tiers(event_id, quantity_available, quantity_sold);

-- Index for pricing analysis
CREATE INDEX idx_tier_price 
ON ticket_tiers(tier_level, base_price);

-- Index for sales window queries
CREATE INDEX idx_tier_sales_dates 
ON ticket_tiers(sales_start_date, sales_end_date);

-- ----------------------------------------------------------------------------
-- EVENT_SEAT_ASSIGNMENTS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for seat availability lookup
-- Supports queries: "Show available seats for event X"
CREATE INDEX idx_esa_event_status 
ON event_seat_assignments(event_id, assignment_status);

-- Index for seat-specific queries
CREATE INDEX idx_esa_seat 
ON event_seat_assignments(seat_id, event_id);

-- Index for hold expiration cleanup
CREATE INDEX idx_esa_held_until 
ON event_seat_assignments(held_until, assignment_status);

-- Index for ticket-based seat lookup
CREATE INDEX idx_esa_ticket 
ON event_seat_assignments(ticket_id);

-- ----------------------------------------------------------------------------
-- PROMO_CODES TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Index for promo code validation
-- Supports queries: "Is promo code X valid right now?"
CREATE INDEX idx_promo_active_dates 
ON promo_codes(is_active, valid_from, valid_until);

-- Index for promo code usage tracking
CREATE INDEX idx_promo_usage 
ON promo_codes(current_uses, max_uses);

-- Index for discount type analysis
CREATE INDEX idx_promo_discount_type 
ON promo_codes(discount_type, discount_value);

-- ----------------------------------------------------------------------------
-- REFUNDS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for customer refund history
CREATE INDEX idx_refund_customer_date 
ON refunds(customer_id, requested_at DESC);

-- Index for refund status processing
CREATE INDEX idx_refund_status 
ON refunds(refund_status, requested_at);

-- Index for order refund lookup
CREATE INDEX idx_refund_order 
ON refunds(order_id, refund_status);

-- Index for ticket refund lookup
CREATE INDEX idx_refund_ticket 
ON refunds(ticket_id);

-- Index for refund reason analysis
CREATE INDEX idx_refund_reason 
ON refunds(refund_reason, refund_status);

-- Index for refund processing time analysis
CREATE INDEX idx_refund_processing 
ON refunds(requested_at, processed_at);

-- ----------------------------------------------------------------------------
-- SECTIONS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Index for venue section lookup
CREATE INDEX idx_section_venue 
ON sections(venue_id, section_type);

-- ----------------------------------------------------------------------------
-- SEATS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for section seat lookup
CREATE INDEX idx_seat_section_row 
ON seats(section_id, row_label, seat_number);

-- Index for accessibility feature queries
CREATE INDEX idx_seat_accessibility 
ON seats(accessibility_features, is_active);

-- Index for active seat filtering
CREATE INDEX idx_seat_active 
ON seats(is_active, section_id);

-- ----------------------------------------------------------------------------
-- AUDIT_LOG TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for audit trail queries
CREATE INDEX idx_audit_table_record 
ON audit_log(table_name, record_id, changed_at DESC);

-- Index for audit timestamp queries
CREATE INDEX idx_audit_timestamp 
ON audit_log(changed_at DESC);

-- Index for audit action type analysis
CREATE INDEX idx_audit_action 
ON audit_log(action_type, changed_at);

-- ============================================================================
-- COVERING INDEXES (for specific high-frequency queries)
-- ============================================================================

-- Covering index for event dashboard query
-- Includes all columns needed for the upcoming events view
CREATE INDEX idx_event_dashboard 
ON events(event_date, event_status, event_id, event_name, event_type, 
          venue_id, total_tickets_available, tickets_sold, tickets_held);

-- Covering index for customer order summary
-- Includes columns for customer purchase history view
CREATE INDEX idx_customer_orders_summary 
ON orders(customer_id, order_status, order_date, total_amount, order_id);

-- ============================================================================
-- ADDITIONAL COMPOSITE INDEXES
-- Note: MySQL does not support filtered/partial indexes with WHERE clauses
--       (that's a PostgreSQL feature). Using composite indexes instead.
-- ============================================================================

-- Composite index for active events queries
-- Useful for queries filtering by status and ordering by date
-- Replaces filtered index: WHERE event_status IN ('scheduled', 'on_sale')
CREATE INDEX idx_event_status_date
ON events(event_status, event_date, event_id);

-- Composite index for order status and date
-- Useful for revenue and sales reporting by status
-- Replaces filtered index: WHERE order_status = 'confirmed'
CREATE INDEX idx_order_status_date
ON orders(order_status, order_date, total_amount);

-- ============================================================================
-- FULL-TEXT INDEXES (for search functionality)
-- ============================================================================

-- Full-text index for event search
CREATE FULLTEXT INDEX idx_ft_event_search 
ON events(event_name, event_description);

-- Full-text index for venue search
CREATE FULLTEXT INDEX idx_ft_venue_search 
ON venues(venue_name, address, city);

-- ============================================================================
-- INDEX USAGE NOTES
-- ============================================================================

/*
INDEXING STRATEGY RATIONALE:

1. COMPOSITE INDEXES:
   - Ordered by selectivity (most selective column first)
   - Support common query patterns (WHERE, JOIN, ORDER BY)
   - Example: idx_order_customer_date supports:
     * WHERE customer_id = X
     * WHERE customer_id = X ORDER BY order_date DESC
     * WHERE customer_id = X AND order_date > Y

2. COVERING INDEXES:
   - Include all columns needed for specific queries
   - Eliminate need to access table data (index-only scan)
   - Trade-off: Larger index size vs. faster query performance

3. PARTIAL INDEXES:
   - Reduce index size by only indexing relevant rows
   - Faster updates (fewer index entries to maintain)
   - Only useful when queries consistently filter on the condition

4. FULL-TEXT INDEXES:
   - Enable natural language search on text columns
   - Support MATCH() AGAINST() queries
   - Better than LIKE '%term%' for search functionality

5. TRADE-OFFS:
   - Write Performance: Each index slows down INSERT/UPDATE/DELETE
   - Storage: Indexes consume disk space
   - Maintenance: Indexes need to be rebuilt/optimized periodically
   - Decision: Index columns used in WHERE, JOIN, ORDER BY clauses
              of frequent queries

6. MONITORING:
   - Use EXPLAIN to verify index usage
   - Monitor slow query log
   - Analyze index statistics with SHOW INDEX
   - Remove unused indexes identified by performance schema
*/

-- ============================================================================
-- END OF INDEXES
-- ============================================================================

