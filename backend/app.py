"""
Waste Management System - Flask Backend
Query Logging: All UPDATE/DELETE queries are logged to database/schema.sql
Fixed: Connection pooling, proper error handling, async logging
"""
from flask import Flask, render_template, request, jsonify
import mysql.connector
from mysql.connector import Error, pooling
import json
from datetime import datetime
import os
import threading

# Setup template directory - use frontend/templates or root templates
template_dir = os.path.join(os.path.dirname(__file__), '..', 'frontend', 'templates')
if not os.path.exists(template_dir):
    template_dir = os.path.join(os.path.dirname(__file__), '..', 'templates')

# Setup static files directory
static_dir = os.path.join(os.path.dirname(__file__), '..', 'static')

app = Flask(__name__, template_folder=template_dir, static_folder=static_dir, static_url_path='/static')

# Database Configuration with Connection Pooling
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'waste_management'
}

# Create connection pool (reuse connections, avoid crashes)
try:
    cnx_pool = pooling.MySQLConnectionPool(
        pool_name="waste_pool",
        pool_size=5,
        pool_reset_session=True,
        **DB_CONFIG
    )
except Exception as e:
    print(f"⚠️ Connection pool error: {e}")
    cnx_pool = None

# Schema file path for logging queries (from project root, not backend/)
SCHEMA_FILE = os.path.join(os.path.dirname(__file__), '..', 'database', 'schema.sql')
SCHEMA_FILE = os.path.abspath(SCHEMA_FILE)  # Resolve to absolute path

# ===== DATABASE HELPER FUNCTIONS =====

def log_query_to_schema_async(query_text, params, operation_type, table_name):
    """Log UPDATE/DELETE/INSERT queries to schema.sql with actual values (async, non-blocking)"""
    def async_log():
        try:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            # Convert parameterized query to actual SQL with values
            formatted_query = query_text.strip()
            
            if params:
                # Replace %s placeholders with actual values
                param_list = list(params) if params else []
                for param in param_list:
                    if isinstance(param, str):
                        # Escape single quotes in strings
                        escaped = param.replace("'", "\\'")
                        formatted_query = formatted_query.replace('%s', f"'{escaped}'", 1)
                    elif isinstance(param, (int, float)):
                        formatted_query = formatted_query.replace('%s', str(param), 1)
                    elif param is None:
                        formatted_query = formatted_query.replace('%s', 'NULL', 1)
                    else:
                        formatted_query = formatted_query.replace('%s', str(param), 1)
            
            if not formatted_query.endswith(';'):
                formatted_query += ';'
            
            # Create detailed log entry with timestamp and operation info
            log_entry = f"\n-- ========================================\n"
            log_entry += f"-- FRONTEND AUTO-SAVE: {operation_type} Operation\n"
            log_entry += f"-- Table: {table_name}\n"
            log_entry += f"-- Timestamp: {timestamp}\n"
            log_entry += f"-- Status: Successfully executed and logged\n"
            log_entry += f"-- ========================================\n"
            log_entry += f"{formatted_query}\n"
            
            # Ensure schema file exists
            if os.path.exists(SCHEMA_FILE):
                with open(SCHEMA_FILE, 'a') as f:
                    f.write(log_entry)
                print(f"✅ Query auto-saved to schema.sql: {operation_type} on {table_name}")
            else:
                print(f"⚠️ Schema file not found at: {SCHEMA_FILE}")
        except Exception as e:
            print(f"⚠️ Query auto-save error: {e}")
    
    # Log in background thread (don't block request)
    thread = threading.Thread(target=async_log, daemon=True)
    thread.start()

def get_db_connection():
    """Get database connection from pool (with retry logic)"""
    try:
        if cnx_pool:
            conn = cnx_pool.get_connection()
            # Test connection (reconnect if needed)
            if conn and not conn.is_connected():
                conn.reconnect()
            return conn
        else:
            # Fallback if pool failed
            return mysql.connector.connect(**DB_CONFIG)
    except Error as e:
        print(f"⚠ Database Connection Error: {e}")
        return None

def execute_query(query, params=None, fetch_all=True):
    """Execute SELECT query with connection pooling"""
    conn = None
    try:
        conn = get_db_connection()
        if not conn:
            return [] if fetch_all else None
        
        cursor = conn.cursor(dictionary=True)
        
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        result = cursor.fetchall() if fetch_all else cursor.fetchone()
        cursor.close()
        return result if result else ([] if fetch_all else None)
    except Error as e:
        print(f"⚠ Query Execution Error: {e}")
        return [] if fetch_all else None
    finally:
        if conn and conn.is_connected():
            conn.close()

