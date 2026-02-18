-- ============================================================================
-- Event Ticketing & Seating System - Sample Data
-- COMP 345 Final Project Reference Implementation
-- ============================================================================

USE event_ticketing;

-- Disable foreign key checks for faster loading
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- VENUES (5 venues)
-- ============================================================================
INSERT INTO venues (venue_name, address, city, state_province, country, postal_code, total_capacity, venue_type, contact_email, contact_phone) VALUES
('Madison Square Garden', '4 Pennsylvania Plaza', 'New York', 'NY', 'USA', '10001', 20789, 'arena', 'info@msg.com', '212-465-6741'),
('Hollywood Bowl', '2301 N Highland Ave', 'Los Angeles', 'CA', 'USA', '90068', 17500, 'outdoor', 'info@hollywoodbowl.com', '323-850-2000'),
('Red Rocks Amphitheatre', '18300 W Alameda Pkwy', 'Morrison', 'CO', 'USA', '80465', 9525, 'outdoor', 'info@redrocks.com', '720-865-2494'),
('The Orpheum Theatre', '842 S Broadway', 'Los Angeles', 'CA', 'USA', '90014', 2000, 'theater', 'info@orpheum-la.com', '877-677-4386'),
('AT&T Stadium', 'One AT&T Way', 'Arlington', 'TX', 'USA', '76011', 80000, 'stadium', 'info@attstadium.com', '817-892-4000');

-- ============================================================================
-- SECTIONS (20 sections across venues)
-- ============================================================================
INSERT INTO sections (venue_id, section_name, section_type, total_seats) VALUES
-- Madison Square Garden (venue_id = 1)
(1, 'Floor A', 'floor', 500),
(1, 'Floor B', 'floor', 500),
(1, 'Lower Bowl', 'lower_level', 8000),
(1, 'Upper Bowl', 'upper_level', 10000),
(1, 'VIP Suites', 'vip', 289),
-- Hollywood Bowl (venue_id = 2)
(2, 'Pool Circle', 'vip', 1000),
(2, 'Garden Boxes', 'box', 2500),
(2, 'Terrace', 'lower_level', 6000),
(2, 'Bench Seating', 'upper_level', 8000),
-- Red Rocks (venue_id = 3)
(3, 'Reserved Rows 1-20', 'lower_level', 2000),
(3, 'Reserved Rows 21-40', 'lower_level', 2500),
(3, 'Reserved Rows 41-70', 'upper_level', 5025),
-- Orpheum Theatre (venue_id = 4)
(4, 'Orchestra', 'floor', 800),
(4, 'Mezzanine', 'lower_level', 600),
(4, 'Balcony', 'balcony', 600),
-- AT&T Stadium (venue_id = 5)
(5, 'Field Level', 'floor', 10000),
(5, 'Lower Bowl', 'lower_level', 30000),
(5, 'Upper Bowl', 'upper_level', 35000),
(5, 'Club Seats', 'vip', 5000);

-- ============================================================================
-- SEATS (100+ seats - focusing on smaller sections for manageability)
-- ============================================================================
-- Orpheum Theatre Orchestra Section (50 seats)
INSERT INTO seats (section_id, row_label, seat_number, accessibility_features) VALUES
-- Row A (10 seats)
(13, 'A', '1', 'aisle'), (13, 'A', '2', 'none'), (13, 'A', '3', 'none'), (13, 'A', '4', 'none'), (13, 'A', '5', 'none'),
(13, 'A', '6', 'none'), (13, 'A', '7', 'none'), (13, 'A', '8', 'none'), (13, 'A', '9', 'none'), (13, 'A', '10', 'aisle'),
-- Row B (10 seats)
(13, 'B', '1', 'aisle'), (13, 'B', '2', 'none'), (13, 'B', '3', 'none'), (13, 'B', '4', 'none'), (13, 'B', '5', 'none'),
(13, 'B', '6', 'none'), (13, 'B', '7', 'none'), (13, 'B', '8', 'none'), (13, 'B', '9', 'none'), (13, 'B', '10', 'aisle'),
-- Row C (10 seats)
(13, 'C', '1', 'aisle'), (13, 'C', '2', 'wheelchair'), (13, 'C', '3', 'companion'), (13, 'C', '4', 'none'), (13, 'C', '5', 'none'),
(13, 'C', '6', 'none'), (13, 'C', '7', 'none'), (13, 'C', '8', 'none'), (13, 'C', '9', 'none'), (13, 'C', '10', 'aisle'),
-- Row D (10 seats)
(13, 'D', '1', 'aisle'), (13, 'D', '2', 'none'), (13, 'D', '3', 'none'), (13, 'D', '4', 'none'), (13, 'D', '5', 'none'),
(13, 'D', '6', 'none'), (13, 'D', '7', 'none'), (13, 'D', '8', 'none'), (13, 'D', '9', 'none'), (13, 'D', '10', 'aisle'),
-- Row E (10 seats)
(13, 'E', '1', 'aisle'), (13, 'E', '2', 'none'), (13, 'E', '3', 'none'), (13, 'E', '4', 'none'), (13, 'E', '5', 'none'),
(13, 'E', '6', 'none'), (13, 'E', '7', 'none'), (13, 'E', '8', 'none'), (13, 'E', '9', 'none'), (13, 'E', '10', 'aisle');

-- Orpheum Mezzanine Section (30 seats)
INSERT INTO seats (section_id, row_label, seat_number, accessibility_features) VALUES
-- Row A (10 seats)
(14, 'A', '1', 'aisle'), (14, 'A', '2', 'none'), (14, 'A', '3', 'none'), (14, 'A', '4', 'none'), (14, 'A', '5', 'none'),
(14, 'A', '6', 'none'), (14, 'A', '7', 'none'), (14, 'A', '8', 'none'), (14, 'A', '9', 'none'), (14, 'A', '10', 'aisle'),
-- Row B (10 seats)
(14, 'B', '1', 'aisle'), (14, 'B', '2', 'none'), (14, 'B', '3', 'none'), (14, 'B', '4', 'none'), (14, 'B', '5', 'none'),
(14, 'B', '6', 'none'), (14, 'B', '7', 'none'), (14, 'B', '8', 'none'), (14, 'B', '9', 'none'), (14, 'B', '10', 'aisle'),
-- Row C (10 seats)
(14, 'C', '1', 'aisle'), (14, 'C', '2', 'none'), (14, 'C', '3', 'none'), (14, 'C', '4', 'none'), (14, 'C', '5', 'none'),
(14, 'C', '6', 'none'), (14, 'C', '7', 'none'), (14, 'C', '8', 'none'), (14, 'C', '9', 'none'), (14, 'C', '10', 'aisle');

-- Red Rocks Reserved Rows (30 seats)
INSERT INTO seats (section_id, row_label, seat_number, accessibility_features) VALUES
-- Row 1 (15 seats)
(10, '1', '1', 'aisle'), (10, '1', '2', 'none'), (10, '1', '3', 'none'), (10, '1', '4', 'none'), (10, '1', '5', 'none'),
(10, '1', '6', 'none'), (10, '1', '7', 'none'), (10, '1', '8', 'none'), (10, '1', '9', 'none'), (10, '1', '10', 'none'),
(10, '1', '11', 'none'), (10, '1', '12', 'none'), (10, '1', '13', 'none'), (10, '1', '14', 'none'), (10, '1', '15', 'aisle'),
-- Row 2 (15 seats)
(10, '2', '1', 'aisle'), (10, '2', '2', 'none'), (10, '2', '3', 'none'), (10, '2', '4', 'none'), (10, '2', '5', 'none'),
(10, '2', '6', 'none'), (10, '2', '7', 'wheelchair'), (10, '2', '8', 'companion'), (10, '2', '9', 'none'), (10, '2', '10', 'none'),
(10, '2', '11', 'none'), (10, '2', '12', 'none'), (10, '2', '13', 'none'), (10, '2', '14', 'none'), (10, '2', '15', 'aisle');

