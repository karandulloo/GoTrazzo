#!/bin/bash

# Trazzo - Run Backend (with port check)

echo "🚀 Starting Trazzo Backend..."

cd "$(dirname "$0")/backend"

# Check if port 8080 is in use
if lsof -ti:8080 > /dev/null 2>&1; then
    echo "⚠️  Port 8080 is already in use!"
    echo "   Killing existing process..."
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    sleep 2
    echo "   ✓ Port freed, starting backend..."
fi

# Run with Maven
./mvnw spring-boot:run
