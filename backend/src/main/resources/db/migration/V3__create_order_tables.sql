-- Orders table
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    business_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rider_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    chat_id BIGINT NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    
    -- Order status state machine
    status VARCHAR(50) NOT NULL DEFAULT 'DRAFT' CHECK (status IN (
        'DRAFT', 
        'PENDING_BUSINESS', 
        'NEGOTIATING', 
        'AWAITING_PAYMENT', 
        'PAYMENT_CONFIRMED', 
        'RIDER_ASSIGNED', 
        'IN_TRANSIT', 
        'DELIVERED', 
        'CANCELLED'
    )),
    
    -- Delivery details
    delivery_address TEXT NOT NULL,
    delivery_location GEOMETRY(Point, 4326) NOT NULL,
    
    -- Payment details
    total_amount DECIMAL(10, 2),
    payment_method VARCHAR(50),
    payment_transaction_id VARCHAR(255),
    
    -- OTP for delivery verification
    delivery_otp VARCHAR(6),
    otp_generated_at TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    delivered_at TIMESTAMP
);

-- Order items table
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    item_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_business ON orders(business_id);
CREATE INDEX idx_orders_rider ON orders(rider_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_order_items_order ON order_items(order_id);
