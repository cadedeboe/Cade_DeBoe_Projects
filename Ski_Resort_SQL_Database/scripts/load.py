#!/usr/bin/env python3

"""
============================================================================
Ski Resort Management System - Database Load Script (Python)
COMP 345 Final Project
Purpose: One-command database setup and data loading

IMPORTANT: This script is IDEMPOTENT - it drops and recreates the database
           on every run to ensure a clean slate. All existing data will be lost!
============================================================================
"""

import os
import sys
import mysql.connector
from mysql.connector import Error
from pathlib import Path

# ANSI color codes
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

# Configuration
DB_CONFIG = {
    'host': os.getenv('MYSQL_HOST', 'localhost'),
    'port': int(os.getenv('MYSQL_PORT', '3306')),
    'user': os.getenv('MYSQL_USER', 'root'),
    'password': os.getenv('MYSQL_PASSWORD', ''),
    'database': 'ski_resort'
}

# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
SQL_DIR = PROJECT_ROOT / 'sql'

def print_header(message):
    """Print a formatted header"""
    print(f"{Colors.BLUE}{'=' * 76}{Colors.NC}")
    print(f"{Colors.BLUE}{message}{Colors.NC}")
    print(f"{Colors.BLUE}{'=' * 76}{Colors.NC}")

def print_success(message):
    """Print a success message"""
    print(f"{Colors.GREEN}✓ {message}{Colors.NC}")

def print_error(message):
    """Print an error message"""
    print(f"{Colors.RED}✗ {message}{Colors.NC}")

def print_info(message):
    """Print an info message"""
    print(f"{Colors.YELLOW}ℹ {message}{Colors.NC}")

def check_mysql_connection():
    """Check if MySQL is accessible"""
    print_info("Checking MySQL connection...")

    try:
        # Try to connect without database first
        config = DB_CONFIG.copy()
        config.pop('database', None)

        connection = mysql.connector.connect(**config)

        if connection.is_connected():
            print_success("MySQL connection successful")
            connection.close()
            return True
    except Error as e:
        print_error(f"Cannot connect to MySQL: {e}")
        print_info("Please check your MySQL credentials and ensure MySQL is running")
        print_info("Set environment variables: MYSQL_USER, MYSQL_PASSWORD, MYSQL_HOST, MYSQL_PORT")
        return False

def drop_database():
    """Drop the database if it exists (for idempotent behavior)"""
    print_info("Ensuring clean slate by dropping existing database...")

    try:
        # Connect without specifying database
        config = DB_CONFIG.copy()
        config.pop('database', None)

        connection = mysql.connector.connect(**config)
        cursor = connection.cursor()

        # Drop database if exists
        cursor.execute(f"DROP DATABASE IF EXISTS {DB_CONFIG['database']}")

        connection.commit()
        cursor.close()
        connection.close()

        print_success("Database dropped (if it existed) - starting fresh")
        return True

    except Error as e:
        print_error(f"Failed to drop database: {e}")
        return False

