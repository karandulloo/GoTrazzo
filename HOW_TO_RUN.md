# Trazzo - Quick Start Guide

## Prerequisites
- Docker Desktop installed and running
- Java 17 or higher
- Maven (or use included Maven wrapper)
- Flutter 3.x (for mobile app)

## Quick Start

### Option 1: Start Everything (Recommended)
```bash
./restart-all.sh
```
This will:
1. Stop any existing services
2. Start PostgreSQL + Redis
3. Launch the backend (runs in foreground)

Press `Ctrl+C` to stop the backend when done.

### Option 2: Start Step by Step

**Step 1: Start Databases**
```bash
./docker-up.sh
```
Wait for "🎉 Docker services started successfully!"

**Step 2: Run Backend**
```bash
./run-backend.sh
```
Wait for "Started TrazzoApplication" message.

**Step 3: Run Mobile App** (separate terminal)
```bash
./run-mobile.sh
```

## Stopping Services

**Stop Backend**: Press `Ctrl+C` in the terminal running backend

**Stop Docker Services**:
```bash
./docker-down.sh
```

**Complete Cleanup** (removes data volumes):
```bash
docker-compose down -v
```

## Testing the Backend

**Health Check**:
```bash
curl http://localhost:8080/api/auth/register
```

**Register a Test User**:
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Customer",
    "email": "customer@test.com",
    "phone": "+1234567890",
    "password": "password123",
    "role": "CUSTOMER",
    "deliveryAddress": "123 Main St"
  }'
```

**Login**:
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "emailOrPhone": "customer@test.com",
    "password": "password123"
  }'
```

## Troubleshooting

### PostgreSQL Won't Start
```bash
# Check logs
docker logs trazzo-postgres

# Restart with fresh data
docker-compose down -v
./docker-up.sh
```

### Backend Won't Connect
1. Ensure Docker services are running: `docker ps`
2. Check PostgreSQL is accessible: `docker exec trazzo-postgres pg_isready -U trazzo_user`
3. Restart everything: `./restart-all.sh`

### Port Already in Use
```bash
# Check what's using port 8080
lsof -i :8080

# Or change port in backend/src/main/resources/application.yml
```

## Available Scripts

- `./docker-up.sh` - Start PostgreSQL + Redis
- `./docker-down.sh` - Stop Docker services
- `./run-backend.sh` - Run Spring Boot backend
- `./run-mobile.sh` - Run Flutter mobile app
- `./restart-all.sh` - Complete system restart

## API Endpoints

All endpoints: http://localhost:8080

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/customer/businesses/nearby` - Find nearby businesses
- `POST /api/chat/create` - Create chat
- `POST /api/orders` - Create order
- `PUT /api/rider/{riderId}/status` - Update rider status

See [README.md](README.md) for complete API documentation.

## Database Access

**PostgreSQL**:
```bash
docker exec -it trazzo-postgres psql -U trazzo_user -d trazzo
```

**Redis**:
```bash
docker exec -it trazzo-redis redis-cli
```

## Next Steps

1. ✅ Backend is running
2. 📱 Develop Flutter mobile app
3. 🧪 Test complete user flows
4. 🚀 Deploy to production
