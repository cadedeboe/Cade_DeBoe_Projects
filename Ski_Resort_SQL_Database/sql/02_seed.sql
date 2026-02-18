-- ============================================================================
-- Ski Resort Management System - Sample Data
-- COMP 345 Final Project
-- ============================================================================

USE ski_resort;

-- Disable foreign key checks for faster loading
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- CUSTOMERS (50+ customers to meet data volume requirements)
-- ============================================================================
INSERT INTO Customers (FirstName, LastName, Email, Phone, DOB, Address, City, StateProvince, PostalCode, Country) VALUES
('John', 'Smith', 'john.smith@email.com', '555-0101', '1985-03-15', '123 Main St', 'Denver', 'CO', '80201', 'USA'),
('Sarah', 'Johnson', 'sarah.johnson@email.com', '555-0102', '1990-07-22', '456 Oak Ave', 'Aspen', 'CO', '81611', 'USA'),
('Michael', 'Williams', 'michael.williams@email.com', '555-0103', '1988-11-30', '789 Pine Rd', 'Vail', 'CO', '81657', 'USA'),
('Emily', 'Brown', 'emily.brown@email.com', '555-0104', '1992-05-18', '321 Elm St', 'Boulder', 'CO', '80301', 'USA'),
('David', 'Jones', 'david.jones@email.com', '555-0105', '1987-09-12', '654 Maple Dr', 'Breckenridge', 'CO', '80424', 'USA'),
('Jessica', 'Garcia', 'jessica.garcia@email.com', '555-0106', '1995-01-25', '987 Cedar Ln', 'Steamboat Springs', 'CO', '80487', 'USA'),
('Christopher', 'Miller', 'christopher.miller@email.com', '555-0107', '1983-12-08', '147 Birch Way', 'Telluride', 'CO', '81435', 'USA'),
('Amanda', 'Davis', 'amanda.davis@email.com', '555-0108', '1991-04-03', '258 Spruce St', 'Crested Butte', 'CO', '81224', 'USA'),
('Matthew', 'Rodriguez', 'matthew.rodriguez@email.com', '555-0109', '1989-08-19', '369 Willow Ave', 'Winter Park', 'CO', '80482', 'USA'),
('Ashley', 'Martinez', 'ashley.martinez@email.com', '555-0110', '1993-06-14', '741 Cherry Blvd', 'Keystone', 'CO', '80435', 'USA'),
('James', 'Hernandez', 'james.hernandez@email.com', '555-0111', '1986-02-28', '852 Poplar Rd', 'Copper Mountain', 'CO', '80443', 'USA'),
('Lauren', 'Lopez', 'lauren.lopez@email.com', '555-0112', '1994-10-07', '963 Fir St', 'Beaver Creek', 'CO', '81620', 'USA'),
('Robert', 'Wilson', 'robert.wilson@email.com', '555-0113', '1984-07-21', '159 Hemlock Dr', 'Snowmass', 'CO', '81615', 'USA'),
('Michelle', 'Anderson', 'michelle.anderson@email.com', '555-0114', '1990-03-09', '357 Juniper Ln', 'Durango', 'CO', '81301', 'USA'),
('Daniel', 'Thomas', 'daniel.thomas@email.com', '555-0115', '1988-11-16', '468 Cypress Way', 'Frisco', 'CO', '80443', 'USA'),
('Nicole', 'Taylor', 'nicole.taylor@email.com', '555-0116', '1992-05-04', '579 Redwood Ave', 'Silverthorne', 'CO', '80498', 'USA'),
('William', 'Moore', 'william.moore@email.com', '555-0117', '1985-09-23', '680 Sequoia St', 'Glenwood Springs', 'CO', '81601', 'USA'),
('Stephanie', 'Jackson', 'stephanie.jackson@email.com', '555-0118', '1991-01-11', '791 Magnolia Blvd', 'Leadville', 'CO', '80461', 'USA'),
('Joseph', 'White', 'joseph.white@email.com', '555-0119', '1987-07-30', '802 Dogwood Rd', 'Salida', 'CO', '81201', 'USA'),
('Kimberly', 'Harris', 'kimberly.harris@email.com', '555-0120', '1993-12-18', '913 Sycamore Dr', 'Buena Vista', 'CO', '81211', 'USA'),
('Thomas', 'Martin', 'thomas.martin@email.com', '555-0121', '1989-04-26', '124 Hickory Ln', 'Pagosa Springs', 'CO', '81147', 'USA'),
('Rachel', 'Thompson', 'rachel.thompson@email.com', '555-0122', '1995-08-13', '235 Ash Way', 'Estes Park', 'CO', '80517', 'USA'),
('Charles', 'Garcia', 'charles.garcia@email.com', '555-0123', '1986-02-01', '346 Beech St', 'Grand Junction', 'CO', '81501', 'USA'),
('Samantha', 'Martinez', 'samantha.martinez@email.com', '555-0124', '1992-10-20', '457 Walnut Ave', 'Montrose', 'CO', '81401', 'USA'),
('Andrew', 'Robinson', 'andrew.robinson@email.com', '555-0125', '1988-06-08', '568 Chestnut Blvd', 'Gunnison', 'CO', '81230', 'USA'),
('Elizabeth', 'Clark', 'elizabeth.clark@email.com', '555-0126', '1994-03-27', '679 Alder Rd', 'Carbondale', 'CO', '81623', 'USA'),
('Joshua', 'Lewis', 'joshua.lewis@email.com', '555-0127', '1987-11-14', '780 Basswood Dr', 'Basalt', 'CO', '81621', 'USA'),
('Megan', 'Lee', 'megan.lee@email.com', '555-0128', '1991-07-02', '891 Cottonwood Ln', 'Avon', 'CO', '81620', 'USA'),
('Ryan', 'Walker', 'ryan.walker@email.com', '555-0129', '1989-01-19', '902 Eucalyptus Way', 'Edwards', 'CO', '81632', 'USA'),
('Brittany', 'Hall', 'brittany.hall@email.com', '555-0130', '1993-09-06', '113 Acacia St', 'Gypsum', 'CO', '81637', 'USA'),
('Kevin', 'Allen', 'kevin.allen@email.com', '555-0131', '1985-05-24', '224 Catalpa Ave', 'Eagle', 'CO', '81631', 'USA'),
('Amanda', 'Young', 'amanda.young@email.com', '555-0132', '1990-12-12', '335 Locust Blvd', 'Minturn', 'CO', '81645', 'USA'),
('Brian', 'King', 'brian.king@email.com', '555-0133', '1988-08-29', '446 Mulberry Rd', 'Red Cliff', 'CO', '81649', 'USA'),
('Melissa', 'Wright', 'melissa.wright@email.com', '555-0134', '1994-04-16', '557 Persimmon Dr', 'Vail', 'CO', '81657', 'USA'),
('Steven', 'Lopez', 'steven.lopez@email.com', '555-0135', '1986-11-03', '668 Pawpaw Ln', 'Aspen', 'CO', '81611', 'USA'),
('Rebecca', 'Hill', 'rebecca.hill@email.com', '555-0136', '1992-07-21', '779 Sassafras Way', 'Breckenridge', 'CO', '80424', 'USA'),
('Jason', 'Scott', 'jason.scott@email.com', '555-0137', '1989-02-08', '880 Sumac St', 'Steamboat Springs', 'CO', '80487', 'USA'),
('Laura', 'Green', 'laura.green@email.com', '555-0138', '1995-10-25', '991 Tulip Ave', 'Telluride', 'CO', '81435', 'USA'),
('Eric', 'Adams', 'eric.adams@email.com', '555-0139', '1987-06-12', '102 Lilac Blvd', 'Crested Butte', 'CO', '81224', 'USA'),
('Heather', 'Baker', 'heather.baker@email.com', '555-0140', '1991-01-28', '213 Rose Rd', 'Winter Park', 'CO', '80482', 'USA'),
('Mark', 'Nelson', 'mark.nelson@email.com', '555-0141', '1988-09-15', '324 Daisy Dr', 'Keystone', 'CO', '80435', 'USA'),
('Jennifer', 'Carter', 'jennifer.carter@email.com', '555-0142', '1994-05-02', '435 Sunflower Ln', 'Copper Mountain', 'CO', '80443', 'USA'),
('Paul', 'Mitchell', 'paul.mitchell@email.com', '555-0143', '1986-12-19', '546 Marigold Way', 'Beaver Creek', 'CO', '81620', 'USA'),
('Lisa', 'Perez', 'lisa.perez@email.com', '555-0144', '1992-08-06', '657 Zinnia St', 'Snowmass', 'CO', '81615', 'USA'),
('Justin', 'Roberts', 'justin.roberts@email.com', '555-0145', '1989-03-23', '768 Petunia Ave', 'Durango', 'CO', '81301', 'USA'),
('Angela', 'Turner', 'angela.turner@email.com', '555-0146', '1995-11-10', '879 Pansy Blvd', 'Frisco', 'CO', '80443', 'USA'),
('Brandon', 'Phillips', 'brandon.phillips@email.com', '555-0147', '1987-07-27', '980 Carnation Rd', 'Silverthorne', 'CO', '80498', 'USA'),
('Christina', 'Campbell', 'christina.campbell@email.com', '555-0148', '1993-02-13', '191 Aster Dr', 'Glenwood Springs', 'CO', '81601', 'USA'),
('Kyle', 'Parker', 'kyle.parker@email.com', '555-0149', '1990-10-01', '202 Lavender Ln', 'Leadville', 'CO', '80461', 'USA'),
('Tiffany', 'Evans', 'tiffany.evans@email.com', '555-0150', '1988-04-18', '313 Orchid Way', 'Salida', 'CO', '81201', 'USA');

