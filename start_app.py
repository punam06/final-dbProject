#!/usr/bin/env python3
"""
Waste Management System - Starter Script
This script should be run from the project root to ensure all paths are correct
"""
import os
import sys

# Add backend directory to path
backend_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'backend')
sys.path.insert(0, backend_dir)

# Import and run the app
from app import app, find_available_port

if __name__ == '__main__':
    port = find_available_port(8000)
    print(f"\n✅ Starting Waste Management System on port {port}")
    print(f"📍 Access at: http://localhost:{port}")
    print(f"🌐 API at: http://localhost:{port}/api\n")
    
    # Only warn if port changed
    if port != 8000:
        print(f"⚠️  Port 8000 was in use, using port {port} instead\n")
    
    app.run(debug=False, host='127.0.0.1', port=port, threaded=True)
