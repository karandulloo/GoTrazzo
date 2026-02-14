#!/bin/bash

# Trazzo - Start Docker Services

echo "🐳 Starting Docker services (PostgreSQL + Redis)..."

cd "$(dirname "$0")"

# Start Docker Compose
docker-compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for databases to be ready..."
sleep 5

# Check if PostgreSQL is ready (max 30 attempts, 2 seconds each = 60 seconds total)
attempt=0
max_attempts=30
until docker exec trazzo-postgres pg_isready -U trazzo_user 2>/dev/null | grep -q "accepting connections"; do
  attempt=$((attempt + 1))
  if [ $attempt -ge $max_attempts ]; then
    echo "❌ PostgreSQL failed to start after $max_attempts attempts"
    echo "Check logs with: docker logs trazzo-postgres"
    exit 1
  fi
  echo "Waiting for PostgreSQL... (attempt $attempt/$max_attempts)"
  sleep 2
done

echo "✅ PostgreSQL is ready"

# Check if Redis is ready
attempt=0
until docker exec trazzo-redis redis-cli ping 2>/dev/null | grep -q "PONG"; do
  attempt=$((attempt + 1))
  if [ $attempt -ge $max_attempts ]; then
    echo "❌ Redis failed to start after $max_attempts attempts"
    echo "Check logs with: docker logs trazzo-redis"
    exit 1
  fi
  echo "Waiting for Redis... (attempt $attempt/$max_attempts)"
  sleep 2
done

echo "✅ Redis is ready"
echo ""
echo "🎉 Docker services started successfully!"
echo "   - PostgreSQL: localhost:5432"
echo "   - Redis: localhost:6379"