-- ============================================================================
-- PASS TYPES (Catalog of available pass types)
-- ============================================================================
INSERT INTO Pass_Types (PassName, PassDescription, CurrentPrice, AgeGroup, DurationDays, IsSeasonPass) VALUES
('Adult Day Pass', 'Full-day lift access for adults', 89.00, 'Adult', 1, FALSE),
('Child Day Pass', 'Full-day lift access for children (ages 5-12)', 45.00, 'Child', 1, FALSE),
('Senior Day Pass', 'Full-day lift access for seniors (65+)', 65.00, 'Senior', 1, FALSE),
('Adult Multi-Day Pass', '3-day lift access for adults', 240.00, 'Adult', 3, FALSE),
('Child Multi-Day Pass', '3-day lift access for children', 120.00, 'Child', 3, FALSE),
('Senior Multi-Day Pass', '3-day lift access for seniors', 180.00, 'Senior', 3, FALSE),
('Adult Season Pass', 'Unlimited lift access for the entire season', 899.00, 'Adult', 180, TRUE),
('Child Season Pass', 'Unlimited lift access for children', 449.00, 'Child', 180, TRUE),
('Senior Season Pass', 'Unlimited lift access for seniors', 599.00, 'Senior', 180, TRUE),
('Family Season Pass', 'Unlimited lift access for entire family', 1999.00, 'Adult', 180, TRUE);

-- ============================================================================
-- INSTRUCTORS (Ski and snowboard instructors)
-- ============================================================================
INSERT INTO Instructors (FirstName, LastName, Email, Phone, Specialty, CertificationLevel, HireDate, IsActive) VALUES
('Alex', 'Thompson', 'alex.thompson@skiresort.com', '555-1001', 'Skiing', 'Level 3', '2018-11-01', TRUE),
('Maria', 'Rodriguez', 'maria.rodriguez@skiresort.com', '555-1002', 'Snowboarding', 'Level 3', '2019-10-15', TRUE),
('James', 'Wilson', 'james.wilson@skiresort.com', '555-1003', 'Both', 'Certified', '2017-09-20', TRUE),
('Emma', 'Davis', 'emma.davis@skiresort.com', '555-1004', 'Skiing', 'Level 2', '2020-11-10', TRUE),
('Michael', 'Brown', 'michael.brown@skiresort.com', '555-1005', 'Snowboarding', 'Level 2', '2021-10-05', TRUE),
('Sophia', 'Miller', 'sophia.miller@skiresort.com', '555-1006', 'Both', 'Level 3', '2019-12-01', TRUE),
('David', 'Garcia', 'david.garcia@skiresort.com', '555-1007', 'Skiing', 'Level 1', '2022-11-15', TRUE),
('Olivia', 'Martinez', 'olivia.martinez@skiresort.com', '555-1008', 'Snowboarding', 'Level 1', '2022-12-10', TRUE),
('Christopher', 'Anderson', 'christopher.anderson@skiresort.com', '555-1009', 'Both', 'Level 2', '2020-10-20', TRUE),
('Isabella', 'Taylor', 'isabella.taylor@skiresort.com', '555-1010', 'Skiing', 'Level 3', '2018-09-15', TRUE),
('Daniel', 'Thomas', 'daniel.thomas@skiresort.com', '555-1011', 'Snowboarding', 'Level 2', '2021-11-01', TRUE),
('Ava', 'Jackson', 'ava.jackson@skiresort.com', '555-1012', 'Both', 'Certified', '2016-10-10', TRUE);

-- ============================================================================
-- TRAILS (Ski trails/runs at the resort)
-- ============================================================================
INSERT INTO Trails (TrailName, Difficulty, LengthMeters, ElevationDropMeters, IsOpen, ConditionsNotes) VALUES
('Bunny Slope', 'Beginner', 200.00, 30.00, TRUE, 'Perfect for beginners, groomed daily'),
('Green Circle', 'Beginner', 500.00, 80.00, TRUE, 'Wide and gentle, ideal for learning'),
('Easy Rider', 'Beginner', 800.00, 120.00, TRUE, 'Long beginner trail with scenic views'),
('Blue Moon', 'Intermediate', 1200.00, 250.00, TRUE, 'Moderate difficulty, well-groomed'),
('Mountain View', 'Intermediate', 1500.00, 300.00, TRUE, 'Scenic intermediate run'),
('Thunder Ridge', 'Intermediate', 1800.00, 400.00, TRUE, 'Challenging intermediate terrain'),
('Black Diamond', 'Advanced', 2000.00, 600.00, TRUE, 'Steep and challenging'),
('Powder Bowl', 'Advanced', 2500.00, 750.00, TRUE, 'Ungroomed powder terrain'),
('Extreme Run', 'Expert', 3000.00, 900.00, TRUE, 'Expert only - extreme terrain'),
('Cliff Drop', 'Expert', 1500.00, 800.00, TRUE, 'Very steep expert terrain'),
('Backcountry Access', 'Expert', 4000.00, 1200.00, FALSE, 'Closed - avalanche risk'),
('Family Fun', 'Beginner', 600.00, 100.00, TRUE, 'Family-friendly beginner trail'),
('Sunset Ridge', 'Intermediate', 1400.00, 320.00, TRUE, 'Great for afternoon skiing'),
('Morning Glory', 'Advanced', 2200.00, 650.00, TRUE, 'Early morning powder runs'),
('Eagle Peak', 'Expert', 3500.00, 1100.00, TRUE, 'Highest peak - expert terrain only');

