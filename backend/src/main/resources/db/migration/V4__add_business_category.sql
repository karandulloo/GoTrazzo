-- Add category field to users table for businesses
ALTER TABLE users ADD COLUMN IF NOT EXISTS category VARCHAR(100);

-- Create index for category filtering
CREATE INDEX IF NOT EXISTS idx_users_category ON users(category) WHERE category IS NOT NULL;
