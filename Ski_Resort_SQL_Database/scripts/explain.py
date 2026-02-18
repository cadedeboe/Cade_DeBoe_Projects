#!/usr/bin/env python3

"""
============================================================================
Ski Resort Management System - EXPLAIN/ANALYZE Script (Python)
COMP 345 Final Project
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
    'password': os.getenv('MYSQL_PASSWORD', '123789'),
    'database': 'ski_resort'
}


# ---------------------------------------------------------------------------
# Helper printing functions
# ---------------------------------------------------------------------------

def print_header(message: str) -> None:
    print(f"{Colors.BLUE}{'=' * 76}{Colors.NC}")
    print(f"{Colors.BLUE}{message}{Colors.NC}")
    print(f"{Colors.BLUE}{'=' * 76}{Colors.NC}")


def print_subheader(message: str) -> None:
    print(f"{Colors.MAGENTA}--- {message} ---{Colors.NC}")


def print_success(message: str) -> None:
    print(f"{Colors.GREEN}✓ {message}{Colors.NC}")


def print_error(message: str) -> None:
    print(f"{Colors.RED}✗ {message}{Colors.NC}")


def print_info(message: str) -> None:
    print(f"{Colors.YELLOW}ℹ {message}{Colors.NC}")


# ---------------------------------------------------------------------------
# Core DB helpers
# ---------------------------------------------------------------------------

def execute_query(query: str, fetch_all: bool = True):
    """
    Execute a query and return (results, columns).

    For EXPLAIN / SHOW INDEX, fetch_all=True to display tabular output.
    For DDL (CREATE/DROP INDEX), use fetch_all=False.
    """
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        cursor.execute(query)

        if fetch_all:
            results = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description] if cursor.description else []
        else:
            results, columns = None, None

        cursor.close()
        connection.close()
        return results, columns

    except Error as e:
        print_error(f"Query execution failed: {e}")
        return None, None


def display_results(results, columns) -> None:
    if results and columns:
        print(tabulate(results, headers=columns, tablefmt='grid'))
    elif results:
        for row in results:
            print(row)


# ---------------------------------------------------------------------------
# Query 1: Lift ticket / pass revenue summary (multi-table join)
# ---------------------------------------------------------------------------

def analyze_query_1() -> None:
    """
    Analyze Query 1: Daily revenue per pass type (3-table JOIN).
    Demonstrates use of indexes on Lift_Tickets and Pass_Types.
    """
    print_header("Query 1: Daily Revenue by Pass Type (Lift_Tickets × Pass_Types × Customers)")

    query = """
    SELECT
        DATE(lt.PurchaseDate) AS RevenueDate,
        pt.PassTypeID,
        pt.PassName,
        pt.AgeGroup,
        pt.IsSeasonPass,
        COUNT(*) AS TicketsSold,
        SUM(lt.SalePrice) AS TotalRevenue
    FROM Lift_Tickets lt
    JOIN Pass_Types pt
        ON lt.PassTypeID = pt.PassTypeID
    JOIN Customers c
        ON lt.CustomerID = c.CustomerID
    WHERE lt.TicketStatus IN ('Active', 'Used')
    GROUP BY
        DATE(lt.PurchaseDate),
        pt.PassTypeID,
        pt.PassName,
        pt.AgeGroup,
        pt.IsSeasonPass
    ORDER BY
        RevenueDate,
        TotalRevenue DESC;
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
    print("  - JOIN types on Lift_Tickets → Pass_Types / Customers should be ref/eq_ref (FK indexes).")
    print("  - Key used on Lift_Tickets should include PassTypeID and CustomerID.")
    print("  - Rows examined on Lift_Tickets should be reduced by idx_ticket_pass_status and idx_ticket_customer_date (if present).")
    print()


# ---------------------------------------------------------------------------
# Query 2: Customer activity and spending (security / reporting query)
# ---------------------------------------------------------------------------

