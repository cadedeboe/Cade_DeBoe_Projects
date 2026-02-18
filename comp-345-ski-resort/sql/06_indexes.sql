-- ============================================================================
-- Ski Resort Management System - Indexes
-- COMP 345 Final Project
-- ============================================================================

USE ski_resort;

-- ============================================================================
-- PERFORMANCE INDEXES
-- Note: Primary keys and UNIQUE constraints already create indexes.
--       Below are additional indexes for query optimization.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CUSTOMERS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Index for customer search by name (operations, customer service)
CREATE INDEX idx_customer_name 
ON Customers(LastName, FirstName);

-- Index for customer filtering by location (reporting, marketing)
CREATE INDEX idx_customer_location 
ON Customers(City, StateProvince, Country);

-- ----------------------------------------------------------------------------
-- PASS_TYPES TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Index to support pass revenue analysis by age group and season flag
-- (used indirectly by vw_pass_revenue_summary via joins with Lift_Tickets)
CREATE INDEX idx_pass_age_season 
ON Pass_Types(AgeGroup, IsSeasonPass);

-- Index for price-based analysis and admin UI sorting
CREATE INDEX idx_pass_price 
ON Pass_Types(CurrentPrice);

-- ----------------------------------------------------------------------------
-- LIFT_TICKETS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for customer ticket history
-- Supports: "Show all tickets for customer X ordered by purchase date"
CREATE INDEX idx_ticket_customer_date
ON Lift_Tickets(CustomerID, PurchaseDate);

-- Composite index for revenue and usage by pass type and status
-- Supports vw_pass_revenue_summary and operational queries
CREATE INDEX idx_ticket_pass_status
ON Lift_Tickets(PassTypeID, TicketStatus, SalePrice);

-- Index for validity/date-range queries (e.g., tickets valid on a given day)
CREATE INDEX idx_ticket_valid_status
ON Lift_Tickets(ValidDate, TicketStatus);

-- ----------------------------------------------------------------------------
-- INSTRUCTORS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Index for instructor lookup by name
CREATE INDEX idx_instructor_name
ON Instructors(LastName, FirstName);

-- Index for filtering by specialty and active flag
CREATE INDEX idx_instructor_specialty_active
ON Instructors(Specialty, IsActive);

-- ----------------------------------------------------------------------------
-- SCHEDULED_LESSONS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for instructor schedule views
-- Supports queries: "Show upcoming lessons for instructor X"
CREATE INDEX idx_lesson_instructor_time
ON Scheduled_Lessons(InstructorID, StartTime);

-- Composite index for upcoming lessons dashboard
-- Supports filtering by start time and status (vw_upcoming_lessons_dashboard)
CREATE INDEX idx_lesson_start_status
ON Scheduled_Lessons(StartTime, LessonStatus, LessonID);

-- Index for lesson type/status-based reporting
CREATE INDEX idx_lesson_type_status
ON Scheduled_Lessons(LessonType, LessonStatus);

-- ----------------------------------------------------------------------------
-- ENROLLMENTS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for lesson utilization and revenue
-- Supports vw_lesson_utilization_summary and vw_upcoming_lessons_dashboard
CREATE INDEX idx_enrollment_lesson_payment
ON Enrollments(LessonID, PaymentStatus, EnrollmentDate);

-- Composite index for customer activity and spend analysis
-- Supports vw_customer_activity_masked
CREATE INDEX idx_enrollment_customer_payment
ON Enrollments(CustomerID, PaymentStatus, EnrollmentDate);

-- ----------------------------------------------------------------------------
-- EQUIPMENT TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for equipment rental performance by type/brand/model
-- Supports vw_equipment_rental_performance
CREATE INDEX idx_equipment_type_brand_model
ON Equipment(EquipmentType, Brand, Model, Size);

-- Index for operational queries by status and type
CREATE INDEX idx_equipment_status_type
ON Equipment(Status, EquipmentType);

-- ----------------------------------------------------------------------------
-- RENTALS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for customer rental history
-- Supports: "Show all rentals for customer X ordered by date"
CREATE INDEX idx_rental_customer_date
ON Rentals(CustomerID, RentalDate);

-- Composite index for active/overdue rental monitoring
-- Supports vw_active_rentals_dashboard (status + expected return date)
CREATE INDEX idx_rental_status_expected
ON Rentals(RentalStatus, ExpectedReturnDate, RentalDate);

-- Index for rental status and date-based reporting
CREATE INDEX idx_rental_status_date
ON Rentals(RentalStatus, RentalDate);

-- ----------------------------------------------------------------------------
-- RENTAL_ITEMS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for rental → items lookup
CREATE INDEX idx_rental_items_rental
ON Rental_Items(RentalID, EquipmentID);

-- Composite index for equipment usage lookup
-- Supports vw_equipment_rental_performance via EquipmentID joins
CREATE INDEX idx_rental_items_equipment
ON Rental_Items(EquipmentID, RentalID, UnitPrice);

-- ----------------------------------------------------------------------------
-- TRAILS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Index for difficulty-based filtering and reporting
CREATE INDEX idx_trail_difficulty
ON Trails(Difficulty);

-- ----------------------------------------------------------------------------
-- LIFTS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Index for lift type filtering (operations dashboards)
CREATE INDEX idx_lift_type
ON Lifts(LiftType);

-- Index for filtering open lifts by type
CREATE INDEX idx_lift_open_type
ON Lifts(IsOpen, LiftType);

-- ----------------------------------------------------------------------------
-- LIFT_ACCESS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- UNIQUE(LiftID, TrailID) already indexed; this supports the reverse lookup:
-- "Which lifts serve trail X?"
CREATE INDEX idx_lift_access_trail_lift
ON Lift_Access(TrailID, LiftID);

