# Trazzo – Comprehensive Testing Guide

End-to-end testing for **auth**, **customer**, **business**, **chat**, **Make an offer**, and **rider** flows.  

**Current flow:** Customer sees **chat only** (no Create Order). Business can **Make an offer** (amount, pay on delivery via UPI).  
**OTP removed:** riders use **Mark delivered**.  
**Payment:** See `PAYMENT_FLOW_DESIGN.md` for how amount flows to business, rider, and platform.

---

## Prerequisites

### 1. Backend & database
- **PostgreSQL** and **Redis** running (e.g. via Docker).
- **Backend** running:
  ```bash
  cd /Users/karandulloo/Desktop/Trazzo
  ./run-backend.sh
  ```
  Or: `cd backend && mvn spring-boot:run`
- Migrations applied (category, orders, chat, etc.).

### 2. Mobile app
- **Flutter** project:
  ```bash
  cd /Users/karandulloo/Desktop/Trazzo/mobile/trazzo_app
  flutter pub get
  flutter run -d <your-iphone-device-id>
  ```
- **API URL**: In `lib/core/config/app_config.dart`, `devApiBaseUrl` must point to your Mac’s IP (e.g. `http://192.168.1.6:8080`), not `localhost`, when testing on a physical device.
- **Google Maps**: If you use maps, set the API key in `ios/Runner/AppDelegate.swift`.

### 3. Network
- iPhone and Mac on the **same Wi‑Fi**.
- Backend reachable from the device at `http://<MAC_IP>:8080`.

---

## Part 1: Authentication

### 1.1 Register – Business
1. Open app → **Register**.
2. Select **Business**.
3. Fill:
   - Name: `John's Hardware`
   - Email: `business@test.com`
   - Phone: `+1234567890`
   - Password: `password123`
   - Business Name: `John's Hardware`
   - Business Description: `We sell tools and hardware`
4. Tap **Set Business Location** (allow location).
5. Submit.
6. **Expected:** Redirect to **Business Dashboard**.

### 1.2 Register – Customer
1. **Logout** (app bar).
2. **Register** → select **Customer**.
3. Fill:
   - Name: `Alice Customer`
   - Email: `customer@test.com`
   - Phone: `+0987654321`
   - Password: `password123`
4. Submit.
5. **Expected:** Redirect to **Customer** home (Nearby Businesses).

### 1.3 Register – Rider
1. **Logout**.
2. **Register** → select **Rider**.
3. Fill name, email, phone, password (and any rider-specific fields if present).
4. Submit.
5. **Expected:** Redirect to **Rider Dashboard**.

### 1.4 Login & logout
- **Login:** Use registered email + password. **Expected:** Role-based home (Customer / Business / Rider).
- **Logout:** App bar → logout. **Expected:** Back to Login.

---

## Part 2: Business onboarding & profile

1. Login as **Business** (`business@test.com`).
2. On Dashboard, tap **Update Business Details**.
3. Set:
   - Business Name: `John's Hardware Store`
   - Description: `Your one-stop shop for hardware`
   - **Category:** e.g. `Hardware`
   - **Location:** Tap **Set Business Location** (allow location).
4. Tap **Save Business Details**.
5. **Expected:** Success, back to dashboard.

---

## Part 3: Customer – discovery & chat

### 3.1 Nearby businesses
1. Login as **Customer** (`customer@test.com`).
2. **Expected:** **Nearby Businesses** list (categories, chips).
3. If empty: check location permission, backend running, business has location set.
4. Use **category** chips to filter.

### 3.2 Business details
1. Tap a business (e.g. `John's Hardware Store`).
2. **Expected:** Details (name, description, category, contact).
3. Only **Start Chat** is visible (no Create Order).

### 3.3 Chat (customer → business)
1. On business details, tap **Start Chat**.
2. **Expected:** Chat screen opens; chat created if new.
3. Send: `I want one drill machine.`
4. **Expected:** Message appears on the right (yours).
5. **Note:** New messages from business require **pull-to-refresh** or re-opening chat (no WebSocket).

---

## Part 4: Business – chats & Make an offer

### 4.1 Chats tab
1. Login as **Business** (`business@test.com`).
2. Open **Chats** tab (bottom nav).
3. **Expected:** List of customer chats; unread badge if applicable.
4. If you don’t see the new chat, **pull to refresh**.
5. Tap **Alice Customer** (or the customer you chatted with).
6. **Expected:** Conversation with customer message (e.g. “I want one drill machine.”).
7. Reply: `Yes we have.` → Send.
8. **Expected:** Your message appears.

### 4.2 Make an offer
1. In the same chat, tap the **Make an offer** (offer) icon in the app bar.
2. **Expected:** Dialog “Make an offer” with **Amount (₹)** and optional **Note**.
3. Enter amount, e.g. `1500`. (Optional) Note: `Includes delivery`.
4. Tap **Send offer**.
5. **Expected:** “Offer sent”; an **Offer** card appears in chat (amount + “Pay on delivery (UPI)”).
6. **Note:** Payment is **on delivery** (UPI). See `PAYMENT_FLOW_DESIGN.md` for split between business, rider, and platform.

### 4.3 Orders tab (optional / legacy)
1. **Orders** tab (between Dashboard and Chats) still lists orders from the **full order flow** (create order → add items → confirm → pay).
2. For the **chat + Make an offer** flow, we do not create orders yet; offers live in chat only.

---

## Part 5: Customer – accept offer, rider assigned, rider details

