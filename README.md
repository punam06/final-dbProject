# Dhaka Waste Management System

> **🌐 FRONTEND**: **http://localhost:8000** or **http://localhost:8001** ← Open this link after running `./run.sh`
>
> ℹ️ **NOTE**: If port 8000 is busy, the system automatically uses port 8001 or the next available port.

A comprehensive waste management system for Dhaka city built with Flask backend, MySQL database, and responsive HTML5 frontend.

## Quick Start

```bash
# Make scripts executable
chmod +x run.sh server-quick-start.sh

# Start the server
./run.sh

# OR quick restart (kills lingering processes first)
./server-quick-start.sh
```

## Features

- **Waste Collection Management**: Track waste collection routes and schedules
- **Team Management**: Manage collection teams and assignments
- **Citizen Registration**: Register and track citizens and their waste disposal
- **Payment Tracking**: Process and track waste management payments in BDT (৳)
- **Recycling Centers**: Manage 5 recycling centers across Dhaka (Gulshan, Banani, Dhanmondi, Mirpur, Motijheel)
- **Area Coverage**: Serve 5 major areas in Dhaka
- **Reporting**: Comprehensive reports on collections, payments, and recycling
- **Real-time Auto-Save**: All updates automatically logged to database

## Project Structure

```
backend/              - Flask application with 40+ API endpoints
frontend/             - HTML5 templates with responsive design
api/                  - API documentation and examples
database/             - MySQL schema and sample data
environment/          - Configuration files
static/               - CSS, JavaScript, images
run.sh                - Main startup script (use this)
server-quick-start.sh - Quick restart script (kills stuck processes first)
```

## Tech Stack

- **Backend**: Python 3.x with Flask 3.1.2
- **Database**: MySQL with connection pooling
- **Frontend**: HTML5, CSS3, JavaScript
- **Authentication**: Session-based with Flask

## Database

The system uses 11 tables with the following coverage:
- 5 Dhaka areas
- 5 recycling centers
- 10 collection teams
- 45+ sample citizen records
- 10 payment records
- 10 virtual views for reporting

### Dhaka Areas Served

1. **Gulshan** - Modern commercial district
2. **Banani** - Residential area
3. **Dhanmondi** - Educational hub
4. **Mirpur** - Industrial area
5. **Motijheel** - Business district

### Recycling Centers

- Gulshan Recycling Center
- Banani Recycling Center
- Dhanmondi Recycling Center
- Mirpur Recycling Center
- Motijheel Recycling Center

## Setup

### Requirements

- Python 3.7+
- MySQL 5.7+
- pip package manager
- macOS/Linux/Windows with bash shell

### Quick Start (Recommended)

The easiest way to run the application is using the startup script:

```bash
# Clone the repository
git clone https://github.com/punam06/final-dbProject.git
cd final-dbProject

# Make the startup script executable
chmod +x run.sh

# Run the application
./run.sh
```

The script automatically:
- ✅ Checks MySQL is running
- ✅ Initializes database if needed
- ✅ Installs dependencies
- ✅ Clears port conflicts
- ✅ Starts Flask server on port 8000

### Manual Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/punam06/final-dbProject.git
   cd final-dbProject
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Setup database**
   ```bash
   mysql -u root -p < database/schema.sql
   ```

4. **Configure environment** (optional)
   ```bash
   cp environment/.env.development environment/.env
   # Edit environment/.env with your database credentials if needed
   ```

5. **Run the application**
   ```bash
   python backend/app.py
   ```

## Access the Application

### 🌐 Frontend (Web Interface) - START HERE
**Main Dashboard**: **http://localhost:8000**

This is your main entry point. Open this link in your browser after running `./run.sh`:

#### Available Pages:
| Page | URL | Purpose |
|------|-----|---------|
| Dashboard | `http://localhost:8000/` | System overview with statistics |
| Citizens | `http://localhost:8000/citizens` | Manage citizen registrations |
| Areas | `http://localhost:8000/areas` | Area coverage management |
| Crew/Teams | `http://localhost:8000/crew` | Waste collection team management |
| Waste | `http://localhost:8000/waste` | Waste collection tracking |
| Bins | `http://localhost:8000/bins` | Smart bin management |
| Bills | `http://localhost:8000/bills` | Billing and charges (BDT currency) |
| Payments | `http://localhost:8000/payments` | Payment records and tracking |
| Schedules | `http://localhost:8000/schedules` | Collection schedules |
| Recycling Centers | `http://localhost:8000/centers` | Recycling facility management |

### Backend (API)
- **Base URL**: `http://localhost:8000/api`
- **Dashboard Stats**: `http://localhost:8000/api/dashboard-stats`

