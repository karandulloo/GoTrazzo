-- Link orders created from chat offers to the offer message
ALTER TABLE orders ADD COLUMN IF NOT EXISTS offer_message_id BIGINT REFERENCES messages(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_orders_offer_message ON orders(offer_message_id) WHERE offer_message_id IS NOT NULL;
