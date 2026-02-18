USE ski_resort;

-- ============================================================================
-- TRIGGER 1: Prevent Lesson Overbooking
-- Purpose: Before adding a student, check if the class is already full.
-- Why a trigger? A CHECK constraint cannot easily query the current count 
-- relative to the max capacity dynamically.
-- ============================================================================
DROP TRIGGER IF EXISTS trg_prevent_overbooking;

DELIMITER $$

CREATE TRIGGER trg_prevent_overbooking
BEFORE INSERT ON Enrollments
FOR EACH ROW
BEGIN
    DECLARE current_count INT;
    DECLARE max_cap INT;

    -- Get current stats for the target lesson
    SELECT CurrentEnrollment, MaxCapacity 
    INTO current_count, max_cap
    FROM Scheduled_Lessons
    WHERE LessonID = NEW.LessonID;

    -- Check if full
    IF current_count >= max_cap THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Cannot enroll. Lesson is at maximum capacity.';
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- TRIGGER 2: Sync Enrollment Counts
-- Purpose: Automatically update the 'CurrentEnrollment' counter in the 
-- Scheduled_Lessons table whenever a student is added or removed.
-- ============================================================================
DROP TRIGGER IF EXISTS trg_after_enrollment_insert;
DROP TRIGGER IF EXISTS trg_after_enrollment_delete;

DELIMITER $$

CREATE TRIGGER trg_after_enrollment_insert
AFTER INSERT ON Enrollments
FOR EACH ROW
BEGIN
    UPDATE Scheduled_Lessons
    SET CurrentEnrollment = CurrentEnrollment + 1
    WHERE LessonID = NEW.LessonID;
END$$

CREATE TRIGGER trg_after_enrollment_delete
AFTER DELETE ON Enrollments
FOR EACH ROW
BEGIN
    UPDATE Scheduled_Lessons
    SET CurrentEnrollment = CurrentEnrollment - 1
    WHERE LessonID = OLD.LessonID;
END$$

DELIMITER ;

-- ============================================================================
-- TRIGGER 3: Auto-Update Equipment Status on Rental
-- Purpose: When an item is added to a rental transaction, automatically
-- mark the physical equipment as 'Rented' so no one else can take it.
-- ============================================================================
DROP TRIGGER IF EXISTS trg_set_equipment_rented;

DELIMITER $$

CREATE TRIGGER trg_set_equipment_rented
AFTER INSERT ON Rental_Items
FOR EACH ROW
BEGIN
    DECLARE current_status VARCHAR(20);

    -- Optional: Safety check to ensure we aren't renting broken gear
    SELECT Status INTO current_status
    FROM Equipment WHERE EquipmentID = NEW.EquipmentID;

    IF current_status = 'Maintenance' OR current_status = 'Retired' THEN
         SIGNAL SQLSTATE '45000' 
         SET MESSAGE_TEXT = 'Error: Cannot rent equipment that is in Maintenance or Retired.';
    ELSE
        -- Update status to Rented
        UPDATE Equipment
        SET Status = 'Rented'
        WHERE EquipmentID = NEW.EquipmentID;
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- TRIGGER 4: Auto-Release Equipment on Return
-- Purpose: When a Rental is marked as "Returned" (ActualReturnDate set),
-- automatically release all associated equipment back to 'Available'.
-- ============================================================================
DROP TRIGGER IF EXISTS trg_return_equipment;

DELIMITER $$

CREATE TRIGGER trg_return_equipment
AFTER UPDATE ON Rentals
FOR EACH ROW
BEGIN
    -- Only run logic if the item is being returned just now
    IF OLD.ActualReturnDate IS NULL AND NEW.ActualReturnDate IS NOT NULL THEN
        
        -- Update status to 'Available' for all items in this rental
        UPDATE Equipment
        SET Status = 'Available'
        WHERE EquipmentID IN (
            SELECT EquipmentID 
            FROM Rental_Items 
            WHERE RentalID = NEW.RentalID
        );
        
    END IF;
END$$

DELIMITER ;