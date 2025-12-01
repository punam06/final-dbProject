#!/usr/bin/env python3
"""
Flask Watchdog - Keeps Flask running 24/7
Monitors port 8000 and automatically restarts Flask if it crashes
Perfect for presentations - no downtime!
"""

import subprocess
import time
import sys
import os
import signal
from pathlib import Path

PROJECT_DIR = Path(__file__).parent.absolute()
FLASK_APP = PROJECT_DIR / "backend" / "app.py"
LOG_FILE = PROJECT_DIR / "watchdog.log"
FLASK_PROCESS = None
RESTART_COUNT = 0

def log_msg(msg):
    """Log to console and file"""
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    full_msg = f"[{ts}] {msg}"
    print(full_msg)
    with open(LOG_FILE, "a") as f:
        f.write(full_msg + "\n")

def is_flask_alive():
    """Check if Flask is responding using curl"""
    try:
        result = subprocess.run(
            ["curl", "-s", "-m", "2", "http://localhost:8000/"],
            capture_output=True,
            timeout=3
        )
        return result.returncode == 0
    except:
        return False

def start_flask():
    """Start Flask process"""
    global FLASK_PROCESS
    try:
        FLASK_PROCESS = subprocess.Popen(
            [sys.executable, str(FLASK_APP)],
            cwd=str(PROJECT_DIR),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            preexec_fn=os.setsid  # Create new process group for clean shutdown
        )
        log_msg(f"✅ Flask started (PID: {FLASK_PROCESS.pid})")
        return True
    except Exception as e:
        log_msg(f"❌ Failed to start Flask: {e}")
        return False

def stop_flask():
    """Stop Flask gracefully"""
    global FLASK_PROCESS
    if FLASK_PROCESS and FLASK_PROCESS.poll() is None:
        try:
            os.killpg(os.getpgid(FLASK_PROCESS.pid), signal.SIGTERM)
            FLASK_PROCESS.wait(timeout=5)
            log_msg("✅ Flask stopped gracefully")
        except:
            try:
                os.killpg(os.getpgid(FLASK_PROCESS.pid), signal.SIGKILL)
                log_msg("⚠️ Flask force killed")
            except:
                pass

def main():
    """Main watchdog loop"""
    global RESTART_COUNT
    
    log_msg("=" * 70)
    log_msg("🔍 FLASK WATCHDOG STARTED - Auto-recovery enabled")
    log_msg(f"📁 Project: {PROJECT_DIR}")
    log_msg("⏱️  Checking every 3 seconds")
    log_msg("=" * 70)
    
    try:
        # Start Flask initially
        if not start_flask():
            log_msg("⚠️ Initial Flask startup failed")
        
        time.sleep(3)  # Give Flask time to start
        
        # Monitor loop
        while True:
            if not is_flask_alive():
                RESTART_COUNT += 1
                log_msg(f"⚠️ Flask not responding! Restart #{RESTART_COUNT}")
                log_msg("🔄 Stopping old process...")
                stop_flask()
                time.sleep(2)
                log_msg("🚀 Starting Flask...")
                start_flask()
                time.sleep(3)  # Wait for Flask to start
            
            time.sleep(3)  # Check every 3 seconds
            
    except KeyboardInterrupt:
        log_msg("\n🛑 Watchdog shutdown requested")
        stop_flask()
        log_msg("✅ Watchdog stopped cleanly")
    except Exception as e:
        log_msg(f"❌ Watchdog error: {e}")
        stop_flask()
    finally:
        log_msg("=" * 70)

if __name__ == "__main__":
    main()