def execute_update(query, params):
    """Execute INSERT, UPDATE, DELETE with connection pooling"""
    conn = None
    try:
        conn = get_db_connection()
        if not conn:
            return False
        
        cursor = conn.cursor()
        cursor.execute(query, params)
        conn.commit()
        
        # Determine operation type for logging
        query_upper = query.strip().upper()
        if query_upper.startswith('UPDATE'):
            op_type = "UPDATE"
            table_name = query.split()[1] if len(query.split()) > 1 else "Unknown"
        elif query_upper.startswith('DELETE'):
            op_type = "DELETE"
            match = query.split('FROM')[1].split()[0] if 'FROM' in query else "Unknown"
            table_name = match
        else:
            op_type = "INSERT"
            table_name = query.split()[2] if len(query.split()) > 2 else "Unknown"
        
        # Log asynchronously (non-blocking) with actual parameter values
        log_query_to_schema_async(query, params, op_type, table_name)
        
        cursor.close()
        return True
    except Error as e:
        print(f"⚠ Update Execution Error: {e}")
        return False
    finally:
        if conn and conn.is_connected():
            conn.close()

# ===== FRONTEND ROUTES =====

@app.route('/')
def home():
    """Dashboard page"""
    # Fetch stats from database
    try:
        stats = {
            'total_citizens': 0,
            'total_waste_kg': 0.0,
            'total_recycled_kg': 0.0,
            'total_bills_paid': 0.0,
            'areas': 0,
            'crews': 0,
            'bins': 0,
            'waste_status': {'collected': 0, 'recycled': 0, 'disposed': 0, 'pending': 0},
            'bill_status': {'paid': 0, 'pending': 0, 'overdue': 0}
        }
        
        # Total citizens
        result = execute_query("SELECT COUNT(*) as count FROM Citizen", fetch_all=False)
        stats['total_citizens'] = result['count'] if result else 0
        
        # Total waste collected
        result = execute_query("SELECT SUM(weight) as total FROM Waste", fetch_all=False)
        stats['total_waste_kg'] = float(result['total']) if result and result['total'] else 0.0
        
        # Total waste recycled
        result = execute_query("SELECT SUM(weight) as total FROM Waste WHERE status='Recycled'", fetch_all=False)
        stats['total_recycled_kg'] = float(result['total']) if result and result['total'] else 0.0
        
        # Bills paid total
        result = execute_query("SELECT SUM(amount) as total FROM Bill WHERE status='Paid'", fetch_all=False)
        stats['total_bills_paid'] = float(result['total']) if result and result['total'] else 0.0
        
        # Count by entity
        result = execute_query("SELECT COUNT(*) as count FROM Area", fetch_all=False)
        stats['areas'] = result['count'] if result else 0
        
        result = execute_query("SELECT COUNT(*) as count FROM Crew", fetch_all=False)
        stats['crews'] = result['count'] if result else 0
        
        result = execute_query("SELECT COUNT(*) as count FROM Bins", fetch_all=False)
        stats['bins'] = result['count'] if result else 0
        
        # Waste by status
        results = execute_query("SELECT status, COUNT(*) as count FROM Waste GROUP BY status")
        for row in results:
            status_key = row['status'].lower() if row['status'] else 'pending'
            if status_key in stats['waste_status']:
                stats['waste_status'][status_key] = row['count']
        
        # Bills by status
        results = execute_query("SELECT status, COUNT(*) as count FROM Bill GROUP BY status")
        for row in results:
            status_key = row['status'].lower() if row['status'] else 'pending'
            if status_key in stats['bill_status']:
                stats['bill_status'][status_key] = row['count']
    except:
        stats = {
            'total_citizens': 0, 'total_waste_kg': 0.0, 'total_recycled_kg': 0.0, 'total_bills_paid': 0.0,
            'areas': 0, 'crews': 0, 'bins': 0,
            'waste_status': {'collected': 0, 'recycled': 0, 'disposed': 0, 'pending': 0},
            'bill_status': {'paid': 0, 'pending': 0, 'overdue': 0}
        }
    
    return render_template('dashboard.html', stats=stats)

@app.route('/citizens')
def citizens_page():
    return render_template('citizens.html')

@app.route('/areas')
def areas_page():
    return render_template('areas.html')

@app.route('/crew')
def crew_page():
    return render_template('crew.html')

@app.route('/staff')
def staff_page():
    return render_template('staff.html')

