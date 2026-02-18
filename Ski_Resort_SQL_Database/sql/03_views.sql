-- ============================================================================
-- Ski Resort Management System - Views
-- COMP 345 Final Project
-- ============================================================================

USE ski_resort;

-- ============================================================================
-- REPORTING VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 1: Pass Revenue Summary
-- Purpose: Aggregate revenue and usage by pass type and age group
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_pass_revenue_summary AS
SELECT
    pt.PassTypeID,
    pt.PassName,
    pt.AgeGroup,
    pt.IsSeasonPass,
    pt.CurrentPrice AS list_price,
    COUNT(DISTINCT lt.TicketID) AS tickets_sold,
    SUM(lt.SalePrice) AS total_revenue,
    AVG(lt.SalePrice) AS avg_sale_price,
    MIN(lt.SalePrice) AS min_sale_price,
    MAX(lt.SalePrice) AS max_sale_price,
    COUNT(CASE WHEN lt.TicketStatus = 'Active' THEN 1 END) AS tickets_active,
    COUNT(CASE WHEN lt.TicketStatus = 'Used' THEN 1 END) AS tickets_used,
    COUNT(CASE WHEN lt.TicketStatus = 'Expired' THEN 1 END) AS tickets_expired,
    COUNT(CASE WHEN lt.TicketStatus = 'Cancelled' THEN 1 END) AS tickets_cancelled
FROM Pass_Types pt
LEFT JOIN Lift_Tickets lt ON pt.PassTypeID = lt.PassTypeID
GROUP BY
    pt.PassTypeID,
    pt.PassName,
    pt.AgeGroup,
    pt.IsSeasonPass,
    pt.CurrentPrice
ORDER BY
    pt.AgeGroup,
    pt.IsSeasonPass DESC,
    pt.PassName;


-- ----------------------------------------------------------------------------
-- View 2: Lesson Utilization & Revenue
-- Purpose: Capacity utilization and revenue per lesson and instructor
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_lesson_utilization_summary AS
SELECT
    sl.LessonID,
    sl.LessonName,
    sl.LessonType,
    sl.LessonStatus,
    sl.StartTime,
    sl.EndTime,
    sl.MaxCapacity,
    sl.CurrentEnrollment,
    (sl.MaxCapacity - sl.CurrentEnrollment) AS seats_remaining,
    ROUND(
        sl.CurrentEnrollment * 100.0 / NULLIF(sl.MaxCapacity, 0),
        2
    ) AS utilization_percentage,
    i.InstructorID,
    CONCAT(i.FirstName, ' ', i.LastName) AS InstructorName,
    i.Specialty,
    COUNT(e.EnrollmentID) AS total_enrollments,
    SUM(e.PaymentAmount) AS total_lesson_revenue,
    AVG(e.PaymentAmount) AS avg_payment_amount
FROM Scheduled_Lessons sl
JOIN Instructors i ON sl.InstructorID = i.InstructorID
LEFT JOIN Enrollments e
    ON sl.LessonID = e.LessonID
    AND e.PaymentStatus IN ('Paid', 'Refunded')
GROUP BY
    sl.LessonID,
    sl.LessonName,
    sl.LessonType,
    sl.LessonStatus,
    sl.StartTime,
    sl.EndTime,
    sl.MaxCapacity,
    sl.CurrentEnrollment,
    i.InstructorID,
    i.FirstName,
    i.LastName,
    i.Specialty
ORDER BY
    sl.StartTime,
    sl.LessonName;


-- ----------------------------------------------------------------------------
-- View 3: Equipment Rental Performance
-- Purpose: Revenue and usage metrics by equipment type/brand/model
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_equipment_rental_performance AS
SELECT
    e.EquipmentType,
    e.Brand,
    e.Model,
    e.Size,
    e.Status AS current_status,
    COUNT(DISTINCT ri.RentalItemID) AS rental_item_count,
    COUNT(DISTINCT r.RentalID) AS unique_rentals,
    SUM(ri.Quantity) AS total_units_rented,
    SUM(ri.UnitPrice * ri.Quantity) AS total_rental_revenue,
    AVG(ri.UnitPrice) AS avg_unit_price,
    MIN(ri.UnitPrice) AS min_unit_price,
    MAX(ri.UnitPrice) AS max_unit_price