def execute_sql_file(filepath, description):
    """Execute a SQL file"""
    print_info(f"Executing: {description}")
    
    if not filepath.exists():
        print_error(f"File not found: {filepath}")
        return False
    
    try:
        # Read SQL file
        with open(filepath, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # Connect to MySQL
        config = DB_CONFIG.copy()
        # Don't specify database for schema creation
        if 'schema' in filepath.name:
            config.pop('database', None)
        
        connection = mysql.connector.connect(**config, allow_local_infile=True)
        cursor = connection.cursor()
        
        # Consume any unread results
        if connection.unread_result:
            cursor.fetchall()
        
        # Split SQL content into individual statements with proper DELIMITER handling
        statements = []
        current_statement = ''
        delimiter = ';'
        
        lines = sql_content.split('\n')
        i = 0
        
        while i < len(lines):
            line = lines[i].strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('--'):
                i += 1
                continue
            
            # Handle DELIMITER changes
            if line.upper().startswith('DELIMITER'):
                # Save any current statement before changing delimiter
                if current_statement.strip():
                    statements.append(current_statement.strip())
                    current_statement = ''
                
                # Change delimiter
                if len(line.split()) > 1:
                    delimiter = line.split()[1]
                i += 1
                continue
            
            # Add line to current statement
            current_statement += line + '\n'
            
            # Check if statement ends with current delimiter
            if line.endswith(delimiter):
                # Remove the delimiter from the statement
                stmt = current_statement.rstrip()
                if stmt.endswith(delimiter):
                    stmt = stmt[:-len(delimiter)].strip()
                
                if stmt:
                    statements.append(stmt)
                current_statement = ''
            
            i += 1
        
        # Add any remaining statement
        if current_statement.strip():
            final_stmt = current_statement.strip()
            if final_stmt.endswith(delimiter):
                final_stmt = final_stmt[:-len(delimiter)].strip()
            if final_stmt:
                statements.append(final_stmt)
        
        # Execute each statement
        for statement in statements:
            if statement.strip():
                try:
                    # Execute and commit immediately for each statement
                    cursor.execute(statement)
                    
                    # Consume any unread results
                    while cursor.nextset():
                        pass
                    
                    # Commit after each statement to avoid sync issues
                    connection.commit()
                except Error as e:
                    # Some statements might fail silently (like DROP IF EXISTS)
                    error_msg = str(e).lower()
                    if ('already exists' not in error_msg and 
                        'unknown database' not in error_msg and 
                        'duplicate entry' not in error_msg and
                        'table' not in error_msg or 'doesn\'t exist' not in error_msg):
                        print_error(f"Error executing statement: {e}")
                        print_error(f"Statement: {statement[:100]}...")
                        cursor.close()
                        connection.close()
                        return False
        
        cursor.close()
        connection.close()
        
        print_success(f"{description} completed")
        return True
        
    except Error as e:
        print_error(f"{description} failed: {e}")
        return False

def verify_database():
    """Verify database setup"""
    print_info("Verifying database setup...")
    
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        # Get object counts
        cursor.execute(f"""
            SELECT 
                (SELECT COUNT(*) FROM information_schema.tables 
                 WHERE table_schema = '{DB_CONFIG['database']}') AS tables,
                (SELECT COUNT(*) FROM information_schema.views 
                 WHERE table_schema = '{DB_CONFIG['database']}') AS views,
                (SELECT COUNT(*) FROM information_schema.routines 
                 WHERE routine_schema = '{DB_CONFIG['database']}' 
                 AND routine_type = 'PROCEDURE') AS procedures,
                (SELECT COUNT(*) FROM information_schema.routines 
                 WHERE routine_schema = '{DB_CONFIG['database']}' 
                 AND routine_type = 'FUNCTION') AS functions,
                (SELECT COUNT(*) FROM information_schema.triggers 
                 WHERE trigger_schema = '{DB_CONFIG['database']}') AS triggers
        """)
        
        result = cursor.fetchone()
        print_success(f"Database objects created: Tables: {result[0]}, Views: {result[1]}, "
                     f"Procedures: {result[2]}, Functions: {result[3]}, Triggers: {result[4]}")
        
        # Get row counts
        print_info("Verifying data loaded...")
        
        tables = ['Customers', 'Pass_Types', 'Instructors', 'Trails', 'Lifts',
                 'Lift_Access', 'Equipment', 'Lift_Tickets', 'Scheduled_Lessons',
                 'Rentals', 'Enrollments', 'Rental_Items', 'Maintenance_Staff',
                 'Lift_Maintenance_Logs', 'Equipment_Maintenance_Logs', 'Trail_Maintenance_Logs']
        
        print(f"\n{'Table':<30} {'Row Count':>10}")
        print("-" * 42)
        
        for table in tables:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {table}")
                count = cursor.fetchone()[0]
                print(f"{table:<30} {count:>10}")
            except Error as e:
                # Table might not exist yet (if views/functions/triggers not created)
                print(f"{table:<30} {'N/A':>10}")
        
        cursor.close()
        connection.close()
        
        return True
        
    except Error as e:
        print_error(f"Verification failed: {e}")
        return False

def main():
    """Main execution"""
    print_header("Ski Resort Management System - Database Setup")
    
    print()
    print_info("Configuration:")
    print(f"  Database: {DB_CONFIG['database']}")
    print(f"  Host: {DB_CONFIG['host']}:{DB_CONFIG['port']}")
    print(f"  User: {DB_CONFIG['user']}")
    print(f"  SQL Directory: {SQL_DIR}")
    print()
    
    # Check MySQL connection
    if not check_mysql_connection():
        sys.exit(1)

    # Drop existing database for idempotent behavior
    print()
    print_header("Step 0: Dropping Existing Database (if exists)")

    if not drop_database():
        print_error("Setup failed!")
        sys.exit(1)

    # Execute SQL files in order
    sql_files = [
        (SQL_DIR / '01_schema.sql', 'Schema creation (tables, constraints)'),
        (SQL_DIR / '02_seed.sql', 'Sample data insertion'),
    ]
    
    # Add optional files if they exist
    optional_files = [
        (SQL_DIR / '03_views.sql', 'View creation'),
        (SQL_DIR / '04_functions.sql', 'Functions and stored procedures'),
        (SQL_DIR / '05_triggers.sql', 'Trigger creation'),
        (SQL_DIR / '06_indexes.sql', 'Index creation'),
    ]
    
    # Add optional files if they exist
    for filepath, description in optional_files:
        if filepath.exists():
            sql_files.append((filepath, description))
    
    for i, (filepath, description) in enumerate(sql_files, 1):
        print()
        print_header(f"Step {i}: {description.split('(')[0].strip()}")
        
        if not execute_sql_file(filepath, description):
            print_error("Setup failed!")
            sys.exit(1)
    
    # Verify setup
    print()
    print_header("Verification")
    
    if not verify_database():
        print_error("Verification failed!")
        sys.exit(1)
    
    print()
    print_header("Setup Complete!")
    print_success(f"Database '{DB_CONFIG['database']}' is ready to use")
    print_info("You can now run queries, test transactions, or use the explain.py script")
    print()

if __name__ == '__main__':
    main()

