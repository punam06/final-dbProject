#!/bin/bash
# Quick server restart script - kills lingering processes and starts fresh

echo "🔄 Quick Server Restart..."

# Kill all lingering Flask/Python processes
pkill -f "backend/app.py" 2>/dev/null || true
pkill -f "python.*app.py" 2>/dev/null || true

# Also kill on specific ports if they're stuck
for port in 8000 8001 8002 8003; do
    lsof -ti:$port | xargs kill -9 2>/dev/null || true
done

sleep 2

# Start the server
cd "$(dirname "$0")"
python3 backend/app.py