-- ============================================================================
-- LIFTS (Chairlifts and gondolas)
-- ============================================================================
INSERT INTO Lifts (LiftName, LiftType, Capacity, IsOpen, OperatingHours) VALUES
('Magic Carpet 1', 'Magic Carpet', 50, TRUE, '9:00 AM - 4:00 PM'),
('Magic Carpet 2', 'Magic Carpet', 50, TRUE, '9:00 AM - 4:00 PM'),
('Beginner Chair', 'Chairlift', 4, TRUE, '9:00 AM - 4:00 PM'),
('Mountain Express', 'Chairlift', 6, TRUE, '8:30 AM - 4:30 PM'),
('Summit Gondola', 'Gondola', 8, TRUE, '8:00 AM - 5:00 PM'),
('Thunder Lift', 'Chairlift', 4, TRUE, '9:00 AM - 4:00 PM'),
('Eagle Peak Chair', 'Chairlift', 4, TRUE, '8:30 AM - 4:00 PM'),
('Backside T-Bar', 'T-Bar', 2, FALSE, 'Closed for maintenance'),
('Sunset Express', 'Chairlift', 6, TRUE, '9:00 AM - 4:30 PM'),
('Family Fun Lift', 'Chairlift', 4, TRUE, '9:00 AM - 4:00 PM'),
('Powder Bowl Lift', 'Chairlift', 4, TRUE, '8:30 AM - 4:00 PM'),
('Base Area Gondola', 'Gondola', 8, TRUE, '8:00 AM - 5:00 PM');

-- ============================================================================
-- LIFT ACCESS (Bridge table: Lifts ↔ Trails)
-- ============================================================================
INSERT INTO Lift_Access (LiftID, TrailID, AccessType) VALUES
-- Magic Carpet 1 accesses Bunny Slope
(1, 1, 'Direct'),
-- Magic Carpet 2 accesses Green Circle
(2, 2, 'Direct'),
-- Beginner Chair accesses multiple beginner trails
(3, 1, 'Direct'),
(3, 2, 'Direct'),
(3, 3, 'Direct'),
(3, 12, 'Direct'),
-- Mountain Express accesses intermediate trails
(4, 4, 'Direct'),
(4, 5, 'Direct'),
(4, 13, 'Direct'),
-- Summit Gondola accesses multiple trails
(5, 4, 'Indirect'),
(5, 5, 'Indirect'),
(5, 6, 'Direct'),
(5, 7, 'Direct'),
(5, 8, 'Direct'),
-- Thunder Lift accesses Thunder Ridge
(6, 6, 'Direct'),
-- Eagle Peak Chair accesses expert trails
(7, 9, 'Direct'),
(7, 10, 'Direct'),
(7, 15, 'Direct'),
-- Sunset Express accesses Sunset Ridge
(9, 13, 'Direct'),
-- Family Fun Lift accesses Family Fun trail
(10, 12, 'Direct'),
-- Powder Bowl Lift accesses Powder Bowl
(11, 8, 'Direct'),
(11, 14, 'Direct'),
-- Base Area Gondola accesses multiple trails
(12, 1, 'Indirect'),
(12, 2, 'Indirect'),
(12, 3, 'Indirect'),
(12, 4, 'Indirect');

-- ============================================================================
-- EQUIPMENT (Inventory of rental equipment)
-- ============================================================================
INSERT INTO Equipment (EquipmentType, Brand, Model, Size, Status, PurchaseDate, LastMaintenanceDate, NextMaintenanceDate, ConditionNotes) VALUES
-- Skis
('Ski', 'Rossignol', 'Experience 80', '160cm', 'Available', '2023-10-15', '2024-11-01', '2025-01-15', 'Good condition'),
('Ski', 'Rossignol', 'Experience 80', '165cm', 'Available', '2023-10-15', '2024-11-01', '2025-01-15', 'Good condition'),
('Ski', 'Rossignol', 'Experience 80', '170cm', 'Rented', '2023-10-15', '2024-11-01', '2025-01-15', 'Good condition'),
('Ski', 'Rossignol', 'Experience 80', '175cm', 'Available', '2023-10-15', '2024-11-01', '2025-01-15', 'Good condition'),
('Ski', 'Atomic', 'Vantage 75', '160cm', 'Available', '2023-11-01', '2024-11-10', '2025-01-20', 'Excellent condition'),
('Ski', 'Atomic', 'Vantage 75', '165cm', 'Available', '2023-11-01', '2024-11-10', '2025-01-20', 'Excellent condition'),
('Ski', 'Atomic', 'Vantage 75', '170cm', 'Rented', '2023-11-01', '2024-11-10', '2025-01-20', 'Excellent condition'),
('Ski', 'Atomic', 'Vantage 75', '175cm', 'Available', '2023-11-01', '2024-11-10', '2025-01-20', 'Excellent condition'),
('Ski', 'Salomon', 'QST 92', '168cm', 'Available', '2023-10-20', '2024-11-05', '2025-01-18', 'Good condition'),
('Ski', 'Salomon', 'QST 92', '173cm', 'Maintenance', '2023-10-20', '2024-11-05', '2024-12-20', 'Needs edge tuning'),
-- Snowboards
('Snowboard', 'Burton', 'Custom', '152cm', 'Available', '2023-10-25', '2024-11-08', '2025-01-22', 'Good condition'),
('Snowboard', 'Burton', 'Custom', '156cm', 'Rented', '2023-10-25', '2024-11-08', '2025-01-22', 'Good condition'),
('Snowboard', 'Burton', 'Custom', '160cm', 'Available', '2023-10-25', '2024-11-08', '2025-01-22', 'Good condition'),
('Snowboard', 'Ride', 'War Pig', '154cm', 'Available', '2023-11-05', '2024-11-12', '2025-01-25', 'Excellent condition'),
('Snowboard', 'Ride', 'War Pig', '158cm', 'Available', '2023-11-05', '2024-11-12', '2025-01-25', 'Excellent condition'),
('Snowboard', 'Ride', 'War Pig', '162cm', 'Rented', '2023-11-05', '2024-11-12', '2025-01-25', 'Excellent condition'),
-- Boots
('Boots', 'Rossignol', 'Alltrack 70', '26.5', 'Available', '2023-10-15', '2024-11-01', '2025-01-15', 'Good condition'),
('Boots', 'Rossignol', 'Alltrack 70', '27.5', 'Available', '2023-10-15', '2024-11-01', '2025-01-15', 'Good condition'),
('Boots', 'Rossignol', 'Alltrack 70', '28.5', 'Rented', '2023-10-15', '2024-11-01', '2025-01-15', 'Good condition'),
('Boots', 'Atomic', 'Hawx Prime', '26.0', 'Available', '2023-11-01', '2024-11-10', '2025-01-20', 'Excellent condition'),
('Boots', 'Atomic', 'Hawx Prime', '27.0', 'Available', '2023-11-01', '2024-11-10', '2025-01-20', 'Excellent condition'),
('Boots', 'Atomic', 'Hawx Prime', '28.0', 'Rented', '2023-11-01', '2024-11-10', '2025-01-20', 'Excellent condition'),
('Boots', 'Burton', 'Ruler', '8', 'Available', '2023-10-25', '2024-11-08', '2025-01-22', 'Good condition'),
('Boots', 'Burton', 'Ruler', '9', 'Rented', '2023-10-25', '2024-11-08', '2025-01-22', 'Good condition'),
('Boots', 'Burton', 'Ruler', '10', 'Available', '2023-10-25', '2024-11-08', '2025-01-22', 'Good condition'),
-- Poles
('Poles', 'Leki', 'Carbon', '120cm', 'Available', '2023-10-15', NULL, '2025-02-01', 'Good condition'),
('Poles', 'Leki', 'Carbon', '125cm', 'Available', '2023-10-15', NULL, '2025-02-01', 'Good condition'),
('Poles', 'Leki', 'Carbon', '130cm', 'Rented', '2023-10-15', NULL, '2025-02-01', 'Good condition'),
('Poles', 'Black Diamond', 'Trail', '115cm', 'Available', '2023-11-01', NULL, '2025-02-05', 'Excellent condition'),
('Poles', 'Black Diamond', 'Trail', '120cm', 'Available', '2023-11-01', NULL, '2025-02-05', 'Excellent condition'),
-- Helmets
('Helmet', 'Giro', 'Range', 'S', 'Available', '2023-10-20', NULL, '2025-03-01', 'Good condition'),
('Helmet', 'Giro', 'Range', 'M', 'Available', '2023-10-20', NULL, '2025-03-01', 'Good condition'),
('Helmet', 'Giro', 'Range', 'L', 'Rented', '2023-10-20', NULL, '2025-03-01', 'Good condition'),
('Helmet', 'Smith', 'Vantage', 'S', 'Available', '2023-11-05', NULL, '2025-03-05', 'Excellent condition'),
('Helmet', 'Smith', 'Vantage', 'M', 'Available', '2023-11-05', NULL, '2025-03-05', 'Excellent condition'),
('Helmet', 'Smith', 'Vantage', 'L', 'Rented', '2023-11-05', NULL, '2025-03-05', 'Excellent condition'),
-- Goggles
('Goggles', 'Oakley', 'Flight Deck', 'One Size', 'Available', '2023-10-25', NULL, NULL, 'Good condition'),
('Goggles', 'Oakley', 'Flight Deck', 'One Size', 'Rented', '2023-10-25', NULL, NULL, 'Good condition'),
('Goggles', 'Smith', 'IO Mag', 'One Size', 'Available', '2023-11-01', NULL, NULL, 'Excellent condition'),
('Goggles', 'Smith', 'IO Mag', 'One Size', 'Available', '2023-11-01', NULL, NULL, 'Excellent condition'),
('Goggles', 'Anon', 'M4', 'One Size', 'Rented', '2023-11-10', NULL, NULL, 'Good condition');

