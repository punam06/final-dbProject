#!/bin/bash

# Waste Management System - Robust Server Runner with Auto-Restart
# This script handles crashes and keeps the server running

PROJECT_DIR="/Users/punam/Desktop/varsity/3-1/Lab/dbms/finalProj"
VENV_PATH="$PROJECT_DIR/venv"
APP_PATH="$PROJECT_DIR/backend/app.py"
LOG_FILE="$PROJECT_DIR/server.log"
PID_FILE="$PROJECT_DIR/.server.pid"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to kill any existing Flask processes
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up existing processes...${NC}"
    pkill -f "python.*app.py" 2>/dev/null || true
    pkill -f "python backend/app.py" 2>/dev/null || true
    sleep 1
}

# Function to check if port is in use
check_port() {
    if lsof -i :8000 2>/dev/null; then
        return 0  # Port in use
    else
        return 1  # Port free
    fi
}

# Function to start the server
start_server() {
    echo -e "${GREEN}🚀 Starting Waste Management Server...${NC}"
    
    # Check if port is still in use
    if check_port; then
        echo -e "${YELLOW}⚠️  Port 8000 still in use, forcing cleanup...${NC}"
        lsof -i :8000 -t | xargs kill -9 2>/dev/null || true
        sleep 2
    fi
    
    # Activate venv and start server
    cd "$PROJECT_DIR"
    source "$VENV_PATH/bin/activate"
    
    # Start server in background with output logging
    python "$APP_PATH" >> "$LOG_FILE" 2>&1 &
    SERVER_PID=$!
    echo $SERVER_PID > "$PID_FILE"
    
    echo -e "${GREEN}✅ Server started with PID: $SERVER_PID${NC}"
    echo -e "${GREEN}📍 Access at: http://localhost:8000${NC}"
    echo -e "${GREEN}📋 Logs at: $LOG_FILE${NC}"
    
    # Wait a moment for server to fully start
    sleep 3
    
    # Test if server is responding
    if curl -s http://localhost:8000 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Server is responding!${NC}"
        return 0
    else
        echo -e "${RED}❌ Server is not responding${NC}"
        return 1
    fi
}

# Function to monitor and restart if crashes
monitor_server() {
    echo -e "${GREEN}📡 Monitoring server (Press Ctrl+C to stop)...${NC}"
    
    while true; do
        sleep 5
        
        # Check if server process is still running
        if [ -f "$PID_FILE" ]; then
            SERVER_PID=$(cat "$PID_FILE")
            if ! kill -0 "$SERVER_PID" 2>/dev/null; then
                echo -e "${RED}❌ Server crashed (PID: $SERVER_PID)${NC}"
                echo -e "${YELLOW}🔄 Restarting server...${NC}"
                cleanup
                start_server
                if [ $? -ne 0 ]; then
                    echo -e "${RED}❌ Failed to restart server${NC}"
                    echo "Check logs: tail -f $LOG_FILE"
                    exit 1
                fi
            fi
        fi
        
        # Also check if port is responsive
        if ! curl -s http://localhost:8000 > /dev/null 2>&1; then
            echo -e "${RED}❌ Server not responding${NC}"
            echo -e "${YELLOW}🔄 Restarting server...${NC}"
            cleanup
            start_server
            if [ $? -ne 0 ]; then
                echo -e "${RED}❌ Failed to restart server${NC}"
                echo "Check logs: tail -f $LOG_FILE"
                exit 1
            fi
        fi
    done
}

# Main execution
case "${1:-start}" in
    start)
        cleanup
        start_server
        if [ $? -eq 0 ]; then
            monitor_server
        else
            echo -e "${RED}❌ Server failed to start${NC}"
            echo "Check logs: tail -f $LOG_FILE"
            exit 1
        fi
        ;;
    stop)
        echo -e "${YELLOW}🛑 Stopping server...${NC}"
        cleanup
        rm -f "$PID_FILE"
        echo -e "${GREEN}✅ Server stopped${NC}"
        ;;
    restart)
        echo -e "${YELLOW}🔄 Restarting server...${NC}"
        cleanup
        start_server
        if [ $? -eq 0 ]; then
            monitor_server
        else
            echo -e "${RED}❌ Server failed to restart${NC}"
            exit 1
        fi
        ;;
    logs)
        tail -f "$LOG_FILE"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs}"
        echo ""
        echo "Commands:"
        echo "  start   - Start server with auto-restart monitoring"
        echo "  stop    - Stop the server"
        echo "  restart - Restart the server"
        echo "  logs    - Show server logs in real-time"
        exit 1
        ;;
esac
