-- ============================================================================
-- TRANSACTION TEST SCRIPT
-- Purpose: Verify ACID properties, Trigger Logic, and Constraints
-- ============================================================================
USE ski_resort;

SELECT '--- TEST 1: Prevent Lesson Overbooking (Trigger 1) ---' AS Test_Case;
-- Scenario: Try to enroll a student into a lesson that is already at capacity.
-- Expected Result: The INSERT should fail with a custom error message.

-- 1. Setup: Create a dummy full lesson (Capacity 1, Enrollment 1)
INSERT INTO Scheduled_Lessons (InstructorID, StartTime, MaxCapacity, CurrentEnrollment, LessonType)
VALUES (1, NOW() + INTERVAL 1 DAY, 1, 1, 'Private'); -- Already full!
SET @full_lesson_id = LAST_INSERT_ID();

-- 2. Test: Try to squeeze another student in
-- We use a stored procedure or just a block to catch the error for demonstration
-- specific to MySQL command line, but here we just run the statement.
-- NOTE: If running this in a script, this specific statement is EXPECTED TO FAIL.
INSERT IGNORE INTO Enrollments (CustomerID, LessonID, PaymentStatus)
VALUES (1, @full_lesson_id, 'Paid');

SELECT 'Check if enrollment count stayed at 1 (Should be 1):' AS Verification;
SELECT CurrentEnrollment, MaxCapacity FROM Scheduled_Lessons WHERE LessonID = @full_lesson_id;

-- Cleanup
DELETE FROM Scheduled_Lessons WHERE LessonID = @full_lesson_id;


SELECT '--- TEST 2: Sync Enrollment Counts (Trigger 2) ---' AS Test_Case;
-- Scenario: Enroll a student and verify the counter increments automatically.
-- Expected Result: CurrentEnrollment goes from 0 -> 1.

-- 1. Setup: New empty lesson
INSERT INTO Scheduled_Lessons (InstructorID, StartTime, MaxCapacity, CurrentEnrollment)
VALUES (1, NOW() + INTERVAL 2 DAY, 5, 0);
SET @test_lesson_id = LAST_INSERT_ID();

-- 2. Action: Enroll Customer #2
INSERT INTO Enrollments (CustomerID, LessonID, PaymentStatus)
VALUES (2, @test_lesson_id, 'Paid');

-- 3. Verification
SELECT LessonID, CurrentEnrollment AS 'Expect 1' 
FROM Scheduled_Lessons WHERE LessonID = @test_lesson_id;

-- 4. Action: Remove Student
DELETE FROM Enrollments WHERE LessonID = @test_lesson_id AND CustomerID = 2;

-- 5. Verification
SELECT LessonID, CurrentEnrollment AS 'Expect 0' 
FROM Scheduled_Lessons WHERE LessonID = @test_lesson_id;

-- Cleanup
DELETE FROM Scheduled_Lessons WHERE LessonID = @test_lesson_id;


SELECT '--- TEST 3: Equipment Rental Automation (Trigger 3) ---' AS Test_Case;
-- Scenario: Renting an item should flip its status to 'Rented'.
-- Expected Result: Equipment Status becomes 'Rented'.

START TRANSACTION;

-- 1. Setup: Pick an available Ski (assuming ID 1 is available)
UPDATE Equipment SET Status = 'Available' WHERE EquipmentID = 1;

-- 2. Action: Create Rental Header
INSERT INTO Rentals (CustomerID, TotalPrice) VALUES (1, 50.00);
SET @rental_id = LAST_INSERT_ID();

-- 3. Action: Add the Ski to the rental
INSERT INTO Rental_Items (RentalID, EquipmentID, UnitPrice) VALUES (@rental_id, 1, 25.00);

-- 4. Verify Trigger
SELECT EquipmentID, Status AS 'Expect Rented' 
FROM Equipment WHERE EquipmentID = 1;

COMMIT;


SELECT '--- TEST 4: Block Bad Rentals (Trigger 3 Safety) ---' AS Test_Case;
-- Scenario: Try to rent an item that is in 'Maintenance'.
-- Expected Result: Error "Cannot rent equipment..."

-- 1. Setup: Mark item as broken
UPDATE Equipment SET Status = 'Maintenance' WHERE EquipmentID = 2;

-- 2. Action: Try to rent it (Should Fail)
-- This INSERT should produce an error
INSERT IGNORE INTO Rental_Items (RentalID, EquipmentID, UnitPrice) VALUES (@rental_id, 2, 25.00);

-- 3. Verify it wasn't added
SELECT Count(*) AS 'Expect 0' FROM Rental_Items WHERE RentalID = @rental_id AND EquipmentID = 2;


SELECT '--- TEST 5: Auto-Return Equipment (Trigger 4) ---' AS Test_Case;
-- Scenario: Closing the rental (setting return date) should free the equipment.
-- Expected Result: Equipment Status goes back to 'Available'.

START TRANSACTION;

-- 1. Verify current status is Rented (from Test 3)
SELECT EquipmentID, Status AS 'Before Return (Rented)' FROM Equipment WHERE EquipmentID = 1;

-- 2. Action: Return the rental
UPDATE Rentals 
SET ActualReturnDate = NOW() 
WHERE RentalID = @rental_id;

-- 3. Verify Trigger Result
SELECT EquipmentID, Status AS 'After Return (Available)' 
FROM Equipment WHERE EquipmentID = 1;

COMMIT;

SELECT '--- ALL TESTS COMPLETED ---' AS Status;