-- ============================================================================
-- CUSTOMERS (50+ customers to meet data volume requirements)
-- ============================================================================
INSERT INTO customers (email, first_name, last_name, phone, date_of_birth, address, city, state_province, postal_code, country, loyalty_tier, total_lifetime_spend, account_status) VALUES
('john.smith@email.com', 'John', 'Smith', '555-0101', '1985-03-15', '123 Main St', 'New York', 'NY', '10001', 'USA', 'gold', 2500.00, 'active'),
('sarah.johnson@email.com', 'Sarah', 'Johnson', '555-0102', '1990-07-22', '456 Oak Ave', 'Los Angeles', 'CA', '90001', 'USA', 'platinum', 5000.00, 'active'),
('michael.williams@email.com', 'Michael', 'Williams', '555-0103', '1988-11-30', '789 Pine Rd', 'Chicago', 'IL', '60601', 'USA', 'silver', 1200.00, 'active'),
('emily.brown@email.com', 'Emily', 'Brown', '555-0104', '1992-05-18', '321 Elm St', 'Houston', 'TX', '77001', 'USA', 'standard', 350.00, 'active'),
('david.jones@email.com', 'David', 'Jones', '555-0105', '1987-09-25', '654 Maple Dr', 'Phoenix', 'AZ', '85001', 'USA', 'gold', 3200.00, 'active'),
('jessica.garcia@email.com', 'Jessica', 'Garcia', '555-0106', '1995-01-12', '987 Cedar Ln', 'Philadelphia', 'PA', '19019', 'USA', 'standard', 180.00, 'active'),
('james.martinez@email.com', 'James', 'Martinez', '555-0107', '1983-12-08', '147 Birch Ct', 'San Antonio', 'TX', '78201', 'USA', 'silver', 1500.00, 'active'),
('jennifer.rodriguez@email.com', 'Jennifer', 'Rodriguez', '555-0108', '1991-04-20', '258 Spruce Way', 'San Diego', 'CA', '92101', 'USA', 'platinum', 6500.00, 'active'),
('robert.hernandez@email.com', 'Robert', 'Hernandez', '555-0109', '1986-08-14', '369 Willow Pl', 'Dallas', 'TX', '75201', 'USA', 'gold', 2800.00, 'active'),
('linda.lopez@email.com', 'Linda', 'Lopez', '555-0110', '1993-06-03', '741 Ash Blvd', 'San Jose', 'CA', '95101', 'USA', 'standard', 420.00, 'active'),
('william.gonzalez@email.com', 'William', 'Gonzalez', '555-0111', '1989-10-17', '852 Poplar Ave', 'Austin', 'TX', '73301', 'USA', 'silver', 1650.00, 'active'),
('mary.wilson@email.com', 'Mary', 'Wilson', '555-0112', '1994-02-28', '963 Hickory St', 'Jacksonville', 'FL', '32099', 'USA', 'standard', 290.00, 'active'),
('richard.anderson@email.com', 'Richard', 'Anderson', '555-0113', '1984-07-11', '159 Walnut Dr', 'Fort Worth', 'TX', '76101', 'USA', 'gold', 3100.00, 'active'),
('patricia.thomas@email.com', 'Patricia', 'Thomas', '555-0114', '1990-11-24', '357 Chestnut Rd', 'Columbus', 'OH', '43004', 'USA', 'silver', 1400.00, 'active'),
('charles.taylor@email.com', 'Charles', 'Taylor', '555-0115', '1988-03-09', '486 Sycamore Ln', 'Charlotte', 'NC', '28201', 'USA', 'standard', 520.00, 'active'),
('barbara.moore@email.com', 'Barbara', 'Moore', '555-0116', '1992-09-16', '624 Magnolia Ct', 'San Francisco', 'CA', '94102', 'USA', 'platinum', 7200.00, 'active'),
('joseph.jackson@email.com', 'Joseph', 'Jackson', '555-0117', '1987-05-21', '735 Dogwood Way', 'Indianapolis', 'IN', '46201', 'USA', 'gold', 2900.00, 'active'),
('susan.martin@email.com', 'Susan', 'Martin', '555-0118', '1991-12-05', '846 Redwood Pl', 'Seattle', 'WA', '98101', 'USA', 'silver', 1750.00, 'active'),
('thomas.lee@email.com', 'Thomas', 'Lee', '555-0119', '1985-08-19', '957 Fir Blvd', 'Denver', 'CO', '80201', 'USA', 'standard', 380.00, 'active'),
('nancy.perez@email.com', 'Nancy', 'Perez', '555-0120', '1993-04-07', '168 Beech Ave', 'Washington', 'DC', '20001', 'USA', 'gold', 3400.00, 'active'),
('daniel.white@email.com', 'Daniel', 'White', '555-0121', '1989-01-26', '279 Cypress St', 'Boston', 'MA', '02101', 'USA', 'silver', 1550.00, 'active'),
('karen.harris@email.com', 'Karen', 'Harris', '555-0122', '1994-10-13', '381 Palm Dr', 'Nashville', 'TN', '37201', 'USA', 'standard', 310.00, 'active'),
('matthew.sanchez@email.com', 'Matthew', 'Sanchez', '555-0123', '1986-06-29', '492 Juniper Rd', 'Detroit', 'MI', '48201', 'USA', 'platinum', 5800.00, 'active'),
('betty.clark@email.com', 'Betty', 'Clark', '555-0124', '1991-02-14', '513 Laurel Ln', 'Portland', 'OR', '97201', 'USA', 'gold', 2700.00, 'active'),
('anthony.ramirez@email.com', 'Anthony', 'Ramirez', '555-0125', '1988-09-01', '624 Sequoia Ct', 'Las Vegas', 'NV', '89101', 'USA', 'silver', 1320.00, 'active'),
('dorothy.lewis@email.com', 'Dorothy', 'Lewis', '555-0126', '1992-05-18', '735 Acacia Way', 'Memphis', 'TN', '37501', 'USA', 'standard', 270.00, 'active'),
('mark.robinson@email.com', 'Mark', 'Robinson', '555-0127', '1987-11-22', '846 Mesquite Pl', 'Louisville', 'KY', '40201', 'USA', 'gold', 3050.00, 'active'),
('lisa.walker@email.com', 'Lisa', 'Walker', '555-0128', '1990-07-08', '957 Cottonwood Blvd', 'Baltimore', 'MD', '21201', 'USA', 'silver', 1680.00, 'active'),
('donald.young@email.com', 'Donald', 'Young', '555-0129', '1985-03-25', '168 Ironwood Ave', 'Milwaukee', 'WI', '53201', 'USA', 'standard', 440.00, 'active'),
('sandra.allen@email.com', 'Sandra', 'Allen', '555-0130', '1993-12-11', '279 Boxwood St', 'Albuquerque', 'NM', '87101', 'USA', 'platinum', 6100.00, 'active'),
('paul.king@email.com', 'Paul', 'King', '555-0131', '1989-08-27', '381 Hawthorn Dr', 'Tucson', 'AZ', '85701', 'USA', 'gold', 2850.00, 'active'),
('ashley.wright@email.com', 'Ashley', 'Wright', '555-0132', '1994-04-15', '492 Buckeye Rd', 'Fresno', 'CA', '93650', 'USA', 'silver', 1420.00, 'active'),
('kevin.scott@email.com', 'Kevin', 'Scott', '555-0133', '1986-10-02', '513 Sassafras Ln', 'Sacramento', 'CA', '94203', 'USA', 'standard', 360.00, 'active'),
('kimberly.torres@email.com', 'Kimberly', 'Torres', '555-0134', '1991-06-19', '624 Mulberry Ct', 'Mesa', 'AZ', '85201', 'USA', 'gold', 3150.00, 'active'),
('brian.nguyen@email.com', 'Brian', 'Nguyen', '555-0135', '1988-02-06', '735 Alder Way', 'Kansas City', 'MO', '64101', 'USA', 'silver', 1590.00, 'active'),
('michelle.hill@email.com', 'Michelle', 'Hill', '555-0136', '1992-11-23', '846 Linden Pl', 'Atlanta', 'GA', '30301', 'USA', 'standard', 330.00, 'active'),
('george.flores@email.com', 'George', 'Flores', '555-0137', '1987-07-10', '957 Hemlock Blvd', 'Colorado Springs', 'CO', '80901', 'USA', 'platinum', 5500.00, 'active'),
('amanda.green@email.com', 'Amanda', 'Green', '555-0138', '1990-03-28', '168 Tamarack Ave', 'Raleigh', 'NC', '27601', 'USA', 'gold', 2950.00, 'active'),
('joshua.adams@email.com', 'Joshua', 'Adams', '555-0139', '1985-12-14', '279 Yew St', 'Omaha', 'NE', '68101', 'USA', 'silver', 1470.00, 'active'),
('stephanie.nelson@email.com', 'Stephanie', 'Nelson', '555-0140', '1993-08-31', '381 Locust Dr', 'Miami', 'FL', '33101', 'USA', 'standard', 395.00, 'active'),
('andrew.baker@email.com', 'Andrew', 'Baker', '555-0141', '1989-04-17', '492 Aspen Rd', 'Oakland', 'CA', '94601', 'USA', 'gold', 3250.00, 'active'),
('rebecca.hall@email.com', 'Rebecca', 'Hall', '555-0142', '1994-01-04', '513 Pecan Ln', 'Minneapolis', 'MN', '55401', 'USA', 'silver', 1630.00, 'active'),
('ryan.rivera@email.com', 'Ryan', 'Rivera', '555-0143', '1986-09-20', '624 Walnut Ct', 'Tulsa', 'OK', '74101', 'USA', 'standard', 410.00, 'active'),
('laura.campbell@email.com', 'Laura', 'Campbell', '555-0144', '1991-05-07', '735 Butternut Way', 'Cleveland', 'OH', '44101', 'USA', 'platinum', 6800.00, 'active'),
('jacob.mitchell@email.com', 'Jacob', 'Mitchell', '555-0145', '1988-01-24', '846 Hornbeam Pl', 'Wichita', 'KS', '67201', 'USA', 'gold', 2750.00, 'active'),
('samantha.roberts@email.com', 'Samantha', 'Roberts', '555-0146', '1992-10-11', '957 Rowan Blvd', 'Arlington', 'TX', '76010', 'USA', 'silver', 1510.00, 'active'),
('nicholas.carter@email.com', 'Nicholas', 'Carter', '555-0147', '1987-06-28', '168 Hazel Ave', 'New Orleans', 'LA', '70112', 'USA', 'standard', 340.00, 'active'),
('heather.phillips@email.com', 'Heather', 'Phillips', '555-0148', '1990-02-15', '279 Sumac St', 'Bakersfield', 'CA', '93301', 'USA', 'gold', 3350.00, 'active'),
('jonathan.evans@email.com', 'Jonathan', 'Evans', '555-0149', '1985-11-01', '381 Catalpa Dr', 'Tampa', 'FL', '33601', 'USA', 'silver', 1720.00, 'active'),
('melissa.turner@email.com', 'Melissa', 'Turner', '555-0150', '1993-07-19', '492 Persimmon Rd', 'Honolulu', 'HI', '96801', 'USA', 'standard', 460.00, 'active');

