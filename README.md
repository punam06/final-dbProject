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

When you make changes through the web interface (add, edit, delete), the system automatically:

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

## Project Files

- `run.sh` - Automated startup script (recommended)
- `server-quick-start.sh` - Quick restart with process cleanup (USE THIS if server won't start)
- `backend/app.py` - Flask application with all API endpoints
- `frontend/templates/` - HTML templates for UI
- `database/schema.sql` - MySQL database schema with sample data
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