@app.route('/assignments')
def assignments_page():
    return render_template('assignments.html')

@app.route('/waste')
def waste_page():
    return render_template('waste.html')

@app.route('/bins')
def bins_page():
    return render_template('bins.html')

@app.route('/bills')
def bills_page():
    return render_template('bills.html')

@app.route('/payments')
def payments_page():
    return render_template('payments.html')

@app.route('/schedules')
def schedules_page():
    return render_template('schedules.html')

@app.route('/centers')
def centers_page():
    return render_template('centers.html')

# ===== DASHBOARD API =====

@app.route('/api/dashboard-stats')
def dashboard_stats():
    """Get dashboard statistics"""
    try:
        # Initialize stats with proper default values (using lowercase status names)
        stats = {
            'total_citizens': 0,
            'total_waste_kg': 0.0,
            'total_recycled_kg': 0.0,
            'total_bills_paid': 0.0,
            'areas': 0,
            'crews': 0,
            'bins': 0,
            'waste_status': {'collected': 0, 'recycled': 0, 'disposed': 0, 'pending': 0},
            'bill_status': {'paid': 0, 'pending': 0, 'overdue': 0}
        }
        
        # Total citizens
        result = execute_query("SELECT COUNT(*) as count FROM Citizen", fetch_all=False)
        stats['total_citizens'] = result['count'] if result else 0
        
        # Total waste collected
        result = execute_query("SELECT SUM(weight) as total FROM Waste", fetch_all=False)
        stats['total_waste_kg'] = float(result['total']) if result and result['total'] else 0.0
        
        # Total waste recycled
        result = execute_query("SELECT SUM(weight) as total FROM Waste WHERE status='Recycled'", fetch_all=False)
        stats['total_recycled_kg'] = float(result['total']) if result and result['total'] else 0.0
        
        # Bills paid total
        result = execute_query("SELECT SUM(amount) as total FROM Bill WHERE status='Paid'", fetch_all=False)
        stats['total_bills_paid'] = float(result['total']) if result and result['total'] else 0.0
        
        # Count by entity
        result = execute_query("SELECT COUNT(*) as count FROM Area", fetch_all=False)
        stats['areas'] = result['count'] if result else 0
        
        result = execute_query("SELECT COUNT(*) as count FROM Crew", fetch_all=False)
        stats['crews'] = result['count'] if result else 0
        
        result = execute_query("SELECT COUNT(*) as count FROM Bins", fetch_all=False)
        stats['bins'] = result['count'] if result else 0
        
        # Waste by status - map to lowercase keys
        results = execute_query("SELECT status, COUNT(*) as count FROM Waste GROUP BY status")
        for row in results:
            status_key = row['status'].lower() if row['status'] else 'pending'
            if status_key in stats['waste_status']:
                stats['waste_status'][status_key] = row['count']
        
        # Bills by status - map to lowercase keys
        results = execute_query("SELECT status, COUNT(*) as count FROM Bill GROUP BY status")
        for row in results:
            status_key = row['status'].lower() if row['status'] else 'pending'
            if status_key in stats['bill_status']:
                stats['bill_status'][status_key] = row['count']
        
        return jsonify(stats)
    except Exception as e:
        print(f"Dashboard Stats Error: {e}")
        return jsonify({'error': str(e)}), 500

# ===== CITIZENS API =====

