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

-- ===== AGGREGATE FUNCTIONS WITH GROUP BY - QUERIES FOR REAL-TIME REPORTING =====

-- 1. WASTE STATISTICS BY CATEGORY (COUNT, SUM, AVG, MIN, MAX)
-- Purpose: Analyze waste data across categories using all aggregate functions
-- Usage: Copy entire SELECT query and paste into MySQL
SELECT 
    category,
    COUNT(*) AS item_count,
    SUM(weight) AS total_weight_kg,
    AVG(weight) AS average_weight_kg,
    MIN(weight) AS min_weight_kg,
    MAX(weight) AS max_weight_kg
FROM Waste
GROUP BY category
ORDER BY total_weight_kg DESC;

-- 2. WASTE STATISTICS BY STATUS (Real-time updates)
-- Purpose: Track waste by collection status
SELECT 
    status,
    COUNT(*) AS total_waste_items,
    SUM(weight) AS total_weight_kg,
    AVG(weight) AS avg_weight_per_item,
    MIN(weight) AS minimum_weight,
    MAX(weight) AS maximum_weight,
    COUNT(DISTINCT citizen_id) AS unique_citizens
FROM Waste
GROUP BY status
ORDER BY total_weight_kg DESC;

-- 3. WASTE BY CITIZEN (Find who produces most waste)
-- Purpose: Identify top waste producers
SELECT 
    c.citizen_id,
    c.name,
    c.address,
    COUNT(w.waste_id) AS waste_count,
    SUM(w.weight) AS total_waste_kg,
    AVG(w.weight) AS avg_weight_per_entry,
    a.area_name
FROM Citizen c
LEFT JOIN Waste w ON c.citizen_id = w.citizen_id
LEFT JOIN Area a ON c.area_id = a.area_id
GROUP BY c.citizen_id, c.name, c.address, a.area_name
ORDER BY total_waste_kg DESC;

-- 4. WASTE COLLECTION BY AREA (Performance metrics)
-- Purpose: See how much waste each area generates
SELECT 
    a.area_id,
    a.area_name,
    a.population,
    COUNT(DISTINCT c.citizen_id) AS active_citizens,
    COUNT(w.waste_id) AS waste_entries,
    SUM(w.weight) AS total_waste_kg,
    AVG(w.weight) AS avg_weight_per_waste,
    ROUND(SUM(w.weight) / a.population * 1000, 2) AS waste_per_1000_population
FROM Area a
LEFT JOIN Citizen c ON a.area_id = c.area_id
LEFT JOIN Waste w ON c.citizen_id = w.citizen_id
GROUP BY a.area_id, a.area_name, a.population
ORDER BY total_waste_kg DESC;

-- 5. BILL SUMMARY WITH AGGREGATE FUNCTIONS
-- Purpose: Financial overview with all calculations
SELECT 
    status,
    COUNT(*) AS bill_count,
    SUM(amount) AS total_amount_bdt,
    AVG(amount) AS average_bill_amount,
    MIN(amount) AS minimum_bill,
    MAX(amount) AS maximum_bill,
    ROUND(AVG(amount), 2) AS mean_amount
FROM Bill
GROUP BY status
ORDER BY total_amount_bdt DESC;

-- 6. PAYMENT STATISTICS BY METHOD
-- Purpose: Track payment methods and amounts
SELECT 
    method,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_amount_bdt,
    AVG(amount) AS avg_payment_amount,
    MIN(amount) AS min_payment,
    MAX(amount) AS max_payment
FROM Payment
GROUP BY method
ORDER BY total_amount_bdt DESC;

-- 7. BILL PAYMENT STATUS ANALYSIS
-- Purpose: Determine paid vs unpaid amounts by status
SELECT 
    b.status,
    COUNT(DISTINCT b.bill_id) AS total_bills,
    SUM(b.amount) AS billing_amount_bdt,
    COALESCE(SUM(p.amount), 0) AS total_paid_bdt,
    (SUM(b.amount) - COALESCE(SUM(p.amount), 0)) AS outstanding_bdt,
    ROUND((COALESCE(SUM(p.amount), 0) / SUM(b.amount)) * 100, 2) AS payment_percentage