def analyze_query_2() -> None:
    """
    Analyze Query 2: Customer activity summary (tickets + lessons + rentals).
    Demonstrates selective access to a single customer and use of composite indexes.
    """
    print_header("Query 2: Customer Activity & Spending Summary")

    query = """
    SELECT
        c.CustomerID,
        c.Email,
        c.FirstName,
        c.LastName,
        COUNT(DISTINCT lt.TicketID) AS TicketsPurchased,
        COUNT(DISTINCT e.EnrollmentID) AS LessonsEnrolled,
        COUNT(DISTINCT r.RentalID) AS RentalsMade,
        COALESCE(SUM(lt.SalePrice), 0) AS TicketSpend,
        COALESCE(SUM(e.PaymentAmount), 0) AS LessonSpend,
        COALESCE(SUM(r.TotalPrice), 0) AS RentalSpend,
        COALESCE(SUM(lt.SalePrice), 0)
          + COALESCE(SUM(e.PaymentAmount), 0)
          + COALESCE(SUM(r.TotalPrice), 0) AS TotalSpend
    FROM Customers c
    LEFT JOIN Lift_Tickets lt
        ON c.CustomerID = lt.CustomerID
           AND lt.TicketStatus IN ('Active', 'Used', 'Expired')
    LEFT JOIN Enrollments e
        ON c.CustomerID = e.CustomerID
           AND e.PaymentStatus IN ('Paid', 'Refunded')
    LEFT JOIN Rentals r
        ON c.CustomerID = r.CustomerID
           AND r.RentalStatus IN ('Active', 'Completed', 'Overdue')
    WHERE c.CustomerID = 1
    GROUP BY
        c.CustomerID,
        c.Email,
        c.FirstName,
        c.LastName;
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
    print("  - Customers should use PRIMARY key lookup (type=const).")
    print("  - Lift_Tickets should use composite index on (CustomerID, PurchaseDate) or (CustomerID, TicketStatus).")
    print("  - Enrollments and Rentals should use composite indexes on (CustomerID, PaymentStatus/Status).")
    print()


# ---------------------------------------------------------------------------
# Query 3: Maintenance workload in the last 30 days
# ---------------------------------------------------------------------------

def analyze_query_3() -> None:
    """
    Analyze Query 3: Maintenance workload by staff over last 30 days.
    Uses all three maintenance log tables and Maintenance_Staff.
    """
    print_header("Query 3: Maintenance Workload (Last 30 Days)")

    query = """
    SELECT
        ms.StaffID,
        CONCAT(ms.FirstName, ' ', ms.LastName) AS StaffName,
        ms.Specialty,
        COUNT(DISTINCT lm.LogID) AS LiftTasks,
        COUNT(DISTINCT tm.LogID) AS TrailTasks,
        COUNT(DISTINCT em.LogID) AS EquipmentTasks,
        COUNT(DISTINCT lm.LogID)
          + COUNT(DISTINCT tm.LogID)
          + COUNT(DISTINCT em.LogID) AS TotalTasks,
        COUNT(CASE WHEN lm.Status IN ('Scheduled', 'In Progress') THEN 1 END)
          + COUNT(CASE WHEN tm.Status IN ('Scheduled', 'In Progress') THEN 1 END)
          + COUNT(CASE WHEN em.Status IN ('Scheduled', 'In Progress') THEN 1 END) AS OpenTasks
    FROM Maintenance_Staff ms
    LEFT JOIN Lift_Maintenance_Logs lm
        ON ms.StaffID = lm.StaffID
           AND lm.ScheduledDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    LEFT JOIN Trail_Maintenance_Logs tm
        ON ms.StaffID = tm.StaffID
           AND tm.ScheduledDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    LEFT JOIN Equipment_Maintenance_Logs em
        ON ms.StaffID = em.StaffID
           AND em.ScheduledDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY
        ms.StaffID,
        StaffName,
        ms.Specialty
    HAVING TotalTasks > 0
    ORDER BY
        OpenTasks DESC,
        TotalTasks DESC;
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
    print("  - Maintenance_Staff should use PRIMARY key (const) for ms.")
    print("  - Each *_Maintenance_Logs table should have indexes on (StaffID, ScheduledDate, Status).")
    print("  - This pattern is read-heavy; indexes greatly reduce examined rows.")
    print()


# ---------------------------------------------------------------------------
# Index statistics for key tables
# ---------------------------------------------------------------------------

def show_index_statistics() -> None:
    """Show SHOW INDEX output for key tables."""
    print_header("Index Usage Statistics (SHOW INDEX)")

    tables = [
        'Customers',
        'Lift_Tickets',
        'Pass_Types',
        'Scheduled_Lessons',
        'Enrollments',
        'Rentals',
        'Equipment',
        'Lift_Maintenance_Logs',
        'Trail_Maintenance_Logs',
        'Equipment_Maintenance_Logs'
    ]

    for table in tables:
        print_subheader(f"Indexes on {table}")
        query = f"SHOW INDEX FROM {table};"
        results, columns = execute_query(query)
        if results:
            display_results(results, columns)
        else:
            print_info(f"No index information returned for {table}.")
        print()


# ---------------------------------------------------------------------------
# Demonstrate impact of a composite index (drop / recreate)
# ---------------------------------------------------------------------------