FROM Equipment e
LEFT JOIN Rental_Items ri ON e.EquipmentID = ri.EquipmentID
LEFT JOIN Rentals r ON ri.RentalID = r.RentalID
GROUP BY
    e.EquipmentType,
    e.Brand,
    e.Model,
    e.Size,
    e.Status
ORDER BY
    e.EquipmentType,
    e.Brand,
    e.Model,
    e.Size;


-- ----------------------------------------------------------------------------
-- View 4: Maintenance Workload Summary
-- Purpose: Combined view of lift, trail, and equipment maintenance workload
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_maintenance_workload_summary AS
SELECT
    'Lift' AS asset_type,
    l.LiftID AS asset_id,
    l.LiftName AS asset_name,
    lm.MaintenanceType,
    lm.Priority,
    lm.Status,
    lm.ScheduledDate,
    lm.StartedDate,
    lm.CompletedDate,
    lm.EstimatedCost AS estimated_cost,
    lm.ActualCost AS actual_cost,
    ms.StaffID,
    CONCAT(ms.FirstName, ' ', ms.LastName) AS StaffName,
    TIMESTAMPDIFF(HOUR, lm.StartedDate, lm.CompletedDate) AS duration_hours
FROM Lift_Maintenance_Logs lm
JOIN Lifts l ON lm.LiftID = l.LiftID
LEFT JOIN Maintenance_Staff ms ON lm.StaffID = ms.StaffID

UNION ALL

SELECT
    'Trail' AS asset_type,
    t.TrailID AS asset_id,
    t.TrailName AS asset_name,
    tm.MaintenanceType,
    tm.Priority,
    tm.Status,
    tm.ScheduledDate,
    tm.StartedDate,
    tm.CompletedDate,
    tm.Cost AS estimated_cost,
    tm.Cost AS actual_cost,
    ms.StaffID,
    CONCAT(ms.FirstName, ' ', ms.LastName) AS StaffName,
    TIMESTAMPDIFF(HOUR, tm.StartedDate, tm.CompletedDate) AS duration_hours
FROM Trail_Maintenance_Logs tm
JOIN Trails t ON tm.TrailID = t.TrailID
LEFT JOIN Maintenance_Staff ms ON tm.StaffID = ms.StaffID

UNION ALL

SELECT
    'Equipment' AS asset_type,
    e.EquipmentID AS asset_id,
    CONCAT(e.EquipmentType, ' - ', e.Brand, ' ', e.Model) AS asset_name,
    em.MaintenanceType,
    em.Priority,
    em.Status,
    em.ScheduledDate,
    em.StartedDate,
    em.CompletedDate,
    em.Cost AS estimated_cost,
    em.Cost AS actual_cost,
    ms.StaffID,
    CONCAT(ms.FirstName, ' ', ms.LastName) AS StaffName,
    TIMESTAMPDIFF(HOUR, em.StartedDate, em.CompletedDate) AS duration_hours
FROM Equipment_Maintenance_Logs em
JOIN Equipment e ON em.EquipmentID = e.EquipmentID
LEFT JOIN Maintenance_Staff ms ON em.StaffID = ms.StaffID;


-- ============================================================================
-- OPERATIONAL VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 5: Upcoming Lessons Dashboard
-- Purpose: Quick overview of upcoming lessons for operations team
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_upcoming_lessons_dashboard AS
SELECT
    sl.LessonID,
    sl.LessonName,
    sl.LessonType,
    sl.LessonStatus,
    sl.StartTime,
    sl.EndTime,
    DATEDIFF(DATE(sl.StartTime), CURDATE()) AS days_until_lesson,
    sl.MaxCapacity,
    sl.CurrentEnrollment,
    (sl.MaxCapacity - sl.CurrentEnrollment) AS seats_remaining,
    ROUND(
        sl.CurrentEnrollment * 100.0 / NULLIF(sl.MaxCapacity, 0),
        2
    ) AS capacity_percentage,
    i.InstructorID,
    CONCAT(i.FirstName, ' ', i.LastName) AS InstructorName,
    i.Specialty,
    COUNT(e.EnrollmentID) AS total_enrollments,
    SUM(CASE
            WHEN e.PaymentStatus = 'Paid' THEN e.PaymentAmount
            ELSE 0
        END) AS confirmed_revenue
