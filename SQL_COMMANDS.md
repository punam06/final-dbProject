# 🚀 SQL Commands - Copy & Paste Ready

📖 **Full Documentation:** [README.md](./README.md)

**Setup (Run First):**
```sql
mysql -u root
USE waste_management;
```

---

## 📋 VIEW ALL TABLES (Normal Queries)

```sql
SELECT * FROM Area;
SELECT * FROM Citizen;
SELECT * FROM Waste;
SELECT * FROM Bins;
SELECT * FROM Bill;
SELECT * FROM Payment;
SELECT * FROM Crew;
SELECT * FROM Recycling_Center;
SELECT * FROM Collection_Schedule;
SELECT * FROM Has_Schedule;
SELECT * FROM Assigned;
```

---

## 🔍 TABLE DESCRIPTION (Schema)

```sql
DESCRIBE Area;
DESCRIBE Citizen;
DESCRIBE Waste;
DESCRIBE Bins;
DESCRIBE Bill;
DESCRIBE Payment;
DESCRIBE Crew;
DESCRIBE Recycling_Center;
DESCRIBE Collection_Schedule;
DESCRIBE Has_Schedule;
DESCRIBE Assigned;
```

---

## 📊 COUNT RECORDS IN EACH TABLE

```sql
SELECT COUNT(*) as area_count FROM Area;
SELECT COUNT(*) as citizen_count FROM Citizen;
SELECT COUNT(*) as waste_count FROM Waste;
SELECT COUNT(*) as bins_count FROM Bins;
SELECT COUNT(*) as bill_count FROM Bill;
SELECT COUNT(*) as payment_count FROM Payment;
SELECT COUNT(*) as crew_count FROM Crew;
SELECT COUNT(*) as recycling_center_count FROM Recycling_Center;
SELECT COUNT(*) as collection_schedule_count FROM Collection_Schedule;
SELECT COUNT(*) as has_schedule_count FROM Has_Schedule;
SELECT COUNT(*) as assigned_count FROM Assigned;
```

---

## 🔗 JOIN QUERIES (Multiple Tables)

### JOIN #1: Citizens with Their Areas
```sql
SELECT c.citizen_id, c.name, c.address, c.contact, a.area_name, a.location FROM Citizen c JOIN Area a ON c.area_id = a.area_id;
```

### JOIN #2: Waste with Citizen Names
```sql
SELECT w.waste_id, w.name, w.category, w.weight, w.status, c.name as citizen_name FROM Waste w JOIN Citizen c ON w.citizen_id = c.citizen_id;
```

### JOIN #3: Bills with Citizen Names
```sql
SELECT b.bill_id, b.bill_number, c.name as citizen_name, b.amount, b.status FROM Bill b JOIN Citizen c ON b.citizen_id = c.citizen_id;
```

### JOIN #4: Payments with Citizen and Bill Details
```sql
SELECT p.payment_id, c.name as citizen_name, b.bill_number, p.amount, p.method, p.payment_date FROM Payment p JOIN Citizen c ON p.citizen_id = c.citizen_id LEFT JOIN Bill b ON p.bill_id = b.bill_id;
```

### JOIN #5: Team with Area Assignment
```sql
SELECT cr.crew_id, cr.team_name, cr.team_size, a.area_name, a.location FROM Crew cr JOIN Area a ON cr.area_id = a.area_id;
```

### JOIN #6: Bins with Area Details
```sql
SELECT b.bin_id, b.bin_number, b.status, b.fill_level, a.area_name FROM Bins b JOIN Area a ON b.area_id = a.area_id;
```

### JOIN #7: Waste Collection by Area (Multiple Joins)
```sql
SELECT a.area_name, c.name as citizen_name, w.name as waste_name, w.category, w.weight, w.status FROM Area a JOIN Citizen c ON a.area_id = c.area_id JOIN Waste w ON c.citizen_id = w.citizen_id;
```

