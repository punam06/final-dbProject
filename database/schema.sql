-- ========================================
-- WASTE MANAGEMENT DATABASE SCHEMA - DHAKA CONTEXT
-- English Names Only, No Bengali Script
-- Updated: December 2025
-- ========================================

DROP DATABASE IF EXISTS waste_management;
CREATE DATABASE waste_management;
USE waste_management;

-- ===== TABLE DEFINITIONS =====

CREATE TABLE Area (
    area_id INT PRIMARY KEY AUTO_INCREMENT,
    area_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(255) NOT NULL,
    population INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Citizen (
    citizen_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    contact VARCHAR(20) NOT NULL UNIQUE,
    area_id INT NOT NULL,
    email VARCHAR(100),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE
);

CREATE TABLE Bins (
    bin_id INT PRIMARY KEY AUTO_INCREMENT,
    bin_number VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(20) DEFAULT 'Empty',
    fill_level INT DEFAULT 0,
    location VARCHAR(255),
    area_id INT NOT NULL,
    sensor VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE
);

CREATE TABLE Waste (
    waste_id INT PRIMARY KEY AUTO_INCREMENT,
    waste_type VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) DEFAULT 'Non-recyclable',
    weight DECIMAL(10, 2) NOT NULL,
    citizen_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'Collected',
    collection_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (citizen_id) REFERENCES Citizen(citizen_id) ON DELETE CASCADE
);

CREATE TABLE Crew (
    crew_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    contact VARCHAR(20) NOT NULL UNIQUE,
    area_id INT NOT NULL,
    team_size INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE
);

