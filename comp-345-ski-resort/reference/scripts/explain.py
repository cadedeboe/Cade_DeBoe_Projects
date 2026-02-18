#!/usr/bin/env python3

"""
============================================================================
Event Ticketing & Seating System - EXPLAIN/ANALYZE Script (Python)
COMP 345 Final Project Reference Implementation
Purpose: Demonstrate query performance with and without indexes
============================================================================
"""

import os
import sys
import mysql.connector
from mysql.connector import Error
from tabulate import tabulate

# ANSI color codes
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    NC = '\033[0m'

# Configuration
DB_CONFIG = {
    'host': os.getenv('MYSQL_HOST', 'localhost'),
    'port': int(os.getenv('MYSQL_PORT', '3306')),
    'user': os.getenv('MYSQL_USER', 'root'),
    'password': os.getenv('MYSQL_PASSWORD', ''),
    'database': 'event_ticketing'
}

def print_header(message):
    """Print a formatted header"""
    print(f"{Colors.BLUE}{'=' * 76}{Colors.NC}")
    print(f"{Colors.BLUE}{message}{Colors.NC}")
    print(f"{Colors.BLUE}{'=' * 76}{Colors.NC}")

def print_subheader(message):
    """Print a formatted subheader"""
    print(f"{Colors.MAGENTA}--- {message} ---{Colors.NC}")

def print_success(message):
    """Print a success message"""
    print(f"{Colors.GREEN}✓ {message}{Colors.NC}")

def print_error(message):
    """Print an error message"""
    print(f"{Colors.RED}✗ {message}{Colors.NC}")

def print_info(message):
    """Print an info message"""
    print(f"{Colors.YELLOW}ℹ {message}{Colors.NC}")

