### 5. Conceptual & Logical Design

5.1 Requirements Analysis 

**Scope Description**
The "Summit Peaks Management System" is a relational database designed to manage the core revenue streams and operational maintenance of a mid-sized ski resort. The system centralizes data for customer access (ticketing), guest services (rentals and ski school), and infrastructure reliability (maintenance of lifts, trails, and equipment).

**Key Actors**

* **Guests:** Individuals who purchase lift tickets, rent equipment, and enroll in lessons.
* **Instructors:** Employees who manage lesson schedules and class rosters.
* **Maintenance Staff:** Specialized technicians (Lift Mechanics, Trail Groomers) responsible for logging repairs and inspections.
* **Operations Managers:** Staff who oversee lift status (Open/Closed) and analyze revenue.

**Key Business Rules & Constraints**

1. **Safety & Capacity:**
* Lessons cannot exceed `MaxCapacity` (Safety Ratio).
* Lifts must track operational status; a lift marked "Closed" cannot be used for trail access calculations.


2. **Temporal Logic:**
* Rental `ActualReturnDate` can be null (active rental), but if present, it must be on or after the `RentalDate`.
* Maintenance `CompletedDate` must be \ge `StartedDate`.


3. **Financial Integrity:**
* All prices (tickets, lessons, rentals) must be non-negative (`CHECK >= 0`).
* Historical pricing must be preserved; `Rental_Items` stores the `UnitPrice` at the moment of transaction, ensuring that changing the base price in `Equipment` does not corrupt past financial records.



---

5.2 Entity-Relationship Diagram (ERD) 

![Diagram should be here](./ER_Diagram.png)

**Cardinality & Participation Notes:**

* **Customers 1 : N Lift_Tickets** — A customer can buy many tickets; a ticket belongs to exactly one customer.
* **Lifts M : N Trails** — Modeled via `Lift_Access`. A lift can service multiple trails, and a long trail may be accessible from multiple lifts.
* **Rentals M : N Equipment** — Modeled via `Rental_Items`. A single transaction can include multiple physical items (e.g., Skis + Boots + Helmet).

---

5.3 Normalization Proof 

We ensured the database structure adheres to **Third Normal Form (3NF)** to eliminate redundancy and update anomalies.

**Example 1: The Rental System**

* **Unnormalized Form (UNF):** A single "Rental Log" containing Customer Name, Rental Date, Ski Brand, Boot Size, Helmet Type, and Total Price.
* *Problem:* Repeating groups (multiple items per rental) and mixed dependencies.


* **1NF (Atomic Values):** We separate the items into a specific structure where every column is atomic.
* *Result:* `Rentals` table for the transaction header, `Equipment` for the inventory.


* **2NF (No Partial Dependencies):**
* In a combined table, the `Brand` of the skis would depend only on the `EquipmentID`, not on the `RentalID`.
* *Solution:* We isolate Equipment attributes (Brand, Size, Model) in the `Equipment` table. The `Rental_Items` bridge table only contains the intersection data (`RentalID`, `EquipmentID`, `UnitPrice` at time of rental).


* **3NF (No Transitive Dependencies):**
* We ensure that non-key attributes depend *only* on the primary key.
* *Example:* We do not store `CustomerEmail` in the `Rentals` table. `Rentals` stores `CustomerID`. To get the email, we join to `Customers`. This prevents data inconsistency if a customer updates their email.



**Special Case: Maintenance Specialization**
Instead of a single "Maintenance Log" table (which would violate 3NF by having many NULL columns depending on the *type* of maintenance), we normalized this into three distinct tables:

1. `Lift_Maintenance_Logs` (Attributes: LiftID, EstimatedCost)
2. `Trail_Maintenance_Logs` (Attributes: TrailID, SnowDepth, WeatherConditions)
3. `Equipment_Maintenance_Logs` (Attributes: EquipmentID, PartsUsed)

This ensures that `SnowDepth` (which is irrelevant to a pair of ski boots) does not exist as a NULL column in equipment logs, preserving storage efficiency and data integrity.

---

5.4 Mapping to Relational Schema 

This section maps the conceptual relationships to the physical SQL tables found in `01_schema.sql`.

**1. Strong Entities \rightarrow Tables**

* Entities like `Customers`, `Instructors`, `Lifts`, and `Pass_Types` map directly to tables with their respective Primary Keys (`CustomerID`, etc.).

**2. One-to-Many (1:N) Relationships \rightarrow Foreign Keys**

* **Concept:** A Pass Type defines many Tickets.
* **Schema:** The `Lift_Tickets` table contains a Foreign Key column `PassTypeID` referencing `Pass_Types(PassTypeID)`.

**3. Many-to-Many (M:N) Relationships \rightarrow Bridge Tables**

* **Concept:** Students take Lessons; Lessons have many Students.
* **Schema:** Created `Enrollments` table.
* PK: `EnrollmentID`
* FKs: `CustomerID`, `LessonID`
* Constraint: `UNIQUE(CustomerID, LessonID)` prevents double-booking the same lesson.


* **Concept:** Lifts access Trails; Trails are accessed by Lifts.
* **Schema:** Created `Lift_Access` table.
* FKs: `LiftID`, `TrailID`
* Attribute: `AccessType` (Direct vs. Indirect) allows distinct attributes for the relationship itself.