def demonstrate_index_impact() -> None:
    """
    Demonstrate performance impact of composite index on Rentals:
      idx_rental_customer_date ON Rentals(CustomerID, RentalDate)

    NOTE: In this schema, the index is required by a foreign key, so we do not
    actually drop/recreate it. Instead, we show EXPLAIN and explain what would
    happen without the index.
    """
    print_header("Performance Comparison: Index Impact on Rentals (Customer History)")

    print_info("Using query: SELECT * FROM Rentals WHERE CustomerID = 1 ORDER BY RentalDate DESC")

    base_query = """
    SELECT *
    FROM Rentals
    WHERE CustomerID = 1
    ORDER BY RentalDate DESC;
    """

    explain_query = f"EXPLAIN {base_query}"

    print()
    print_subheader("EXPLAIN WITH idx_rental_customer_date (current schema)")
    results, columns = execute_query(explain_query)
    if results:
        display_results(results, columns)

    print()
    print_info("Index Impact Discussion:")
    print("  - In our design, idx_rental_customer_date supports foreign key and history lookups,")
    print("    so MySQL does not allow dropping it (it is tied to a constraint).")
    print("  - With this index present, EXPLAIN shows an index lookup on Rentals using")
    print("    idx_rental_customer_date (type=ref/range) instead of a full table scan.")
    print("  - Hypothetically, without this index MySQL would need to scan more rows or perform")
    print("    a less efficient lookup on CustomerID, especially as Rentals grows.")
    print("  - This is exactly the kind of composite index that makes time-ordered history")
    print("    queries (customer rental history) scalable.")
    print()


# ---------------------------------------------------------------------------
# Demonstrate covering index usage
# ---------------------------------------------------------------------------

def demonstrate_covering_index() -> None:
    """
    Demonstrate covering index for upcoming lessons dashboard.
    Assumes an index such as:
      idx_lesson_upcoming_dashboard ON Scheduled_Lessons(
          StartTime, LessonStatus, LessonID,
          LessonName, LessonType, MaxCapacity,
          CurrentEnrollment, InstructorID
      )
    """
    print_header("Covering Index Demonstration: Upcoming Lessons")

    query = """
    SELECT
        LessonID,
        LessonName,
        LessonType,
        LessonStatus,
        StartTime,
        EndTime,
        MaxCapacity,
        CurrentEnrollment,
        (MaxCapacity - CurrentEnrollment) AS SeatsRemaining
    FROM Scheduled_Lessons
    WHERE
        StartTime >= NOW()
        AND LessonStatus IN ('Scheduled', 'In Progress')
    ORDER BY
        StartTime,
        LessonName;
    """

    print_subheader("Query Using Covering Index on Scheduled_Lessons")
    print(query)

    print()
    print_subheader("EXPLAIN Output")

    explain_query = f"EXPLAIN {query}"
    results, columns = execute_query(explain_query)

    if results:
        display_results(results, columns)

    print()
    print_info("Key Observations:")
    print("  - With a covering index, Extra may show 'Using index'.")
    print("  - All selected columns can be read from the index without touching the table.")
    print("  - This is ideal for read-heavy dashboard-style queries.")
    print()


# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

def print_summary() -> None:
    print_header("Performance Analysis Summary")

    print()
    print_success("Index Strategy Effectiveness:")
    print()
    print("1. Foreign Key Indexes:")
    print("   - Enable efficient JOINs between core tables (Customers, Lift_Tickets, Pass_Types, Rentals, etc.).")
    print("   - EXPLAIN should show type='ref' or 'eq_ref' on these joins.")
    print()
    print("2. Composite Indexes:")
    print("   - Support common filter + sort patterns, e.g., (CustomerID, RentalDate).")
    print("   - Crucial for time-ordered history queries and dashboard slices.")
    print()
    print("3. Covering Indexes:")
    print("   - Include all columns needed by frequent SELECT queries.")
    print("   - EXPLAIN Extra='Using index' indicates index-only access.")
    print()
    print("4. Trade-offs:")
    print("   - Each index adds overhead on INSERT/UPDATE/DELETE.")
    print("   - Indexes consume additional disk space.")
    print("   - Need periodic review to drop unused or redundant indexes.")
    print()
    print("5. Recommendations:")
    print("   - Index columns used in WHERE, JOIN, and ORDER BY clauses.")
    print("   - Use EXPLAIN regularly to validate index usage.")
    print("   - Monitor slow queries and adjust indexes accordingly.")
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print_header("Query Performance Analysis with EXPLAIN (Ski Resort Management System)")

    print()
    print_info("This script demonstrates the impact of indexes on query performance.")
    print_info(f"Database: {DB_CONFIG['database']} @ {DB_CONFIG['host']}:{DB_CONFIG['port']}")
    print()

    analyze_query_1()
    analyze_query_2()
    analyze_query_3()
    show_index_statistics()
    demonstrate_index_impact()
    demonstrate_covering_index()
    print_summary()

    print()
    print_success("Analysis complete!")
    print()


if __name__ == '__main__':
    # Ensure tabulate is available
    try:
        from tabulate import tabulate  # noqa: F811 (re-import to match reference style)
    except ImportError:
        print_error("Required package 'tabulate' not found.")
        print_info("Install it with: pip install tabulate")
        sys.exit(1)

    main()
