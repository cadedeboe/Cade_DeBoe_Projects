-- ============================================================================
-- Ski Resort Management System - Database Schema
-- COMP 345 Final Project
-- DBMS: MySQL 8.0+
-- ============================================================================
DROP DATABASE IF EXISTS ski_resort;
CREATE DATABASE ski_resort CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ski_resort;
-- ============================================================================
-- CORE ENTITIES
-- ============================================================================
-- ----------------------------------------------------------------------------
-- 1. Customers: People who purchase passes, rent equipment, or take lessons
-- ----------------------------------------------------------------------------
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    DOB DATE NOT NULL,
    Address VARCHAR(255),
    City VARCHAR(100),
    StateProvince VARCHAR(50),
    PostalCode VARCHAR(20),
    Country VARCHAR(50) DEFAULT 'USA',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_dob_range CHECK (DOB < '2022-01-01'),
    -- Customers must be older than 3 years as of 2025
    CONSTRAINT chk_email_format CHECK (Email LIKE '%@%.%')
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 2. Pass Types: Catalog of available pass types (Day Pass, Season Pass, etc.)
-- ----------------------------------------------------------------------------
CREATE TABLE Pass_Types (
    PassTypeID INT PRIMARY KEY AUTO_INCREMENT,
    PassName VARCHAR(50) NOT NULL UNIQUE,
    PassDescription TEXT,
    CurrentPrice DECIMAL(10, 2) NOT NULL,
    AgeGroup ENUM('Child', 'Adult', 'Senior') NOT NULL,
    DurationDays INT DEFAULT 1 CHECK (DurationDays > 0),
    IsSeasonPass BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_pass_price CHECK (CurrentPrice >= 0)
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 3. Lift Tickets: Individual ticket purchases/transactions
-- ----------------------------------------------------------------------------
CREATE TABLE Lift_Tickets (
    TicketID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    PassTypeID INT NOT NULL,
    PurchaseDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ValidDate DATE NOT NULL,
    ExpirationDate DATE,
    SalePrice DECIMAL(10, 2) NOT NULL,
    TicketStatus ENUM('Active', 'Used', 'Expired', 'Cancelled') DEFAULT 'Active',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ticket_price CHECK (SalePrice >= 0),
    CONSTRAINT chk_valid_date CHECK (ValidDate >= DATE(PurchaseDate)),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (PassTypeID) REFERENCES Pass_Types(PassTypeID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 4. Instructors: Ski and snowboard instructors
-- ----------------------------------------------------------------------------
CREATE TABLE Instructors (
    InstructorID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    Specialty ENUM('Skiing', 'Snowboarding', 'Both') NOT NULL,
    CertificationLevel ENUM('Level 1', 'Level 2', 'Level 3', 'Certified') DEFAULT 'Level 1',
    HireDate DATE,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 5. Scheduled Lessons: Lessons scheduled by instructors
-- ----------------------------------------------------------------------------
CREATE TABLE Scheduled_Lessons (
    LessonID INT PRIMARY KEY AUTO_INCREMENT,
    InstructorID INT NOT NULL,
    LessonName VARCHAR(100),
    StartTime TIMESTAMP NOT NULL,
    EndTime TIMESTAMP,
    MaxCapacity INT DEFAULT 10 CHECK (MaxCapacity > 0),
    CurrentEnrollment INT DEFAULT 0 CHECK (CurrentEnrollment >= 0),
    LessonType ENUM('Group', 'Private', 'Semi-Private') DEFAULT 'Group',
    LessonStatus ENUM(
        'Scheduled',
        'In Progress',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Scheduled',
    Price DECIMAL(10, 2) DEFAULT 0.00 CHECK (Price >= 0),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_enrollment_capacity CHECK (CurrentEnrollment <= MaxCapacity),
    CONSTRAINT chk_lesson_times CHECK (
        EndTime IS NULL
        OR EndTime > StartTime
    ),
    FOREIGN KEY (InstructorID) REFERENCES Instructors(InstructorID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 6. Lesson Enrollments: Bridge table linking customers to scheduled lessons
-- ----------------------------------------------------------------------------
CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    LessonID INT NOT NULL,
    EnrollmentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PaymentStatus ENUM('Paid', 'Pending', 'Cancelled', 'Refunded') NOT NULL DEFAULT 'Pending',
    PaymentAmount DECIMAL(10, 2) DEFAULT 0.00 CHECK (PaymentAmount >= 0),
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_customer_lesson UNIQUE (CustomerID, LessonID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (LessonID) REFERENCES Scheduled_Lessons(LessonID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 7. Equipment: Inventory of rental equipment
-- ----------------------------------------------------------------------------
CREATE TABLE Equipment (
    EquipmentID INT PRIMARY KEY AUTO_INCREMENT,
    EquipmentType ENUM(
        'Ski',
        'Snowboard',
        'Boots',
        'Poles',
        'Helmet',
        'Goggles'
    ) NOT NULL,
    Brand VARCHAR(50),
    Model VARCHAR(50),
    Size VARCHAR(20),
    Status ENUM('Available', 'Rented', 'Maintenance', 'Retired') NOT NULL DEFAULT 'Available',
    PurchaseDate DATE,
    LastMaintenanceDate DATE,
    NextMaintenanceDate DATE,
    ConditionNotes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 8. Rentals: Rental transactions linking customers to equipment
-- ----------------------------------------------------------------------------
CREATE TABLE Rentals (
    RentalID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    RentalDate DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ExpectedReturnDate DATETIME,
    ActualReturnDate DATETIME,
    TotalPrice DECIMAL(10, 2) NOT NULL CHECK (TotalPrice >= 0),
    RentalStatus ENUM('Active', 'Returned', 'Overdue', 'Lost') DEFAULT 'Active',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_return_dates CHECK (
        ExpectedReturnDate IS NULL
        OR ExpectedReturnDate >= RentalDate
    ),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 9. Rental Items: Bridge table linking rentals to specific equipment items
-- Many-to-Many: Rentals ↔ Equipment
-- ----------------------------------------------------------------------------
CREATE TABLE Rental_Items (
    RentalItemID INT PRIMARY KEY AUTO_INCREMENT,
    RentalID INT NOT NULL,
    EquipmentID INT NOT NULL,
    Quantity INT DEFAULT 1 CHECK (Quantity > 0),
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_rental_equipment UNIQUE (RentalID, EquipmentID),
    FOREIGN KEY (RentalID) REFERENCES Rentals(RentalID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (EquipmentID) REFERENCES Equipment(EquipmentID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 10. Trails: Ski trails/runs at the resort
-- ----------------------------------------------------------------------------
CREATE TABLE Trails (
    TrailID INT PRIMARY KEY AUTO_INCREMENT,
    TrailName VARCHAR(100) NOT NULL,
    Difficulty ENUM('Beginner', 'Intermediate', 'Advanced', 'Expert') NOT NULL,
    LengthMeters DECIMAL(10, 2) CHECK (LengthMeters > 0),
    ElevationDropMeters DECIMAL(10, 2) CHECK (ElevationDropMeters >= 0),
    IsOpen BOOLEAN DEFAULT TRUE,
    ConditionsNotes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 11. Lifts: Chairlifts and gondolas
-- ----------------------------------------------------------------------------
CREATE TABLE Lifts (
    LiftID INT PRIMARY KEY AUTO_INCREMENT,
    LiftName VARCHAR(100) NOT NULL UNIQUE,
    LiftType ENUM('Chairlift', 'Gondola', 'Magic Carpet', 'T-Bar') NOT NULL,
    Capacity INT CHECK (Capacity > 0),
    IsOpen BOOLEAN DEFAULT TRUE,
    OperatingHours VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 12. Lift Access: Bridge table linking lifts to trails (which lifts access which trails)
-- Many-to-Many: Lifts ↔ Trails
-- ----------------------------------------------------------------------------
CREATE TABLE Lift_Access (
    AccessID INT PRIMARY KEY AUTO_INCREMENT,
    LiftID INT NOT NULL,
    TrailID INT NOT NULL,
    AccessType ENUM('Direct', 'Indirect') DEFAULT 'Direct',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_lift_trail UNIQUE (LiftID, TrailID),
    FOREIGN KEY (LiftID) REFERENCES Lifts(LiftID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (TrailID) REFERENCES Trails(TrailID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 13. Maintenance Staff: Technicians and maintenance personnel
-- ----------------------------------------------------------------------------
CREATE TABLE Maintenance_Staff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    Specialty ENUM(
        'Lifts',
        'Equipment',
        'Trails',
        'Facilities',
        'General'
    ) NOT NULL,
    HireDate DATE NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 14. Lift Maintenance Logs: Maintenance records for chairlifts and gondolas
-- ----------------------------------------------------------------------------
CREATE TABLE Lift_Maintenance_Logs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    LiftID INT NOT NULL,
    StaffID INT,
    MaintenanceType ENUM('Routine', 'Repair', 'Emergency', 'Inspection') NOT NULL,
    Description TEXT NOT NULL,
    Priority ENUM('Low', 'Medium', 'High', 'Critical') NOT NULL,
    Status ENUM(
        'Scheduled',
        'In Progress',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Scheduled',
    ScheduledDate DATETIME,
    StartedDate DATETIME,
    CompletedDate DATETIME,
    EstimatedCost DECIMAL(10, 2) CHECK (EstimatedCost >= 0),
    ActualCost DECIMAL(10, 2) CHECK (ActualCost >= 0),
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_maintenance_dates CHECK (
        CompletedDate IS NULL
        OR CompletedDate >= StartedDate
    ),
    FOREIGN KEY (LiftID) REFERENCES Lifts(LiftID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (StaffID) REFERENCES Maintenance_Staff(StaffID) ON DELETE
    SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 15. Equipment Maintenance Logs: Maintenance records for rental equipment
-- ----------------------------------------------------------------------------
CREATE TABLE Equipment_Maintenance_Logs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    EquipmentID INT NOT NULL,
    StaffID INT,
    MaintenanceType ENUM('Routine', 'Repair', 'Replacement', 'Inspection') NOT NULL,
    Description TEXT NOT NULL,
    Priority ENUM('Low', 'Medium', 'High') NOT NULL,
    Status ENUM(
        'Scheduled',
        'In Progress',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Scheduled',
    ScheduledDate DATETIME,
    StartedDate DATETIME,
    CompletedDate DATETIME,
    Cost DECIMAL(10, 2) CHECK (Cost >= 0),
    PartsUsed TEXT,
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_equipment_dates CHECK (
        CompletedDate IS NULL
        OR CompletedDate >= StartedDate
    ),
    FOREIGN KEY (EquipmentID) REFERENCES Equipment(EquipmentID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (StaffID) REFERENCES Maintenance_Staff(StaffID) ON DELETE
    SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;
-- ----------------------------------------------------------------------------
-- 16. Trail Maintenance Logs: Maintenance records for ski trails
-- ----------------------------------------------------------------------------
CREATE TABLE Trail_Maintenance_Logs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    TrailID INT NOT NULL,
    StaffID INT,
    MaintenanceType ENUM(
        'Grooming',
        'Snow Making',
        'Repair',
        'Safety Inspection',
        'Signage'
    ) NOT NULL,
    Description TEXT NOT NULL,
    Priority ENUM('Low', 'Medium', 'High') NOT NULL,
    Status ENUM(
        'Scheduled',
        'In Progress',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Scheduled',
    ScheduledDate DATETIME,
    StartedDate DATETIME,
    CompletedDate DATETIME,
    WeatherConditions VARCHAR(100),
    SnowDepth INT,
    -- in centimeters
    Cost DECIMAL(10, 2) CHECK (Cost >= 0),
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_trail_dates CHECK (
        CompletedDate IS NULL
        OR CompletedDate >= StartedDate
    ),
    CONSTRAINT chk_snow_depth CHECK (
        SnowDepth IS NULL
        OR SnowDepth >= 0
    ),
    FOREIGN KEY (TrailID) REFERENCES Trails(TrailID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (StaffID) REFERENCES Maintenance_Staff(StaffID) ON DELETE
    SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;