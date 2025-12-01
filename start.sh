#!/bin/bash
# Start Flask with automatic crash recovery
# Run this before your presentation!

cd "$(dirname "$0")"

echo "🎯 Starting Waste Management System with Auto-Recovery..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Access at: http://localhost:8000"
echo "📊 Dashboard: http://localhost:8000/"
echo ""
echo "🔄 Flask will AUTO-RESTART if it crashes"
echo "🛑 Press CTRL+C to stop the system"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

python3 monitor.py