@app.route('/api/citizens', methods=['GET', 'POST'])
def api_citizens():
    if request.method == 'GET':
        query = """SELECT c.citizen_id, c.name, c.address, c.contact, c.email, 
                          a.area_id, a.area_name
                   FROM Citizen c 
                   JOIN Area a ON c.area_id = a.area_id"""
        results = execute_query(query)
        return jsonify(results)
    
    elif request.method == 'POST':
        data = request.json
        try:
            query = """INSERT INTO Citizen (name, address, contact, area_id, email)
                      VALUES (%s, %s, %s, %s, %s)"""
            params = (data['name'], data['address'], data['contact'], data['area_id'], data.get('email', ''))
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Citizen added successfully'})
            return jsonify({'success': False, 'message': 'Failed to add citizen'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/citizens/<int:citizen_id>', methods=['GET', 'PUT', 'DELETE'])
def api_citizen_detail(citizen_id):
    if request.method == 'GET':
        query = """SELECT c.citizen_id, c.name, c.address, c.contact, c.email, 
                          a.area_id, a.area_name
                   FROM Citizen c 
                   JOIN Area a ON c.area_id = a.area_id 
                   WHERE c.citizen_id = %s"""
        result = execute_query(query, (citizen_id,), fetch_all=False)
        return jsonify(result) if result else jsonify({}), 404 if not result else 200
    
    elif request.method == 'PUT':
        data = request.json
        try:
            query = """UPDATE Citizen SET name=%s, address=%s, contact=%s, area_id=%s, email=%s 
                      WHERE citizen_id=%s"""
            params = (data['name'], data['address'], data['contact'], data['area_id'], data.get('email', ''), citizen_id)
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Citizen updated successfully'})
            return jsonify({'success': False, 'message': 'Failed to update citizen'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400
    
    elif request.method == 'DELETE':
        try:
            query = "DELETE FROM Citizen WHERE citizen_id=%s"
            if execute_update(query, (citizen_id,)):
                return jsonify({'success': True, 'message': 'Citizen deleted successfully'})
            return jsonify({'success': False, 'message': 'Failed to delete citizen'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

# ===== AREAS API =====

@app.route('/api/areas', methods=['GET', 'POST'])
def api_areas():
    if request.method == 'GET':
        query = "SELECT area_id, area_name, location, population FROM Area"
        results = execute_query(query)
        return jsonify(results)
    
    elif request.method == 'POST':
        data = request.json
        try:
            query = "INSERT INTO Area (area_name, location, population) VALUES (%s, %s, %s)"
            params = (data['area_name'], data['location'], data.get('population', 0))
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Area added successfully'})
            return jsonify({'success': False, 'message': 'Failed to add area'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/areas/<int:area_id>', methods=['GET', 'PUT', 'DELETE'])
def api_area_detail(area_id):
    if request.method == 'GET':
        query = "SELECT area_id, area_name, location, population FROM Area WHERE area_id=%s"
        result = execute_query(query, (area_id,), fetch_all=False)
        return jsonify(result) if result else jsonify({}), 404 if not result else 200
    
    elif request.method == 'PUT':
        data = request.json
        try:
            query = "UPDATE Area SET area_name=%s, location=%s, population=%s WHERE area_id=%s"
            params = (data['area_name'], data['location'], data['population'], area_id)
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Area updated successfully'})
            return jsonify({'success': False, 'message': 'Failed to update area'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400
    
    elif request.method == 'DELETE':
        try:
            query = "DELETE FROM Area WHERE area_id=%s"
            if execute_update(query, (area_id,)):
                return jsonify({'success': True, 'message': 'Area deleted successfully'})
            return jsonify({'success': False, 'message': 'Failed to delete area'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

# ===== CREW API =====

@app.route('/api/crew', methods=['GET', 'POST'])
def api_crew():
    if request.method == 'GET':
        query = """SELECT cr.crew_id, cr.team_name, cr.contact, cr.team_size, 
                          a.area_id, a.area_name
                   FROM Crew cr 
                   JOIN Area a ON cr.area_id = a.area_id"""
        results = execute_query(query)
        return jsonify(results)
    
    elif request.method == 'POST':
        data = request.json
        try:
            query = "INSERT INTO Crew (team_name, contact, area_id, team_size) VALUES (%s, %s, %s, %s)"
            params = (data['team_name'], data['contact'], data['area_id'], data['team_size'])
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Crew added successfully'})
            return jsonify({'success': False, 'message': 'Failed to add crew'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/crew/<int:crew_id>', methods=['GET', 'PUT', 'DELETE'])
def api_crew_detail(crew_id):
    if request.method == 'GET':
        query = """SELECT cr.crew_id, cr.team_name, cr.contact, cr.team_size, 
                          a.area_id, a.area_name
                   FROM Crew cr 
                   JOIN Area a ON cr.area_id = a.area_id 
                   WHERE cr.crew_id = %s"""
        result = execute_query(query, (crew_id,), fetch_all=False)
        return jsonify(result) if result else jsonify({}), 404 if not result else 200
    
    elif request.method == 'PUT':
        data = request.json
        try:
            query = "UPDATE Crew SET team_name=%s, contact=%s, area_id=%s, team_size=%s WHERE crew_id=%s"
            params = (data['team_name'], data['contact'], data['area_id'], data['team_size'], crew_id)
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Crew updated successfully'})
            return jsonify({'success': False, 'message': 'Failed to update crew'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400
    
    elif request.method == 'DELETE':
        try:
            query = "DELETE FROM Crew WHERE crew_id=%s"
            if execute_update(query, (crew_id,)):
                return jsonify({'success': True, 'message': 'Crew deleted successfully'})
            return jsonify({'success': False, 'message': 'Failed to delete crew'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

# ===== WASTE API =====

@app.route('/api/waste', methods=['GET', 'POST'])
def api_waste():
    if request.method == 'GET':
        query = """SELECT w.waste_id, w.name, w.waste_type, w.category, w.weight, w.status,
                          c.citizen_id, c.name as citizen_name
                   FROM Waste w 
                   JOIN Citizen c ON w.citizen_id = c.citizen_id"""
        results = execute_query(query)
        return jsonify(results)
    
    elif request.method == 'POST':
        data = request.json
        try:
            query = """INSERT INTO Waste (waste_type, name, category, weight, citizen_id, status)
                      VALUES (%s, %s, %s, %s, %s, %s)"""
            params = (data['waste_type'], data['name'], data['category'], data['weight'], data['citizen_id'], data.get('status', 'Collected'))
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Waste added successfully'})
            return jsonify({'success': False, 'message': 'Failed to add waste'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/waste/<int:waste_id>', methods=['GET', 'PUT', 'DELETE'])
def api_waste_detail(waste_id):
    if request.method == 'GET':
        query = """SELECT w.waste_id, w.name, w.waste_type, w.category, w.weight, w.status,
                          c.citizen_id, c.name as citizen_name
                   FROM Waste w 
                   JOIN Citizen c ON w.citizen_id = c.citizen_id 
                   WHERE w.waste_id = %s"""
        result = execute_query(query, (waste_id,), fetch_all=False)
        return jsonify(result) if result else jsonify({}), 404 if not result else 200
    
    elif request.method == 'PUT':
        data = request.json
        try:
            query = """UPDATE Waste SET waste_type=%s, name=%s, category=%s, weight=%s, citizen_id=%s, status=%s 
                      WHERE waste_id=%s"""
            params = (data['waste_type'], data['name'], data['category'], data['weight'], data['citizen_id'], data.get('status', 'Collected'), waste_id)
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Waste updated successfully'})
            return jsonify({'success': False, 'message': 'Failed to update waste'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400
    
    elif request.method == 'DELETE':
        try:
            query = "DELETE FROM Waste WHERE waste_id=%s"
            if execute_update(query, (waste_id,)):
                return jsonify({'success': True, 'message': 'Waste deleted successfully'})
            return jsonify({'success': False, 'message': 'Failed to delete waste'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

# ===== BINS API =====

@app.route('/api/bins', methods=['GET', 'POST'])
def api_bins():
    if request.method == 'GET':
        query = """SELECT b.bin_id, b.bin_number, b.status, b.fill_level, b.location, b.sensor,
                          a.area_id, a.area_name
                   FROM Bins b 
                   JOIN Area a ON b.area_id = a.area_id"""
        results = execute_query(query)
        return jsonify(results)
    
    elif request.method == 'POST':
        data = request.json
        try:
            query = """INSERT INTO Bins (bin_number, status, fill_level, location, area_id, sensor)
                      VALUES (%s, %s, %s, %s, %s, %s)"""
            params = (data['bin_number'], data.get('status', 'Empty'), data.get('fill_level', 0), data['location'], data['area_id'], data.get('sensor', ''))
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Bin added successfully'})
            return jsonify({'success': False, 'message': 'Failed to add bin'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/bins/<int:bin_id>', methods=['GET', 'PUT', 'DELETE'])
def api_bins_detail(bin_id):
    if request.method == 'GET':
        query = """SELECT b.bin_id, b.bin_number, b.status, b.fill_level, b.location, b.sensor,
                          a.area_id, a.area_name
                   FROM Bins b 
                   JOIN Area a ON b.area_id = a.area_id 
                   WHERE b.bin_id = %s"""
        result = execute_query(query, (bin_id,), fetch_all=False)
        return jsonify(result) if result else jsonify({}), 404 if not result else 200
    
    elif request.method == 'PUT':
        data = request.json
        try:
            query = """UPDATE Bins SET bin_number=%s, status=%s, fill_level=%s, location=%s, area_id=%s, sensor=%s 
                      WHERE bin_id=%s"""
            params = (data['bin_number'], data['status'], data['fill_level'], data['location'], data['area_id'], data.get('sensor', ''), bin_id)
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Bin updated successfully'})
            return jsonify({'success': False, 'message': 'Failed to update bin'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400
    
    elif request.method == 'DELETE':
        try:
            query = "DELETE FROM Bins WHERE bin_id=%s"
            if execute_update(query, (bin_id,)):
                return jsonify({'success': True, 'message': 'Bin deleted successfully'})
            return jsonify({'success': False, 'message': 'Failed to delete bin'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

# ===== BILLS API =====

@app.route('/api/bills', methods=['GET', 'POST'])
def api_bills():
    if request.method == 'GET':
        query = """SELECT b.bill_id, b.bill_number, b.status, b.amount, b.due_date,
                          c.citizen_id, c.name as citizen_name
                   FROM Bill b 
                   JOIN Citizen c ON b.citizen_id = c.citizen_id"""
        results = execute_query(query)
        return jsonify(results)
    
    elif request.method == 'POST':
        data = request.json
        try:
            query = """INSERT INTO Bill (bill_number, status, amount, due_date, citizen_id)
                      VALUES (%s, %s, %s, %s, %s)"""
            params = (data['bill_number'], data.get('status', 'Pending'), data['amount'], data['due_date'], data['citizen_id'])
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Bill added successfully'})
            return jsonify({'success': False, 'message': 'Failed to add bill'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/bills/<int:bill_id>', methods=['GET', 'PUT', 'DELETE'])
def api_bills_detail(bill_id):
    if request.method == 'GET':
        query = """SELECT b.bill_id, b.bill_number, b.status, b.amount, b.due_date,
                          c.citizen_id, c.name as citizen_name
                   FROM Bill b 
                   JOIN Citizen c ON b.citizen_id = c.citizen_id 
                   WHERE b.bill_id = %s"""
        result = execute_query(query, (bill_id,), fetch_all=False)
        return jsonify(result) if result else jsonify({}), 404 if not result else 200
    
    elif request.method == 'PUT':
        data = request.json
        try:
            query = """UPDATE Bill SET bill_number=%s, status=%s, amount=%s, due_date=%s, citizen_id=%s 
                      WHERE bill_id=%s"""
            params = (data['bill_number'], data['status'], data['amount'], data['due_date'], data['citizen_id'], bill_id)
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Bill updated successfully'})
            return jsonify({'success': False, 'message': 'Failed to update bill'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400
    
    elif request.method == 'DELETE':
        try:
            query = "DELETE FROM Bill WHERE bill_id=%s"
            if execute_update(query, (bill_id,)):
                return jsonify({'success': True, 'message': 'Bill deleted successfully'})
            return jsonify({'success': False, 'message': 'Failed to delete bill'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

# ===== PAYMENTS API =====

@app.route('/api/payments', methods=['GET', 'POST'])
def api_payments():
    if request.method == 'GET':
        query = """SELECT p.payment_id, p.payment_date, p.amount, p.method,
                          c.citizen_id, c.name as citizen_name,
                          b.bill_id, b.bill_number
                   FROM Payment p 
                   JOIN Citizen c ON p.citizen_id = c.citizen_id 
                   LEFT JOIN Bill b ON p.bill_id = b.bill_id"""
        results = execute_query(query)
        return jsonify(results)
    
    elif request.method == 'POST':
        data = request.json
        try:
            query = """INSERT INTO Payment (payment_date, amount, method, citizen_id, bill_id)
                      VALUES (%s, %s, %s, %s, %s)"""
            params = (data['payment_date'], data['amount'], data.get('method', 'Cash'), data['citizen_id'], data.get('bill_id'))
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Payment added successfully'})
            return jsonify({'success': False, 'message': 'Failed to add payment'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/payments/<int:payment_id>', methods=['GET', 'PUT', 'DELETE'])
def api_payments_detail(payment_id):
    if request.method == 'GET':
        query = """SELECT p.payment_id, p.payment_date, p.amount, p.method,
                          c.citizen_id, c.name as citizen_name,
                          b.bill_id, b.bill_number
                   FROM Payment p 
                   JOIN Citizen c ON p.citizen_id = c.citizen_id 
                   LEFT JOIN Bill b ON p.bill_id = b.bill_id
                   WHERE p.payment_id = %s"""
        result = execute_query(query, (payment_id,), fetch_all=False)
        return jsonify(result) if result else jsonify({}), 404 if not result else 200
    
    elif request.method == 'PUT':
        data = request.json
        try:
            query = """UPDATE Payment SET payment_date=%s, amount=%s, method=%s, citizen_id=%s, bill_id=%s 
                      WHERE payment_id=%s"""
            params = (data['payment_date'], data['amount'], data['method'], data['citizen_id'], data.get('bill_id'), payment_id)
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Payment updated successfully'})
            return jsonify({'success': False, 'message': 'Failed to update payment'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400
    
    elif request.method == 'DELETE':
        try:
            query = "DELETE FROM Payment WHERE payment_id=%s"
            if execute_update(query, (payment_id,)):
                return jsonify({'success': True, 'message': 'Payment deleted successfully'})
            return jsonify({'success': False, 'message': 'Failed to delete payment'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

# ===== SCHEDULES API =====

@app.route('/api/schedules', methods=['GET'])
def api_schedules():
    query = """SELECT hs.schedule_id, hs.schedule_date,
                      a.area_id, a.area_name,
                      cr.crew_id, cr.crew_name
               FROM Has_Schedule hs 
               JOIN Area a ON hs.area_id = a.area_id 
               JOIN Crew cr ON hs.crew_id = cr.crew_id"""
    results = execute_query(query)
    return jsonify(results)

# ===== RECYCLING CENTERS API =====

@app.route('/api/centers', methods=['GET', 'POST'])
def api_centers():
    if request.method == 'GET':
        query = "SELECT center_id, location, capacity, operational_hours FROM Recycling_Center"
        results = execute_query(query)
        return jsonify(results)
    
    elif request.method == 'POST':
        data = request.json
        try:
            query = """INSERT INTO Recycling_Center (location, capacity, operational_hours)
                      VALUES (%s, %s, %s)"""
            params = (data['location'], data['capacity'], data.get('operational_hours', ''))
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Center added successfully'})
            return jsonify({'success': False, 'message': 'Failed to add center'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

# ===== DROPDOWN LISTS API =====

@app.route('/api/areas-list')
def areas_list():
    results = execute_query("SELECT area_id, area_name FROM Area")
    return jsonify(results)

@app.route('/api/citizens-list')
def citizens_list():
    results = execute_query("SELECT citizen_id, name FROM Citizen")
    return jsonify(results)

@app.route('/api/crews-list')
def crews_list():
    results = execute_query("SELECT crew_id, crew_name FROM Crew")
    return jsonify(results)

# ===== STAFF API (Individual Team Members) =====

@app.route('/api/staff', methods=['GET', 'POST'])
def api_staff():
    if request.method == 'GET':
        query = "SELECT staff_id, staff_name, position, contact, email, status FROM Staff ORDER BY staff_name"
        results = execute_query(query)
        return jsonify(results)
    
    elif request.method == 'POST':
        data = request.json
        try:
            query = """INSERT INTO Staff (staff_name, position, contact, email, status)
                      VALUES (%s, %s, %s, %s, %s)"""
            params = (data['staff_name'], data.get('position', ''), data['contact'], 
                     data.get('email', ''), data.get('status', 'Active'))
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Staff member added successfully'})
            return jsonify({'success': False, 'message': 'Failed to add staff member'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/staff/<int:staff_id>', methods=['GET', 'PUT', 'DELETE'])
def api_staff_detail(staff_id):
    if request.method == 'GET':
        query = "SELECT staff_id, staff_name, position, contact, email, status FROM Staff WHERE staff_id = %s"
        result = execute_query(query, (staff_id,), fetch_all=False)
        return jsonify(result) if result else jsonify({}), 404 if not result else 200
    
    elif request.method == 'PUT':
        data = request.json
        try:
            query = """UPDATE Staff SET staff_name=%s, position=%s, contact=%s, email=%s, status=%s 
                      WHERE staff_id=%s"""
            params = (data['staff_name'], data.get('position', ''), data['contact'], 
                     data.get('email', ''), data.get('status', 'Active'), staff_id)
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Staff member updated successfully'})
            return jsonify({'success': False, 'message': 'Failed to update staff member'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400
    
    elif request.method == 'DELETE':
        try:
            query = "DELETE FROM Staff WHERE staff_id=%s"
            if execute_update(query, (staff_id,)):
                return jsonify({'success': True, 'message': 'Staff member deleted successfully'})
            return jsonify({'success': False, 'message': 'Failed to delete staff member'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

# ===== ASSIGNMENT API (Assign Staff to Teams) =====

@app.route('/api/assignments', methods=['GET', 'POST'])
def api_assignments():
    if request.method == 'GET':
        # Get assignments with team and staff details
        query = """SELECT 
                    a.assigned_id, a.crew_id, c.team_name, a.staff_id, s.staff_name, 
                    s.position, a.role, a.status, a.assignment_date
                   FROM Assigned a
                   JOIN Crew c ON a.crew_id = c.crew_id
                   JOIN Staff s ON a.staff_id = s.staff_id
                   ORDER BY c.team_name, s.staff_name"""
        results = execute_query(query)
        return jsonify(results)
    
    elif request.method == 'POST':
        data = request.json
        try:
            query = """INSERT INTO Assigned (crew_id, staff_id, assignment_date, role, status)
                      VALUES (%s, %s, %s, %s, %s)"""
            params = (data['crew_id'], data['staff_id'], data.get('assignment_date'), 
                     data.get('role', 'Staff Member'), data.get('status', 'Assigned'))
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Staff assigned to team successfully'})
            return jsonify({'success': False, 'message': 'Failed to assign staff'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/api/assignments/<int:assigned_id>', methods=['GET', 'PUT', 'DELETE'])
def api_assignment_detail(assigned_id):
    if request.method == 'GET':
        query = """SELECT 
                    a.assigned_id, a.crew_id, c.team_name, a.staff_id, s.staff_name, 
                    s.position, a.role, a.status, a.assignment_date
                   FROM Assigned a
                   JOIN Crew c ON a.crew_id = c.crew_id
                   JOIN Staff s ON a.staff_id = s.staff_id
                   WHERE a.assigned_id = %s"""
        result = execute_query(query, (assigned_id,), fetch_all=False)
        return jsonify(result) if result else jsonify({}), 404 if not result else 200
    
    elif request.method == 'PUT':
        data = request.json
        try:
            query = """UPDATE Assigned SET crew_id=%s, staff_id=%s, assignment_date=%s, role=%s, status=%s 
                      WHERE assigned_id=%s"""
            params = (data['crew_id'], data['staff_id'], data.get('assignment_date'), 
                     data.get('role', 'Staff Member'), data.get('status', 'Assigned'), assigned_id)
            
            if execute_update(query, params):
                return jsonify({'success': True, 'message': 'Assignment updated successfully'})
            return jsonify({'success': False, 'message': 'Failed to update assignment'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400
    
    elif request.method == 'DELETE':
        try:
            query = "DELETE FROM Assigned WHERE assigned_id=%s"
            if execute_update(query, (assigned_id,)):
                return jsonify({'success': True, 'message': 'Assignment removed successfully'})
            return jsonify({'success': False, 'message': 'Failed to remove assignment'}), 400
        except Exception as e:
            return jsonify({'success': False, 'error': str(e)}), 400

# ===== TEAM STAFF API (Get all staff in a specific team) =====

@app.route('/api/team/<int:crew_id>/staff', methods=['GET'])
def api_team_staff(crew_id):
    """Get all staff members assigned to a specific team"""
    query = """SELECT 
                a.assigned_id, s.staff_id, s.staff_name, s.position, s.contact, 
                a.role, a.status, a.assignment_date
               FROM Assigned a
               JOIN Staff s ON a.staff_id = s.staff_id
               WHERE a.crew_id = %s
               ORDER BY a.role DESC, s.staff_name"""
    results = execute_query(query, (crew_id,))
    return jsonify(results)

@app.route('/api/staff/<int:staff_id>/teams', methods=['GET'])
def api_staff_teams(staff_id):
    """Get all teams a staff member is assigned to"""
    query = """SELECT 
                a.assigned_id, c.crew_id, c.team_name, c.contact, c.area_id,
                a.role, a.status, a.assignment_date
               FROM Assigned a
               JOIN Crew c ON a.crew_id = c.crew_id
               WHERE a.staff_id = %s
               ORDER BY c.team_name"""
    results = execute_query(query, (staff_id,))
    return jsonify(results)

@app.route('/api/bills-list')
def bills_list():
    results = execute_query("SELECT bill_id, bill_number FROM Bill")
    return jsonify(results)

# ===== ERROR HANDLERS =====

@app.errorhandler(404)
def page_not_found(e):
    return "Page Not Found (404)", 404

@app.errorhandler(500)
def internal_error(e):
    return "Internal Server Error (500)", 500

# ===== MAIN =====

def find_available_port(preferred_port=8000, max_attempts=5):
    """Find an available port starting from preferred_port"""
    import socket
    port = preferred_port
    for i in range(max_attempts):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.bind(('127.0.0.1', port))
            sock.close()
            return port
        except OSError:
            port += 1
    return preferred_port  # Fallback

if __name__ == '__main__':
    port = find_available_port(8000)
    print(f"\n✅ Starting Waste Management System on port {port}")
    print(f"📍 Access at: http://localhost:{port}")
    print(f"🌐 API at: http://localhost:{port}/api\n")
    
    # Only warn if port changed
    if port != 8000:
        print(f"⚠️  Port 8000 was in use, using port {port} instead\n")
    
    app.run(debug=False, host='127.0.0.1', port=port, threaded=True)