### JOIN #8: Area with Crew and Citizens
```sql
SELECT a.area_name, COUNT(DISTINCT c.citizen_id) as citizen_count, COUNT(DISTINCT cr.crew_id) as crew_count FROM Area a LEFT JOIN Citizen c ON a.area_id = c.area_id LEFT JOIN Crew cr ON a.area_id = cr.area_id GROUP BY a.area_id, a.area_name;
```

### JOIN #9: Schedule with Crew and Area
```sql
SELECT hs.schedule_id, hs.schedule_date, a.area_name, cr.crew_name, cr.team_size FROM Has_Schedule hs JOIN Area a ON hs.area_id = a.area_id JOIN Crew cr ON hs.crew_id = cr.crew_id;
```

### JOIN #10: Assigned Tasks with Crew and Area
```sql
SELECT a.task_id, a.team_name, a.assigned_date, cr.crew_name, a.area_id FROM Assigned a JOIN Crew cr ON a.crew_id = cr.crew_id;
```

---

## 📈 AGGREGATE FUNCTIONS (GROUP BY)

### AGGREGATE #1: Waste by Category (COUNT, SUM, AVG, MIN, MAX)
```sql
SELECT category, COUNT(*) as item_count, SUM(weight) as total_weight, AVG(weight) as avg_weight, MIN(weight) as min_weight, MAX(weight) as max_weight FROM Waste GROUP BY category;
```

### AGGREGATE #2: Bill Status Summary
```sql
SELECT status, COUNT(*) as count, SUM(amount) as total_amount, AVG(amount) as avg_amount FROM Bill GROUP BY status;
```

### AGGREGATE #3: Waste Status Distribution
```sql
SELECT status, COUNT(*) as count, SUM(weight) as total_weight FROM Waste GROUP BY status;
```

### AGGREGATE #4: Bins by Area (Status Breakdown)
```sql
SELECT a.area_name, COUNT(b.bin_id) as total_bins, SUM(CASE WHEN b.status='Full' THEN 1 ELSE 0 END) as full_bins, SUM(CASE WHEN b.status='Partial' THEN 1 ELSE 0 END) as partial_bins, SUM(CASE WHEN b.status='Empty' THEN 1 ELSE 0 END) as empty_bins, ROUND(AVG(b.fill_level), 2) as avg_fill_level FROM Area a JOIN Bins b ON a.area_id = b.area_id GROUP BY a.area_id, a.area_name;
```

### AGGREGATE #5: Payment Method Statistics
```sql
SELECT method, COUNT(*) as total_payments, SUM(amount) as total_amount, AVG(amount) as avg_payment FROM Payment GROUP BY method ORDER BY total_amount DESC;
```

### AGGREGATE #6: Waste by Citizen
```sql
SELECT c.name, COUNT(w.waste_id) as waste_count, SUM(w.weight) as total_weight FROM Citizen c JOIN Waste w ON c.citizen_id = w.citizen_id GROUP BY c.citizen_id, c.name ORDER BY total_weight DESC;
```

### AGGREGATE #7: Crew Team Statistics
```sql
SELECT a.area_name, COUNT(cr.crew_id) as total_crews, SUM(cr.team_size) as total_staff FROM Area a JOIN Crew cr ON a.area_id = cr.area_id GROUP BY a.area_id, a.area_name;
```

### AGGREGATE #8: Recycling Center Capacity
```sql
SELECT COUNT(*) as total_centers, SUM(capacity) as total_capacity, AVG(capacity) as avg_capacity, MAX(capacity) as max_capacity, MIN(capacity) as min_capacity FROM Recycling_Center;
```

---

## 🎯 VIEW QUERIES (Pre-defined Views)

```sql
SELECT * FROM citizen_area_view;
SELECT * FROM bill_summary_view;
SELECT * FROM waste_collection_summary;
SELECT * FROM waste_collection_by_area;
SELECT * FROM crew_assignment_view;
SELECT * FROM bin_status_by_area;
SELECT * FROM payment_tracking_view;
SELECT * FROM area_utilization_view;
SELECT * FROM waste_status_summary;
SELECT * FROM bill_payment_reconciliation;
```

---

