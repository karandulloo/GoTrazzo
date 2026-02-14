# Chat Functionality Testing Guide

## ✅ **What Has Been Implemented**

### Backend:
1. ✅ Added `category` field to User model and database
2. ✅ Created `/api/business/profile` endpoint (PUT) to update business details
3. ✅ Updated chat service to send notifications via WebSocket
4. ✅ Chat endpoints already exist:
   - `POST /api/chat/create` - Create or get chat
   - `GET /api/chat/{chatId}/messages` - Get chat messages
   - `POST /api/chat/send` - Send a message
   - `GET /api/chat/user/{userId}` - Get user's chats

### Mobile App:
1. ✅ Chat screen UI with message bubbles
2. ✅ Business onboarding form connected to API
3. ✅ Chat service methods for sending/receiving messages
4. ✅ Navigation from business details to chat screen

---

## 🧪 **How to Test Chat Functionality**

### **Prerequisites:**
1. ✅ Backend is running (`./run-backend.sh`)
2. ✅ Database migration has run (category field added)
3. ✅ Mobile app is running on iPhone

---

## 📱 **Test Scenario: Customer Chats with Business**

### **Step 1: Register a Business**
1. Open the app
2. Go to Register screen
3. Select "Business" role
4. Fill in:
   - Name: "John's Hardware Store"
   - Email: `business@test.com`
   - Phone: `+1234567890`
   - Password: `password123`
   - Business Name: "John's Hardware"
   - Business Description: "We sell tools and hardware"
5. Click "Set Business Location" (captures GPS location)
6. Submit registration
7. **Expected:** Redirects to business dashboard

### **Step 2: Complete Business Onboarding**
1. On business dashboard, tap "Update Business Details"
2. Fill in:
   - Business Name: "John's Hardware Store"
   - Business Description: "Your one-stop shop for all hardware needs"
   - Category: Select "Hardware"
   - Location: Tap "Set Business Location"
3. Tap "Save Business Details"
4. **Expected:** Success message, returns to dashboard

### **Step 3: Register a Customer**
1. Logout from business account
2. Go to Register screen
3. Select "Customer" role
4. Fill in:
   - Name: "Alice Customer"
   - Email: `customer@test.com`
   - Phone: `+0987654321`
   - Password: `password123`
5. Submit registration
6. **Expected:** Redirects to customer home (business list)

### **Step 4: Customer Finds Business**
1. On customer home screen, you should see "John's Hardware Store" in the list
2. If not visible, check:
   - Both devices are on same WiFi network
   - Location permissions granted
   - Business location was set correctly
3. Tap on "John's Hardware Store"
4. **Expected:** Business details screen opens

### **Step 5: Customer Starts Chat**
1. On business details screen, tap "Start Chat" button
2. **Expected:** Chat screen opens
3. **Expected:** Chat is created automatically (or retrieved if exists)

### **Step 6: Customer Sends Message**
1. Type a message: "Hi, I need some tools for my project. Can you help?"
2. Tap send button
3. **Expected:** 
   - Message appears in chat
   - Message shows on right side (your messages)
   - Timestamp appears

### **Step 7: Business Receives Notification**
1. **On Business Device (or same device after logout/login):**
   - Login as business (`business@test.com`)
   - Go to Business Dashboard
   - Tap "Chats" tab at bottom
2. **Expected:**
   - "Alice Customer" appears in chat list
   - Last message preview shows: "Hi, I need some tools..."
   - Unread count badge (if implemented)
   - Timestamp shows "Just now" or time

### **Step 8: Business Opens Chat**
1. Tap on "Alice Customer" chat
2. **Expected:** Chat screen opens showing customer's message
3. Type reply: "Sure! What tools do you need?"
4. Tap send
5. **Expected:** Message appears in chat

### **Step 9: Customer Sees Reply**
1. **Switch back to Customer app** (or refresh)
2. **Expected:**
   - Business reply appears in chat
   - Message shows on left side (business messages)
   - Chat updates automatically (if WebSocket connected)

