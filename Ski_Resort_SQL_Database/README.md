# Ski Resort System

**COMP 345 Database Management Systems - Final Project Reference Implementation**

---

## Table of Contents

- [Ski Resort System](#ski-resort-system)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [System Requirements](#system-requirements)
    - [Required Software](#required-software)
  - [Quick Start](#quick-start)
    - [Expected Output](#expected-output)

---

## Overview

This project implements a ski resort management system that handles:

- **Ski Pass Management**: Issuing and tracking ski passes for visitors.
- **Lift Operations**: Managing ski lift usage and maintenance.
- **Resort Facilities**: Overseeing various resort amenities and services.
- **User Management**: Handling user accounts and permissions.
- **Reporting**: Generating reports on resort usage and performance.
- **Database Integration**: Storing and retrieving data using a relational database.

---

## System Requirements

### Required Software

- **MySQL**: Version 8.0 or higher
- **Python 3.8+**: For running scripts
- **Git**: For version control

## Quick Start

After cloning the repository, follow these steps to set up the system:
```bash
# 1. Setup Python Virtual Environment
python3 -m venv env

# 2. Activate Virtual Environment
# On MacOS/Linux
source env/bin/activate # OR
# On Windows
.\env\Scripts\activate.bat

# 3. Install Required Python Packages
pip install -r requirements.txt

# 4. Setup MySQL Credentials
export MYSQL_USER=root
export MYSQL_PASSWORD=your_password

# 5. Run the setup script
python3 scripts/load.py

# 6. Verify installation
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW TABLES IN ski_resort;"
```

### Expected Output

After successful setup, you should see:

```
✓ MySQL connection successful
✓ Database dropped (if it existed) - starting fresh
✓ Schema creation (tables, constraints) completed
✓ Sample data insertion completed
✓ Database objects created: Tables: 16, Views: 0, Procedures: 0, Functions: 0, Triggers: 0

Table                           Row Count
------------------------------------------
Customers                              50
Pass_Types                             10
Instructors                            12
Trails                                 15
Lifts                                  12
Lift_Access                            26
Equipment                              41
Lift_Tickets                           40
Scheduled_Lessons                      15
Rentals                                20
Enrollments                            60
Rental_Items                           77
Maintenance_Staff                      15
Lift_Maintenance_Logs                  12
Equipment_Maintenance_Logs             15
Trail_Maintenance_Logs                 15
```

Here is the documentation for your `README.md`. You can copy and paste this section directly into your project's documentation file.

It covers the **Why** (ACID/Constraints), the **How** (Running the script), and the **What** (Interpreting results).

---

## 🧪 Testing & Validation (`08_transactions.sql`)

To ensure data integrity and reliability, we have implemented a comprehensive transaction test script. This script verifies **ACID properties**, **Business Logic Triggers**, and **Database Constraints** by attempting both valid and invalid operations.

### **1. How to Run the Tests**

You can run the transaction tests directly using the MySQL command line tool.

**Note:** We use the `-f` (force) flag because some tests are *designed to fail* (to prove our security constraints work). The flag allows the script to continue running after encountering these expected errors.

```bash
# Run from the project root directory
mysql -u root -p -f ski_resort < sql/08_transactions.sql

```

*(If on macOS/Linux and `mysql` is not in your path, use `/usr/local/mysql/bin/mysql` or your specific installation path)*

### **2. Test Coverage & Expected Results**

The script executes 5 distinct test scenarios. Below is the guide to interpreting the output.

| Test Case | Feature Tested | Concept | Description | Expected Outcome |
| --- | --- | --- | --- | --- |
| **Test 1** | `trg_prevent_overbooking` | **Consistency** | Attempts to add an 11th student to a class capped at 10. | **FAIL** (Error 1644: Lesson is at maximum capacity) |
| **Test 2** | `trg_after_enrollment...` | **Automation** | Enrolls and un-enrolls a student to verify the `CurrentEnrollment` counter updates automatically. | **PASS** (Counter toggles 0 → 1 → 0) |
| **Test 3** | Equipment Rental | **Atomicity** | Processes a rental inside a `START TRANSACTION` block. Updates inventory status and inserts rental records simultaneously. | **PASS** (Equipment status changes to 'Rented') |
| **Test 4** | Maintenance Safety | **Constraint** | Attempts to rent equipment that is flagged as 'Maintenance'. | **FAIL** (Error: Cannot rent equipment...) |
| **Test 5** | Equipment Return | **Atomicity** | Returns a rental item. Trigger should automatically release the specific equipment back to 'Available'. | **PASS** (Equipment status returns to 'Available') |

### **3. Sample Output**

When running the script, you will see output similar to this. Note that **ERROR messages are good** in Test 1 and Test 4—they prove the database is protecting itself.

```text
Test_Case
--- TEST 1: Prevent Lesson Overbooking (Trigger 1) ---
ERROR 1644 (45000) at line 20: Error: Cannot enroll. Lesson is at maximum capacity.
Verification
Check if enrollment count stayed at 1 (Should be 1): 1

Test_Case
--- TEST 2: Sync Enrollment Counts (Trigger 2) ---
Expect 1
1
Expect 0
0

Test_Case
--- TEST 3: Equipment Rental Automation (Trigger 3) ---
Expect Rented
Rented

Test_Case
--- TEST 4: Block Bad Rentals (Trigger 3 Safety) ---
Expect 0
0

Test_Case
--- TEST 5: Auto-Return Equipment (Trigger 4) ---
After Return (Available)
Available

```

### **4. ACID Compliance Rationale**

* **Atomicity:** demonstrated in **Test 3**, where inventory updates and rental record creation are wrapped in a single transaction. If one fails, both fail.
* **Consistency:** demonstrated in **Test 1**, where the database refuses to enter an invalid state (overbooked class) effectively enforcing the business rule.
* **Isolation:** implicit in the use of `START TRANSACTION`. Intermediate states (like a rental being processed) are not visible to other queries until `COMMIT` is executed.
* **Durability:** ensured by the database engine (InnoDB) defaults; once Test 3 confirms 'Rented', that state persists even in the event of a system crash.
