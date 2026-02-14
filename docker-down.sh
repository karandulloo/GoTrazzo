#!/bin/bash

# Trazzo - Stop Docker Services

echo "🛑 Stopping Docker services..."

cd "$(dirname "$0")"

# Stop and remove containers, networks
docker-compose down

echo "✅ Docker services stopped"
