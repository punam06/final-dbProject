# Dhaka Waste Management System

A comprehensive waste management system for Dhaka city built with Flask backend, MySQL database, and responsive HTML5 frontend.

## Features

- **Waste Collection Management**: Track waste collection routes and schedules
- **Team Management**: Manage collection teams and assignments
- **Citizen Registration**: Register and track citizens and their waste disposal
- **Payment Tracking**: Process and track waste management payments
- **Recycling Centers**: Manage 5 recycling centers across Dhaka (Gulshan, Banani, Dhanmondi, Mirpur, Motijheel)
- **Area Coverage**: Serve 5 major areas in Dhaka
- **Reporting**: Comprehensive reports on collections, payments, and recycling

## Project Structure

```
backend/              - Flask application with 40+ API endpoints
frontend/             - HTML5 templates with responsive design
api/                  - API documentation and examples
database/             - MySQL schema and sample data
environment/          - Configuration files
static/               - CSS, JavaScript, images
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

### Frontend (HTML Interface)
- **URL**: `http://localhost:8000`
- **Pages Available**:
  - Dashboard: `http://localhost:8000/` (Home)
  - Citizens: `http://localhost:8000/citizens`
  - Areas: `http://localhost:8000/areas`
  - Crew/Teams: `http://localhost:8000/crew`
  - Waste: `http://localhost:8000/waste`
  - Bins: `http://localhost:8000/bins`
  - Bills: `http://localhost:8000/bills`
  - Payments: `http://localhost:8000/payments`
  - Schedules: `http://localhost:8000/schedules`
  - Recycling Centers: `http://localhost:8000/centers`

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

## Troubleshooting

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
**Frontend Port**: 8000  
**Repository**: https://github.com/punam06/final-dbProject.git