FROM Bill b
LEFT JOIN Payment p ON b.bill_id = p.bill_id
GROUP BY b.status
ORDER BY outstanding_bdt DESC;

-- 8. BIN STATUS DISTRIBUTION BY AREA
-- Purpose: Monitor bin capacity across all areas
SELECT 
    a.area_id,
    a.area_name,
    COUNT(b.bin_id) AS total_bins,
    SUM(CASE WHEN b.status = 'Full' THEN 1 ELSE 0 END) AS full_bins,
    SUM(CASE WHEN b.status = 'Partial' THEN 1 ELSE 0 END) AS partial_bins,
    SUM(CASE WHEN b.status = 'Empty' THEN 1 ELSE 0 END) AS empty_bins,
    ROUND(AVG(b.fill_level), 2) AS avg_fill_level,
    MAX(b.fill_level) AS max_fill_level
FROM Area a
JOIN Bins b ON a.area_id = b.area_id
GROUP BY a.area_id, a.area_name
ORDER BY full_bins DESC;

-- 9. CREW TEAM STATISTICS BY AREA
-- Purpose: Analyze crew deployment and team sizes
SELECT 
    a.area_id,
    a.area_name,
    COUNT(c.crew_id) AS total_crews,
    SUM(c.team_size) AS total_team_members,
    AVG(c.team_size) AS avg_team_size,
    MIN(c.team_size) AS min_team_size,
    MAX(c.team_size) AS max_team_size
FROM Area a
LEFT JOIN Crew c ON a.area_id = c.area_id
GROUP BY a.area_id, a.area_name
ORDER BY total_team_members DESC;

-- 10. RECYCLING CENTER CAPACITY ANALYSIS
-- Purpose: Track recycling center utilization
SELECT 
    center_id,
    location,
    capacity,
    COUNT(DISTINCT CAST(SUBSTRING(location, 1, LOCATE(' ', location) - 1) AS CHAR)) AS facility_count
FROM Recycling_Center
GROUP BY center_id, location, capacity
ORDER BY capacity DESC;

-- ===== REAL-TIME UPDATE COMMANDS WITH INLINE COMMENTS =====

-- UPDATE 1: UPDATE WASTE STATUS FROM PENDING TO COLLECTED
-- Usage: Marks all pending waste as collected for real-time tracking
UPDATE Waste 
SET status = 'Collected', collection_date = NOW() 
WHERE status = 'Pending' 
LIMIT 10;

-- Verify the update worked
SELECT waste_id, name, status, collection_date FROM Waste WHERE status = 'Collected' LIMIT 5;

-- UPDATE 2: UPDATE BIN FILL LEVELS (Real-time sensor data)
-- Usage: Simulates IoT sensor updates for bin fill levels
UPDATE Bins 
SET fill_level = CASE 
    WHEN bin_number = 'BIN001' THEN 75
    WHEN bin_number = 'BIN002' THEN 20
    WHEN bin_number = 'BIN003' THEN 90
    WHEN bin_number = 'BIN004' THEN 55
    ELSE fill_level
END,
status = CASE
    WHEN fill_level >= 80 THEN 'Full'
    WHEN fill_level < 20 THEN 'Empty'
    ELSE 'Partial'
END,
created_at = NOW()
WHERE bin_number IN ('BIN001', 'BIN002', 'BIN003', 'BIN004');

-- Verify bin updates
SELECT bin_number, status, fill_level FROM Bins WHERE bin_number IN ('BIN001', 'BIN002', 'BIN003', 'BIN004');

-- UPDATE 3: UPDATE OVERDUE BILLS TO OVERDUE STATUS
-- Usage: Auto-flag bills past due date as overdue
UPDATE Bill 
SET status = 'Overdue', created_at = NOW()
WHERE due_date < CURDATE() AND status != 'Paid';

-- Verify overdue bills
SELECT bill_number, status, due_date FROM Bill WHERE status = 'Overdue';

