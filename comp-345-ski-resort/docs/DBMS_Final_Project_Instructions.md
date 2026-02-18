# COMP 345
## Database Management Systems Design — Final Project
**Instructor:** Daniel Matlock

## 1) Overview

Design, build, and evaluate a small but realistic information system from end to end. You'll start with a real‑world scenario, model the data conceptually, translate it into a normalized relational schema, implement it in a relational DBMS, populate it with a small amount of example realistic data, and demonstrate correct functionality, performance, security, and reliability.

- **Team size:** 2–4 students total
- **Total points:** 100
- **Due:** Final exam week (submit by 11:59pm local time)
- **Accepted DBMS:** MySQL, PostgreSQL. If you use another DBMS, clear it with the instructor first.
- **Portability:** Your submission must be reproducible on a clean machine using only your repo/files and standard DBMS tooling (e.g., psql/mysql, Docker, or a simple run script).

## 2) Choose ONE Scenario (or propose your own)

Pick a domain that's rich enough to require multiple entities, relationships, constraints, and realistic queries. Feel free to adapt the prompts below.

### Campus Housing & Maintenance
Manage residence halls, rooms, students, assignments, RAs, maintenance requests, work orders, vendors, and billing.

- **Constraints:** capacity limits; overlapping room assignments disallowed; work orders must reference valid rooms; vendor insurance expiry dates.
- **Queries:** occupancy by hall/term; average time to close; RAs on duty schedule; rooms with repeated issues.

### Clinic Appointments & Referrals
Patients, providers, appointments, referrals, prescriptions, insurance, and payments.

- **Constraints:** provider license types; appointment overlaps; referral chains; medication interactions (basic rule set).
- **Queries:** no‑show rates by provider; utilization by specialty; common referral paths; average cost per visit.

### Event Ticketing & Seating
Venues, events, seat maps, ticket tiers, orders, customers, and promotions.

- **Constraints:** seat uniqueness; hold vs purchase windows; refund policies; promo code limits.
- **Queries:** revenue by event/tier; seat map heatmaps; conversion rates; fraud patterns (suspicious orders).

### Inventory, Orders, & Fulfillment (Retail/Wholesale)
Products, categories, vendors, inventory locations, purchase orders, customer orders, shipments, returns.

- **Constraints:** stock levels; reorder points; backorders; returns within policy windows.
- **Queries:** aging inventory; fill rate; on‑time shipment %; supplier performance.

### Or propose your own scenario
(must be approved) with comparable scope.

## 3) Minimum Functional Scope

Your system must include **8–12 core entities**, with at least **3 many‑to‑one** and **2 many‑to‑many** relationships (resolve M:N with bridge tables). Ensure:

- **Keys & Constraints:** Primary keys, foreign keys, NOT NULL, UNIQUE, and at least **3 CHECK** constraints reflecting business rules.
- **Cardinality & Optionality** clearly documented in your ERD (Crow's Foot notation preferred).
- **Normalization:** Show your reasoning from FDs → 3NF (or BCNF where applicable). Call out any intentional denormalization.
- **Data Volume:** ≥ **100 example total rows** across the schema; ≥ **1 table with 50+ rows**; ≥ **2 bridge tables** populated.
- **Workload:** Implement an application‑style workload as a set of SQL statements and stored logic (see §6).

## 4) Deliverables (What to Submit)

Submit a single folder (or repo) with this structure:

```
project_root/
  README.md                   # setup, run, and grading instructions
  /docs
    erd.png                   # exported ERD
    design_rationale.(md or pdf)      # 3–6 pages: requirements → model → schema
  /sql
    01_schema.sql             # DDL: tables, types, constraints
    02_seed.sql               # sample data inserts or CSV loader
    03_views.sql              # all views
    04_functions.sql          # stored procs/functions
    05_triggers.sql           # business-rule triggers
    06_indexes.sql            # index creation w/ comments
    07_queries.sql            # required workload queries
    08_transactions.sql       # demo of ACID & isolation behavior
  /scripts
    load.sh or load.py       # one‑command setup
    explain.sh or explain.py # runs EXPLAIN/ANALYZE for selected 
  /data
    *.csv (if used)
```

### Repro requirement

On a blank machine, the grader must be able to run:

- `./scripts/load.(sh or py)` → creates DB, runs `01_schema.sql` … `06_indexes.sql`, loads data.
- `./scripts/explain.(sh or py)` → prints baseline vs tuned performance.
- `mysql -u root -p event_ticketing < sql/07_queries.sql` → prints query results from database.
- `mysql -u root -p event_ticketing < sql/08_transactions.sql` → transactions to test checks, triggers, and ACID functionality of implementation.

These queries should be **idempotent** (meaning it can be run multiple times without errors). For example, the load file should tear down the database each time so the same result is created each time.

## 5) Conceptual & Logical Design (30 pts)

### 5.1 Requirements (5 pts)
Narrative of scope, actors, events, and key business rules.

### 5.2 ERD (10 pts)
Entities with attributes (key vs non‑key), relationships with cardinality and participation, weak entities (if any), associative entities for M:N. Should be an image export from a tool like DBeaver, DataGrip, etc.

### 5.3 Normalization (10 pts)
- List key **functional dependencies** (FDs).
- Show steps to **3NF** (or BCNF where applicable). Identify any anomalies avoided.
- Justify selective denormalization (if used).

### 5.4 Mapping to Relational Schema (5 pts)
Clear mapping from ERD to relations with PK/FK/constraints.

## 6) Physical Implementation & Workload (40 pts)

### 6.1 DDL & Constraints (10 pts)
Clean DDL with meaningful data types (domains/enums where helpful).
Use NOT NULL/UNIQUE/CHECK/FK constraints thoughtfully; include ON DELETE/UPDATE rules.

### 6.2 Data Loading (5 pts)
Populate with realistic volumes. Provide either INSERTs or bulk load from CSV. Handle referential order.

### 6.3 Views, Functions, Triggers (10 pts)
- ≥ **3 views** (at least one security or reporting view).
- ≥ **2 stored procedures/functions** implementing business logic.
- ≥ **2 triggers** enforcing rules not expressible with simple constraints.

### 6.4 Query Workload (15 pts)
Provide ≥ 10 representative queries that an app/analyst would run. Must include:
- Multi‑table joins (≥ 3 tables at least once).
- Aggregation & grouping; at least one **window function**.
- Subqueries/CTEs; at least one **correlated** subquery or **EXISTS**.
- A **report** query producing grouped KPIs.

## 7) Performance & Indexing (15 pts)

- Create a sensible **indexing strategy** (b‑tree by default; consider composite/partial indexes).
- Use **EXPLAIN (ANALYZE, BUFFERS)** (or MySQL EXPLAIN + timing) on **3 key queries**.
- Provide a before/after comparison and **justify** each index (selectivity, access pattern).
- Discuss any **trade‑offs** (write overhead, storage).

## 8) Integrity & Reliability (10 pts)

### 8.1 Implementation Requirements (5 pts)
- **Input validation** at the DB layer (CHECKs, FKs, triggers).
- **Transaction management** ensuring ACID properties are maintained.
- **Error handling** and appropriate rollback behavior when constraints are violated.

### 8.2 Testing via `08_transactions.sql` (5 pts)

The `08_transactions.sql` file serves as the primary demonstration and testing mechanism for this section. Provide ≥ **5 representative transaction test cases** that would be run by the application. The file must:

- **Execute end-to-end** without manual intervention or errors, producing clear output.
- **Include pass/fail test cases** demonstrating both successful (COMMIT) and failed (ROLLBACK) transactions with explicit output indicating test results.
- **Be idempotent** — executable multiple times without errors or state changes (clean up test data via ROLLBACK or DELETE).
- **Demonstrate ACID properties:**
  - **Atomicity:** Multi-statement transactions that fully complete or fully rollback.
  - **Consistency:** Transactions respecting constraints, triggers, and business rules.
  - **Isolation:** Isolation level behavior (e.g., READ COMMITTED, REPEATABLE READ).
  - **Durability:** Committed transactions persist across queries.
- **Test comprehensively:** Constraint violations (CHECK, FK, UNIQUE, NOT NULL), trigger rules, multi-table atomicity, savepoints, and isolation levels.
- **Document clearly:** Comment each test case with what's being tested, expected outcome, and actual result.

## 9) Documentation & Presentation (5 pts)

- **README.md** with clear setup instructions, DB credentials (if local), and run steps.
- **Design rationale** (3–6 pages PDF) explaining key decisions, assumptions, and limitations.
- A brief **demo video (≤5 min)** or slide deck is welcome (optional) if it clarifies usage.

## 10) Milestones & Suggested Timeline

- **Milestone 1 (Design)** — Requirements draft + ERD + FDs + normalization proof.
- **Milestone 2 (Implementation)** — DDL + seed data + core queries running.
- **Milestone 3 (Hardening)** — Triggers/functions, transactions, indexing, security.
- **Final Submission** — All docs, scripts, and reproducibility checks pass.

## 11) Grading Rubric (100 pts total)

- **Conceptual & Logical Design (30 pts)**
  - Requirements (5) • ERD quality (10) • Normalization/FDs (10) • Mapping (5)
- **Physical Implementation & Workload (40 pts)**
  - DDL/constraints (10) • Data loading (5) • Views/functions/triggers (10) • Queries (15)
- **Performance & Indexing (15 pts)**
  - Index choices (6) • Evidence via EXPLAIN/ANALYZE (6) • Discussion (3)
- **Integrity & Reliability (10 pts)**
  - Implementation (5) • Transaction testing via `08_transactions.sql` (5)
- **Documentation & Presentation (5 pts)**
  - README & rationale clarity (5)

## 12) Academic Integrity & AI Use Policy

- **Collaboration** within your team only; do not share solutions across teams.
- You may use AI tools for brainstorming or drafting **non‑sensitive** code/text. You must: (a) verify all outputs, (b) **cite** the tool and prompts used in your README under an "Assistance" section, and (c) avoid uploading proprietary or personal data.

## 13) Submission Checklist

- ☐ `docs/erd.png` with legend & assumptions
- ☐ `docs/design_rationale.(md or pdf)` (3–6 pages)
- ☐ All SQL files (`01_schema.sql` … `08_transactions.sql`)
- ☐ `scripts/load.(sh or py)`, `explain.(sh or py)`
- ☐ Data files or generation script
- ☐ README with exact commands and expected outputs
- ☐ **Optional:** tests and/or demo video link

## 14) Starter Tips

- Start with **use cases** → entities → attributes → relationships → constraints → FDs → normalized schema.
- Create **sample reports** first; they drive schema and indexing.
- Keep **surrogate keys** (bigserial/identity) where natural keys are messy; still enforce natural **UNIQUEness**.
- Load data early to catch integrity issues.
- Treat performance methodically: baseline timings → one change at a time → document effects.

## Appendix A: Example Data Sources (if you don't synthesize data)

- University course catalogs, residence hall layouts, maintenance logs (anonymized/synthetic).
- Public health appointment datasets (synthetic) and provider registries.
- Open event listings and venue seat maps (use synthetic PII).
- Retail product catalogs and orders (synthetic customer info).

**Note:** If using any real‑world data, ensure it's public and non‑sensitive, and anonymize where needed.