1. **Customer** chat with business (Part 3.3).
2. After **Business** sends **Make an offer** (Part 4.2), **pull to refresh** or re-open chat.
3. **Expected:** An **Offer** card: “Offer from business”, amount (e.g. ₹1,500), “Pay on delivery (UPI)”, and **Accept offer** button.
4. Tap **Accept offer** → enter **delivery address** (or **Use current location**) → **Accept**.
5. **Expected:** “Offer accepted. Rider assigned.” → navigate to **Order details**.
6. On **Order details**: status **Rider assigned**, and **Your rider** card with **name** and **phone** (tap to **call**). Use **Refresh** (app bar) if needed.
7. **Payment:** Customer pays **on delivery** (UPI). See `PAYMENT_FLOW_DESIGN.md` and `PAYMENT_SETUP.md` for Trazzo-as-intermediary and what you need to provide.

### 5.2 My Orders (optional / legacy)
- **My Orders** (app bar) and the **full order flow** (create order → confirm → pay) still exist but are **not** the main path.  
- Main flow: **Chat** → **Make an offer** → **Accept offer** → rider assigned → rider name/contact → pay on delivery (UPI).

---

## Part 6: Rider – availability, orders, delivery

### 6.1 Availability
1. Login as **Rider**.
2. On **Rider Dashboard**, use **Available** / **Busy** / **Offline** chips.
3. **Expected:** Status updates; snackbar confirmation.

### 6.2 Assigned orders
1. Set status to **Available**.
2. **Expected:** After a customer pays, order is assigned to a nearby rider (backend logic).
3. **My orders** lists assigned orders (e.g. **Rider assigned**).

### 6.3 Start delivery
1. Tap an order with status **Rider assigned**.
2. Tap **Start delivery**.
3. **Expected:** Status → **In transit**; snackbar “Delivery started”.

### 6.4 Mark delivered
1. For an **In transit** order, tap **Mark delivered**.
2. **Expected:** “Delivery completed”; status → **Delivered**.
3. **Note:** OTP has been removed; rider marks delivered directly.

---

## Part 7: End-to-end flow (summary)

**Chat + Make an offer (current):**

| Step | Actor    | Action |
|------|----------|--------|
| 1    | Business | Register → onboarding (name, category, location) |
| 2    | Customer | Register → see nearby businesses |
| 3    | Customer | Business details → **Start chat** only (no Create Order) |
| 4    | Customer | Send e.g. “I want one drill machine.” |
| 5    | Business | **Chats** tab → open chat → reply “Yes we have.” (refresh if needed) |
| 6    | Business | **Make an offer** → amount (e.g. ₹1,500) → **Pay on delivery (UPI)** |
| 7    | Customer | Refresh chat → see **Offer** card → **Accept offer** → delivery address → Accept |
| 8    | Backend | Create order from offer, **assign rider** → customer sees **rider name + contact** on order |
| 9    | *(Later)* | Delivery; customer pays (UPI). See `PAYMENT_FLOW_DESIGN.md` and `PAYMENT_SETUP.md`. |

---

## Part 8: Troubleshooting

### App stuck on “Loading businesses” / “Nearby businesses”
- Backend running and reachable at `devApiBaseUrl`.
- Location permission granted; use default location fallback if implemented.
- Business has **location** set (onboarding).

### “Connection refused” / API errors
- `app_config.dart`: `devApiBaseUrl` = `http://<MAC_IP>:8080` (not `localhost`).
- iPhone and Mac on same Wi‑Fi.
- Backend, PostgreSQL, Redis running.

### No businesses in list
- At least one **Business** user with **category** and **location** set.
- Customer location (or default) within search radius.

### Chat messages not updating
- **Manual refresh:** Pull to refresh on chat list; re-open chat to see new messages.
- WebSocket is not used in current implementation.

### Offer not appearing (Customer)
- **Pull to refresh** or re-open chat after business sends **Make an offer**.
- Offers are **ORDER_PROPOSAL** messages; they render as “Offer” cards.

### Orders not appearing (Business / Rider)
- **Orders** / **My orders** use the **full order flow** (create order → add items → confirm → pay).  
- The **chat + Make an offer** flow does not create orders; offers are in chat only.

### Rider not getting assigned / “No available riders” when accepting offer
- Rider must be **Available** (use **Available** chip on Rider dashboard) and within backend’s rider-assignment radius of the business.
- At least one **Rider** user registered. **Accept offer** creates the order and assigns a rider immediately; if none are available, the request fails.

### Maps blank (if used)
- Google Maps API key set in `ios/Runner/AppDelegate.swift`.
- Maps SDK enabled for the key.

---

## Quick reference – roles & homes

| Role     | Home / main screens        |
|----------|----------------------------|
| Customer | Nearby Businesses → Details → **Start Chat** only; **My Orders** (optional) |
| Business | Dashboard → **Chats** (→ **Make an offer**) → **Orders**; **Update Business Details** |
| Rider    | Dashboard → **My orders**; **Available** / **Busy** / **Offline** |

---

## Checklist

- [ ] Backend + DB + Redis running
- [ ] `devApiBaseUrl` = Mac IP when on device
- [ ] Business registered + onboarding (category, location)
- [ ] Customer registered + sees businesses
- [ ] Chat: Customer sends “I want one drill machine” → Business replies “Yes we have”
- [ ] **Make an offer:** Business sends offer (amount, pay on delivery) → Customer sees offer card in chat
- [ ] **Accept offer:** Customer accepts → delivery address → order created, **rider assigned** → rider **name + contact** on order detail
- [ ] (Optional) Full order flow: create order → add items → confirm → pay → rider → mark delivered

---

**Last updated:** Chat-only for customer; **Make an offer** for business; pay on delivery (UPI). See `PAYMENT_FLOW_DESIGN.md`.
