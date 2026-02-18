#!/bin/bash

# ============================================================================
# Event Ticketing & Seating System - Database Load Script
# COMP 345 Final Project Reference Implementation
# Purpose: One-command database setup and data loading
#
# IMPORTANT: This script is IDEMPOTENT - it drops and recreates the database
#            on every run to ensure a clean slate. All existing data will be lost!
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DB_NAME="event_ticketing"
DB_USER="${MYSQL_USER:-root}"
DB_PASSWORD="${MYSQL_PASSWORD:-}"
DB_HOST="${MYSQL_HOST:-localhost}"
DB_PORT="${MYSQL_PORT:-3306}"

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SQL_DIR="$PROJECT_ROOT/sql"

# ============================================================================
# Functions
# ============================================================================

print_header() {
    echo -e "${BLUE}============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================================${NC}"
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

# Check if MySQL is accessible
check_mysql() {
    print_info "Checking MySQL connection..."
    
    if [ -z "$DB_PASSWORD" ]; then
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -e "SELECT 1;" > /dev/null 2>&1
    else
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1
    fi
    
    if [ $? -eq 0 ]; then
        print_success "MySQL connection successful"
        return 0
    else
        print_error "Cannot connect to MySQL"
        print_info "Please check your MySQL credentials and ensure MySQL is running"
        print_info "Set environment variables: MYSQL_USER, MYSQL_PASSWORD, MYSQL_HOST, MYSQL_PORT"
        exit 1
    fi
}

# Execute SQL file
execute_sql_file() {
    local file=$1
    local description=$2
    
    print_info "Executing: $description"
    
    if [ ! -f "$file" ]; then
        print_error "File not found: $file"
        exit 1
    fi
    
    if [ -z "$DB_PASSWORD" ]; then
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" < "$file"
    else
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" < "$file"
    fi
    
    if [ $? -eq 0 ]; then
        print_success "$description completed"
    else
        print_error "$description failed"
        exit 1
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

print_header "Event Ticketing System - Database Setup"

echo ""
print_info "Configuration:"
echo "  Database: $DB_NAME"
echo "  Host: $DB_HOST:$DB_PORT"
echo "  User: $DB_USER"
echo "  SQL Directory: $SQL_DIR"
echo ""

# Check MySQL connection
check_mysql

echo ""
print_header "Step 0: Dropping Existing Database (if exists)"
print_info "Ensuring clean slate by dropping existing database..."

# Drop database if it exists
if [ -z "$DB_PASSWORD" ]; then
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -e "DROP DATABASE IF EXISTS $DB_NAME;" 2>&1
else
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "DROP DATABASE IF EXISTS $DB_NAME;" 2>&1
fi

if [ $? -eq 0 ]; then
    print_success "Database dropped (if it existed) - starting fresh"
else
    print_error "Failed to drop database"
    exit 1
fi

echo ""
print_header "Step 1: Creating Schema"
execute_sql_file "$SQL_DIR/01_schema.sql" "Schema creation (tables, constraints)"

echo ""
print_header "Step 2: Loading Sample Data"
execute_sql_file "$SQL_DIR/02_seed.sql" "Sample data insertion"

echo ""
print_header "Step 3: Creating Views"
execute_sql_file "$SQL_DIR/03_views.sql" "View creation"

echo ""
print_header "Step 4: Creating Functions & Procedures"
execute_sql_file "$SQL_DIR/04_functions.sql" "Functions and stored procedures"

echo ""
print_header "Step 5: Creating Triggers"
execute_sql_file "$SQL_DIR/05_triggers.sql" "Trigger creation"

echo ""
print_header "Step 6: Creating Indexes"
execute_sql_file "$SQL_DIR/06_indexes.sql" "Index creation"

echo ""
print_header "Verification"

# Verify database setup
print_info "Verifying database setup..."

if [ -z "$DB_PASSWORD" ]; then
    VERIFICATION=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -D"$DB_NAME" -N -e "
        SELECT CONCAT(
            'Tables: ', (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME'), ', ',
            'Views: ', (SELECT COUNT(*) FROM information_schema.views WHERE table_schema = '$DB_NAME'), ', ',
            'Procedures: ', (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = '$DB_NAME' AND routine_type = 'PROCEDURE'), ', ',
            'Functions: ', (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = '$DB_NAME' AND routine_type = 'FUNCTION'), ', ',
            'Triggers: ', (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema = '$DB_NAME')
        );
    ")
else
    VERIFICATION=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -D"$DB_NAME" -N -e "
        SELECT CONCAT(
            'Tables: ', (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME'), ', ',
            'Views: ', (SELECT COUNT(*) FROM information_schema.views WHERE table_schema = '$DB_NAME'), ', ',
            'Procedures: ', (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = '$DB_NAME' AND routine_type = 'PROCEDURE'), ', ',
            'Functions: ', (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = '$DB_NAME' AND routine_type = 'FUNCTION'), ', ',
            'Triggers: ', (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema = '$DB_NAME')
        );
    ")
fi

print_success "Database objects created: $VERIFICATION"

# Show data counts
print_info "Verifying data loaded..."

if [ -z "$DB_PASSWORD" ]; then
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -D"$DB_NAME" -t -e "
        SELECT 'Venues' as table_name, COUNT(*) as row_count FROM venues
        UNION ALL SELECT 'Sections', COUNT(*) FROM sections
        UNION ALL SELECT 'Seats', COUNT(*) FROM seats
        UNION ALL SELECT 'Customers', COUNT(*) FROM customers
        UNION ALL SELECT 'Events', COUNT(*) FROM events
        UNION ALL SELECT 'Ticket Tiers', COUNT(*) FROM ticket_tiers
        UNION ALL SELECT 'Promo Codes', COUNT(*) FROM promo_codes
        UNION ALL SELECT 'Orders', COUNT(*) FROM orders
        UNION ALL SELECT 'Tickets', COUNT(*) FROM tickets
        UNION ALL SELECT 'Event Seat Assignments', COUNT(*) FROM event_seat_assignments
        UNION ALL SELECT 'Refunds', COUNT(*) FROM refunds;
    "
else
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -D"$DB_NAME" -t -e "
        SELECT 'Venues' as table_name, COUNT(*) as row_count FROM venues
        UNION ALL SELECT 'Sections', COUNT(*) FROM sections
        UNION ALL SELECT 'Seats', COUNT(*) FROM seats
        UNION ALL SELECT 'Customers', COUNT(*) FROM customers
        UNION ALL SELECT 'Events', COUNT(*) FROM events
        UNION ALL SELECT 'Ticket Tiers', COUNT(*) FROM ticket_tiers
        UNION ALL SELECT 'Promo Codes', COUNT(*) FROM promo_codes
        UNION ALL SELECT 'Orders', COUNT(*) FROM orders
        UNION ALL SELECT 'Tickets', COUNT(*) FROM tickets
        UNION ALL SELECT 'Event Seat Assignments', COUNT(*) FROM event_seat_assignments
        UNION ALL SELECT 'Refunds', COUNT(*) FROM refunds;
    "
fi

echo ""
print_header "Setup Complete!"
print_success "Database '$DB_NAME' is ready to use"
print_info "You can now run queries, test transactions, or use the explain.sh script"
echo ""

