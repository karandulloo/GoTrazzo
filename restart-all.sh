#!/bin/bash

# Trazzo - Complete System Restart

echo "🔄 Restarting entire Trazzo system..."

cd "$(dirname "$0")"

# Stop everything
echo "1️⃣ Stopping existing services..."
docker-compose down -v

# Kill any process using port 8080
echo ""
echo "2️⃣ Checking port 8080..."
if lsof -ti:8080 > /dev/null 2>&1; then
    echo "   Port 8080 is in use, killing process..."
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    sleep 2
    echo "   ✓ Port 8080 freed"
else
    echo "   ✓ Port 8080 is available"
fi

# Start Docker services
echo ""
echo "3️⃣ Starting Docker services..."
./docker-up.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to start Docker services"
    exit 1
fi

# Start backend
echo ""
echo "4️⃣ Starting backend..."
echo "Note: Backend will run in foreground. Press Ctrl+C to stop."
echo ""
./run-backend.sh