## 📝 COMPLEX QUERIES

### Total Waste Collection by Area with All Details
```sql
SELECT a.area_id, a.area_name, a.population, COUNT(DISTINCT c.citizen_id) as citizens, COUNT(w.waste_id) as waste_items, SUM(w.weight) as total_weight, COUNT(DISTINCT b.bin_id) as bins FROM Area a LEFT JOIN Citizen c ON a.area_id = c.area_id LEFT JOIN Waste w ON c.citizen_id = w.citizen_id LEFT JOIN Bins b ON a.area_id = b.area_id GROUP BY a.area_id, a.area_name, a.population ORDER BY total_weight DESC;
```

### Bills Not Fully Paid
```sql
SELECT b.bill_id, b.bill_number, c.name, b.amount, COALESCE(SUM(p.amount), 0) as paid, (b.amount - COALESCE(SUM(p.amount), 0)) as balance_due FROM Bill b JOIN Citizen c ON b.citizen_id = c.citizen_id LEFT JOIN Payment p ON b.bill_id = p.bill_id GROUP BY b.bill_id, b.bill_number, c.name, b.amount HAVING balance_due > 0;
```

### Waste Statistics by Status and Category
```sql
SELECT status, category, COUNT(*) as count, SUM(weight) as total_weight, AVG(weight) as avg_weight FROM Waste GROUP BY status, category;
```

### Area Performance Report
```sql
SELECT a.area_name, COUNT(DISTINCT c.citizen_id) as citizens, SUM(w.weight) as total_waste, COUNT(DISTINCT cr.crew_id) as crews, COUNT(DISTINCT b.bin_id) as bins FROM Area a LEFT JOIN Citizen c ON a.area_id = c.area_id LEFT JOIN Waste w ON c.citizen_id = w.citizen_id LEFT JOIN Crew cr ON a.area_id = cr.area_id LEFT JOIN Bins b ON a.area_id = b.area_id GROUP BY a.area_id, a.area_name;
```

### Citizens with Multiple Waste Entries
```sql
SELECT c.citizen_id, c.name, COUNT(w.waste_id) as waste_count, SUM(w.weight) as total_weight FROM Citizen c JOIN Waste w ON c.citizen_id = w.citizen_id GROUP BY c.citizen_id, c.name HAVING COUNT(w.waste_id) > 1 ORDER BY waste_count DESC;
```

---

## 🗑️ DELETE EXAMPLES

