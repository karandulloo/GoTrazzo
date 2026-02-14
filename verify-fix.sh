#!/bin/bash

# Trazzo - Verify Fixes Script

echo "🧪 Verifying Fixes..."
echo ""

# 1. Register Customer
echo "1️⃣ Registering Customer..."
CUST_RES=$(curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Customer",
    "email": "customer@test.com",
    "phone": "+1234567890",
    "password": "password123",
    "role": "CUSTOMER",
    "deliveryAddress": "123 Main St, Bangalore"
  }')

echo "Response: $CUST_RES"
TOKEN=$(echo $CUST_RES | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ Failed to register customer or extract token."
    exit 1
fi
echo "✅ Customer registered. Token: ${TOKEN:0:10}..."
echo ""

# 2. Register Business (Spatial Insert)
echo "2️⃣ Registering Business (Testing Spatial Insert)..."
BUS_RES=$(curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Pizza Palace",
    "email": "pizza@test.com",
    "phone": "+1234567891",
    "password": "password123",
    "role": "BUSINESS",
    "businessName": "Pizza Palace",
    "businessDescription": "Best pizzas",
    "latitude": 12.9716,
    "longitude": 77.5946
  }')
echo "Response: $BUS_RES"
echo "✅ Business registered."
echo ""

# 3. Nearby Search (Spatial Query)
echo "3️⃣ Testing Nearby Search (Testing Spatial Query)..."
SEARCH_RES=$(curl -s -X GET "http://localhost:8080/api/customer/businesses/nearby?latitude=12.9716&longitude=77.5946&radius=5000" \
  -H "Authorization: Bearer $TOKEN")

echo "Response: $SEARCH_RES"

if [[ "$SEARCH_RES" == *"Pizza Palace"* ]]; then
    echo "✅ Success! Found 'Pizza Palace' in nearby search."
    echo "🎉 All spatial tests passed!"
else
    echo "❌ Failed to find business in nearby search."
    echo "Output: $SEARCH_RES"
    exit 1
fi
