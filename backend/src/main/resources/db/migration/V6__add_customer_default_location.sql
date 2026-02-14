-- Customer default delivery location (for "nearby" search and default order address)
ALTER TABLE users ADD COLUMN IF NOT EXISTS default_delivery_latitude DOUBLE PRECISION;
ALTER TABLE users ADD COLUMN IF NOT EXISTS default_delivery_longitude DOUBLE PRECISION;
