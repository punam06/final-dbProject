-- ========================================
-- WASTE MANAGEMENT DATABASE SCHEMA - DHAKA CONTEXT
-- Complete with JOINs, Constraints, Aggregate Functions
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
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Bins (
    bin_id INT PRIMARY KEY AUTO_INCREMENT,
    bin_number VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(20) DEFAULT 'Empty',
    fill_level INT DEFAULT 0,
    location VARCHAR(255),
    area_id INT NOT NULL,
    sensor VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Waste (
    waste_id INT PRIMARY KEY AUTO_INCREMENT,
    waste_type VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) DEFAULT 'Non-recyclable',
    weight DECIMAL(10, 2) NOT NULL,
    citizen_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'Collected',
    collection_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Crew (
    crew_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    contact VARCHAR(20) NOT NULL UNIQUE,
    area_id INT NOT NULL,
    team_size INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    payment_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    method VARCHAR(50) DEFAULT 'Cash',
    citizen_id INT NOT NULL,
    bill_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Has_Schedule (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    area_id INT NOT NULL,
    crew_id INT NOT NULL,
    schedule_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Collection_Schedule (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    schedule_date DATE NOT NULL,
    area_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Assigned (
    task_id INT PRIMARY KEY AUTO_INCREMENT,
    team_id INT NOT NULL,
    team_name VARCHAR(100),
    crew_id INT NOT NULL,
    area_id INT NOT NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===== ADD CONSTRAINTS USING ALTER =====

-- Area Constraints
ALTER TABLE Area
ADD CONSTRAINT check_population CHECK (population >= 0),
ADD CONSTRAINT unique_area_name UNIQUE (area_name);

-- Citizen Constraints
ALTER TABLE Citizen
ADD CONSTRAINT fk_citizen_area FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE,
ADD CONSTRAINT check_contact_length CHECK (CHAR_LENGTH(TRIM(contact)) >= 10),
ADD CONSTRAINT unique_citizen_contact UNIQUE (contact);

-- Bins Constraints
ALTER TABLE Bins
ADD CONSTRAINT fk_bins_area FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE,
ADD CONSTRAINT check_fill_level CHECK (fill_level >= 0 AND fill_level <= 100),
ADD CONSTRAINT check_bin_status CHECK (status IN ('Empty', 'Partial', 'Full')),
ADD CONSTRAINT unique_bin_number UNIQUE (bin_number);

-- Waste Constraints
ALTER TABLE Waste
ADD CONSTRAINT fk_waste_citizen FOREIGN KEY (citizen_id) REFERENCES Citizen(citizen_id) ON DELETE CASCADE,
ADD CONSTRAINT check_weight CHECK (weight > 0),
ADD CONSTRAINT check_waste_category CHECK (category IN ('Recyclable', 'Biodegradable', 'Non-recyclable')),
ADD CONSTRAINT check_waste_status CHECK (status IN ('Collected', 'Recycled', 'Disposed', 'Pending'));

-- Crew Constraints
ALTER TABLE Crew
ADD CONSTRAINT fk_crew_area FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE,
ADD CONSTRAINT check_team_size CHECK (team_size > 0),
ADD CONSTRAINT check_crew_contact CHECK (CHAR_LENGTH(TRIM(contact)) >= 10),
ADD CONSTRAINT unique_crew_contact UNIQUE (contact);

-- Recycling Center Constraints
ALTER TABLE Recycling_Center
ADD CONSTRAINT check_capacity CHECK (capacity > 0);

-- Bill Constraints
ALTER TABLE Bill
ADD CONSTRAINT fk_bill_citizen FOREIGN KEY (citizen_id) REFERENCES Citizen(citizen_id) ON DELETE CASCADE,
ADD CONSTRAINT check_amount CHECK (amount > 0),
ADD CONSTRAINT check_bill_status CHECK (status IN ('Pending', 'Paid', 'Overdue')),
ADD CONSTRAINT unique_bill_number UNIQUE (bill_number);

-- Payment Constraints
ALTER TABLE Payment
ADD CONSTRAINT fk_payment_citizen FOREIGN KEY (citizen_id) REFERENCES Citizen(citizen_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_payment_bill FOREIGN KEY (bill_id) REFERENCES Bill(bill_id) ON DELETE SET NULL,
ADD CONSTRAINT check_payment_amount CHECK (amount > 0),
ADD CONSTRAINT check_payment_method CHECK (method IN ('Card', 'Cash', 'Online', 'Check'));

-- Has_Schedule Constraints
ALTER TABLE Has_Schedule
ADD CONSTRAINT fk_has_schedule_area FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_has_schedule_crew FOREIGN KEY (crew_id) REFERENCES Crew(crew_id) ON DELETE CASCADE;

-- Collection_Schedule Constraints
ALTER TABLE Collection_Schedule
ADD CONSTRAINT fk_collection_area FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE;

-- Assigned Constraints
ALTER TABLE Assigned
ADD CONSTRAINT fk_assigned_crew FOREIGN KEY (crew_id) REFERENCES Crew(crew_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_assigned_area FOREIGN KEY (area_id) REFERENCES Area(area_id) ON DELETE CASCADE;

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

-- ===== INSERT TEST DATA - DHAKA CONTEXT =====

-- Areas (Dhaka Districts)
INSERT INTO Area (area_name, location, population) VALUES
('গুলশান', 'গুলশান থানা, ঢাকা', 850000),
('বনানী', 'বনানী থানা, ঢাকা', 320000),
('ধানমন্ডি', 'ধানমন্ডি থানা, ঢাকা', 950000),
('মিরপুর', 'মিরপুর থানা, ঢাকা', 1200000),
('মতিঝিল', 'মতিঝিল থানা, ঢাকা', 450000);

-- Citizens (Bengali Names)
INSERT INTO Citizen (name, address, contact, area_id, email) VALUES
('রহিম আহমেদ', '১২৩ গুলশান আভিনিউ', '01700111111', 1, 'rahim@email.com'),
('ফাতিমা বেগম', '৪৫৬ ওক এভিনিউ', '01700111112', 1, 'fatima@email.com'),
('করিম খান', '৭৮৯ পাইন রোড', '01700222222', 2, 'karim@email.com'),
('নাজমা আক্তার', '৩২১ এলম স্ট্রিট', '01700222223', 2, 'nazma@email.com'),
('মুহাম্মদ আলী', '৬৫৪ ম্যাপল ড্রাইভ', '01700333333', 3, 'ali@email.com'),
('সালমা রানী', '৯৮৭ সিডার লেন', '01700333334', 3, 'salma@email.com'),
('ইউসুফ হোসেন', '১৪৭ বার্চ ওয়ে', '01700444444', 4, 'yusuf@email.com'),
('জেসিকা আহমেদ', '২৫৮ অ্যাশ কোর্ট', '01700444445', 4, 'jessica@email.com'),
('জেমস আলী', '৩৬৯ ওয়ালনাট স্ট্রিট', '01700555555', 5, 'james@email.com'),
('লিসা বেগম', '৭৪১ স্প্রুস এভিনিউ', '01700555556', 5, 'lisa@email.com');

-- Crew (Waste Management Teams - Dhaka - Bengali Names)
INSERT INTO Crew (team_name, contact, area_id, team_size) VALUES
('গুলশান পরিষ্কার দল', '01800111111', 1, 5),
('গুলশান রক্ষণাবেক্ষণ দল', '01800111112', 1, 4),
('বনানী বর্জ্য দল', '01800222222', 2, 5),
('বনানী সংগ্রহ দল', '01800222223', 2, 3),
('ধানমন্ডি স্বাস্থ্যবিধি দল', '01800333333', 3, 4),
('ধানমন্ডি নিষ্পত্তি দল', '01800333334', 3, 5),
('মিরপুর পরিচ্ছন্নতা দল', '01800444444', 4, 3),
('মিরপুর বর্জ্য ব্যবস্থাপনা', '01800444445', 4, 4),
('মতিঝিল পুনর্ব্যবহার দল', '01800555555', 5, 5),
('মতিঝিল সংগ্রহ দল', '01800555556', 5, 3);

-- Bins
INSERT INTO Bins (bin_number, status, fill_level, location, area_id, sensor) VALUES
('BIN001', 'Partial', 45, 'গুলশান আভিনিউ', 1, 'IOT_001'),
('BIN002', 'Full', 95, 'গুলশান মার্কেট', 1, 'IOT_002'),
('BIN003', 'Empty', 5, 'বনানী পার্ক', 2, 'IOT_003'),
('BIN004', 'Partial', 60, 'বনানী স্ট্রিট', 2, 'IOT_004'),
('BIN005', 'Partial', 50, 'ধানমন্ডি লেক', 3, 'IOT_005'),
('BIN006', 'Full', 88, 'ধানমন্ডি রোড', 3, 'IOT_006'),
('BIN007', 'Empty', 10, 'মিরপুর প্লেস', 4, 'IOT_007'),
('BIN008', 'Partial', 70, 'মিরপুর মার্কেট', 4, 'IOT_008'),
('BIN009', 'Full', 92, 'মতিঝিল সেন্টার', 5, 'IOT_009'),
('BIN010', 'Partial', 55, 'মতিঝিল এভিনিউ', 5, 'IOT_010');

-- Waste
INSERT INTO Waste (waste_type, name, category, weight, citizen_id, status) VALUES
('জৈব', 'খাবার বর্জ্য', 'Biodegradable', 2.5, 1, 'Collected'),
('প্লাস্টিক', 'বোতল এবং ব্যাগ', 'Recyclable', 1.2, 2, 'Collected'),
('কাগজ', 'সংবাদপত্র', 'Recyclable', 3.0, 3, 'Recycled'),
('ধাতু', 'ক্যান', 'Recyclable', 0.8, 4, 'Recycled'),
('কাচ', 'কাচের বোতল', 'Recyclable', 1.5, 5, 'Collected'),
('জৈব', 'বাগান বর্জ্য', 'Biodegradable', 4.0, 6, 'Disposed'),
('প্লাস্টিক', 'পাত্র', 'Recyclable', 0.9, 7, 'Pending'),
('কাগজ', 'পাপড়', 'Recyclable', 2.2, 8, 'Collected'),
('ধাতু', 'স্ক্র্যাপ ধাতু', 'Recyclable', 2.0, 9, 'Recycled'),
('মিশ্র', 'সাধারণ বর্জ্য', 'Non-recyclable', 5.5, 10, 'Disposed');

-- Recycling Centers (Dhaka - Bengali Names)
INSERT INTO Recycling_Center (location, capacity, operational_hours) VALUES
('ঢাকা কেন্দ্রীয় পুনর্ব্যবহার কেন্দ্র', 1000, '৮:০০ - ১৮:০০'),
('উত্তর ঢাকা পুনর্ব্যবহার কেন্দ্র', 800, '৯:০০ - ১৭:০০'),
('দক্ষিণ ঢাকা পুনর্ব্যবহার কেন্দ্র', 1200, '৮:०० - १९:००'),
('পূর্ব ঢাকা পুনর্ব্যবহার কেন্দ্র', 600, '৯:০০ - ১৭:००'),
('পশ্চিম ঢাকা পুনর্ব্যবহার কেন্দ্র', 900, '৮:००० - १८:००');

-- Bills (Using Taka - ৳)
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

-- Payments (Using Taka - ৳)
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
(1, 'দল এক', 1, 1), (2, 'দল দুই', 2, 1), (3, 'দল তিন', 3, 2), (4, 'দল চার', 4, 2),
(5, 'দল পাঁচ', 5, 3), (6, 'দল ছয়', 6, 3), (7, 'দল সাত', 7, 4), (8, 'দল আট', 8, 4),
(9, 'দল নয়', 9, 5), (10, 'দল দশ', 10, 5);

-- ===== VIEWS FOR EASY DATA ACCESS =====

CREATE VIEW citizen_area_view AS
SELECT 
    c.citizen_id, 
    c.name, 
    c.address, 
    c.contact, 
    c.email, 
    a.area_id,
    a.area_name, 
    a.location 
FROM Citizen c
JOIN Area a ON c.area_id = a.area_id;

CREATE VIEW bill_summary_view AS
SELECT 
    status, 
    COUNT(*) as total_bills,
    SUM(amount) as total_amount,
    AVG(amount) as average_amount,
    MIN(amount) as min_amount,
    MAX(amount) as max_amount
FROM Bill 
GROUP BY status;

CREATE VIEW waste_collection_summary AS
SELECT 
    category, 
    COUNT(*) as total_items,
    SUM(weight) as total_weight_kg,
    AVG(weight) as average_weight_kg,
    MIN(weight) as min_weight,
    MAX(weight) as max_weight
FROM Waste 
GROUP BY category;

CREATE VIEW waste_collection_by_area AS
SELECT 
    a.area_id, 
    a.area_name, 
    COUNT(w.waste_id) as total_waste,
    SUM(w.weight) as total_weight,
    AVG(w.weight) as avg_weight
FROM Area a
LEFT JOIN Citizen c ON a.area_id = c.area_id
LEFT JOIN Waste w ON c.citizen_id = w.citizen_id
GROUP BY a.area_id, a.area_name;

CREATE VIEW crew_assignment_view AS
SELECT 
    cr.crew_id, 
    cr.team_name, 
    cr.contact, 
    cr.team_size,
    a.area_id,
    a.area_name 
FROM Crew cr 
JOIN Area a ON cr.area_id = a.area_id;

CREATE VIEW bin_status_by_area AS
SELECT 
    a.area_id, 
    a.area_name, 
    COUNT(b.bin_id) as total_bins,
    SUM(CASE WHEN b.status='Full' THEN 1 ELSE 0 END) as full_bins,
    SUM(CASE WHEN b.status='Partial' THEN 1 ELSE 0 END) as partial_bins,
    SUM(CASE WHEN b.status='Empty' THEN 1 ELSE 0 END) as empty_bins,
    ROUND(AVG(b.fill_level), 2) as avg_fill_level
FROM Area a
JOIN Bins b ON a.area_id = b.area_id
GROUP BY a.area_id, a.area_name;

CREATE VIEW payment_tracking_view AS
SELECT 
    p.payment_id, 
    c.citizen_id,
    c.name as citizen_name, 
    b.bill_number, 
    p.amount, 
    p.method, 
    p.payment_date 
FROM Payment p
JOIN Citizen c ON p.citizen_id = c.citizen_id
LEFT JOIN Bill b ON p.bill_id = b.bill_id;

CREATE VIEW area_utilization_view AS
SELECT 
    a.area_id, 
    a.area_name, 
    COUNT(DISTINCT c.citizen_id) as citizens,
    COUNT(DISTINCT b.bin_id) as bins,
    COUNT(DISTINCT cr.crew_id) as crews,
    SUM(w.weight) as waste_kg
FROM Area a
LEFT JOIN Citizen c ON a.area_id = c.area_id
LEFT JOIN Bins b ON a.area_id = b.area_id
LEFT JOIN Crew cr ON a.area_id = cr.area_id
LEFT JOIN Waste w ON c.citizen_id = w.citizen_id
GROUP BY a.area_id, a.area_name;

CREATE VIEW waste_status_summary AS
SELECT 
    w.status,
    COUNT(*) as total_items,
    SUM(w.weight) as total_weight_kg,
    AVG(w.weight) as avg_weight_kg,
    COUNT(DISTINCT w.citizen_id) as citizens
FROM Waste w
GROUP BY w.status;

CREATE VIEW bill_payment_reconciliation AS
SELECT 
    b.bill_id,
    b.bill_number,
    b.status,
    b.amount as bill_amount,
    COALESCE(SUM(p.amount), 0) as total_paid,
    (b.amount - COALESCE(SUM(p.amount), 0)) as balance_due,
    c.name as citizen_name,
    a.area_name
FROM Bill b
JOIN Citizen c ON b.citizen_id = c.citizen_id
JOIN Area a ON c.area_id = a.area_id
LEFT JOIN Payment p ON b.bill_id = p.bill_id
GROUP BY b.bill_id, b.bill_number, b.status, b.amount, c.name, a.area_name;
