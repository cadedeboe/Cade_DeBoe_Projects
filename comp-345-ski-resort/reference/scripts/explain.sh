#!/bin/bash

# ============================================================================
# Event Ticketing & Seating System - EXPLAIN/ANALYZE Script
# COMP 345 Final Project Reference Implementation
# Purpose: Demonstrate query performance with and without indexes
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
DB_NAME="event_ticketing"
DB_USER="${MYSQL_USER:-root}"
DB_PASSWORD="${MYSQL_PASSWORD:-}"
DB_HOST="${MYSQL_HOST:-localhost}"
DB_PORT="${MYSQL_PORT:-3306}"

# ============================================================================
# Functions
# ============================================================================

print_header() {
    echo -e "${BLUE}============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================================${NC}"
}

print_subheader() {
    echo -e "${MAGENTA}--- $1 ---${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Execute SQL and display results
execute_sql() {
    local query=$1
    
    if [ -z "$DB_PASSWORD" ]; then
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -D"$DB_NAME" -t -e "$query"
    else
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -D"$DB_NAME" -t -e "$query"
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

print_header "Query Performance Analysis with EXPLAIN"

echo ""
print_info "This script demonstrates the impact of indexes on query performance"
print_info "Database: $DB_NAME @ $DB_HOST:$DB_PORT"
echo ""

# ============================================================================
# QUERY 1: Event Revenue Summary (Multi-table JOIN)
# ============================================================================

print_header "Query 1: Event Revenue Summary (4-table JOIN)"

print_subheader "Query"
cat << 'EOF'
SELECT 
    e.event_id, e.event_name, e.event_date,
    v.venue_name, tt.tier_name,
    COUNT(t.ticket_id) AS tickets_sold,
    SUM(t.purchase_price) AS total_revenue
FROM events e
JOIN venues v ON e.venue_id = v.venue_id
JOIN ticket_tiers tt ON e.event_id = tt.event_id
LEFT JOIN tickets t ON tt.tier_id = t.tier_id 
    AND t.ticket_status IN ('purchased', 'used')
WHERE e.event_status != 'cancelled'
GROUP BY e.event_id, e.event_name, e.event_date, 
         v.venue_name, tt.tier_name
ORDER BY e.event_date, total_revenue DESC;
EOF

echo ""
print_subheader "EXPLAIN Output"
execute_sql "EXPLAIN 
SELECT 
    e.event_id, e.event_name, e.event_date,
    v.venue_name, tt.tier_name,
    COUNT(t.ticket_id) AS tickets_sold,
    SUM(t.purchase_price) AS total_revenue
FROM events e
JOIN venues v ON e.venue_id = v.venue_id
JOIN ticket_tiers tt ON e.event_id = tt.event_id
LEFT JOIN tickets t ON tt.tier_id = t.tier_id 
    AND t.ticket_status IN ('purchased', 'used')
WHERE e.event_status != 'cancelled'
GROUP BY e.event_id, e.event_name, e.event_date, 
         v.venue_name, tt.tier_name
ORDER BY e.event_date, total_revenue DESC;"

echo ""
print_info "Key Observations:"
echo "  - JOIN type: Should show 'ref' or 'eq_ref' for indexed joins"
echo "  - Key used: Should use foreign key indexes (fk_event_venue, fk_tier_event, etc.)"
echo "  - Rows examined: Lower is better"
echo ""

# ============================================================================
# QUERY 2: Customer Order History (Indexed vs Non-indexed)
# ============================================================================

print_header "Query 2: Customer Order History"

print_subheader "Query"
cat << 'EOF'
SELECT 
    c.customer_id, c.email, c.loyalty_tier,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_status = 'confirmed'
WHERE c.customer_id = 1
GROUP BY c.customer_id, c.email, c.loyalty_tier;
EOF

echo ""
print_subheader "EXPLAIN Output"
execute_sql "EXPLAIN 
SELECT 
    c.customer_id, c.email, c.loyalty_tier,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id 
    AND o.order_status = 'confirmed'
WHERE c.customer_id = 1
GROUP BY c.customer_id, c.email, c.loyalty_tier;"

echo ""
print_info "Key Observations:"
echo "  - Should use PRIMARY key on customers (const access)"
echo "  - Should use idx_order_customer_date on orders table"
echo "  - Type 'const' or 'ref' indicates efficient index usage"
echo ""

# ============================================================================
# QUERY 3: Fraud Detection (Complex WHERE with Subqueries)
# ============================================================================

print_header "Query 3: Fraud Pattern Detection"

print_subheader "Query"
cat << 'EOF'
SELECT 
    c.customer_id, c.email,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'confirmed'
  AND o.order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY c.customer_id, c.email
HAVING order_count >= 2 AND total_spent > 1000
ORDER BY total_spent DESC;
EOF

echo ""
print_subheader "EXPLAIN Output"
execute_sql "EXPLAIN 
SELECT 
    c.customer_id, c.email,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'confirmed'
  AND o.order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY c.customer_id, c.email
HAVING order_count >= 2 AND total_spent > 1000
ORDER BY total_spent DESC;"

echo ""
print_info "Key Observations:"
echo "  - Should use idx_order_status_date for filtering by status and date"
echo "  - Using filesort for ORDER BY is acceptable for small result sets"
echo "  - Using temporary table for GROUP BY is common"
echo ""

# ============================================================================
# INDEX USAGE STATISTICS
# ============================================================================

print_header "Index Usage Statistics"

print_subheader "Indexes on Orders Table"
execute_sql "SHOW INDEX FROM orders;"

echo ""
print_subheader "Indexes on Tickets Table"
execute_sql "SHOW INDEX FROM tickets;"

echo ""
print_subheader "Indexes on Events Table"
execute_sql "SHOW INDEX FROM events;"

# ============================================================================
# PERFORMANCE COMPARISON: With vs Without Index
# ============================================================================

print_header "Performance Comparison: Index Impact"

print_info "Temporarily dropping idx_order_customer_date to show impact..."

# Drop index
execute_sql "DROP INDEX idx_order_customer_date ON orders;" 2>/dev/null || true

echo ""
print_subheader "EXPLAIN WITHOUT Index"
execute_sql "EXPLAIN 
SELECT * FROM orders 
WHERE customer_id = 1 
ORDER BY order_date DESC;"

echo ""
print_info "Recreating index..."
execute_sql "CREATE INDEX idx_order_customer_date ON orders(customer_id, order_date DESC);"

echo ""
print_subheader "EXPLAIN WITH Index"
execute_sql "EXPLAIN 
SELECT * FROM orders 
WHERE customer_id = 1 
ORDER BY order_date DESC;"

echo ""
print_info "Comparison:"
echo "  WITHOUT index: Full table scan (type=ALL), examines all rows"
echo "  WITH index: Index scan (type=ref), examines only matching rows"
echo "  Result: Significant performance improvement with index"
echo ""

# ============================================================================
# COVERING INDEX DEMONSTRATION
# ============================================================================

print_header "Covering Index Demonstration"

print_subheader "Query Using Covering Index"
cat << 'EOF'
SELECT customer_id, order_status, order_date, total_amount
FROM orders
WHERE customer_id = 1 AND order_status = 'confirmed'
ORDER BY order_date DESC;
EOF

echo ""
print_subheader "EXPLAIN Output"
execute_sql "EXPLAIN 
SELECT customer_id, order_status, order_date, total_amount
FROM orders
WHERE customer_id = 1 AND order_status = 'confirmed'
ORDER BY order_date DESC;"

echo ""
print_info "Key Observations:"
echo "  - Extra column may show 'Using index' = covering index (no table access needed)"
echo "  - All required columns are in the index itself"
echo "  - Fastest possible query execution"
echo ""

# ============================================================================
# SUMMARY
# ============================================================================

print_header "Performance Analysis Summary"

echo ""
print_success "Index Strategy Effectiveness:"
echo ""
echo "1. Foreign Key Indexes:"
echo "   - Enable efficient JOINs between tables"
echo "   - Type 'ref' or 'eq_ref' in EXPLAIN indicates good performance"
echo ""
echo "2. Composite Indexes:"
echo "   - Support multiple query patterns (WHERE + ORDER BY)"
echo "   - Example: idx_order_customer_date supports customer filtering and date sorting"
echo ""
echo "3. Covering Indexes:"
echo "   - Include all columns needed by query"
echo "   - Eliminate table access (fastest performance)"
echo ""
echo "4. Trade-offs:"
echo "   - Write Performance: Each index slows INSERT/UPDATE/DELETE by ~5-10%"
echo "   - Storage: Indexes consume additional disk space"
echo "   - Maintenance: Indexes need periodic optimization"
echo ""
echo "5. Recommendations:"
echo "   - Index columns used in WHERE, JOIN, ORDER BY clauses"
echo "   - Monitor slow query log to identify missing indexes"
echo "   - Remove unused indexes to improve write performance"
echo ""

print_success "Analysis complete!"
echo ""