-- ============================================================================
-- LIFT TICKETS (Individual ticket purchases)
-- ============================================================================
INSERT INTO Lift_Tickets (CustomerID, PassTypeID, PurchaseDate, ValidDate, ExpirationDate, SalePrice, TicketStatus) VALUES
(1, 1, '2024-12-01 09:00:00', '2024-12-15', '2024-12-15', 89.00, 'Active'),
(2, 1, '2024-12-02 10:30:00', '2024-12-16', '2024-12-16', 89.00, 'Used'),
(3, 2, '2024-12-03 08:15:00', '2024-12-17', '2024-12-17', 45.00, 'Active'),
(4, 1, '2024-12-04 11:00:00', '2024-12-18', '2024-12-18', 89.00, 'Active'),
(5, 3, '2024-12-05 09:30:00', '2024-12-19', '2024-12-19', 65.00, 'Used'),
(6, 1, '2024-12-06 10:00:00', '2024-12-20', '2024-12-20', 89.00, 'Active'),
(7, 4, '2024-12-01 08:00:00', '2024-12-15', '2024-12-17', 240.00, 'Active'),
(8, 1, '2024-12-07 09:15:00', '2024-12-21', '2024-12-21', 89.00, 'Active'),
(9, 2, '2024-12-08 10:45:00', '2024-12-22', '2024-12-22', 45.00, 'Active'),
(10, 1, '2024-12-09 08:30:00', '2024-12-23', '2024-12-23', 89.00, 'Active'),
(11, 7, '2024-11-15 10:00:00', '2024-12-01', '2025-05-31', 899.00, 'Active'),
(12, 1, '2024-12-10 09:00:00', '2024-12-24', '2024-12-24', 89.00, 'Active'),
(13, 3, '2024-12-11 11:15:00', '2024-12-25', '2024-12-25', 65.00, 'Active'),
(14, 1, '2024-12-12 08:45:00', '2024-12-26', '2024-12-26', 89.00, 'Active'),
(15, 2, '2024-12-13 10:30:00', '2024-12-27', '2024-12-27', 45.00, 'Active'),
(16, 4, '2024-12-02 09:00:00', '2024-12-16', '2024-12-18', 240.00, 'Used'),
(17, 1, '2024-12-14 08:15:00', '2024-12-28', '2024-12-28', 89.00, 'Active'),
(18, 1, '2024-12-15 09:30:00', '2024-12-29', '2024-12-29', 89.00, 'Active'),
(19, 3, '2024-12-16 10:00:00', '2024-12-30', '2024-12-30', 65.00, 'Active'),
(20, 1, '2024-12-17 11:45:00', '2024-12-31', '2024-12-31', 89.00, 'Active'),
(21, 8, '2024-11-20 09:00:00', '2024-12-01', '2025-05-31', 449.00, 'Active'),
(22, 1, '2024-12-18 08:30:00', '2025-01-01', '2025-01-01', 89.00, 'Active'),
(23, 2, '2024-12-19 10:15:00', '2025-01-02', '2025-01-02', 45.00, 'Active'),
(24, 1, '2024-12-20 09:45:00', '2025-01-03', '2025-01-03', 89.00, 'Active'),
(25, 3, '2024-12-21 08:00:00', '2025-01-04', '2025-01-04', 65.00, 'Active'),
(26, 1, '2024-12-22 10:30:00', '2025-01-05', '2025-01-05', 89.00, 'Active'),
(27, 4, '2024-12-03 09:00:00', '2024-12-17', '2024-12-19', 240.00, 'Used'),
(28, 1, '2024-12-23 11:00:00', '2025-01-06', '2025-01-06', 89.00, 'Active'),
(29, 2, '2024-12-24 08:45:00', '2025-01-07', '2025-01-07', 45.00, 'Active'),
(30, 1, '2024-12-25 09:15:00', '2025-01-08', '2025-01-08', 89.00, 'Active'),
(31, 9, '2024-11-25 10:00:00', '2024-12-01', '2025-05-31', 599.00, 'Active'),
(32, 1, '2024-12-26 08:30:00', '2025-01-09', '2025-01-09', 89.00, 'Active'),
(33, 1, '2024-12-27 10:45:00', '2025-01-10', '2025-01-10', 89.00, 'Active'),
(34, 2, '2024-12-28 09:00:00', '2025-01-11', '2025-01-11', 45.00, 'Active'),
(35, 1, '2024-12-29 11:30:00', '2025-01-12', '2025-01-12', 89.00, 'Active'),
(36, 3, '2024-12-30 08:15:00', '2025-01-13', '2025-01-13', 65.00, 'Active'),
(37, 1, '2024-12-31 09:45:00', '2025-01-14', '2025-01-14', 89.00, 'Active'),
(38, 4, '2024-12-04 08:00:00', '2024-12-18', '2024-12-20', 240.00, 'Used'),
(39, 1, '2025-01-01 10:00:00', '2025-01-15', '2025-01-15', 89.00, 'Active'),
(40, 1, '2025-01-02 09:30:00', '2025-01-16', '2025-01-16', 89.00, 'Active');