## API Endpoints

40+ endpoints for:
- Citizens (CRUD operations)
- Teams (management and assignments)
- Waste collections (tracking and scheduling)
- Payments (processing and history)
- Recycling centers (management)
- Areas (coverage and statistics)
- Reports and analytics

## Features Implemented

✅ Server stability with connection pooling  
✅ Async logging system  
✅ Complete error handling  
✅ 40+ RESTful API endpoints  
✅ Responsive frontend with modern UI  
✅ Comprehensive data validation  
✅ Payment tracking with Taka (৳) currency  
✅ Team and waste collection management  
✅ Recycling center operations  
✅ Automatic startup script for easy deployment  
✅ Port conflict resolution (uses port 8000)  
✅ Template and static file serving  
✅ MySQL connection pooling  
✅ **Real-time SQL Auto-Save**: All frontend updates automatically logged to `database/schema.sql`  
✅ **Aggregate Functions**: GROUP BY queries with COUNT, SUM, AVG, MIN, MAX  
✅ **Inline Commands**: Every frontend update includes timestamp and verification query  
✅ **Full-Width Responsive Design**: Mobile, tablet, and desktop optimized  
✅ **English-Only Dhaka Context**: All data in English for international use

## Real-Time Database Updates

When you make changes through the web interface (add, edit, delete), the system automatically generates and saves the corresponding SQL queries to `database/schema.sql` with:

✅ **Actual parameter values** (not placeholders)  
✅ **Timestamps** of when the change was made  
✅ **Operation type** (INSERT, UPDATE, DELETE)  
✅ **Table name** where the change occurred  
✅ **Metadata comments** for easy audit trail  

### Example Auto-Saved Queries

When you **add a new citizen** through the Citizens page:
```sql
-- ========================================
-- FRONTEND AUTO-SAVE: INSERT Operation
-- Table: Citizen
-- Timestamp: 2025-12-01 14:54:39
-- Status: Successfully executed and logged
-- ========================================
INSERT INTO Citizen (name, address, contact, area_id, email)
VALUES ('Ali Ahmed Test 2', 'Test Address 2, Dhaka', '01977777777', 2, 'ali.test@email.com');
```

When you **edit an existing citizen**:
```sql
-- ========================================
-- FRONTEND AUTO-SAVE: UPDATE Operation
-- Table: Citizen
-- Timestamp: 2025-12-01 14:55:05
-- Status: Successfully executed and logged
-- ========================================
UPDATE Citizen SET name='Updated Name', contact='01999888888', area_id=1 WHERE citizen_id=4;
```

When you **delete a citizen**:
```sql
-- ========================================
-- FRONTEND AUTO-SAVE: DELETE Operation
-- Table: Citizen
-- Timestamp: 2025-12-01 14:55:24
-- Status: Successfully executed and logged
-- ========================================
DELETE FROM Citizen WHERE citizen_id=16;
```

### How Auto-Save Works