-- ============================================================================
-- EVENTS (10 events)
-- ============================================================================
INSERT INTO events (venue_id, event_name, event_type, event_description, event_date, event_time, doors_open_time, event_status, total_tickets_available, tickets_sold, tickets_held) VALUES
(1, 'Taylor Swift - Eras Tour', 'concert', 'The biggest pop concert of the year featuring all eras of Taylor Swift music', '2025-12-15', '20:00:00', '18:00:00', 'on_sale', 20000, 15234, 1200),
(2, 'LA Philharmonic Summer Series', 'concert', 'Classical music under the stars with the LA Philharmonic Orchestra', '2025-08-20', '19:30:00', '18:00:00', 'on_sale', 17000, 8500, 450),
(3, 'Red Rocks Jazz Festival', 'festival', 'Three-day jazz festival featuring top artists from around the world', '2025-09-10', '18:00:00', '16:00:00', 'on_sale', 9000, 6200, 300),
(4, 'Hamilton - Broadway Tour', 'theater', 'The award-winning musical about American founding father Alexander Hamilton', '2025-11-05', '19:00:00', '18:30:00', 'on_sale', 1800, 1650, 50),
(5, 'Dallas Cowboys vs NY Giants', 'sports', 'NFL regular season game - NFC East rivalry matchup', '2025-10-20', '13:00:00', '11:00:00', 'on_sale', 75000, 68000, 2000),
(1, 'Knicks vs Lakers', 'sports', 'NBA regular season game featuring two historic franchises', '2026-01-18', '19:30:00', '18:00:00', 'on_sale', 19000, 17500, 800),
(3, 'Indie Rock Showcase', 'concert', 'Emerging indie rock bands performing at the iconic Red Rocks venue', '2025-07-25', '19:00:00', '17:30:00', 'on_sale', 9000, 4200, 150),
(4, 'Stand-Up Comedy Night', 'comedy', 'An evening of laughs with top comedians', '2025-10-15', '20:00:00', '19:00:00', 'on_sale', 1900, 1200, 100),
(2, 'Summer Film Series: Casablanca', 'other', 'Classic film screening with live orchestra accompaniment', '2025-08-05', '20:00:00', '19:00:00', 'on_sale', 15000, 3500, 200),
(1, 'Billy Joel Concert', 'concert', 'Piano Man returns to Madison Square Garden for a special performance', '2026-02-28', '20:00:00', '18:30:00', 'scheduled', 20000, 0, 0);