-- ----------------------------------------------------------------------------
-- MAINTENANCE_STAFF TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for finding staff by specialty and active flag
CREATE INDEX idx_staff_specialty_active
ON Maintenance_Staff(Specialty, IsActive);

-- Index for staff lookup by name
CREATE INDEX idx_staff_name
ON Maintenance_Staff(LastName, FirstName);

-- ----------------------------------------------------------------------------
-- LIFT_MAINTENANCE_LOGS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for lift maintenance workload by lift and status
-- Supports vw_maintenance_workload_summary (lift segment)
CREATE INDEX idx_lift_maint_lift_status
ON Lift_Maintenance_Logs(LiftID, Status, Priority);

-- Index for scheduling views and backlog analysis
CREATE INDEX idx_lift_maint_scheduled
ON Lift_Maintenance_Logs(ScheduledDate, Status);

-- Index for staff workload queries
CREATE INDEX idx_lift_maint_staff
ON Lift_Maintenance_Logs(StaffID, Status);

-- ----------------------------------------------------------------------------
-- EQUIPMENT_MAINTENANCE_LOGS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for equipment maintenance by equipment and status
CREATE INDEX idx_equip_maint_equipment_status
ON Equipment_Maintenance_Logs(EquipmentID, Status, Priority);

-- Index for scheduling views and aging maintenance items
CREATE INDEX idx_equip_maint_scheduled
ON Equipment_Maintenance_Logs(ScheduledDate, Status);

-- Index for staff workload on equipment maintenance
CREATE INDEX idx_equip_maint_staff
ON Equipment_Maintenance_Logs(StaffID, Status);

-- ----------------------------------------------------------------------------
-- TRAIL_MAINTENANCE_LOGS TABLE INDEXES
-- ----------------------------------------------------------------------------

-- Composite index for trail maintenance by trail and status
CREATE INDEX idx_trail_maint_trail_status
ON Trail_Maintenance_Logs(TrailID, Status, Priority);

-- Index for scheduling views and weather-related backlog analysis
CREATE INDEX idx_trail_maint_scheduled
ON Trail_Maintenance_Logs(ScheduledDate, Status);

-- Index for staff workload on trail maintenance
CREATE INDEX idx_trail_maint_staff
ON Trail_Maintenance_Logs(StaffID, Status);

-- ============================================================================
-- COVERING INDEXES (for specific high-frequency views)
-- ============================================================================

-- Covering index for pass revenue summary
-- Supports vw_pass_revenue_summary by PassTypeID + status + price
CREATE INDEX idx_ticket_pass_revenue_cover
ON Lift_Tickets(PassTypeID, TicketStatus, SalePrice, ValidDate);

-- Covering index for upcoming lessons dashboard
-- Includes columns most used in vw_upcoming_lessons_dashboard
CREATE INDEX idx_lesson_upcoming_dashboard
ON Scheduled_Lessons(
    StartTime,
    LessonStatus,
    LessonID,
    LessonName,
    LessonType,
    MaxCapacity,
    CurrentEnrollment,
    InstructorID
);

-- Covering index for active rentals dashboard
-- Supports vw_active_rentals_dashboard
CREATE INDEX idx_rental_active_dashboard
ON Rentals(
    RentalStatus,
    ExpectedReturnDate,
    RentalDate,
    CustomerID,
    TotalPrice
);

-- Covering index for equipment rental performance
-- Reduces lookups when aggregating revenue by equipment
CREATE INDEX idx_rental_items_performance_cover
ON Rental_Items(
    EquipmentID,
    RentalID,
    Quantity,
    UnitPrice
);

-- ============================================================================
-- FULL-TEXT INDEXES (for search functionality)
-- ============================================================================

-- Full-text index for trail search (by name and conditions)
CREATE FULLTEXT INDEX idx_ft_trail_search
ON Trails(TrailName, ConditionsNotes);

-- Full-text index for equipment search (by brand/model and notes)
CREATE FULLTEXT INDEX idx_ft_equipment_search
ON Equipment(Brand, Model, ConditionNotes);

-- Full-text index for customer search (name, email, city)
CREATE FULLTEXT INDEX idx_ft_customer_search
ON Customers(FirstName, LastName, Email, City);

-- ============================================================================
-- INDEX USAGE NOTES
-- ============================================================================
/*
INDEXING STRATEGY RATIONALE:

1. COMPOSITE INDEXES:
   - Ordered by selectivity and common filter/order-by patterns.
   - Support typical WHERE/JOIN/ORDER BY clauses in:
     * Reporting views (vw_pass_revenue_summary, vw_lesson_utilization_summary,
       vw_equipment_rental_performance, vw_maintenance_workload_summary).
     * Operational dashboards (vw_upcoming_lessons_dashboard,
       vw_active_rentals_dashboard).
     * Customer activity view (vw_customer_activity_masked).

2. COVERING INDEXES:
   - Include all frequently-used columns for specific views
     to enable index-only plans where possible.
   - Trade-off: more storage vs. faster read-heavy analytics.

3. FULL-TEXT INDEXES:
   - Enable natural-language search on descriptive text fields
     (trails, equipment, customers).
   - Preferred over LIKE '%term%' for search UIs.

4. TRADE-OFFS:
   - Each additional index slows INSERT/UPDATE/DELETE on the table.
   - Indexes consume extra disk space and must be maintained.
   - Only index columns involved in frequent filters, joins, and sorts.

5. MONITORING:
   - Use EXPLAIN on key queries and views to verify index usage.
   - Monitor slow queries and adjust indexes as needed.
   - Periodically review SHOW INDEX FROM <table> to remove unused indexes.
*/

-- ============================================================================
-- END OF INDEXES
-- ============================================================================
