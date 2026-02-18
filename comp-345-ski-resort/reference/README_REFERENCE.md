# Event Ticketing System - Reference Implementation

This folder contains a **complete reference implementation** of the Event Ticketing & Seating System from the COMP 345 Database Management Systems Final Project.

## Purpose

This reference implementation serves as a **guide and example** for building your own database project. It demonstrates:

- ✅ Complete project structure matching assignment requirements
- ✅ All required SQL files (01_schema.sql through 08_transactions.sql)
- ✅ Proper normalization (3NF/BCNF)
- ✅ Business logic implementation (functions, procedures, triggers)
- ✅ Performance optimization (indexes with EXPLAIN analysis)
- ✅ ACID transaction demonstrations
- ✅ Comprehensive documentation

## How to Use This Reference

### ⚠️ Important Notes

1. **Do NOT copy directly** - This is a reference for understanding structure and best practices
2. **Adapt to your domain** - You're building a **Ski Resort** system, not an event ticketing system
3. **Use as a guide** - Study the patterns, constraints, and query structures
4. **Learn from examples** - See how complex queries, triggers, and transactions are implemented

### Key Files to Study

#### SQL Files (`sql/` directory)
- **01_schema.sql** - Study table design, constraints, data types, and relationships
- **02_seed.sql** - See how to populate tables with realistic sample data
- **03_views.sql** - Examples of reporting and security views
- **04_functions.sql** - Stored functions and procedures for business logic
- **05_triggers.sql** - Trigger patterns for data validation and business rules
- **06_indexes.sql** - Indexing strategy with rationale
- **07_queries.sql** - Complex query examples (JOINs, window functions, CTEs)
- **08_transactions.sql** - ACID property demonstrations

#### Scripts (`scripts/` directory)
- **load.py / load.sh** - Idempotent database setup scripts
- **explain.py / explain.sh** - Performance analysis scripts

#### Documentation (`docs/` directory)
- **design_rationale.md** - Complete design documentation (requirements, normalization, etc.)
- **TESTING_GUIDE.md** - Testing and validation procedures
- **ERD images** - Entity-Relationship Diagrams

## Mapping to Your Ski Resort Project

While this reference is for **Event Ticketing**, you can adapt the patterns to your **Ski Resort** system:

| Event Ticketing | → | Ski Resort Equivalent |
|-----------------|---|----------------------|
| Venues | → | Ski Resorts / Mountains |
| Sections | → | Ski Trails / Areas |
| Seats | → | Lift Capacity / Slopes |
| Events | → | Ski Days / Seasons |
| Ticket Tiers | → | Pass Types (Day, Season, Premium) |
| Customers | → | Skiers / Guests |
| Orders | → | Pass Purchases / Rentals |
| Tickets | → | Lift Passes / Equipment Rentals |
| Promo Codes | → | Discount Codes / Packages |
| Refunds | → | Cancellations / Refunds |

## Project Requirements Checklist

Use this reference to ensure your project includes:

- [ ] **8-12 core entities** (this reference has 12)
- [ ] **3+ many-to-one relationships**
- [ ] **2+ many-to-many relationships** (with bridge tables)
- [ ] **3+ CHECK constraints**
- [ ] **100+ sample rows** across all tables
- [ ] **1 table with 50+ rows**
- [ ] **2+ bridge tables** populated
- [ ] **3+ views** (at least one security view)
- [ ] **2+ stored procedures/functions**
- [ ] **2+ triggers**
- [ ] **10+ complex queries** (JOINs, window functions, CTEs, correlated subqueries)
- [ ] **Indexing strategy** with EXPLAIN analysis
- [ ] **Transaction demonstrations** (08_transactions.sql)

## Running the Reference Implementation

If you want to explore the reference implementation:

```bash
# Navigate to reference directory
cd reference

# Set MySQL credentials
export MYSQL_USER=root
export MYSQL_PASSWORD=your_password

# Run setup (Python)
python scripts/load.py

# Or run setup (Shell)
./scripts/load.sh

# Run queries
mysql -u root -p event_ticketing < sql/07_queries.sql

# Test transactions
mysql -u root -p event_ticketing < sql/08_transactions.sql

# Performance analysis
python scripts/explain.py
```

## Learning Objectives

By studying this reference, you should understand:

1. **Schema Design**: How to structure tables, relationships, and constraints
2. **Normalization**: How to achieve 3NF/BCNF and document functional dependencies
3. **Business Logic**: How to implement rules using triggers, functions, and procedures
4. **Performance**: How to design indexes and analyze query performance
5. **Transactions**: How to demonstrate ACID properties
6. **Documentation**: How to document design decisions and testing procedures

## Questions to Consider

As you review this reference, ask yourself:

- How would I adapt these patterns for a ski resort domain?
- What entities would I need for ski lifts, trails, passes, rentals?
- What business rules apply to ski resort operations?
- How would I model season passes vs. day passes?
- What reporting needs would a ski resort have?

---

**Remember**: This is a **reference**, not a template. Your ski resort project should be **your own work**, adapted to the ski resort domain with your own design decisions and implementation.