1. **User Action**: You perform an action on any frontend page (Add, Edit, or Delete)
2. **API Call**: Frontend sends request to backend API endpoint
3. **Database Update**: Data is inserted, updated, or deleted in MySQL
4. **Auto-Save**: Backend generates complete SQL query with actual values
5. **Logging**: Query is appended to `database/schema.sql` as a comment block
6. **Async**: Logging happens in background thread (doesn't slow down frontend)

### View Auto-Saved Queries

All auto-saved queries are appended to the end of `database/schema.sql`:

```bash
# View last 50 auto-saved queries
tail -50 database/schema.sql

# View all queries for a specific table
grep -A3 "Table: Citizen" database/schema.sql

# Count total auto-saves
grep "FRONTEND AUTO-SAVE" database/schema.sql | wc -l
```

### Works on All Tables

Auto-save logging works for all CRUD operations across all tables:
- Citizens (add, edit, delete)
- Areas (add, edit, delete)
- Crew/Teams (add, edit, delete)
- Waste records (add, edit, delete)
- Bins (add, edit, delete)
- Bills (add, edit, delete)
- Payments (add, edit, delete)
- Schedules (add, edit, delete)
- Recycling Centers (add, edit, delete)



1. **Saves** the SQL command to `database/schema.sql`
2. **Logs** the timestamp and operation type
3. **Includes** a verification query for testing
4. **Updates** the live database immediately

### Example Auto-Saved Update in schema.sql:

```sql
-- ========================================
-- REAL-TIME UPDATE - Bill TABLE
-- Timestamp: 2025-01-01 10:30:15
-- Status: AUTO-SAVED from Frontend
-- ========================================
UPDATE Bill SET status = 'Paid', created_at = NOW() WHERE bill_id = 2;

-- Verification Query:
-- SELECT * FROM Bill WHERE bill_id = 2;
```

This feature provides:
- **Complete audit trail** of all changes
- **Replay capability** for testing or replication
- **Debugging support** with timestamps
- **Demo ready** SQL commands

---

## 🛠️ Server Stability Enhancements

### What Was Fixed
The server was crashing due to:
1. **Weak database connection handling** - Connections would timeout silently
2. **No connection recovery** - Failed queries would crash the server
3. **No automatic restart** - Crashed servers wouldn't recover
4. **Poor error handling** - Database errors weren't properly caught

### What's New (Commit: Latest)

**1. Enhanced Connection Pooling**
- Added connection timeout (10 seconds)
- Automatic connection health checks (ping before use)
- Automatic reconnection on connection loss
- Retry logic (up to 3 attempts per query)

**2. Better Error Handling**
- All database operations now have retry mechanisms
- Connection failures don't crash the server
- Timeout protection on queries (30 seconds)
- Detailed error logging for debugging

**3. Robust Server Management Script**
New `run_server.sh` script with auto-restart capability:
```bash
# Start server with auto-restart monitoring
./run_server.sh start

# Stop the server
./run_server.sh stop

# Restart the server
./run_server.sh restart

# View real-time logs
./run_server.sh logs
```

**Features of run_server.sh**:
- ✅ Auto-kills lingering processes before starting
- ✅ Detects port 8000 conflicts automatically
- ✅ Monitors server health every 5 seconds
- ✅ Auto-restarts server if it crashes
- ✅ Comprehensive logging to `server.log`
- ✅ Color-coded status messages

### How to Use

**Option 1: Simple Start (Best for Development)**
```bash
# Just run the monitoring script (auto-restarts on crash)
./run_server.sh start
```

**Option 2: Manual Start (For Debugging)**
```bash
# Start without monitoring
cd /Users/punam/Desktop/varsity/3-1/Lab/dbms/finalProj
source venv/bin/activate
python backend/app.py
```

**Option 3: Force Restart with Legacy Script**
```bash
# Use old script if needed
./server-quick-start.sh
```

### Benefits
- Server automatically recovers from crashes
- No more "Address already in use" errors
- Database connection failures don't crash the server
- Real-time visibility into server health
- All queries logged with timestamps

---

## 🚀 Live Server Deployment

### For Live Servers / Different Environments

**IMPORTANT**: The application uses absolute path resolution to work correctly on any server.

**Two ways to run the server:**

**Option 1: Using start_app.py (Recommended for Deployment)**
```bash
# From project root
cd /path/to/waste-management
python start_app.py
```

**Option 2: Using run_server.sh (Best for Development)**
```bash
# From project root
cd /path/to/waste-management
chmod +x run_server.sh
./run_server.sh start
```

### Why CSS Wasn't Loading on Live Server

**Previous Problem:**
- Relative paths like `../static` didn't work correctly
- CSS file returned 404 when running from different directories
- Only HTML loaded, CSS didn't load

**Solution Implemented:**
- All paths now use absolute resolution
- `start_app.py` runs from project root
- Flask correctly finds `/static` directory
- CSS loads with correct MIME type: `text/css`

### Path Resolution (Automatic)
The system automatically resolves:
- **Static files**: `PROJECT_ROOT/static`
- **Templates**: `PROJECT_ROOT/frontend/templates`
- **Database schema**: `PROJECT_ROOT/database/schema.sql`

### Deployment Checklist

✅ Clone repository to `/path/to/project`
✅ Create Python virtual environment: `python -m venv venv`
✅ Activate venv: `source venv/bin/activate`
✅ Install requirements: `pip install -r requirements.txt`
✅ Set up MySQL database: `mysql -u root < database/schema.sql`
✅ Run server: `python start_app.py` or `./run_server.sh start`
✅ Access: `http://localhost:8000`
✅ CSS and all static files load correctly ✅

### For Docker/Container Deployment

Add to Dockerfile:
```dockerfile
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "start_app.py"]
```

### For Cloud Deployment (Heroku, AWS, etc.)

Create `Procfile`:
```
web: python start_app.py
```

The absolute path resolution works on:
- ✅ Local development
- ✅ Linux servers
- ✅ macOS
- ✅ Docker containers
- ✅ Cloud platforms (Heroku, AWS, Google Cloud)
- ✅ Virtual environments

## Troubleshooting

### 🌐 Quick Access Links
Once the server is running, use these links:
- **Main Dashboard**: http://localhost:8000
- **API Status**: http://localhost:8000/api/dashboard-stats

### Port Already in Use
The application uses port 8000. If you get "Address already in use" error:
```bash
lsof -ti:8000 | xargs kill -9
```

### MySQL Not Running
Make sure MySQL is installed and running:
```bash
# macOS
brew services start mysql

# Linux
sudo systemctl start mysql

# Windows
net start MySQL80
```

## Troubleshooting

### 1. Port Already In Use (Address Already In Use Error)
**Problem**: Flask server won't start because port 8000 is busy  
**Solution**: The system automatically detects and uses the next available port (8001, 8002, etc.)

To force a clean restart:
```bash
./server-quick-start.sh
```

This script kills all lingering processes on ports 8000-8003 before starting fresh.

### 2. Flask Server Won't Start or Crashes
**Problem**: Server crashes immediately or doesn't respond  
**Solution**: Restart with clean process kill:
```bash
./server-quick-start.sh
```

If issues persist, check logs:
```bash
tail -50 server.log
```

### 3. "Address Already In Use" - Force Kill All Processes
```bash
# Kill Flask processes
pkill -f "backend/app.py"
pkill -f "python.*app.py"

# Kill on specific ports
for port in 8000 8001 8002 8003; do
    lsof -ti:$port | xargs kill -9 2>/dev/null || true
done

sleep 2
python3 backend/app.py
```

### 4. MySQL Connection Error
**Problem**: Can't connect to database  
**Solution**: Ensure MySQL is running and initialized:
```bash
# Test MySQL
mysql -u root -e "SELECT 1;"

# Initialize database if needed
mysql -u root < database/schema.sql
```

### 5. Page Not Loading or CSS Missing
**Problem**: Pages load but styling is broken  
**Solution**: Clear browser cache (Cmd+Shift+R) or restart server

### Dependencies Issues
Reinstall dependencies:
```bash
pip install --break-system-packages -r requirements.txt
```

### Database Not Initialized
Initialize the database manually:
```bash
mysql -u root -p < database/schema.sql
```

## Testing Auto-Save Feature

### Automated Test: Verify All CRUD Operations Are Logged

1. **Start the server**
   ```bash
   ./run.sh
   ```

2. **Open in browser**
   ```
   http://localhost:8000
   ```

3. **Test CREATE (INSERT)**
   - Go to Citizens page → Click "+ Add Citizen"
   - Fill in: Name, Address, Contact, Email, Area
   - Click Save
   - **Expected**: Query appears in `database/schema.sql` with INSERT statement

4. **Test READ (SELECT)**
   - Citizens page auto-loads data
   - **Expected**: No logging for SELECT queries (only CRUD changes)

5. **Test UPDATE**
   - Click Edit on any citizen
   - Change the name and contact
   - Click Save
   - **Expected**: UPDATE query logged in `database/schema.sql`

6. **Test DELETE**
   - Click Delete on any citizen
   - Confirm deletion
   - **Expected**: DELETE query logged in `database/schema.sql`

7. **Verify Logs**
   ```bash
   # Check the latest auto-saved queries
   tail -30 database/schema.sql
   
   # Should show something like:
   # -- FRONTEND AUTO-SAVE: INSERT Operation
   # -- Table: Citizen
   # -- Timestamp: 2025-12-01 14:54:39
   # INSERT INTO Citizen (name, address, contact, area_id, email)
   # VALUES ('Your Name', 'Your Address', 'Your Contact', 1, 'your@email.com');
   ```

### Manual API Test

Test auto-save via curl command:

```bash
# Create a citizen (INSERT)
curl -X POST http://localhost:8000/api/citizens \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "address": "Test Address",
    "contact": "01700000000",
    "email": "test@email.com",
    "area_id": 1
  }'

# Wait 2 seconds, then check schema.sql
sleep 2 && tail -10 database/schema.sql
```

## Project Files

- `run.sh` - Automated startup script (recommended)
- `server-quick-start.sh` - Quick restart with process cleanup (USE THIS if server won't start)
- `backend/app.py` - Flask application with all API endpoints
- `frontend/templates/` - HTML templates for UI
- `database/schema.sql` - MySQL database schema with auto-saved queries
- `static/` - CSS and JavaScript files
- `requirements.txt` - Python dependencies
- `environment/` - Configuration files

## Contact & Support

For issues or questions about this project, please create an issue in the GitHub repository.

---

**Project Status**: Production Ready  
**Last Updated**: December 2025  
**Database**: Dhaka City Waste Management  
**Frontend Port**: 8000+ (auto-detects available port)  
**Repository**: https://github.com/punam06/final-dbProject.git