-- ============================================================================
-- SCHEDULED LESSONS (Lessons scheduled by instructors)
-- ============================================================================
INSERT INTO Scheduled_Lessons (InstructorID, LessonName, StartTime, EndTime, MaxCapacity, CurrentEnrollment, LessonType, LessonStatus, Price) VALUES
(1, 'Beginner Ski Group Lesson', '2024-12-15 10:00:00', '2024-12-15 12:00:00', 8, 6, 'Group', 'Scheduled', 75.00),
(2, 'Snowboard Basics', '2024-12-15 14:00:00', '2024-12-15 16:00:00', 6, 4, 'Group', 'Scheduled', 80.00),
(3, 'Advanced Ski Technique', '2024-12-16 09:00:00', '2024-12-16 11:00:00', 4, 2, 'Semi-Private', 'Scheduled', 120.00),
(4, 'Kids Ski Lesson', '2024-12-16 10:00:00', '2024-12-16 12:00:00', 10, 8, 'Group', 'Scheduled', 60.00),
(5, 'Snowboard Tricks', '2024-12-16 13:00:00', '2024-12-16 15:00:00', 5, 3, 'Group', 'Scheduled', 90.00),
(6, 'Private Ski Lesson', '2024-12-17 10:00:00', '2024-12-17 12:00:00', 1, 1, 'Private', 'Scheduled', 150.00),
(7, 'Beginner Ski Group Lesson', '2024-12-17 14:00:00', '2024-12-17 16:00:00', 8, 5, 'Group', 'Scheduled', 75.00),
(8, 'Snowboard Basics', '2024-12-18 10:00:00', '2024-12-18 12:00:00', 6, 4, 'Group', 'Scheduled', 80.00),
(9, 'Intermediate Ski Lesson', '2024-12-18 13:00:00', '2024-12-18 15:00:00', 6, 4, 'Group', 'Scheduled', 85.00),
(10, 'Advanced Ski Technique', '2024-12-19 09:00:00', '2024-12-19 11:00:00', 4, 2, 'Semi-Private', 'Scheduled', 120.00),
(11, 'Snowboard Tricks', '2024-12-19 14:00:00', '2024-12-19 16:00:00', 5, 3, 'Group', 'Scheduled', 90.00),
(12, 'Kids Ski Lesson', '2024-12-20 10:00:00', '2024-12-20 12:00:00', 10, 7, 'Group', 'Scheduled', 60.00),
(1, 'Beginner Ski Group Lesson', '2024-12-20 14:00:00', '2024-12-20 16:00:00', 8, 6, 'Group', 'Scheduled', 75.00),
(2, 'Snowboard Basics', '2024-12-21 10:00:00', '2024-12-21 12:00:00', 6, 4, 'Group', 'Scheduled', 80.00),
(3, 'Private Ski Lesson', '2024-12-21 13:00:00', '2024-12-21 15:00:00', 1, 1, 'Private', 'Scheduled', 150.00);

-- ============================================================================
-- RENTALS (Rental transactions)
-- ============================================================================
INSERT INTO Rentals (CustomerID, RentalDate, ExpectedReturnDate, ActualReturnDate, TotalPrice, RentalStatus) VALUES
(1, '2024-12-10 09:00:00', '2024-12-17 17:00:00', NULL, 280.00, 'Active'),
(2, '2024-12-11 10:30:00', '2024-12-18 17:00:00', '2024-12-18 16:30:00', 320.00, 'Returned'),
(3, '2024-12-12 08:15:00', '2024-12-19 17:00:00', NULL, 240.00, 'Active'),
(4, '2024-12-13 11:00:00', '2024-12-20 17:00:00', NULL, 300.00, 'Active'),
(5, '2024-12-14 09:30:00', '2024-12-21 17:00:00', '2024-12-21 16:45:00', 260.00, 'Returned'),
(6, '2024-12-15 10:00:00', '2024-12-22 17:00:00', NULL, 350.00, 'Active'),
(7, '2024-12-16 08:00:00', '2024-12-23 17:00:00', NULL, 290.00, 'Active'),
(8, '2024-12-17 09:15:00', '2024-12-24 17:00:00', NULL, 310.00, 'Active'),
(9, '2024-12-18 10:45:00', '2024-12-25 17:00:00', NULL, 270.00, 'Active'),
(10, '2024-12-19 08:30:00', '2024-12-26 17:00:00', NULL, 330.00, 'Active'),
(11, '2024-12-20 09:00:00', '2024-12-27 17:00:00', NULL, 280.00, 'Active'),
(12, '2024-12-21 10:15:00', '2024-12-28 17:00:00', NULL, 300.00, 'Active'),
(13, '2024-12-22 11:00:00', '2024-12-29 17:00:00', NULL, 250.00, 'Active'),
(14, '2024-12-23 08:45:00', '2024-12-30 17:00:00', NULL, 340.00, 'Active'),
(15, '2024-12-24 10:30:00', '2024-12-31 17:00:00', NULL, 290.00, 'Active'),
(16, '2024-12-25 09:00:00', '2025-01-01 17:00:00', NULL, 320.00, 'Active'),
(17, '2024-12-26 08:15:00', '2025-01-02 17:00:00', NULL, 280.00, 'Active'),
(18, '2024-12-27 09:30:00', '2025-01-03 17:00:00', NULL, 310.00, 'Active'),
(19, '2024-12-28 10:00:00', '2025-01-04 17:00:00', NULL, 270.00, 'Active'),
(20, '2024-12-29 11:45:00', '2025-01-05 17:00:00', NULL, 350.00, 'Active');

-- ============================================================================
-- ENROLLMENTS (Bridge table: Customers ↔ Scheduled_Lessons)
-- ============================================================================
INSERT INTO Enrollments (CustomerID, LessonID, EnrollmentDate, PaymentStatus, PaymentAmount, Notes) VALUES
-- Lesson 1 (Beginner Ski Group - 6 enrolled)
(1, 1, '2024-12-10 09:00:00', 'Paid', 75.00, NULL),
(2, 1, '2024-12-10 09:15:00', 'Paid', 75.00, NULL),
(3, 1, '2024-12-10 10:00:00', 'Paid', 75.00, NULL),
(4, 1, '2024-12-11 08:30:00', 'Paid', 75.00, NULL),
(5, 1, '2024-12-11 09:00:00', 'Paid', 75.00, NULL),
(6, 1, '2024-12-12 10:00:00', 'Paid', 75.00, NULL),
-- Lesson 2 (Snowboard Basics - 4 enrolled)
(7, 2, '2024-12-10 11:00:00', 'Paid', 80.00, NULL),
(8, 2, '2024-12-10 11:30:00', 'Paid', 80.00, NULL),
(9, 2, '2024-12-11 09:00:00', 'Paid', 80.00, NULL),
(10, 2, '2024-12-11 10:00:00', 'Paid', 80.00, NULL),
-- Lesson 3 (Advanced Ski Technique - 2 enrolled)
(11, 3, '2024-12-11 08:00:00', 'Paid', 120.00, NULL),
(12, 3, '2024-12-11 08:30:00', 'Paid', 120.00, NULL),
-- Lesson 4 (Kids Ski Lesson - 8 enrolled)
(13, 4, '2024-12-11 09:00:00', 'Paid', 60.00, NULL),
(14, 4, '2024-12-11 09:15:00', 'Paid', 60.00, NULL),
(15, 4, '2024-12-11 10:00:00', 'Paid', 60.00, NULL),
(16, 4, '2024-12-12 08:00:00', 'Paid', 60.00, NULL),
(17, 4, '2024-12-12 08:30:00', 'Paid', 60.00, NULL),
(18, 4, '2024-12-12 09:00:00', 'Paid', 60.00, NULL),
(19, 4, '2024-12-12 10:00:00', 'Paid', 60.00, NULL),
(20, 4, '2024-12-13 08:00:00', 'Paid', 60.00, NULL),
-- Lesson 5 (Snowboard Tricks - 3 enrolled)
(21, 5, '2024-12-12 09:00:00', 'Paid', 90.00, NULL),
(22, 5, '2024-12-12 09:30:00', 'Paid', 90.00, NULL),
(23, 5, '2024-12-13 08:00:00', 'Paid', 90.00, NULL),
-- Lesson 6 (Private Ski Lesson - 1 enrolled)
(24, 6, '2024-12-13 09:00:00', 'Paid', 150.00, 'Private lesson'),
-- Lesson 7 (Beginner Ski Group - 5 enrolled)
(25, 7, '2024-12-13 10:00:00', 'Paid', 75.00, NULL),
(26, 7, '2024-12-13 10:30:00', 'Paid', 75.00, NULL),
(27, 7, '2024-12-14 08:00:00', 'Paid', 75.00, NULL),
(28, 7, '2024-12-14 09:00:00', 'Paid', 75.00, NULL),
(29, 7, '2024-12-14 10:00:00', 'Paid', 75.00, NULL),
-- Lesson 8 (Snowboard Basics - 4 enrolled)
(30, 8, '2024-12-14 08:00:00', 'Paid', 80.00, NULL),
(31, 8, '2024-12-14 09:00:00', 'Paid', 80.00, NULL),
(32, 8, '2024-12-15 08:00:00', 'Paid', 80.00, NULL),
(33, 8, '2024-12-15 09:00:00', 'Paid', 80.00, NULL),
-- Lesson 9 (Intermediate Ski Lesson - 4 enrolled)
(34, 9, '2024-12-15 08:00:00', 'Paid', 85.00, NULL),
(35, 9, '2024-12-15 09:00:00', 'Paid', 85.00, NULL),
(36, 9, '2024-12-16 08:00:00', 'Paid', 85.00, NULL),
(37, 9, '2024-12-16 09:00:00', 'Paid', 85.00, NULL),
-- Lesson 10 (Advanced Ski Technique - 2 enrolled)
(38, 10, '2024-12-16 08:00:00', 'Paid', 120.00, NULL),
(39, 10, '2024-12-16 08:30:00', 'Paid', 120.00, NULL),
-- Lesson 11 (Snowboard Tricks - 3 enrolled)
(40, 11, '2024-12-17 08:00:00', 'Paid', 90.00, NULL),
(41, 11, '2024-12-17 09:00:00', 'Paid', 90.00, NULL),
(42, 11, '2024-12-17 10:00:00', 'Paid', 90.00, NULL),
-- Lesson 12 (Kids Ski Lesson - 7 enrolled)
(43, 12, '2024-12-17 08:00:00', 'Paid', 60.00, NULL),
(44, 12, '2024-12-17 09:00:00', 'Paid', 60.00, NULL),
(45, 12, '2024-12-18 08:00:00', 'Paid', 60.00, NULL),
(46, 12, '2024-12-18 09:00:00', 'Paid', 60.00, NULL),
(47, 12, '2024-12-18 10:00:00', 'Paid', 60.00, NULL),
(48, 12, '2024-12-19 08:00:00', 'Paid', 60.00, NULL),
(49, 12, '2024-12-19 09:00:00', 'Paid', 60.00, NULL),
-- Lesson 13 (Beginner Ski Group - 6 enrolled)
(50, 13, '2024-12-19 08:00:00', 'Paid', 75.00, NULL),
(1, 13, '2024-12-19 09:00:00', 'Paid', 75.00, NULL),
(2, 13, '2024-12-19 10:00:00', 'Paid', 75.00, NULL),
(3, 13, '2024-12-20 08:00:00', 'Paid', 75.00, NULL),
(4, 13, '2024-12-20 09:00:00', 'Paid', 75.00, NULL),
(5, 13, '2024-12-20 10:00:00', 'Paid', 75.00, NULL),
-- Lesson 14 (Snowboard Basics - 4 enrolled)
(6, 14, '2024-12-20 08:00:00', 'Paid', 80.00, NULL),
(7, 14, '2024-12-20 09:00:00', 'Paid', 80.00, NULL),
(8, 14, '2024-12-21 08:00:00', 'Paid', 80.00, NULL),
(9, 14, '2024-12-21 09:00:00', 'Paid', 80.00, NULL),
-- Lesson 15 (Private Ski Lesson - 1 enrolled)
(10, 15, '2024-12-21 08:00:00', 'Paid', 150.00, 'Private lesson');