CREATE TABLE Recycling_Center (
    center_id INT PRIMARY KEY AUTO_INCREMENT,
    location VARCHAR(255) NOT NULL,
    capacity INT NOT NULL,
    operational_hours VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Bill (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    bill_number VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(20) DEFAULT 'Pending',
    amount DECIMAL(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    citizen_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (citizen_id) REFERENCES Citizen(citizen_id) ON DELETE CASCADE
);

CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    payment_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    method VARCHAR(50) DEFAULT 'Cash',
    citizen_id INT NOT NULL,
    bill_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (citizen_id) REFERENCES Citizen(citizen_id) ON DELETE CASCADE,
    FOREIGN KEY (bill_id) REFERENCES Bill(bill_id) ON DELETE SET NULL
);

CREATE TABLE Has_Schedule (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    area_id INT NOT NULL,
    crew_id INT NOT NULL,
    schedule_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE,
    FOREIGN KEY (crew_id) REFERENCES Crew(crew_id) ON DELETE CASCADE
);

CREATE TABLE Collection_Schedule (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    schedule_date DATE NOT NULL,
    area_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE
);

CREATE TABLE Assigned (
    assigned_id INT PRIMARY KEY AUTO_INCREMENT,
    team_id INT NOT NULL,
    team_name VARCHAR(100),
    crew_id INT NOT NULL,
    area_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (crew_id) REFERENCES Crew(crew_id) ON DELETE CASCADE,
    FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE
);

-- ===== ADD CONSTRAINTS =====

-- Citizen Constraints
ALTER TABLE Citizen
ADD CONSTRAINT check_citizen_contact CHECK (contact REGEXP '^[0-9]{10,}$');

-- Bins Constraints
ALTER TABLE Bins
ADD CONSTRAINT check_fill_level CHECK (fill_level BETWEEN 0 AND 100),
ADD CONSTRAINT check_bin_status CHECK (status IN ('Empty', 'Partial', 'Full'));

-- Waste Constraints
ALTER TABLE Waste
ADD CONSTRAINT check_weight CHECK (weight > 0),
ADD CONSTRAINT check_waste_status CHECK (status IN ('Pending', 'Collected', 'Recycled', 'Disposed')),
ADD CONSTRAINT check_waste_category CHECK (category IN ('Biodegradable', 'Recyclable', 'Non-recyclable'));

-- Crew Constraints
ALTER TABLE Crew
ADD CONSTRAINT check_team_size CHECK (team_size > 0),
ADD CONSTRAINT check_crew_contact CHECK (contact REGEXP '^[0-9]{10,}$');

-- Recycling_Center Constraints
ALTER TABLE Recycling_Center
ADD CONSTRAINT check_capacity CHECK (capacity > 0);

-- Bill Constraints
ALTER TABLE Bill
ADD CONSTRAINT check_amount CHECK (amount > 0),
ADD CONSTRAINT check_bill_status CHECK (status IN ('Pending', 'Paid', 'Overdue')),
ADD CONSTRAINT unique_bill_number UNIQUE (bill_number);

-- Payment Constraints
ALTER TABLE Payment
ADD CONSTRAINT check_payment_amount CHECK (amount > 0),
ADD CONSTRAINT check_payment_method CHECK (method IN ('Card', 'Cash', 'Online', 'Check'));

-- ===== CREATE INDEXES FOR PERFORMANCE =====

CREATE INDEX idx_citizen_area ON Citizen(area_id);
CREATE INDEX idx_waste_citizen ON Waste(citizen_id);
CREATE INDEX idx_bins_area ON Bins(area_id);
CREATE INDEX idx_crew_area ON Crew(area_id);
CREATE INDEX idx_bill_citizen ON Bill(citizen_id);
CREATE INDEX idx_payment_citizen ON Payment(citizen_id);
CREATE INDEX idx_payment_bill ON Payment(bill_id);
CREATE INDEX idx_schedule_area ON Has_Schedule(area_id);
CREATE INDEX idx_schedule_crew ON Has_Schedule(crew_id);
CREATE INDEX idx_collection_area ON Collection_Schedule(area_id);
CREATE INDEX idx_assigned_crew ON Assigned(crew_id);
CREATE INDEX idx_assigned_area ON Assigned(area_id);

-- ===== INSERT TEST DATA - DHAKA CONTEXT (ENGLISH ONLY) =====

-- Areas (Dhaka Districts - English Names Only)
INSERT INTO Area (area_name, location, population) VALUES
('Gulshan', 'Gulshan Thana, Dhaka', 850000),
('Banani', 'Banani Thana, Dhaka', 320000),
('Dhanmondi', 'Dhanmondi Thana, Dhaka', 950000),
('Mirpur', 'Mirpur Thana, Dhaka', 1200000),
('Motijheel', 'Motijheel Thana, Dhaka', 450000);

-- Citizens (English Names - Dhaka)
INSERT INTO Citizen (name, address, contact, area_id, email) VALUES
('Rahim Ahmed', '123 Gulshan Avenue, Dhaka', '01700111111', 1, 'rahim@email.com'),
('Fatima Begum', '456 Banani Road, Dhaka', '01700111112', 1, 'fatima@email.com'),
('Karim Khan', '789 Dhanmondi Lane, Dhaka', '01700222222', 2, 'karim@email.com'),
('Nazma Akter', '321 Mirpur Street, Dhaka', '01700222223', 2, 'nazma@email.com'),
('Muhammad Ali', '654 Motijheel Drive, Dhaka', '01700333333', 3, 'ali@email.com'),
('Salma Rani', '987 Gulshan Court, Dhaka', '01700333334', 3, 'salma@email.com'),
('Yusuf Hosen', '147 Banani Way, Dhaka', '01700444444', 4, 'yusuf@email.com'),
('Amina Ahmed', '258 Dhanmondi Road, Dhaka', '01700444445', 4, 'amina@email.com'),
('Hassan Ali', '369 Mirpur Street, Dhaka', '01700555555', 5, 'hassan@email.com'),
('Leena Begum', '741 Motijheel Avenue, Dhaka', '01700555556', 5, 'leena@email.com');

-- Crew (Waste Management Teams - Dhaka - English Names)
INSERT INTO Crew (team_name, contact, area_id, team_size) VALUES
('Gulshan Cleaning Team', '01800111111', 1, 5),
('Gulshan Maintenance Team', '01800111112', 1, 4),
('Banani Waste Team', '01800222222', 2, 5),
('Banani Collection Team', '01800222223', 2, 3),
('Dhanmondi Sanitation Team', '01800333333', 3, 4),
('Dhanmondi Disposal Team', '01800333334', 3, 5),
('Mirpur Cleaning Team', '01800444444', 4, 3),
('Mirpur Waste Management', '01800444445', 4, 4),
('Motijheel Recycling Team', '01800555555', 5, 5),
('Motijheel Collection Team', '01800555556', 5, 3);

-- Bins (Dhaka Locations - English Names)
INSERT INTO Bins (bin_number, status, fill_level, location, area_id, sensor) VALUES
('BIN001', 'Partial', 45, 'Gulshan Avenue', 1, 'IOT_001'),
('BIN002', 'Full', 95, 'Gulshan Market', 1, 'IOT_002'),
('BIN003', 'Empty', 5, 'Banani Park', 2, 'IOT_003'),
('BIN004', 'Partial', 60, 'Banani Street', 2, 'IOT_004'),
('BIN005', 'Partial', 50, 'Dhanmondi Lake', 3, 'IOT_005'),
('BIN006', 'Full', 88, 'Dhanmondi Road', 3, 'IOT_006'),
('BIN007', 'Empty', 10, 'Mirpur Place', 4, 'IOT_007'),
('BIN008', 'Partial', 70, 'Mirpur Market', 4, 'IOT_008'),
('BIN009', 'Full', 92, 'Motijheel Center', 5, 'IOT_009'),
('BIN010', 'Partial', 55, 'Motijheel Avenue', 5, 'IOT_010');

-- Waste (English Names - Dhaka Context)
INSERT INTO Waste (waste_type, name, category, weight, citizen_id, status) VALUES
('Organic', 'Food Waste', 'Biodegradable', 2.5, 1, 'Collected'),
('Plastic', 'Bottles and Bags', 'Recyclable', 1.2, 2, 'Collected'),
('Paper', 'Newspaper', 'Recyclable', 3.0, 3, 'Recycled'),
('Metal', 'Aluminum Cans', 'Recyclable', 0.8, 4, 'Recycled'),
('Glass', 'Glass Bottles', 'Recyclable', 1.5, 5, 'Collected'),
('Organic', 'Garden Waste', 'Biodegradable', 4.0, 6, 'Disposed'),
('Plastic', 'Containers', 'Recyclable', 0.9, 7, 'Pending'),
('Paper', 'Cardboard', 'Recyclable', 2.2, 8, 'Collected'),
('Metal', 'Scrap Metal', 'Recyclable', 2.0, 9, 'Recycled'),
('Mixed', 'General Waste', 'Non-recyclable', 5.5, 10, 'Disposed');

-- Recycling Centers (Dhaka - English Names)
INSERT INTO Recycling_Center (location, capacity, operational_hours) VALUES
('Dhaka Central Recycling Center', 1000, '8:00 - 18:00'),
('North Dhaka Recycling Center', 800, '9:00 - 17:00'),
('South Dhaka Recycling Center', 1200, '8:00 - 19:00'),
('East Dhaka Recycling Center', 600, '9:00 - 17:00'),
('West Dhaka Recycling Center', 900, '8:00 - 18:00');

-- Bills (Using Taka - BDT)
INSERT INTO Bill (bill_number, status, amount, due_date, citizen_id) VALUES
('BILL001', 'Paid', 5000.00, '2025-01-31', 1),
('BILL002', 'Pending', 4500.00, '2025-01-15', 2),
('BILL003', 'Overdue', 5500.00, '2024-12-31', 3),
('BILL004', 'Paid', 4000.00, '2025-01-31', 4),
('BILL005', 'Pending', 5200.00, '2025-01-20', 5),
('BILL006', 'Paid', 4800.00, '2024-12-31', 6),
('BILL007', 'Overdue', 5300.00, '2024-12-15', 7),
('BILL008', 'Pending', 4600.00, '2025-01-25', 8),
('BILL009', 'Paid', 5100.00, '2024-12-31', 9),
('BILL010', 'Pending', 4900.00, '2025-01-30', 10);

-- Payments (Using BDT - Bangladeshi Taka)
INSERT INTO Payment (payment_date, amount, method, citizen_id, bill_id) VALUES
('2025-01-10', 5000.00, 'Card', 1, 1),
('2025-01-12', 4500.00, 'Cash', 2, 2),
('2024-12-25', 5500.00, 'Online', 3, 3),
('2025-01-08', 4000.00, 'Card', 4, 4),
('2025-01-13', 5200.00, 'Check', 5, 5),
('2024-12-28', 4800.00, 'Card', 6, 6),
('2024-12-10', 5300.00, 'Cash', 7, 7),
('2025-01-18', 4600.00, 'Online', 8, 8),
('2024-12-30', 5100.00, 'Card', 9, 9),
('2025-01-15', 4900.00, 'Check', 10, 10);

-- Collection Schedules
INSERT INTO Collection_Schedule (schedule_date, area_id) VALUES
('2025-01-05', 1), ('2025-01-06', 1), ('2025-01-07', 2), ('2025-01-08', 2),
('2025-01-09', 3), ('2025-01-10', 3), ('2025-01-11', 4), ('2025-01-12', 4),
('2025-01-13', 5), ('2025-01-14', 5);

-- Has Schedule
INSERT INTO Has_Schedule (area_id, crew_id, schedule_date) VALUES
(1, 1, '2025-01-05'), (1, 2, '2025-01-06'), (2, 3, '2025-01-07'), (2, 4, '2025-01-08'),
(3, 5, '2025-01-09'), (3, 6, '2025-01-10'), (4, 7, '2025-01-11'), (4, 8, '2025-01-12'),
(5, 9, '2025-01-13'), (5, 10, '2025-01-14');

-- Assigned
INSERT INTO Assigned (team_id, team_name, crew_id, area_id) VALUES
(1, 'Team One', 1, 1), (2, 'Team Two', 2, 1), (3, 'Team Three', 3, 2), (4, 'Team Four', 4, 2),
(5, 'Team Five', 5, 3), (6, 'Team Six', 6, 3), (7, 'Team Seven', 7, 4), (8, 'Team Eight', 8, 4),
(9, 'Team Nine', 9, 5), (10, 'Team Ten', 10, 5);

-- ===== CREATE VIEWS FOR EASY DATA ACCESS =====

CREATE VIEW citizen_area_view AS
SELECT c.citizen_id, c.name, c.address, c.contact, c.email, a.area_id, a.area_name, a.location 
FROM Citizen c JOIN Area a ON c.area_id = a.area_id;

CREATE VIEW bill_summary_view AS
SELECT status, COUNT(*) as total_bills, SUM(amount) as total_amount, AVG(amount) as average_amount,
MIN(amount) as min_amount, MAX(amount) as max_amount FROM Bill GROUP BY status;

CREATE VIEW waste_collection_summary AS
SELECT category, COUNT(*) as total_items, SUM(weight) as total_weight_kg, AVG(weight) as average_weight_kg,
MIN(weight) as min_weight, MAX(weight) as max_weight FROM Waste GROUP BY category;

CREATE VIEW waste_collection_by_area AS
SELECT a.area_id, a.area_name, COUNT(w.waste_id) as total_waste, SUM(w.weight) as total_weight, AVG(w.weight) as avg_weight
FROM Area a LEFT JOIN Citizen c ON a.area_id = c.area_id LEFT JOIN Waste w ON c.citizen_id = w.citizen_id
GROUP BY a.area_id, a.area_name;

CREATE VIEW crew_assignment_view AS
SELECT cr.crew_id, cr.team_name, cr.contact, cr.team_size, a.area_id, a.area_name 
FROM Crew cr JOIN Area a ON cr.area_id = a.area_id;

CREATE VIEW bin_status_by_area AS
SELECT a.area_id, a.area_name, COUNT(b.bin_id) as total_bins,
SUM(CASE WHEN b.status='Full' THEN 1 ELSE 0 END) as full_bins,
SUM(CASE WHEN b.status='Partial' THEN 1 ELSE 0 END) as partial_bins,
SUM(CASE WHEN b.status='Empty' THEN 1 ELSE 0 END) as empty_bins,
ROUND(AVG(b.fill_level), 2) as avg_fill_level
FROM Area a JOIN Bins b ON a.area_id = b.area_id GROUP BY a.area_id, a.area_name;

CREATE VIEW payment_tracking_view AS
SELECT p.payment_id, c.citizen_id, c.name as citizen_name, b.bill_number, p.amount, p.method, p.payment_date 
FROM Payment p JOIN Citizen c ON p.citizen_id = c.citizen_id LEFT JOIN Bill b ON p.bill_id = b.bill_id;

CREATE VIEW area_utilization_view AS
SELECT a.area_id, a.area_name, COUNT(DISTINCT c.citizen_id) as citizens, COUNT(DISTINCT b.bin_id) as bins,
COUNT(DISTINCT cr.crew_id) as crews, SUM(w.weight) as waste_kg
FROM Area a LEFT JOIN Citizen c ON a.area_id = c.area_id LEFT JOIN Bins b ON a.area_id = b.area_id
LEFT JOIN Crew cr ON a.area_id = cr.area_id LEFT JOIN Waste w ON c.citizen_id = w.citizen_id
GROUP BY a.area_id, a.area_name;

CREATE VIEW waste_status_summary AS
SELECT w.status, COUNT(*) as total_items, SUM(w.weight) as total_weight_kg, AVG(w.weight) as avg_weight_kg,
COUNT(DISTINCT w.citizen_id) as citizens FROM Waste w GROUP BY w.status;

CREATE VIEW bill_payment_reconciliation AS
SELECT b.bill_id, b.bill_number, b.status, b.amount as bill_amount, COALESCE(SUM(p.amount), 0) as total_paid,
(b.amount - COALESCE(SUM(p.amount), 0)) as balance_due, c.name as citizen_name, a.area_name
FROM Bill b JOIN Citizen c ON b.citizen_id = c.citizen_id JOIN Area a ON c.area_id = a.area_id
LEFT JOIN Payment p ON b.bill_id = p.bill_id GROUP BY b.bill_id, b.bill_number, b.status, b.amount, c.name, a.area_name;
