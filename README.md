# Trazzo Delivery Platform v2.0

Complete rebuild of the Trazzo delivery platform with a production-ready architecture.

## Architecture

### Backend
- **Framework**: Spring Boot 3.2.1
- **Language**: Java 17
- **Database**: PostgreSQL 15 with PostGIS extension
- **Cache**: Redis 7
- **Authentication**: JWT with refresh tokens
- **Real-time**: WebSocket (STOMP protocol)
- **Migrations**: Flyway

### Mobile
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Real-time**: WebSocket + STOMP
- **Maps**: Google Maps

## Features Implemented

### ✅ Core Backend Infrastructure
- PostgreSQL + PostGIS for geospatial queries
- Redis for OTP storage and caching
- Docker Compose for local development
- Flyway database migrations
- JWT authentication with BCrypt password encryption

### ✅ User Management
- Role-based authentication (Customer, Business, Rider)
- User registration and login endpoints
- Spring Security with JWT filters
- Role-specific field validation

### ✅ Geolocation & Business Discovery
- PostGIS geometry columns for locations
- Find nearby businesses within 5km radius
- Distance-based sorting using ST_Distance
- Efficient spatial indexing (GIST)

### ✅ Real-time Chat System
- WebSocket configuration with STOMP
- Chat creation between customers and businesses
- Message persistence in PostgreSQL
- Real-time message delivery via WebSocket
- Support for text and structured messages (order proposals)

### ✅ Order Management
- Complete order lifecycle with 9 states:
  - DRAFT → PENDING_BUSINESS → NEGOTIATING → AWAITING_PAYMENT
  - → PAYMENT_CONFIRMED → RIDER_ASSIGNED → IN_TRANSIT → DELIVERED
- Order item management with automatic subtotal calculation
- Mock UPI payment confirmation
- Order history for all user types

### ✅ Rider Assignment System
- Automatic nearest rider selection using PostGIS
- Rider marks order delivered (OTP removed)
- Rider availability status (AVAILABLE, BUSY, OFFLINE)
- Real-time notifications via WebSocket

### ✅ API Endpoints

**Authentication**
```
POST /api/auth/register
POST /api/auth/login
```

**Customer**
```
GET  /api/customer/businesses/nearby?lat={lat}&lng={lng}&radius={radius}
GET  /api/customer/businesses/{id}
```

**Chat**
```
POST /api/chat/create?customerId={customerId}&businessId={businessId}
GET  /api/chat/{chatId}/messages
POST /api/chat/send
SEND /app/chat.send (WebSocket)
```

**Orders**
```
POST /api/orders
PUT  /api/orders/{orderId}/items
POST /api/orders/{orderId}/confirm
POST /api/orders/{orderId}/payment
GET  /api/orders/{orderId}
GET  /api/orders/customer/{customerId}
GET  /api/orders/business/{businessId}
GET  /api/orders/rider/{riderId}
```

**Rider**
```
PUT  /api/rider/{riderId}/status
PUT  /api/rider/{riderId}/location
POST /api/rider/orders/{orderId}/accept
POST /api/rider/orders/{orderId}/deliver
```

## Quick Start

### 1. Start Docker Services
```bash
./docker-up.sh
```

This will start:
- PostgreSQL with PostGIS on port 5432
- Redis on port 6379

### 2. Run Backend
```bash
./run-backend.sh
```

The backend will:
- Download Maven dependencies
- Run Flyway migrations
- Start on http://localhost:8080
- Enable WebSocket on ws://localhost:8080/ws

### 3. Run Mobile App
```bash
./run-mobile.sh
```

This will:
- Install Flutter dependencies
- Launch the app on connected device/simulator

## Database Schema

### Users Table
- Role-based fields (customer, business, rider)
- PostGIS Point geometry for locations
- BCrypt encrypted passwords

### Chats & Messages
- Customer-business chat sessions
- Message types: TEXT, ORDER_PROPOSAL, ORDER_CONFIRMATION
- WebSocket real-time delivery

### Orders & Order Items
- State machine for order lifecycle
- PostGIS delivery location
- Payment tracking
- Rider mark delivered

## Technology Decisions

### Why PostgreSQL + PostGIS?
- **ACID compliance** for orders and payments
- **PostGIS** provides production-grade geospatial queries
- **Native geometry types** for efficient spatial operations
- **Proven scalability** for transactional workloads

### Why Redis?
- **Caching** and **session management** for future enhancements
- **Rider availability cache** for quick lookups

### Why WebSocket?
- **Real-time chat** between customers and businesses
- **Instant notifications** for order updates
- **Efficient** compared to polling
- **STOMP protocol** for structured messaging

### Why JWT?
- **Stateless authentication** scales horizontally
- **Mobile-friendly** token-based auth
- **Refresh tokens** for extended sessions
- **Role-based access control** (RBAC)

## Next Steps

### Mobile App Development (In Progress)
1. Authentication screens (registration, login)
2. Customer app:
   - Map view with nearby businesses
   - Business profile and chat
   - Order creation and tracking
   - Payment confirmation
3. Business app:
   - Dashboard with incoming orders
   - Chat with customers
   - Order management
4. Rider app:
   - Availability toggle
   - Order assignments
   - Mark delivered

### Testing & Documentation
- API testing guide
- End-to-end flow documentation
- Deployment instructions

## Project Structure

```
Trazzo/
├── backend/
│   ├── src/main/java/com/trazzo/
│   │   ├── config/          # Security, WebSocket, Redis
│   │   ├── controller/      # REST & WebSocket endpoints
│   │   ├── dto/             # Request/Response DTOs
│   │   ├── model/           # JPA entities
│   │   ├── repository/      # Spring Data repositories
│   │   ├── security/        # JWT service & filters
│   │   └── service/         # Business logic
│   └── src/main/resources/
│       ├── application.yml
│       └── db/migration/    # Flyway SQL scripts
├── mobile/
│   └── trazzo_app/
│       └── lib/
│           ├── core/        # Constants, utils
│           ├── features/    # Auth, customer, business, rider
│           └── shared/      # Widgets, services
├── docker-compose.yml
├── docker-up.sh
├── run-backend.sh
└── run-mobile.sh
```

## Configuration

### Backend (application.yml)
- Database: `jdbc:postgresql://localhost:5432/trazzo`
- Redis: `localhost:6379`
- JWT secret: Configurable via environment variable
- Search radius: 5km default

### Mobile (pubspec.yaml)
- Flutter SDK: >=3.0.0
- Key dependencies: riverpod, dio, geolocator, google_maps_flutter, stomp_dart_client

## Database Migrations

All migrations in `backend/src/main/resources/db/migration/`:
- `V1__init_schema.sql` - Users table with PostGIS
- `V2__create_chat_tables.sql` - Chats and messages
- `V3__create_order_tables.sql` - Orders and order items

## API Security

- **Public endpoints**: `/api/auth/**`, `/ws/**`
- **Customer endpoints**: Require `ROLE_CUSTOMER`
- **Business endpoints**: Require `ROLE_BUSINESS`
- **Rider endpoints**: Require `ROLE_RIDER`
- **CORS**: Enabled for mobile clients
- **Session**: Stateless (JWT only)
