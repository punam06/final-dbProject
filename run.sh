#!/bin/bash
# Waste Management System - Startup Script

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Dhaka Waste Management System - Startup Script         ║"
echo "╚════════════════════════════════════════════════════════════════╝"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if port is in use
check_port() {
    if lsof -ti:$1 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to kill process on port
kill_port() {
    echo -e "${YELLOW}Clearing port $1...${NC}"
    lsof -ti:$1 | xargs kill -9 2>/dev/null
    sleep 1
}

# Step 1: Check MySQL
echo -e "\n${YELLOW}[1/4]${NC} Checking MySQL database..."
if mysql -u root -e "SELECT 1" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ MySQL is running${NC}"
else
    echo -e "${RED}✗ MySQL is not running. Please start MySQL first.${NC}"
    exit 1
fi

# Step 2: Check database
if mysql -u root -e "USE waste_management; SHOW TABLES;" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Database 'waste_management' exists${NC}"
else
    echo -e "${RED}✗ Database 'waste_management' not found${NC}"
    echo -e "${YELLOW}Setting up database from schema.sql...${NC}"
    mysql -u root < "$SCRIPT_DIR/database/schema.sql"
    echo -e "${GREEN}✓ Database initialized${NC}"
fi

# Step 3: Check and install dependencies
echo -e "\n${YELLOW}[2/4]${NC} Checking Python dependencies..."
if python3 -c "import flask" 2>/dev/null; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${YELLOW}Installing dependencies...${NC}"
    pip install --break-system-packages -r "$SCRIPT_DIR/requirements.txt" > /dev/null 2>&1
    echo -e "${GREEN}✓ Dependencies installed${NC}"
fi

# Step 4: Kill existing processes on port 8000
echo -e "\n${YELLOW}[3/4]${NC} Checking port 8000..."
if check_port 8000; then
    kill_port 8000
fi

# Step 5: Start Flask server
echo -e "\n${YELLOW}[4/4]${NC} Starting Flask server on port 8000..."
cd "$SCRIPT_DIR"
python3 backend/app.py > server.log 2>&1 &
SERVER_PID=$!

sleep 3

# Verify server started
if check_port 8000; then
    echo -e "${GREEN}✓ Flask server started successfully${NC}"
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 SERVER IS RUNNING 🎉                     ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║ Frontend:     http://localhost:8000                           ║"
    echo "║ API:          http://localhost:8000/api                       ║"
    echo "║ Database:     waste_management (MySQL)                        ║"
    echo "║ Log file:     server.log                                      ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Press Ctrl+C to stop the server"
    wait $SERVER_PID
else
    echo -e "${RED}✗ Failed to start Flask server${NC}"
    echo "Check server.log for details:"
    tail -20 server.log
    exit 1
fi