FROM Scheduled_Lessons sl
JOIN Instructors i ON sl.InstructorID = i.InstructorID
LEFT JOIN Enrollments e ON sl.LessonID = e.LessonID
WHERE
    sl.StartTime >= NOW()
    AND sl.LessonStatus IN ('Scheduled', 'In Progress')
GROUP BY
    sl.LessonID,
    sl.LessonName,
    sl.LessonType,
    sl.LessonStatus,
    sl.StartTime,
    sl.EndTime,
    sl.MaxCapacity,
    sl.CurrentEnrollment,
    i.InstructorID,
    i.FirstName,
    i.LastName,
    i.Specialty
ORDER BY
    sl.StartTime;


-- ----------------------------------------------------------------------------
-- View 6: Active Rentals Dashboard
-- Purpose: Monitor active and overdue rentals by customer
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_active_rentals_dashboard AS
SELECT
    r.RentalID,
    r.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    r.RentalDate,
    r.ExpectedReturnDate,
    r.ActualReturnDate,
    r.TotalPrice,
    r.RentalStatus,
    CASE
        WHEN r.RentalStatus = 'Overdue'
             AND r.ExpectedReturnDate IS NOT NULL
        THEN GREATEST(
            TIMESTAMPDIFF(DAY, r.ExpectedReturnDate, NOW()),
            0
        )
        ELSE 0
    END AS days_overdue,
    CASE
        WHEN r.RentalStatus = 'Overdue' THEN 'Yes'
        ELSE 'No'
    END AS is_overdue_flag
FROM Rentals r
JOIN Customers c ON r.CustomerID = c.CustomerID
WHERE r.RentalStatus IN ('Active', 'Overdue')
ORDER BY
    is_overdue_flag DESC,
    r.ExpectedReturnDate,
    r.RentalDate;


-- ============================================================================
-- SECURITY VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 7: Customer Activity (Masked PII)
-- Purpose: Show multi-channel customer activity without exposing full PII
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_customer_activity_masked AS
SELECT
    c.CustomerID,
    CONCAT(LEFT(c.FirstName, 1), '***') AS FirstNameMasked,
    CONCAT(LEFT(c.LastName, 1), '***') AS LastNameMasked,
    CONCAT(LEFT(c.Email, 3), '***@', SUBSTRING_INDEX(c.Email, '@', -1)) AS EmailMasked,
    COUNT(DISTINCT lt.TicketID) AS total_tickets_purchased,
    COUNT(DISTINCT e.EnrollmentID) AS total_lessons_enrolled,
    COUNT(DISTINCT r.RentalID) AS total_rentals,
    COALESCE(SUM(lt.SalePrice), 0) AS ticket_spend,
    COALESCE(SUM(e.PaymentAmount), 0) AS lesson_spend,
    COALESCE(SUM(r.TotalPrice), 0) AS rental_spend,
    COALESCE(SUM(lt.SalePrice), 0)
        + COALESCE(SUM(e.PaymentAmount), 0)
        + COALESCE(SUM(r.TotalPrice), 0) AS total_spend
FROM Customers c
LEFT JOIN Lift_Tickets lt ON c.CustomerID = lt.CustomerID
LEFT JOIN Enrollments e ON c.CustomerID = e.CustomerID
LEFT JOIN Rentals r ON c.CustomerID = r.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email;


-- ----------------------------------------------------------------------------
-- View 8: Customer Contact Info (Secure / Admin Only)
-- Purpose: Centralized customer PII; should be granted only to admin role
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_customer_contact_secure AS
SELECT
    CustomerID,
    FirstName,
    LastName,
    Email,
    Phone,
    CONCAT(
        Address, ', ',
        City, ', ',
        StateProvince, ' ',
        PostalCode
    ) AS FullAddress,
    Country,
    CreatedAt
FROM Customers;

-- ============================================================================
-- END OF VIEWS
-- ============================================================================