def execute_query(query, fetch_all=True):
    """Execute a query and return results"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        cursor.execute(query)
        
        if fetch_all:
            results = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description] if cursor.description else []
        else:
            results = None
            columns = []
        
        cursor.close()
        connection.close()
        
        return results, columns
        
    except Error as e:
        print_error(f"Query execution failed: {e}")
        return None, None

def display_results(results, columns):
    """Display query results in a formatted table"""
    if results and columns:
        print(tabulate(results, headers=columns, tablefmt='grid'))
    elif results:
        for row in results:
            print(row)

def analyze_query_1():
    """Analyze Query 1: Event Revenue Summary"""
    print_header("Query 1: Event Revenue Summary (4-table JOIN)")
    
    query = """
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
    ORDER BY e.event_date, total_revenue DESC
    """
    
    print_subheader("Query")
    print(query)
    
    print()
    print_subheader("EXPLAIN Output")
    
    explain_query = f"EXPLAIN {query}"
    results, columns = execute_query(explain_query)
    
    if results:
        display_results(results, columns)
    
    print()
    print_info("Key Observations:")
    print("  - JOIN type: Should show 'ref' or 'eq_ref' for indexed joins")
    print("  - Key used: Should use foreign key indexes")
    print("  - Rows examined: Lower is better")
    print()

def analyze_query_2():
    """Analyze Query 2: Customer Order History"""
    print_header("Query 2: Customer Order History")
    
    query = """
    SELECT 
        c.customer_id, c.email, c.loyalty_tier,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id 
        AND o.order_status = 'confirmed'
    WHERE c.customer_id = 1
    GROUP BY c.customer_id, c.email, c.loyalty_tier
    """
    
    print_subheader("Query")
    print(query)
    
    print()
    print_subheader("EXPLAIN Output")
    
    explain_query = f"EXPLAIN {query}"
    results, columns = execute_query(explain_query)
    
    if results:
        display_results(results, columns)
    
    print()
    print_info("Key Observations:")
    print("  - Should use PRIMARY key on customers (const access)")
    print("  - Should use idx_order_customer_date on orders table")
    print("  - Type 'const' or 'ref' indicates efficient index usage")
    print()

def analyze_query_3():
    """Analyze Query 3: Fraud Detection"""
    print_header("Query 3: Fraud Pattern Detection")
    
    query = """
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
    ORDER BY total_spent DESC
    """
    
    print_subheader("Query")
    print(query)
    
    print()
    print_subheader("EXPLAIN Output")
    
    explain_query = f"EXPLAIN {query}"
    results, columns = execute_query(explain_query)
    
    if results:
        display_results(results, columns)
    
    print()
    print_info("Key Observations:")
    print("  - Should use idx_order_status_date for filtering")
    print("  - Using filesort for ORDER BY is acceptable for small result sets")
    print("  - Using temporary table for GROUP BY is common")
    print()

def show_index_statistics():
    """Show index statistics for key tables"""
    print_header("Index Usage Statistics")
    
    tables = ['orders', 'tickets', 'events']
    
    for table in tables:
        print_subheader(f"Indexes on {table.capitalize()} Table")
        
        query = f"SHOW INDEX FROM {table}"
        results, columns = execute_query(query)
        
        if results:
            display_results(results, columns)
        
        print()

def demonstrate_index_impact():
    """Demonstrate the impact of indexes on query performance"""
    print_header("Performance Comparison: Index Impact")
    
    print_info("Temporarily dropping idx_order_customer_date to show impact...")
    
    # Drop index
    try:
        execute_query("DROP INDEX idx_order_customer_date ON orders", fetch_all=False)
    except:
        pass
    
    print()
    print_subheader("EXPLAIN WITHOUT Index")
    
    query = "SELECT * FROM orders WHERE customer_id = 1 ORDER BY order_date DESC"
    explain_query = f"EXPLAIN {query}"
    results, columns = execute_query(explain_query)
    
    if results:
        display_results(results, columns)
    
    print()
    print_info("Recreating index...")
    execute_query("CREATE INDEX idx_order_customer_date ON orders(customer_id, order_date DESC)", 
                 fetch_all=False)
    
    print()
    print_subheader("EXPLAIN WITH Index")
    
    results, columns = execute_query(explain_query)
    
    if results:
        display_results(results, columns)
    
    print()
    print_info("Comparison:")
    print("  WITHOUT index: Full table scan (type=ALL), examines all rows")
    print("  WITH index: Index scan (type=ref), examines only matching rows")
    print("  Result: Significant performance improvement with index")
    print()

def demonstrate_covering_index():
    """Demonstrate covering index benefits"""
    print_header("Covering Index Demonstration")
    
    query = """
    SELECT customer_id, order_status, order_date, total_amount
    FROM orders
    WHERE customer_id = 1 AND order_status = 'confirmed'
    ORDER BY order_date DESC
    """
    
    print_subheader("Query Using Covering Index")
    print(query)
    
    print()
    print_subheader("EXPLAIN Output")
    
    explain_query = f"EXPLAIN {query}"
    results, columns = execute_query(explain_query)
    
    if results:
        display_results(results, columns)
    
    print()
    print_info("Key Observations:")
    print("  - Extra column may show 'Using index' = covering index")
    print("  - All required columns are in the index itself")
    print("  - Fastest possible query execution")
    print()

def print_summary():
    """Print performance analysis summary"""
    print_header("Performance Analysis Summary")
    
    print()
    print_success("Index Strategy Effectiveness:")
    print()
    print("1. Foreign Key Indexes:")
    print("   - Enable efficient JOINs between tables")
    print("   - Type 'ref' or 'eq_ref' in EXPLAIN indicates good performance")
    print()
    print("2. Composite Indexes:")
    print("   - Support multiple query patterns (WHERE + ORDER BY)")
    print("   - Example: idx_order_customer_date supports customer filtering and date sorting")
    print()
    print("3. Covering Indexes:")
    print("   - Include all columns needed by query")
    print("   - Eliminate table access (fastest performance)")
    print()
    print("4. Trade-offs:")
    print("   - Write Performance: Each index slows INSERT/UPDATE/DELETE by ~5-10%")
    print("   - Storage: Indexes consume additional disk space")
    print("   - Maintenance: Indexes need periodic optimization")
    print()
    print("5. Recommendations:")
    print("   - Index columns used in WHERE, JOIN, ORDER BY clauses")
    print("   - Monitor slow query log to identify missing indexes")
    print("   - Remove unused indexes to improve write performance")
    print()

def main():
    """Main execution"""
    print_header("Query Performance Analysis with EXPLAIN")
    
    print()
    print_info("This script demonstrates the impact of indexes on query performance")
    print_info(f"Database: {DB_CONFIG['database']} @ {DB_CONFIG['host']}:{DB_CONFIG['port']}")
    print()
    
    # Run analyses
    analyze_query_1()
    analyze_query_2()
    analyze_query_3()
    show_index_statistics()
    demonstrate_index_impact()
    demonstrate_covering_index()
    print_summary()
    
    print_success("Analysis complete!")
    print()

if __name__ == '__main__':
    # Check if tabulate is installed
    try:
        from tabulate import tabulate
    except ImportError:
        print_error("Required package 'tabulate' not found")
        print_info("Install it with: pip install tabulate")
        sys.exit(1)
    
    main()