-- ============================================================================
-- RENTAL ITEMS (Bridge table: Rentals ↔ Equipment)
-- ============================================================================
INSERT INTO Rental_Items (RentalID, EquipmentID, Quantity, UnitPrice) VALUES
-- Rental 1: Skis, Boots, Poles, Helmet
(1, 1, 1, 50.00),  -- Ski
(1, 17, 1, 30.00), -- Boots
(1, 21, 1, 10.00), -- Poles
(1, 26, 1, 15.00), -- Helmet
-- Rental 2: Snowboard, Boots, Helmet, Goggles
(2, 11, 1, 60.00), -- Snowboard
(2, 23, 1, 35.00), -- Boots
(2, 27, 1, 15.00), -- Helmet
(2, 33, 1, 20.00), -- Goggles
-- Rental 3: Skis, Boots, Poles
(3, 2, 1, 50.00),  -- Ski
(3, 18, 1, 30.00), -- Boots
(3, 22, 1, 10.00), -- Poles
-- Rental 4: Complete ski package
(4, 5, 1, 55.00),  -- Ski
(4, 19, 1, 32.00), -- Boots
(4, 23, 1, 12.00), -- Poles
(4, 28, 1, 18.00), -- Helmet
(4, 34, 1, 22.00), -- Goggles
-- Rental 5: Snowboard package
(5, 12, 1, 60.00), -- Snowboard
(5, 24, 1, 35.00), -- Boots
(5, 28, 1, 18.00), -- Helmet
-- Rental 6: Premium ski package
(6, 9, 1, 65.00),  -- Ski
(6, 20, 1, 38.00), -- Boots
(6, 24, 1, 12.00), -- Poles
(6, 29, 1, 20.00), -- Helmet
(6, 35, 1, 25.00), -- Goggles
-- Rental 7: Basic ski rental
(7, 3, 1, 50.00),  -- Ski
(7, 19, 1, 32.00), -- Boots
(7, 23, 1, 12.00), -- Poles
-- Rental 8: Snowboard rental
(8, 13, 1, 60.00), -- Snowboard
(8, 25, 1, 35.00), -- Boots
(8, 29, 1, 20.00), -- Helmet
-- Rental 9: Ski package
(9, 4, 1, 50.00),  -- Ski
(9, 17, 1, 30.00), -- Boots
(9, 21, 1, 10.00), -- Poles
(9, 26, 1, 15.00), -- Helmet
-- Rental 10: Complete package
(10, 6, 1, 55.00),  -- Ski
(10, 20, 1, 38.00), -- Boots
(10, 24, 1, 12.00), -- Poles
(10, 30, 1, 22.00), -- Helmet
(10, 36, 1, 28.00), -- Goggles
-- Rental 11: Basic rental
(11, 1, 1, 50.00),  -- Ski
(11, 17, 1, 30.00), -- Boots
(11, 21, 1, 10.00), -- Poles
-- Rental 12: Snowboard package
(12, 14, 1, 60.00), -- Snowboard
(12, 23, 1, 35.00), -- Boots
(12, 27, 1, 15.00), -- Helmet
(12, 33, 1, 20.00), -- Goggles
-- Rental 13: Ski rental
(13, 2, 1, 50.00),  -- Ski
(13, 18, 1, 30.00), -- Boots
(13, 22, 1, 10.00), -- Poles
-- Rental 14: Premium package
(14, 7, 1, 55.00),  -- Ski
(14, 21, 1, 38.00), -- Boots
(14, 25, 1, 12.00), -- Poles
(14, 31, 1, 22.00), -- Helmet
(14, 37, 1, 28.00), -- Goggles
-- Rental 15: Basic rental
(15, 3, 1, 50.00),  -- Ski
(15, 19, 1, 32.00), -- Boots
(15, 23, 1, 12.00), -- Poles
-- Rental 16: Snowboard rental
(16, 15, 1, 60.00), -- Snowboard
(16, 24, 1, 35.00), -- Boots
(16, 28, 1, 18.00), -- Helmet
-- Rental 17: Ski package
(17, 4, 1, 50.00),  -- Ski
(17, 17, 1, 30.00), -- Boots
(17, 21, 1, 10.00), -- Poles
(17, 26, 1, 15.00), -- Helmet
-- Rental 18: Complete package
(18, 8, 1, 55.00),  -- Ski
(18, 20, 1, 38.00), -- Boots
(18, 24, 1, 12.00), -- Poles
(18, 30, 1, 22.00), -- Helmet
(18, 36, 1, 28.00), -- Goggles
-- Rental 19: Basic rental
(19, 1, 1, 50.00),  -- Ski
(19, 17, 1, 30.00), -- Boots
(19, 21, 1, 10.00), -- Poles
-- Rental 20: Premium package
(20, 9, 1, 65.00),  -- Ski
(20, 21, 1, 38.00), -- Boots
(20, 25, 1, 12.00), -- Poles
(20, 31, 1, 22.00), -- Helmet
(20, 37, 1, 28.00); -- Goggles

