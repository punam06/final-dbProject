#!/usr/bin/env python3
"""
Flask Process Monitor - Automatically restarts Flask if it crashes
Runs Flask with automatic restart capability
"""

import subprocess
import time
import sys
import os
import signal
from pathlib import Path

# Get project directory
PROJECT_DIR = Path(__file__).parent.absolute()
BACKEND_APP = PROJECT_DIR / "backend" / "app.py"
LOG_FILE = PROJECT_DIR / "flask_monitor.log"

def log_message(msg):
    """Log messages to both console and file"""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    full_msg = f"[{timestamp}] {msg}"
    print(full_msg)
    with open(LOG_FILE, "a") as f:
        f.write(full_msg + "\n")

def check_flask_running(process):
    """Check if Flask process is still running"""
    return process.poll() is None

def start_flask():
    """Start Flask process"""
    log_message("🚀 Starting Flask server...")
    try:
        process = subprocess.Popen(
            [sys.executable, str(BACKEND_APP)],
            cwd=str(PROJECT_DIR),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            bufsize=1
        )
        log_message(f"✅ Flask started with PID {process.pid}")
        return process
    except Exception as e:
        log_message(f"❌ Failed to start Flask: {e}")
        return None

def main():
    """Main monitor loop"""
    log_message("=" * 60)
    log_message("🔍 Flask Monitor Started - Auto-restart enabled")
    log_message(f"📁 Project: {PROJECT_DIR}")
    log_message(f"📝 Log file: {LOG_FILE}")
    log_message("=" * 60)
    
    restart_count = 0
    process = None
    
    try:
        while True:
            # Start Flask if not running
            if process is None or not check_flask_running(process):
                if process is not None:
                    restart_count += 1
                    log_message(f"⚠️  Flask crashed! Restart attempt #{restart_count}")
                    time.sleep(2)  # Wait before restart
                
                process = start_flask()
                if process is None:
                    log_message("❌ Failed to start Flask, retrying in 10 seconds...")
                    time.sleep(10)
                    continue
            
            # Check every 5 seconds
            time.sleep(5)
            
    except KeyboardInterrupt:
        log_message("\n⏹️  Monitor shutdown requested")
        if process and check_flask_running(process):
            log_message("Terminating Flask process...")
            process.terminate()
            try:
                process.wait(timeout=5)
                log_message("✅ Flask terminated cleanly")
            except subprocess.TimeoutExpired:
                log_message("⚠️  Flask didn't terminate, force killing...")
                process.kill()
        log_message("✅ Monitor stopped")
    except Exception as e:
        log_message(f"❌ Monitor error: {e}")
        if process and check_flask_running(process):
            process.kill()
    finally:
        log_message("=" * 60)

if __name__ == "__main__":
    main()