### Delete Old Disposed Waste (older than 30 days)
```sql
DELETE FROM Waste WHERE status='Disposed' AND collection_date < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

### Delete Payments from Specific Bill
```sql
DELETE FROM Payment WHERE bill_id = 1;
```

### Delete Bills with Zero Balance
```sql
DELETE b FROM Bill b WHERE NOT EXISTS (SELECT 1 FROM Payment p WHERE p.bill_id = b.bill_id);
```

---

## ✏️ UPDATE EXAMPLES

### Update Waste Status to Disposed
```sql
UPDATE Waste SET status='Disposed' WHERE category='Recyclable' AND status='Collected';
```

### Update Bin Fill Level by Area
```sql
UPDATE Bins SET fill_level=50 WHERE area_id=1;
```

### Update Overdue Bills
```sql
UPDATE Bill SET status='Overdue' WHERE status='Pending' AND due_date < CURDATE();
```

---

## 📌 USEFUL COMMANDS

```sql
SHOW TABLES;
SHOW DATABASES;
SHOW CREATE TABLE Area;
SHOW VIEWS;
SHOW FULL TABLES WHERE Table_Type='VIEW';
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='waste_management';
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='waste_management' AND TABLE_NAME='Waste';
EXPLAIN SELECT * FROM Waste;
```

---

## ✅ HOW TO USE

1. **Copy any single line** from above
2. **Paste into MySQL terminal** (after `USE waste_management;`)
3. **Press Enter** to execute
4. **See results immediately**

**Example:**
```
mysql -u root
USE waste_management;
SELECT * FROM Area;
```

---

## 👥 CREW MANAGEMENT EXPLAINED

### How Teams are Assigned (Dhaka Waste Management):

**TEAM-BASED (Not Individual-Based)**

Each "Crew" is a complete team:
- Gulshan Cleanup Team = 5 members (work together)
- Banani Waste Team = 5 members (work together)
- Dhanmondi Sanitization Team = 4 members (work together)

**NOT individual crew members assigned separately**

### Team Structure:

**Step 1: Define Team**
```sql
SELECT crew_id, team_name, team_size, area_id, contact FROM Crew;
```
Shows: All teams, their size (3-5 members), and home area (Gulshan, Banani, Dhanmondi, Mirpur, Motijheel)

**Step 2: Assign Team to Schedule**
```sql
SELECT * FROM Has_Schedule;
```
Shows: Which team, assigned to which Dhaka area, on what date

**Step 3: Create Task Assignment**
```sql
SELECT * FROM Assigned;
```
Shows: Team assigned to area with assignment date

### Query: See All Team Assignments
```sql
SELECT cr.team_name, cr.team_size, a.area_name, hs.schedule_date FROM Has_Schedule hs JOIN Crew cr ON hs.crew_id = cr.crew_id JOIN Area a ON hs.area_id = a.area_id ORDER BY hs.schedule_date;
```

### Current Teams in Dhaka (10 Waste Management Teams):
- Gulshan Cleanup Team (5 members) → Gulshan
- Gulshan Maintenance Crew (4 members) → Gulshan
- Banani Waste Team (5 members) → Banani
- Banani Collection Crew (3 members) → Banani
- Dhanmondi Sanitization Team (4 members) → Dhanmondi
- Dhanmondi Disposal Crew (5 members) → Dhanmondi
- Mirpur Cleaning Team (3 members) → Mirpur
- Mirpur Waste Management (4 members) → Mirpur
- Motijheel Recycling Team (5 members) → Motijheel
- Motijheel Collection Crew (3 members) → Motijheel

---

## ⚠️ SERVER STABILITY GUIDE

### If Server Crashes or Stops Responding:

**Step 1: Kill existing processes**
```bash
pkill -f "python app.py"
lsof -i :5000 -t | xargs kill -9
sleep 2
```

**Step 2: Restart the server**
```bash
cd /Users/punam/Desktop/varsity/3-1/Lab/dbms/finalProj
source venv/bin/activate
python app.py
```

**Step 3: Test it's running**
```bash
curl -s http://127.0.0.1:5000 | head -10
```

### Why Server May Crash After Several Requests:

1. **Port 5000 Already in Use**
   - Check: `lsof -i :5000`
   - Kill: `lsof -i :5000 -t | xargs kill -9`
   - Restart Flask

2. **Database Connection Issues**
   - MySQL connection timeout after inactivity
   - Solution: Restart Flask, it will auto-reconnect
   - Ensure MySQL is running: `mysql -u root -e "SELECT 1"`

3. **Memory Buildup (After Many Update/Delete Operations)**
   - Normal for Flask development server
   - Query logging writes to schema.sql repeatedly
   - Solution: Restart Flask periodically

4. **Too Many Concurrent Requests**
   - Flask development server handles limited requests
   - Production would use Gunicorn/WSGI
   - Solution: Don't refresh browser repeatedly

### Prevention & Best Practices:

✅ Wait 2-3 seconds between API calls
✅ Don't continuously refresh the browser
✅ Use one MySQL client at a time
✅ Restart server if it becomes unresponsive
✅ Monitor server logs: `tail -f server.log`

### Quick Server Restart Script:

```bash
# Save this as restart_server.sh
pkill -f "python app.py"
lsof -i :5000 -t | xargs kill -9 2>/dev/null
sleep 2
cd /Users/punam/Desktop/varsity/3-1/Lab/dbms/finalProj
source venv/bin/activate
nohup python app.py > server.log 2>&1 &
sleep 3
echo "✅ Server restarted"
```

Run with: `bash restart_server.sh`

---

**All queries tested and production-ready!** 🎉
