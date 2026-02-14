-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Users table (combining Customer, Business, and Rider)
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('CUSTOMER', 'BUSINESS', 'RIDER')),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    phone_verified BOOLEAN DEFAULT FALSE,
    profile_image_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Customer-specific fields
    delivery_address TEXT,
    
    -- Business-specific fields
    business_name VARCHAR(255),
    business_description TEXT,
    location GEOMETRY(Point, 4326),
    
    -- Rider-specific fields
    vehicle_type VARCHAR(100),
    vehicle_number VARCHAR(50),
    current_location GEOMETRY(Point, 4326),
    rider_status VARCHAR(50) CHECK (rider_status IN ('AVAILABLE', 'BUSY', 'OFFLINE'))
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_rider_status ON users(rider_status);

-- PostGIS spatial indices for geolocation queries
CREATE INDEX idx_users_location ON users USING GIST(location);
CREATE INDEX idx_users_current_location ON users USING GIST(current_location);