-- ============================================================================
-- MAINTENANCE STAFF (Maintenance personnel)
-- ============================================================================
INSERT INTO Maintenance_Staff (FirstName, LastName, Email, Phone, Specialty, HireDate, IsActive) VALUES
('Robert', 'Chen', 'robert.chen@skiresort.com', '555-2001', 'Lifts', '2018-05-15', TRUE),
('Patricia', 'Martinez', 'patricia.martinez@skiresort.com', '555-2002', 'Equipment', '2019-06-01', TRUE),
('James', 'Anderson', 'james.anderson@skiresort.com', '555-2003', 'Trails', '2018-10-20', TRUE),
('Linda', 'Taylor', 'linda.taylor@skiresort.com', '555-2004', 'Facilities', '2020-03-10', TRUE),
('Michael', 'Thomas', 'michael.thomas@skiresort.com', '555-2005', 'Lifts', '2019-11-15', TRUE),
('Barbara', 'Jackson', 'barbara.jackson@skiresort.com', '555-2006', 'Equipment', '2021-04-01', TRUE),
('William', 'White', 'william.white@skiresort.com', '555-2007', 'Trails', '2020-09-20', TRUE),
('Elizabeth', 'Harris', 'elizabeth.harris@skiresort.com', '555-2008', 'General', '2021-05-10', TRUE),
('David', 'Martin', 'david.martin@skiresort.com', '555-2009', 'Lifts', '2018-08-25', TRUE),
('Jennifer', 'Thompson', 'jennifer.thompson@skiresort.com', '555-2010', 'Equipment', '2019-12-01', TRUE),
('Richard', 'Garcia', 'richard.garcia@skiresort.com', '555-2011', 'Trails', '2020-07-15', TRUE),
('Susan', 'Martinez', 'susan.martinez@skiresort.com', '555-2012', 'Facilities', '2021-02-20', TRUE),
('Joseph', 'Robinson', 'joseph.robinson@skiresort.com', '555-2013', 'General', '2022-01-10', TRUE),
('Jessica', 'Clark', 'jessica.clark@skiresort.com', '555-2014', 'Lifts', '2021-08-05', TRUE),
('Thomas', 'Rodriguez', 'thomas.rodriguez@skiresort.com', '555-2015', 'Equipment', '2022-03-15', TRUE);

-- ============================================================================
-- LIFT MAINTENANCE LOGS (Maintenance records for lifts)
-- ============================================================================
INSERT INTO Lift_Maintenance_Logs (LiftID, StaffID, MaintenanceType, Description, Priority, Status, ScheduledDate, StartedDate, CompletedDate, EstimatedCost, ActualCost, Notes) VALUES
(8, 1, 'Repair', 'T-Bar cable tension adjustment needed', 'High', 'Completed', '2024-12-01 08:00:00', '2024-12-01 08:30:00', '2024-12-01 14:00:00', 500.00, 475.00, 'Cable tension adjusted, lift operational'),
(5, 1, 'Routine', 'Monthly safety inspection of Summit Gondola', 'Medium', 'Completed', '2024-12-05 07:00:00', '2024-12-05 07:15:00', '2024-12-05 10:30:00', 200.00, 200.00, 'All safety systems checked and verified'),
(4, 5, 'Routine', 'Weekly maintenance check on Mountain Express', 'Low', 'Completed', '2024-12-10 06:00:00', '2024-12-10 06:00:00', '2024-12-10 07:30:00', 150.00, 150.00, 'Routine lubrication and inspection'),
(7, 9, 'Inspection', 'Annual inspection of Eagle Peak Chair', 'Medium', 'Completed', '2024-12-08 08:00:00', '2024-12-08 08:00:00', '2024-12-08 16:00:00', 1000.00, 950.00, 'Full system inspection completed'),
(12, 1, 'Emergency', 'Gondola door mechanism malfunction', 'Critical', 'Completed', '2024-12-12 14:00:00', '2024-12-12 14:15:00', '2024-12-12 18:00:00', 800.00, 825.00, 'Door mechanism replaced, lift operational'),
(3, 5, 'Routine', 'Weekly maintenance on Beginner Chair', 'Low', 'Completed', '2024-12-15 06:00:00', '2024-12-15 06:00:00', '2024-12-15 07:00:00', 100.00, 100.00, 'Routine check completed'),
(6, 9, 'Repair', 'Thunder Lift motor bearing replacement', 'High', 'In Progress', '2024-12-18 08:00:00', '2024-12-18 08:30:00', NULL, 1200.00, NULL, 'Bearing replacement in progress'),
(9, 1, 'Routine', 'Monthly inspection of Sunset Express', 'Medium', 'Scheduled', '2024-12-20 07:00:00', NULL, NULL, 200.00, NULL, 'Scheduled for next week'),
(11, 5, 'Routine', 'Weekly maintenance on Powder Bowl Lift', 'Low', 'Scheduled', '2024-12-22 06:00:00', NULL, NULL, 150.00, NULL, 'Routine maintenance scheduled'),
(1, 14, 'Routine', 'Daily check of Magic Carpet 1', 'Low', 'Completed', '2024-12-14 06:00:00', '2024-12-14 06:00:00', '2024-12-14 06:30:00', 50.00, 50.00, 'Daily inspection completed'),
(2, 14, 'Routine', 'Daily check of Magic Carpet 2', 'Low', 'Completed', '2024-12-14 06:00:00', '2024-12-14 06:00:00', '2024-12-14 06:30:00', 50.00, 50.00, 'Daily inspection completed'),
(10, 1, 'Inspection', 'Quarterly inspection of Family Fun Lift', 'Medium', 'Completed', '2024-12-11 08:00:00', '2024-12-11 08:00:00', '2024-12-11 12:00:00', 300.00, 300.00, 'Quarterly inspection completed');