-- ============================================================================
-- TICKET TIERS (30+ tiers across events)
-- ============================================================================
INSERT INTO ticket_tiers (event_id, section_id, tier_name, tier_level, base_price, quantity_available, quantity_sold, quantity_held, sales_start_date, sales_end_date) VALUES
-- Event 1: Taylor Swift (Madison Square Garden)
(1, 1, 'Floor VIP Package', 'vip', 850.00, 500, 480, 20, '2025-06-01 10:00:00', '2025-12-15 20:00:00'),
(1, 2, 'Floor Premium', 'premium', 550.00, 500, 450, 30, '2025-06-01 10:00:00', '2025-12-15 20:00:00'),
(1, 3, 'Lower Bowl', 'standard', 250.00, 8000, 7200, 400, '2025-06-01 10:00:00', '2025-12-15 20:00:00'),
(1, 4, 'Upper Bowl', 'budget', 125.00, 10000, 7104, 750, '2025-06-01 10:00:00', '2025-12-15 20:00:00'),
(1, 5, 'VIP Suite', 'vip', 1200.00, 289, 289, 0, '2025-06-01 10:00:00', '2025-12-15 20:00:00'),
-- Event 2: LA Phil (Hollywood Bowl)
(2, 6, 'Pool Circle Premium', 'vip', 180.00, 1000, 600, 50, '2025-05-01 09:00:00', '2025-08-20 19:30:00'),
(2, 7, 'Garden Box', 'premium', 120.00, 2500, 1800, 100, '2025-05-01 09:00:00', '2025-08-20 19:30:00'),
(2, 8, 'Terrace', 'standard', 75.00, 6000, 3500, 150, '2025-05-01 09:00:00', '2025-08-20 19:30:00'),
(2, 9, 'Bench Seating', 'budget', 35.00, 8000, 2600, 150, '2025-05-01 09:00:00', '2025-08-20 19:30:00'),
-- Event 3: Red Rocks Jazz (Red Rocks)
(3, 10, 'Reserved Premium Rows 1-20', 'premium', 150.00, 2000, 1600, 100, '2025-04-15 10:00:00', '2025-09-10 18:00:00'),
(3, 11, 'Reserved Standard Rows 21-40', 'standard', 95.00, 2500, 2000, 100, '2025-04-15 10:00:00', '2025-09-10 18:00:00'),
(3, 12, 'Reserved Budget Rows 41-70', 'budget', 60.00, 5000, 2600, 100, '2025-04-15 10:00:00', '2025-09-10 18:00:00'),
-- Event 4: Hamilton (Orpheum)
(4, 13, 'Orchestra Premium', 'premium', 295.00, 800, 750, 20, '2025-07-01 10:00:00', '2025-11-05 19:00:00'),
(4, 14, 'Mezzanine', 'standard', 185.00, 600, 550, 20, '2025-07-01 10:00:00', '2025-11-05 19:00:00'),
(4, 15, 'Balcony', 'budget', 95.00, 600, 350, 10, '2025-07-01 10:00:00', '2025-11-05 19:00:00'),
-- Event 5: Cowboys vs Giants (AT&T Stadium)
(5, 16, 'Field Level', 'vip', 450.00, 10000, 9500, 500, '2025-06-01 10:00:00', '2025-10-20 13:00:00'),
(5, 17, 'Lower Bowl', 'premium', 225.00, 30000, 28000, 800, '2025-06-01 10:00:00', '2025-10-20 13:00:00'),
(5, 18, 'Upper Bowl', 'standard', 95.00, 35000, 30000, 700, '2025-06-01 10:00:00', '2025-10-20 13:00:00'),
(5, 19, 'Club Seats', 'vip', 650.00, 5000, 500, 0, '2025-06-01 10:00:00', '2025-10-20 13:00:00'),
-- Event 6: Knicks vs Lakers (Madison Square Garden)
(6, 1, 'Floor Courtside', 'vip', 1500.00, 500, 480, 20, '2025-09-01 10:00:00', '2026-01-18 19:30:00'),
(6, 3, 'Lower Bowl', 'premium', 350.00, 8000, 7500, 300, '2025-09-01 10:00:00', '2026-01-18 19:30:00'),
(6, 4, 'Upper Bowl', 'standard', 150.00, 10000, 9520, 480, '2025-09-01 10:00:00', '2026-01-18 19:30:00'),
-- Event 7: Indie Rock (Red Rocks)
(7, 10, 'Reserved Premium', 'premium', 85.00, 2000, 1200, 50, '2025-05-01 10:00:00', '2025-07-25 19:00:00'),
(7, 11, 'Reserved Standard', 'standard', 55.00, 2500, 1800, 50, '2025-05-01 10:00:00', '2025-07-25 19:00:00'),
(7, 12, 'Reserved Budget', 'budget', 35.00, 5000, 1200, 50, '2025-05-01 10:00:00', '2025-07-25 19:00:00'),
-- Event 8: Comedy Night (Orpheum)
(8, 13, 'Orchestra', 'premium', 75.00, 800, 600, 50, '2025-08-01 10:00:00', '2025-10-15 20:00:00'),
(8, 14, 'Mezzanine', 'standard', 55.00, 600, 400, 30, '2025-08-01 10:00:00', '2025-10-15 20:00:00'),
(8, 15, 'Balcony', 'budget', 35.00, 600, 200, 20, '2025-08-01 10:00:00', '2025-10-15 20:00:00'),
-- Event 9: Film Series (Hollywood Bowl)
(9, 8, 'Terrace Premium', 'premium', 45.00, 6000, 2000, 100, '2025-06-01 10:00:00', '2025-08-05 20:00:00'),
(9, 9, 'Bench Seating', 'standard', 25.00, 9000, 1500, 100, '2025-06-01 10:00:00', '2025-08-05 20:00:00');

-- ============================================================================
-- PROMO CODES (10 promo codes)
-- ============================================================================
INSERT INTO promo_codes (promo_code, description, discount_type, discount_value, max_uses, current_uses, valid_from, valid_until, min_purchase_amount, is_active) VALUES
('SUMMER2025', 'Summer concert discount', 'percentage', 15.00, 1000, 234, '2025-06-01 00:00:00', '2025-09-01 23:59:59', 50.00, TRUE),
('EARLYBIRD', 'Early bird special - 20% off', 'percentage', 20.00, 500, 487, '2025-04-01 00:00:00', '2025-06-30 23:59:59', 100.00, TRUE),
('VIP50', 'VIP members get $50 off', 'fixed_amount', 50.00, NULL, 1523, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 200.00, TRUE),
('STUDENT10', 'Student discount', 'percentage', 10.00, NULL, 892, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 25.00, TRUE),
('FLASH25', 'Flash sale - 25% off', 'percentage', 25.00, 200, 200, '2025-07-04 00:00:00', '2025-07-04 23:59:59', 75.00, FALSE),
('LOYALTY100', 'Loyalty reward - $100 off', 'fixed_amount', 100.00, 100, 67, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 500.00, TRUE),
('WELCOME15', 'New customer welcome', 'percentage', 15.00, NULL, 2341, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 0.00, TRUE),
('GROUPSAVE', 'Group booking discount', 'percentage', 12.00, 500, 156, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 300.00, TRUE),
('WEEKEND20', 'Weekend special', 'fixed_amount', 20.00, 1000, 445, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 100.00, TRUE),
('LASTMINUTE', 'Last minute deals', 'percentage', 30.00, 300, 89, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 50.00, TRUE);