-- UPDATE 4: UPDATE CITIZEN CONTACT WITH NEW PHONE NUMBERS
-- Usage: Real-time contact updates for specific citizens
UPDATE Citizen 
SET contact = CASE 
    WHEN citizen_id = 1 THEN '01900000001'
    WHEN citizen_id = 2 THEN '01900000002'
    WHEN citizen_id = 3 THEN '01900000003'
    ELSE contact
END,
registration_date = NOW()
WHERE citizen_id IN (1, 2, 3);

-- Verify citizen updates
SELECT citizen_id, name, contact FROM Citizen WHERE citizen_id IN (1, 2, 3);

-- UPDATE 5: MARK PROCESSED WASTE AS RECYCLED
-- Usage: Update waste items that have been processed at recycling centers
UPDATE Waste 
SET status = 'Recycled', collection_date = NOW()
WHERE category = 'Recyclable' AND status = 'Collected'
LIMIT 5;

-- Verify recycled items
SELECT waste_id, name, category, status FROM Waste WHERE status = 'Recycled';

-- UPDATE 6: AUTO-UPDATE PAYMENT METHOD FOR FAILED TRANSACTIONS
-- Usage: Change payment method if online payment failed
UPDATE Payment 
SET method = 'Cash', created_at = NOW()
WHERE method = 'Online' AND payment_date < DATE_SUB(CURDATE(), INTERVAL 7 DAY)
LIMIT 3;

-- Verify payment updates
SELECT payment_id, method, payment_date FROM Payment WHERE method = 'Cash' ORDER BY payment_date DESC LIMIT 5;

-- UPDATE 7: BATCH UPDATE CREW TEAM SIZES BASED ON AREA DEMAND
-- Usage: Scale up team sizes for high-population areas
UPDATE Crew
SET team_size = CASE
    WHEN area_id = 4 THEN 6
    WHEN area_id = 3 THEN 5
    WHEN area_id = 1 THEN 5
    ELSE team_size
END,
created_at = NOW()
WHERE area_id IN (1, 3, 4);

-- Verify crew updates
SELECT crew_id, team_name, team_size, area_id FROM Crew WHERE area_id IN (1, 3, 4);

-- UPDATE 8: REAL-TIME UPDATE BIN STATUS BASED ON FILL LEVEL
-- Usage: Auto-update bin status to match fill level thresholds
UPDATE Bins
SET status = CASE
    WHEN fill_level >= 85 THEN 'Full'
    WHEN fill_level <= 20 THEN 'Empty'
    WHEN fill_level > 20 AND fill_level < 85 THEN 'Partial'
    ELSE status
END
WHERE 1=1;

-- Verify bin status updates
SELECT bin_number, status, fill_level FROM Bins ORDER BY fill_level DESC;

-- ===== CONSTRAINT ENFORCEMENT EXAMPLES =====

-- Constraint Test 1: Try to insert invalid weight (should fail)
-- INSERT INTO Waste (waste_type, name, category, weight, citizen_id, status) 
-- VALUES ('Test', 'Invalid', 'Recyclable', -1.5, 1, 'Collected');
-- Error: Check constraint 'check_weight' violated

-- Constraint Test 2: Try to insert invalid fill level (should fail)
-- UPDATE Bins SET fill_level = 150 WHERE bin_id = 1;
-- Error: Check constraint 'check_fill_level' violated

-- Constraint Test 3: Try to insert invalid status (should fail)
-- UPDATE Waste SET status = 'Invalid' WHERE waste_id = 1;
-- Error: Check constraint 'check_waste_status' violated

-- ===== INLINE DOCUMENTATION FOR QUERIES =====

-- Query Types Included:
-- 1. COUNT(*) - Counts number of records in each group
-- 2. SUM() - Adds up all values in a column
-- 3. AVG() - Calculates average value across group
-- 4. MIN() - Finds minimum value in group
-- 5. MAX() - Finds maximum value in group
-- 6. GROUP BY - Organizes results by specified column
-- 7. LEFT JOIN - Includes all records from left table even if no match
-- 8. CASE WHEN - Conditional updates for real-time status changes
-- 9. CURDATE() - Current date for real-time updates
-- 10. NOW() - Current timestamp for real-time updates
-- 11. LIMIT - Restricts number of rows affected
-- 12. ORDER BY - Sorts results by specified column