-- ============================================================================
-- EQUIPMENT MAINTENANCE LOGS (Maintenance records for rental equipment)
-- ============================================================================
INSERT INTO Equipment_Maintenance_Logs (EquipmentID, StaffID, MaintenanceType, Description, Priority, Status, ScheduledDate, StartedDate, CompletedDate, Cost, PartsUsed, Notes) VALUES
(10, 2, 'Repair', 'Edge tuning required on Salomon QST 92 skis', 'Medium', 'Completed', '2024-12-01 09:00:00', '2024-12-01 09:15:00', '2024-12-01 11:00:00', 25.00, 'Edge file, wax', 'Edges sharpened and waxed'),
(3, 2, 'Routine', 'Regular maintenance check on rented skis', 'Low', 'Completed', '2024-12-05 10:00:00', '2024-12-05 10:00:00', '2024-12-05 10:30:00', 15.00, 'Wax', 'Routine waxing completed'),
(7, 6, 'Repair', 'Binding adjustment needed on Atomic Vantage skis', 'Medium', 'Completed', '2024-12-08 09:00:00', '2024-12-08 09:30:00', '2024-12-08 11:30:00', 40.00, 'Binding parts', 'Binding adjusted and tested'),
(12, 6, 'Routine', 'Regular maintenance on Burton Custom snowboard', 'Low', 'Completed', '2024-12-10 10:00:00', '2024-12-10 10:00:00', '2024-12-10 10:45:00', 20.00, 'Wax', 'Board waxed and edges checked'),
(19, 10, 'Repair', 'Boot buckle replacement on Rossignol boots', 'Medium', 'Completed', '2024-12-12 11:00:00', '2024-12-12 11:15:00', '2024-12-12 12:00:00', 30.00, 'Buckle assembly', 'Buckle replaced and tested'),
(24, 10, 'Routine', 'Regular maintenance check on Atomic boots', 'Low', 'Completed', '2024-12-15 10:00:00', '2024-12-15 10:00:00', '2024-12-15 10:30:00', 10.00, NULL, 'Cleaning and inspection completed'),
(28, 15, 'Repair', 'Helmet strap replacement on Giro Range helmet', 'Low', 'Completed', '2024-12-18 09:00:00', '2024-12-18 09:15:00', '2024-12-18 09:45:00', 15.00, 'Helmet strap', 'Strap replaced'),
(23, 2, 'Routine', 'Regular maintenance on Burton snowboard boots', 'Low', 'Completed', '2024-12-20 10:00:00', '2024-12-20 10:00:00', '2024-12-20 10:30:00', 12.00, NULL, 'Cleaning and inspection'),
(16, 6, 'Repair', 'Snowboard edge repair on Ride War Pig', 'High', 'In Progress', '2024-12-22 09:00:00', '2024-12-22 09:30:00', NULL, 50.00, 'Edge material', 'Edge repair in progress'),
(35, 10, 'Routine', 'Regular maintenance on Oakley Flight Deck goggles', 'Low', 'Completed', '2024-12-14 11:00:00', '2024-12-14 11:00:00', '2024-12-14 11:15:00', 5.00, 'Lens cleaner', 'Lens cleaned and inspected'),
(21, 2, 'Routine', 'Regular maintenance on Leki Carbon poles', 'Low', 'Completed', '2024-12-16 10:00:00', '2024-12-16 10:00:00', '2024-12-16 10:20:00', 8.00, NULL, 'Pole inspection completed'),
(27, 15, 'Inspection', 'Annual safety inspection on Smith Vantage helmet', 'Medium', 'Completed', '2024-12-19 09:00:00', '2024-12-19 09:00:00', '2024-12-19 09:30:00', 20.00, NULL, 'Safety inspection passed'),
(33, 6, 'Routine', 'Regular maintenance on Smith IO Mag goggles', 'Low', 'Scheduled', '2024-12-23 10:00:00', NULL, NULL, 5.00, NULL, 'Scheduled for maintenance'),
(1, 2, 'Routine', 'Regular maintenance on Rossignol Experience skis', 'Low', 'Completed', '2024-12-17 10:00:00', '2024-12-17 10:00:00', '2024-12-17 10:45:00', 18.00, 'Wax', 'Routine waxing completed'),
(11, 6, 'Repair', 'Snowboard base repair on Burton Custom', 'Medium', 'Scheduled', '2024-12-24 09:00:00', NULL, NULL, 45.00, 'P-tex', 'Base repair scheduled');

-- ============================================================================
-- TRAIL MAINTENANCE LOGS (Maintenance records for ski trails)
-- ============================================================================
INSERT INTO Trail_Maintenance_Logs (TrailID, StaffID, MaintenanceType, Description, Priority, Status, ScheduledDate, StartedDate, CompletedDate, WeatherConditions, SnowDepth, Cost, Notes) VALUES
(1, 3, 'Grooming', 'Daily grooming of Bunny Slope', 'Low', 'Completed', '2024-12-14 04:00:00', '2024-12-14 04:00:00', '2024-12-14 05:30:00', 'Clear, -5°C', 45, 200.00, 'Trail groomed and ready'),
(2, 3, 'Grooming', 'Daily grooming of Green Circle', 'Low', 'Completed', '2024-12-14 04:00:00', '2024-12-14 04:00:00', '2024-12-14 06:00:00', 'Clear, -5°C', 50, 250.00, 'Trail groomed and ready'),
(4, 7, 'Grooming', 'Daily grooming of Blue Moon intermediate trail', 'Low', 'Completed', '2024-12-14 04:30:00', '2024-12-14 04:30:00', '2024-12-14 06:30:00', 'Clear, -5°C', 55, 300.00, 'Trail groomed and ready'),
(7, 7, 'Snow Making', 'Snow making on Black Diamond advanced trail', 'Medium', 'Completed', '2024-12-10 20:00:00', '2024-12-10 20:00:00', '2024-12-11 06:00:00', 'Cold, -8°C', 40, 800.00, 'Snow making completed, trail ready'),
(11, 3, 'Repair', 'Safety barrier repair on Backcountry Access trail', 'High', 'Completed', '2024-12-08 08:00:00', '2024-12-08 08:30:00', '2024-12-08 14:00:00', 'Cloudy, -3°C', 60, 500.00, 'Safety barriers repaired'),
(8, 7, 'Grooming', 'Daily grooming of Powder Bowl', 'Low', 'Completed', '2024-12-14 05:00:00', '2024-12-14 05:00:00', '2024-12-14 07:00:00', 'Clear, -5°C', 65, 350.00, 'Powder bowl groomed'),
(12, 3, 'Grooming', 'Daily grooming of Family Fun trail', 'Low', 'Completed', '2024-12-14 04:00:00', '2024-12-14 04:00:00', '2024-12-14 05:45:00', 'Clear, -5°C', 48, 220.00, 'Family trail groomed'),
(13, 7, 'Grooming', 'Daily grooming of Sunset Ridge', 'Low', 'Completed', '2024-12-14 04:30:00', '2024-12-14 04:30:00', '2024-12-14 06:15:00', 'Clear, -5°C', 52, 280.00, 'Trail groomed'),
(14, 7, 'Snow Making', 'Snow making on Morning Glory advanced trail', 'Medium', 'Completed', '2024-12-11 20:00:00', '2024-12-11 20:00:00', '2024-12-12 06:00:00', 'Cold, -7°C', 45, 750.00, 'Snow making completed'),
(15, 7, 'Safety Inspection', 'Safety inspection of Eagle Peak expert trail', 'High', 'Completed', '2024-12-09 08:00:00', '2024-12-09 08:00:00', '2024-12-09 12:00:00', 'Clear, -4°C', 70, 400.00, 'Safety inspection completed, trail safe'),
(3, 3, 'Grooming', 'Daily grooming of Easy Rider beginner trail', 'Low', 'Completed', '2024-12-14 04:15:00', '2024-12-14 04:15:00', '2024-12-14 06:15:00', 'Clear, -5°C', 50, 270.00, 'Trail groomed'),
(5, 7, 'Grooming', 'Daily grooming of Mountain View intermediate trail', 'Low', 'Completed', '2024-12-14 04:30:00', '2024-12-14 04:30:00', '2024-12-14 06:45:00', 'Clear, -5°C', 55, 320.00, 'Trail groomed'),
(6, 7, 'Grooming', 'Daily grooming of Thunder Ridge intermediate trail', 'Low', 'Completed', '2024-12-14 04:45:00', '2024-12-14 04:45:00', '2024-12-14 07:00:00', 'Clear, -5°C', 58, 340.00, 'Trail groomed'),
(9, 7, 'Signage', 'Trail marker replacement on Extreme Run', 'Medium', 'Completed', '2024-12-07 09:00:00', '2024-12-07 09:30:00', '2024-12-07 13:00:00', 'Cloudy, -2°C', 65, 150.00, 'Trail markers replaced'),
(10, 7, 'Repair', 'Rock removal and trail repair on Cliff Drop', 'High', 'Completed', '2024-12-06 08:00:00', '2024-12-06 08:30:00', '2024-12-06 15:00:00', 'Clear, -3°C', 60, 600.00, 'Rocks removed, trail repaired');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- Data Summary
-- ============================================================================
-- Customers: 50 rows
-- Pass_Types: 10 rows
-- Instructors: 12 rows
-- Trails: 15 rows
-- Lifts: 12 rows
-- Lift_Access: 25 rows (bridge table)
-- Equipment: 35 rows
-- Lift_Tickets: 40 rows
-- Scheduled_Lessons: 15 rows
-- Rentals: 20 rows
-- Enrollments: 60 rows (bridge table)
-- Rental_Items: 65 rows (bridge table)
-- Maintenance_Staff: 15 rows
-- Lift_Maintenance_Logs: 12 rows
-- Equipment_Maintenance_Logs: 15 rows
-- Trail_Maintenance_Logs: 15 rows
-- Total: 400 rows (well above 100 requirement)