-- ============================================================================
-- ORDERS (60+ orders to meet data requirements)
-- ============================================================================
INSERT INTO orders (customer_id, order_number, order_status, order_date, hold_expires_at, confirmed_at, subtotal, discount_amount, tax_amount, total_amount, promo_id, payment_method, payment_status, ip_address) VALUES
(1, 'ORD-2025-000001', 'confirmed', '2025-06-15 14:23:15', NULL, '2025-06-15 14:25:30', 500.00, 75.00, 34.00, 459.00, 2, 'credit_card', 'captured', '192.168.1.100'),
(2, 'ORD-2025-000002', 'confirmed', '2025-06-15 15:10:22', NULL, '2025-06-15 15:12:45', 1700.00, 0.00, 136.00, 1836.00, NULL, 'credit_card', 'captured', '192.168.1.101'),
(3, 'ORD-2025-000003', 'confirmed', '2025-06-16 09:45:33', NULL, '2025-06-16 09:47:12', 250.00, 25.00, 18.00, 243.00, 4, 'debit_card', 'captured', '192.168.1.102'),
(4, 'ORD-2025-000004', 'held', '2025-11-01 10:15:44', '2025-11-01 10:30:44', NULL, 375.00, 0.00, 30.00, 405.00, NULL, NULL, 'pending', '192.168.1.103'),
(5, 'ORD-2025-000005', 'confirmed', '2025-06-17 11:20:55', NULL, '2025-06-17 11:22:30', 850.00, 0.00, 68.00, 918.00, NULL, 'apple_pay', 'captured', '192.168.1.104'),
(6, 'ORD-2025-000006', 'confirmed', '2025-06-18 13:30:11', NULL, '2025-06-18 13:32:05', 180.00, 27.00, 12.24, 165.24, 1, 'credit_card', 'captured', '192.168.1.105'),
(7, 'ORD-2025-000007', 'confirmed', '2025-06-19 16:45:22', NULL, '2025-06-19 16:47:18', 450.00, 90.00, 28.80, 388.80, 2, 'paypal', 'captured', '192.168.1.106'),
(8, 'ORD-2025-000008', 'confirmed', '2025-06-20 08:15:33', NULL, '2025-06-20 08:17:45', 1200.00, 100.00, 88.00, 1188.00, 6, 'credit_card', 'captured', '192.168.1.107'),
(9, 'ORD-2025-000009', 'confirmed', '2025-06-21 12:25:44', NULL, '2025-06-21 12:27:22', 550.00, 0.00, 44.00, 594.00, NULL, 'debit_card', 'captured', '192.168.1.108'),
(10, 'ORD-2025-000010', 'confirmed', '2025-06-22 14:35:55', NULL, '2025-06-22 14:37:30', 250.00, 37.50, 17.00, 229.50, 1, 'google_pay', 'captured', '192.168.1.109'),
(11, 'ORD-2025-000011', 'confirmed', '2025-06-23 10:40:11', NULL, '2025-06-23 10:42:15', 750.00, 0.00, 60.00, 810.00, NULL, 'credit_card', 'captured', '192.168.1.110'),
(12, 'ORD-2025-000012', 'held', '2025-11-02 11:50:22', '2025-11-02 12:05:22', NULL, 290.00, 0.00, 23.20, 313.20, NULL, NULL, 'pending', '192.168.1.111'),
(13, 'ORD-2025-000013', 'confirmed', '2025-06-24 15:15:33', NULL, '2025-06-24 15:17:45', 1500.00, 0.00, 120.00, 1620.00, NULL, 'credit_card', 'captured', '192.168.1.112'),
(14, 'ORD-2025-000014', 'confirmed', '2025-06-25 09:20:44', NULL, '2025-06-25 09:22:30', 370.00, 37.00, 26.64, 359.64, 4, 'paypal', 'captured', '192.168.1.113'),
(15, 'ORD-2025-000015', 'confirmed', '2025-06-26 13:30:55', NULL, '2025-06-26 13:32:40', 125.00, 18.75, 8.50, 114.75, 1, 'debit_card', 'captured', '192.168.1.114'),
(16, 'ORD-2025-000016', 'confirmed', '2025-06-27 16:40:11', NULL, '2025-06-27 16:42:25', 850.00, 0.00, 68.00, 918.00, NULL, 'apple_pay', 'captured', '192.168.1.115'),
(17, 'ORD-2025-000017', 'confirmed', '2025-06-28 10:50:22', NULL, '2025-06-28 10:52:35', 450.00, 67.50, 30.60, 413.10, 2, 'credit_card', 'captured', '192.168.1.116'),
(18, 'ORD-2025-000018', 'confirmed', '2025-06-29 14:15:33', NULL, '2025-06-29 14:17:50', 1200.00, 0.00, 96.00, 1296.00, NULL, 'credit_card', 'captured', '192.168.1.117'),
(19, 'ORD-2025-000019', 'confirmed', '2025-06-30 11:25:44', NULL, '2025-06-30 11:27:55', 250.00, 25.00, 18.00, 243.00, 4, 'paypal', 'captured', '192.168.1.118'),
(20, 'ORD-2025-000020', 'confirmed', '2025-07-01 15:35:55', NULL, '2025-07-01 15:38:10', 700.00, 0.00, 56.00, 756.00, NULL, 'google_pay', 'captured', '192.168.1.119'),
(21, 'ORD-2025-000021', 'confirmed', '2025-07-02 09:45:11', NULL, '2025-07-02 09:47:20', 350.00, 52.50, 23.80, 321.30, 2, 'credit_card', 'captured', '192.168.1.120'),
(22, 'ORD-2025-000022', 'confirmed', '2025-07-03 13:55:22', NULL, '2025-07-03 13:57:35', 185.00, 0.00, 14.80, 199.80, NULL, 'debit_card', 'captured', '192.168.1.121'),
(23, 'ORD-2025-000023', 'confirmed', '2025-07-04 16:10:33', NULL, '2025-07-04 16:12:45', 900.00, 0.00, 72.00, 972.00, NULL, 'apple_pay', 'captured', '192.168.1.122'),
(24, 'ORD-2025-000024', 'confirmed', '2025-07-05 10:20:44', NULL, '2025-07-05 10:22:55', 550.00, 0.00, 44.00, 594.00, NULL, 'credit_card', 'captured', '192.168.1.123'),
(25, 'ORD-2025-000025', 'confirmed', '2025-07-06 14:30:55', NULL, '2025-07-06 14:33:10', 295.00, 29.50, 21.24, 286.74, 4, 'paypal', 'captured', '192.168.1.124'),
(26, 'ORD-2025-000026', 'cancelled', '2025-07-07 11:40:11', '2025-07-07 11:55:11', NULL, 450.00, 0.00, 36.00, 486.00, NULL, NULL, 'failed', '192.168.1.125'),
(27, 'ORD-2025-000027', 'confirmed', '2025-07-08 15:50:22', NULL, '2025-07-08 15:52:35', 1700.00, 0.00, 136.00, 1836.00, NULL, 'credit_card', 'captured', '192.168.1.126'),
(28, 'ORD-2025-000028', 'confirmed', '2025-07-09 09:15:33', NULL, '2025-07-09 09:17:45', 250.00, 37.50, 17.00, 229.50, 1, 'google_pay', 'captured', '192.168.1.127'),
(29, 'ORD-2025-000029', 'confirmed', '2025-07-10 13:25:44', NULL, '2025-07-10 13:27:55', 850.00, 0.00, 68.00, 918.00, NULL, 'debit_card', 'captured', '192.168.1.128'),
(30, 'ORD-2025-000030', 'confirmed', '2025-07-11 16:35:55', NULL, '2025-07-11 16:38:10', 375.00, 56.25, 25.50, 344.25, 2, 'apple_pay', 'captured', '192.168.1.129'),
(31, 'ORD-2025-000031', 'confirmed', '2025-07-12 10:45:11', NULL, '2025-07-12 10:47:20', 1200.00, 100.00, 88.00, 1188.00, 6, 'credit_card', 'captured', '192.168.1.130'),
(32, 'ORD-2025-000032', 'confirmed', '2025-07-13 14:55:22', NULL, '2025-07-13 14:57:35', 550.00, 0.00, 44.00, 594.00, NULL, 'paypal', 'captured', '192.168.1.131'),
(33, 'ORD-2025-000033', 'confirmed', '2025-07-14 11:10:33', NULL, '2025-07-14 11:12:45', 180.00, 27.00, 12.24, 165.24, 1, 'credit_card', 'captured', '192.168.1.132'),
(34, 'ORD-2025-000034', 'confirmed', '2025-07-15 15:20:44', NULL, '2025-07-15 15:22:55', 750.00, 0.00, 60.00, 810.00, NULL, 'debit_card', 'captured', '192.168.1.133'),
(35, 'ORD-2025-000035', 'confirmed', '2025-07-16 09:30:55', NULL, '2025-07-16 09:33:10', 295.00, 44.25, 20.06, 270.81, 2, 'google_pay', 'captured', '192.168.1.134'),
(36, 'ORD-2025-000036', 'refunded', '2025-07-17 13:40:11', NULL, '2025-07-17 13:42:25', 450.00, 0.00, 36.00, 486.00, NULL, 'credit_card', 'refunded', '192.168.1.135'),
(37, 'ORD-2025-000037', 'confirmed', '2025-07-18 16:50:22', NULL, '2025-07-18 16:52:35', 1500.00, 0.00, 120.00, 1620.00, NULL, 'apple_pay', 'captured', '192.168.1.136'),
(38, 'ORD-2025-000038', 'confirmed', '2025-07-19 10:15:33', NULL, '2025-07-19 10:17:45', 250.00, 25.00, 18.00, 243.00, 4, 'paypal', 'captured', '192.168.1.137'),
(39, 'ORD-2025-000039', 'confirmed', '2025-07-20 14:25:44', NULL, '2025-07-20 14:27:55', 850.00, 0.00, 68.00, 918.00, NULL, 'credit_card', 'captured', '192.168.1.138'),
(40, 'ORD-2025-000040', 'confirmed', '2025-07-21 11:35:55', NULL, '2025-07-21 11:38:10', 700.00, 105.00, 47.60, 642.60, 2, 'debit_card', 'captured', '192.168.1.139'),
(41, 'ORD-2025-000041', 'confirmed', '2025-07-22 15:45:11', NULL, '2025-07-22 15:47:20', 350.00, 0.00, 28.00, 378.00, NULL, 'google_pay', 'captured', '192.168.1.140'),
(42, 'ORD-2025-000042', 'confirmed', '2025-07-23 09:55:22', NULL, '2025-07-23 09:57:35', 185.00, 27.75, 12.58, 169.83, 1, 'apple_pay', 'captured', '192.168.1.141'),
(43, 'ORD-2025-000043', 'confirmed', '2025-07-24 13:10:33', NULL, '2025-07-24 13:12:45', 900.00, 0.00, 72.00, 972.00, NULL, 'credit_card', 'captured', '192.168.1.142'),
(44, 'ORD-2025-000044', 'confirmed', '2025-07-25 16:20:44', NULL, '2025-07-25 16:22:55', 550.00, 0.00, 44.00, 594.00, NULL, 'paypal', 'captured', '192.168.1.143'),
(45, 'ORD-2025-000045', 'confirmed', '2025-07-26 10:30:55', NULL, '2025-07-26 10:33:10', 295.00, 29.50, 21.24, 286.74, 4, 'debit_card', 'captured', '192.168.1.144'),
(46, 'ORD-2025-000046', 'confirmed', '2025-07-27 14:40:11', NULL, '2025-07-27 14:42:25', 1200.00, 0.00, 96.00, 1296.00, NULL, 'credit_card', 'captured', '192.168.1.145'),
(47, 'ORD-2025-000047', 'confirmed', '2025-07-28 11:50:22', NULL, '2025-07-28 11:52:35', 450.00, 67.50, 30.60, 413.10, 2, 'google_pay', 'captured', '192.168.1.146'),
(48, 'ORD-2025-000048', 'confirmed', '2025-07-29 15:15:33', NULL, '2025-07-29 15:17:45', 250.00, 0.00, 20.00, 270.00, NULL, 'apple_pay', 'captured', '192.168.1.147'),
(49, 'ORD-2025-000049', 'confirmed', '2025-07-30 09:25:44', NULL, '2025-07-30 09:27:55', 850.00, 0.00, 68.00, 918.00, NULL, 'paypal', 'captured', '192.168.1.148'),
(50, 'ORD-2025-000050', 'confirmed', '2025-07-31 13:35:55', NULL, '2025-07-31 13:38:10', 375.00, 0.00, 30.00, 405.00, NULL, 'credit_card', 'captured', '192.168.1.149'),
-- Additional orders for fraud detection patterns
(1, 'ORD-2025-000051', 'confirmed', '2025-08-01 02:15:22', NULL, '2025-08-01 02:17:35', 3400.00, 0.00, 272.00, 3672.00, NULL, 'credit_card', 'captured', '45.123.45.67'),
(1, 'ORD-2025-000052', 'confirmed', '2025-08-01 02:18:44', NULL, '2025-08-01 02:20:55', 2550.00, 0.00, 204.00, 2754.00, NULL, 'credit_card', 'captured', '45.123.45.67'),
(1, 'ORD-2025-000053', 'confirmed', '2025-08-01 02:22:11', NULL, '2025-08-01 02:24:25', 1700.00, 0.00, 136.00, 1836.00, NULL, 'credit_card', 'captured', '45.123.45.67'),
(25, 'ORD-2025-000054', 'confirmed', '2025-08-02 03:30:33', NULL, '2025-08-02 03:32:45', 4250.00, 0.00, 340.00, 4590.00, NULL, 'credit_card', 'captured', '78.234.56.89'),
(25, 'ORD-2025-000055', 'confirmed', '2025-08-02 03:35:44', NULL, '2025-08-02 03:37:55', 3000.00, 0.00, 240.00, 3240.00, NULL, 'credit_card', 'captured', '78.234.56.89'),
(30, 'ORD-2025-000056', 'confirmed', '2025-08-03 01:45:11', NULL, '2025-08-03 01:47:20', 5100.00, 0.00, 408.00, 5508.00, NULL, 'credit_card', 'captured', '123.45.67.89'),
(30, 'ORD-2025-000057', 'confirmed', '2025-08-03 01:50:22', NULL, '2025-08-03 01:52:35', 4500.00, 0.00, 360.00, 4860.00, NULL, 'credit_card', 'captured', '123.45.67.89'),
(30, 'ORD-2025-000058', 'confirmed', '2025-08-03 01:55:33', NULL, '2025-08-03 01:57:45', 3750.00, 0.00, 300.00, 4050.00, NULL, 'credit_card', 'captured', '123.45.67.89'),
-- Normal orders
(35, 'ORD-2025-000059', 'confirmed', '2025-08-04 14:20:44', NULL, '2025-08-04 14:22:55', 550.00, 0.00, 44.00, 594.00, NULL, 'debit_card', 'captured', '192.168.1.150'),
(40, 'ORD-2025-000060', 'confirmed', '2025-08-05 16:30:55', NULL, '2025-08-05 16:33:10', 295.00, 0.00, 23.60, 318.60, NULL, 'google_pay', 'captured', '192.168.1.151');