---

## 🔍 **Testing Checklist**

### **Backend API Testing (Using Postman/curl):**

#### 1. Update Business Profile
```bash
curl -X PUT http://192.168.1.6:8080/api/business/profile \
  -H "Authorization: Bearer YOUR_BUSINESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "businessName": "John'\''s Hardware Store",
    "businessDescription": "Your one-stop shop",
    "category": "Hardware",
    "latitude": 12.9716,
    "longitude": 77.5946
  }'
```

**Expected:** Returns updated business profile with category

#### 2. Create Chat
```bash
curl -X POST "http://192.168.1.6:8080/api/chat/create?customerId=1&businessId=2" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected:** Returns chat object with id

#### 3. Send Message
```bash
curl -X POST http://192.168.1.6:8080/api/chat/send \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "chatId": 1,
    "senderId": 1,
    "content": "Hi, I need some tools",
    "type": "TEXT"
  }'
```

**Expected:** Returns message object

#### 4. Get Chat Messages
```bash
curl http://192.168.1.6:8080/api/chat/1/messages \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected:** Returns array of messages

#### 5. Get User Chats
```bash
curl http://192.168.1.6:8080/api/chat/user/2 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected:** Returns array of chats for that user

---

## 🐛 **Troubleshooting**

### **Chat Not Appearing:**
1. Check backend logs for errors
2. Verify chat was created: `GET /api/chat/user/{userId}`
3. Check authentication token is valid
4. Verify user IDs are correct

### **Messages Not Sending:**
1. Check network connection
2. Verify chatId exists
3. Check senderId matches authenticated user
4. Look at backend error logs

### **Business Not Receiving Notifications:**
1. WebSocket notifications require WebSocket connection
2. Currently, notifications work via REST API polling
3. For real-time, need to implement WebSocket client in mobile app

### **Category Not Showing:**
1. Verify database migration ran: Check `users` table has `category` column
2. Verify business updated profile with category
3. Check API response includes category field

---

## 📊 **Database Verification**

### Check if category field exists:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'category';
```

### Check business has category:
```sql
SELECT id, name, business_name, category 
FROM users 
WHERE role = 'BUSINESS';
```

### Check chats exist:
```sql
SELECT * FROM chats;
```

### Check messages exist:
```sql
SELECT * FROM messages ORDER BY sent_at DESC LIMIT 10;
```

---

## 🎯 **Expected Behavior Summary**

1. **Customer Flow:**
   - Sees businesses grouped by category
   - Taps business → sees details
   - Taps "Start Chat" → chat screen opens
   - Sends message → appears immediately
   - Receives business reply → appears in chat

2. **Business Flow:**
   - Completes onboarding → saves category and location
   - Sees customer chats in Chats tab
   - Taps chat → sees conversation
   - Sends reply → customer receives it

3. **Real-time Updates:**
   - Currently: REST API polling (pull to refresh)
   - Future: WebSocket for instant updates

---

## ✅ **Success Criteria**

- ✅ Business can update profile with category
- ✅ Customer can see businesses by category
- ✅ Customer can start chat with business
- ✅ Messages send successfully
- ✅ Business sees customer chats
- ✅ Business can reply to customer
- ✅ Messages appear in correct order
- ✅ Timestamps display correctly

---

## 🚀 **Next Steps (Future Enhancements)**

1. **WebSocket Integration:**
   - Connect to `ws://192.168.1.6:8080/ws`
   - Subscribe to `/topic/chat/{chatId}`
   - Receive real-time message updates

2. **Push Notifications:**
   - Implement push notifications for new messages
   - Notify business when customer sends message

3. **Unread Count:**
   - Track unread messages
   - Show badge on chat list

4. **Message Status:**
   - Show "Sent", "Delivered", "Read" indicators

---

**Happy Testing!** 🎉