-- ============================================================================
-- TICKETS (100+ tickets - sample from various orders)
-- ============================================================================
INSERT INTO tickets (order_id, event_id, tier_id, seat_id, ticket_number, ticket_status, purchase_price, face_value, refund_policy_deadline) VALUES
-- Order 1: 2 tickets for Taylor Swift
(1, 1, 3, NULL, 'TKT-2025-000001', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
(1, 1, 3, NULL, 'TKT-2025-000002', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
-- Order 2: 2 VIP tickets for Taylor Swift
(2, 1, 1, NULL, 'TKT-2025-000003', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(2, 1, 1, NULL, 'TKT-2025-000004', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
-- Order 3: 1 ticket for Taylor Swift
(3, 1, 3, NULL, 'TKT-2025-000005', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
-- Order 4: 5 tickets for Hamilton (held)
(4, 4, 14, 51, 'TKT-2025-000006', 'held', 185.00, 185.00, '2025-10-29 23:59:59'),
(4, 4, 14, 52, 'TKT-2025-000007', 'held', 185.00, 185.00, '2025-10-29 23:59:59'),
(4, 4, 15, 81, 'TKT-2025-000008', 'held', 95.00, 95.00, '2025-10-29 23:59:59'),
(4, 4, 15, 82, 'TKT-2025-000009', 'held', 95.00, 95.00, '2025-10-29 23:59:59'),
(4, 4, 15, 83, 'TKT-2025-000010', 'held', 95.00, 95.00, '2025-10-29 23:59:59'),
-- Order 5: 1 VIP ticket for Taylor Swift
(5, 1, 1, NULL, 'TKT-2025-000011', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
-- Order 6: 1 ticket for LA Phil
(6, 2, 6, NULL, 'TKT-2025-000012', 'purchased', 180.00, 180.00, '2025-08-13 23:59:59'),
-- Order 7: 3 tickets for Red Rocks Jazz
(7, 3, 10, 95, 'TKT-2025-000013', 'purchased', 150.00, 150.00, '2025-09-03 23:59:59'),
(7, 3, 10, 96, 'TKT-2025-000014', 'purchased', 150.00, 150.00, '2025-09-03 23:59:59'),
(7, 3, 10, 97, 'TKT-2025-000015', 'purchased', 150.00, 150.00, '2025-09-03 23:59:59'),
-- Order 8: 1 VIP Suite for Taylor Swift
(8, 1, 5, NULL, 'TKT-2025-000016', 'purchased', 1200.00, 1200.00, '2025-12-08 23:59:59'),
-- Order 9: 1 Floor Premium for Taylor Swift
(9, 1, 2, NULL, 'TKT-2025-000017', 'purchased', 550.00, 550.00, '2025-12-08 23:59:59'),
-- Order 10: 1 Lower Bowl for Taylor Swift
(10, 1, 3, NULL, 'TKT-2025-000018', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
-- Order 11: 3 Upper Bowl for Taylor Swift
(11, 1, 4, NULL, 'TKT-2025-000019', 'purchased', 125.00, 125.00, '2025-12-08 23:59:59'),
(11, 1, 4, NULL, 'TKT-2025-000020', 'purchased', 125.00, 125.00, '2025-12-08 23:59:59'),
(11, 1, 4, NULL, 'TKT-2025-000021', 'purchased', 125.00, 125.00, '2025-12-08 23:59:59'),
-- Order 12: 2 tickets for Hamilton (held)
(12, 4, 14, 53, 'TKT-2025-000022', 'held', 185.00, 185.00, '2025-10-29 23:59:59'),
(12, 4, 15, 84, 'TKT-2025-000023', 'held', 95.00, 95.00, '2025-10-29 23:59:59'),
-- Order 13: 1 Courtside for Knicks vs Lakers
(13, 6, 20, NULL, 'TKT-2025-000024', 'purchased', 1500.00, 1500.00, '2026-01-11 23:59:59'),
-- Order 14: 2 Lower Bowl for Knicks
(14, 6, 21, NULL, 'TKT-2025-000025', 'purchased', 350.00, 350.00, '2026-01-11 23:59:59'),
(14, 6, 21, NULL, 'TKT-2025-000026', 'purchased', 350.00, 350.00, '2026-01-11 23:59:59'),
-- Order 15: 1 Upper Bowl for Taylor Swift
(15, 1, 4, NULL, 'TKT-2025-000027', 'purchased', 125.00, 125.00, '2025-12-08 23:59:59'),
-- Order 16: 1 VIP for Taylor Swift
(16, 1, 1, NULL, 'TKT-2025-000028', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
-- Order 17: 3 tickets for Red Rocks Jazz
(17, 3, 11, NULL, 'TKT-2025-000029', 'purchased', 95.00, 95.00, '2025-09-03 23:59:59'),
(17, 3, 11, NULL, 'TKT-2025-000030', 'purchased', 95.00, 95.00, '2025-09-03 23:59:59'),
(17, 3, 11, NULL, 'TKT-2025-000031', 'purchased', 95.00, 95.00, '2025-09-03 23:59:59'),
-- Order 18: 1 VIP Suite for Taylor Swift
(18, 1, 5, NULL, 'TKT-2025-000032', 'purchased', 1200.00, 1200.00, '2025-12-08 23:59:59'),
-- Order 19: 1 Lower Bowl for Taylor Swift
(19, 1, 3, NULL, 'TKT-2025-000033', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
-- Order 20: 4 Upper Bowl for Taylor Swift
(20, 1, 4, NULL, 'TKT-2025-000034', 'purchased', 125.00, 125.00, '2025-12-08 23:59:59'),
(20, 1, 4, NULL, 'TKT-2025-000035', 'purchased', 125.00, 125.00, '2025-12-08 23:59:59'),
(20, 1, 4, NULL, 'TKT-2025-000036', 'purchased', 125.00, 125.00, '2025-12-08 23:59:59'),
(20, 1, 4, NULL, 'TKT-2025-000037', 'purchased', 125.00, 125.00, '2025-12-08 23:59:59'),
-- Continue with more tickets for remaining orders (simplified for brevity)
(21, 6, 21, NULL, 'TKT-2025-000038', 'purchased', 350.00, 350.00, '2026-01-11 23:59:59'),
(22, 4, 14, 54, 'TKT-2025-000039', 'purchased', 185.00, 185.00, '2025-10-29 23:59:59'),
(23, 5, 16, NULL, 'TKT-2025-000040', 'purchased', 450.00, 450.00, '2025-10-13 23:59:59'),
(23, 5, 16, NULL, 'TKT-2025-000041', 'purchased', 450.00, 450.00, '2025-10-13 23:59:59'),
(24, 1, 2, NULL, 'TKT-2025-000042', 'purchased', 550.00, 550.00, '2025-12-08 23:59:59'),
(25, 4, 13, 1, 'TKT-2025-000043', 'purchased', 295.00, 295.00, '2025-10-29 23:59:59'),
(27, 1, 1, NULL, 'TKT-2025-000044', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(27, 1, 1, NULL, 'TKT-2025-000045', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(28, 1, 3, NULL, 'TKT-2025-000046', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
(29, 1, 1, NULL, 'TKT-2025-000047', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(30, 3, 10, 98, 'TKT-2025-000048', 'purchased', 150.00, 150.00, '2025-09-03 23:59:59'),
(30, 3, 10, 99, 'TKT-2025-000049', 'purchased', 150.00, 150.00, '2025-09-03 23:59:59'),
(31, 1, 5, NULL, 'TKT-2025-000050', 'purchased', 1200.00, 1200.00, '2025-12-08 23:59:59'),
(32, 1, 2, NULL, 'TKT-2025-000051', 'purchased', 550.00, 550.00, '2025-12-08 23:59:59'),
(33, 2, 6, NULL, 'TKT-2025-000052', 'purchased', 180.00, 180.00, '2025-08-13 23:59:59'),
(34, 1, 3, NULL, 'TKT-2025-000053', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
(34, 1, 3, NULL, 'TKT-2025-000054', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
(34, 1, 3, NULL, 'TKT-2025-000055', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
(35, 4, 13, 2, 'TKT-2025-000056', 'purchased', 295.00, 295.00, '2025-10-29 23:59:59'),
(36, 3, 11, NULL, 'TKT-2025-000057', 'refunded', 150.00, 150.00, '2025-09-03 23:59:59'),
(36, 3, 11, NULL, 'TKT-2025-000058', 'refunded', 150.00, 150.00, '2025-09-03 23:59:59'),
(36, 3, 11, NULL, 'TKT-2025-000059', 'refunded', 150.00, 150.00, '2025-09-03 23:59:59'),
(37, 6, 20, NULL, 'TKT-2025-000060', 'purchased', 1500.00, 1500.00, '2026-01-11 23:59:59'),
(38, 1, 3, NULL, 'TKT-2025-000061', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
(39, 1, 1, NULL, 'TKT-2025-000062', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(40, 6, 21, NULL, 'TKT-2025-000063', 'purchased', 350.00, 350.00, '2026-01-11 23:59:59'),
(40, 6, 21, NULL, 'TKT-2025-000064', 'purchased', 350.00, 350.00, '2026-01-11 23:59:59'),
(41, 6, 21, NULL, 'TKT-2025-000065', 'purchased', 350.00, 350.00, '2026-01-11 23:59:59'),
(42, 4, 14, 55, 'TKT-2025-000066', 'purchased', 185.00, 185.00, '2025-10-29 23:59:59'),
(43, 5, 17, NULL, 'TKT-2025-000067', 'purchased', 225.00, 225.00, '2025-10-13 23:59:59'),
(43, 5, 17, NULL, 'TKT-2025-000068', 'purchased', 225.00, 225.00, '2025-10-13 23:59:59'),
(43, 5, 17, NULL, 'TKT-2025-000069', 'purchased', 225.00, 225.00, '2025-10-13 23:59:59'),
(43, 5, 17, NULL, 'TKT-2025-000070', 'purchased', 225.00, 225.00, '2025-10-13 23:59:59'),
(44, 1, 2, NULL, 'TKT-2025-000071', 'purchased', 550.00, 550.00, '2025-12-08 23:59:59'),
(45, 4, 13, 3, 'TKT-2025-000072', 'purchased', 295.00, 295.00, '2025-10-29 23:59:59'),
(46, 1, 5, NULL, 'TKT-2025-000073', 'purchased', 1200.00, 1200.00, '2025-12-08 23:59:59'),
(47, 3, 10, 100, 'TKT-2025-000074', 'purchased', 150.00, 150.00, '2025-09-03 23:59:59'),
(47, 3, 10, 101, 'TKT-2025-000075', 'purchased', 150.00, 150.00, '2025-09-03 23:59:59'),
(47, 3, 10, 102, 'TKT-2025-000076', 'purchased', 150.00, 150.00, '2025-09-03 23:59:59'),
(48, 1, 3, NULL, 'TKT-2025-000077', 'purchased', 250.00, 250.00, '2025-12-08 23:59:59'),
(49, 1, 1, NULL, 'TKT-2025-000078', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(50, 3, 11, NULL, 'TKT-2025-000079', 'purchased', 95.00, 95.00, '2025-09-03 23:59:59'),
(50, 3, 11, NULL, 'TKT-2025-000080', 'purchased', 95.00, 95.00, '2025-09-03 23:59:59'),
-- Fraud pattern tickets (large bulk purchases)
(51, 1, 1, NULL, 'TKT-2025-000081', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(51, 1, 1, NULL, 'TKT-2025-000082', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(51, 1, 1, NULL, 'TKT-2025-000083', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(51, 1, 1, NULL, 'TKT-2025-000084', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(52, 1, 2, NULL, 'TKT-2025-000085', 'purchased', 550.00, 550.00, '2025-12-08 23:59:59'),
(52, 1, 2, NULL, 'TKT-2025-000086', 'purchased', 550.00, 550.00, '2025-12-08 23:59:59'),
(52, 1, 2, NULL, 'TKT-2025-000087', 'purchased', 550.00, 550.00, '2025-12-08 23:59:59'),
(53, 1, 1, NULL, 'TKT-2025-000088', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(53, 1, 1, NULL, 'TKT-2025-000089', 'purchased', 850.00, 850.00, '2025-12-08 23:59:59'),
(54, 5, 16, NULL, 'TKT-2025-000090', 'purchased', 450.00, 450.00, '2025-10-13 23:59:59'),
(54, 5, 16, NULL, 'TKT-2025-000091', 'purchased', 450.00, 450.00, '2025-10-13 23:59:59'),
(54, 5, 16, NULL, 'TKT-2025-000092', 'purchased', 450.00, 450.00, '2025-10-13 23:59:59'),
(54, 5, 16, NULL, 'TKT-2025-000093', 'purchased', 450.00, 450.00, '2025-10-13 23:59:59'),
(54, 5, 16, NULL, 'TKT-2025-000094', 'purchased', 450.00, 450.00, '2025-10-13 23:59:59'),
(55, 5, 17, NULL, 'TKT-2025-000095', 'purchased', 225.00, 225.00, '2025-10-13 23:59:59'),
(55, 5, 17, NULL, 'TKT-2025-000096', 'purchased', 225.00, 225.00, '2025-10-13 23:59:59'),
(55, 5, 17, NULL, 'TKT-2025-000097', 'purchased', 225.00, 225.00, '2025-10-13 23:59:59'),
(56, 6, 20, NULL, 'TKT-2025-000098', 'purchased', 1500.00, 1500.00, '2026-01-11 23:59:59'),
(56, 6, 20, NULL, 'TKT-2025-000099', 'purchased', 1500.00, 1500.00, '2026-01-11 23:59:59'),
(56, 6, 20, NULL, 'TKT-2025-000100', 'purchased', 1500.00, 1500.00, '2026-01-11 23:59:59'),
(57, 6, 20, NULL, 'TKT-2025-000101', 'purchased', 1500.00, 1500.00, '2026-01-11 23:59:59'),
(57, 6, 20, NULL, 'TKT-2025-000102', 'purchased', 1500.00, 1500.00, '2026-01-11 23:59:59'),
(57, 6, 20, NULL, 'TKT-2025-000103', 'purchased', 1500.00, 1500.00, '2026-01-11 23:59:59'),
(58, 6, 21, NULL, 'TKT-2025-000104', 'purchased', 350.00, 350.00, '2026-01-11 23:59:59'),
(58, 6, 21, NULL, 'TKT-2025-000105', 'purchased', 350.00, 350.00, '2026-01-11 23:59:59'),
(59, 1, 2, NULL, 'TKT-2025-000106', 'purchased', 550.00, 550.00, '2025-12-08 23:59:59'),
(60, 4, 13, 4, 'TKT-2025-000107', 'purchased', 295.00, 295.00, '2025-10-29 23:59:59');

-- ============================================================================
-- EVENT SEAT ASSIGNMENTS (for seated tickets)
-- ============================================================================
INSERT INTO event_seat_assignments (event_id, seat_id, ticket_id, assignment_status) VALUES
-- Hamilton tickets with specific seats
(4, 51, 6, 'sold'),
(4, 52, 7, 'sold'),
(4, 81, 8, 'sold'),
(4, 82, 9, 'sold'),
(4, 83, 10, 'sold'),
(4, 53, 22, 'sold'),
(4, 84, 23, 'sold'),
(4, 54, 39, 'sold'),
(4, 1, 43, 'sold'),
(4, 55, 66, 'sold'),
(4, 2, 56, 'sold'),
(4, 3, 72, 'sold'),
(4, 4, 107, 'sold'),
-- Red Rocks Jazz tickets with specific seats
(3, 95, 13, 'sold'),
(3, 96, 14, 'sold'),
(3, 97, 15, 'sold'),
(3, 98, 48, 'sold'),
(3, 99, 49, 'sold'),
(3, 100, 74, 'sold'),
(3, 101, 75, 'sold'),
(3, 102, 76, 'sold');

-- ============================================================================
-- REFUNDS (3 refund records)
-- ============================================================================
INSERT INTO refunds (ticket_id, order_id, customer_id, refund_amount, refund_reason, refund_status, requested_at, processed_at, notes) VALUES
(57, 36, 36, 150.00, 'customer_request', 'processed', '2025-07-18 10:00:00', '2025-07-18 14:30:00', 'Customer unable to attend due to scheduling conflict'),
(58, 36, 36, 150.00, 'customer_request', 'processed', '2025-07-18 10:00:00', '2025-07-18 14:30:00', 'Customer unable to attend due to scheduling conflict'),
(59, 36, 36, 150.00, 'customer_request', 'processed', '2025-07-18 10:00:00', '2025-07-18 14:30:00', 'Customer unable to attend due to scheduling conflict');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Verify data loaded correctly
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

-- ============================================================================
-- END OF SEED DATA
-- ============================================================================

