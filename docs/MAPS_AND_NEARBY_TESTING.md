# Maps & Nearby Business – Manual Testing Guide

## 1. Rider dashboard (500 fix)

- **Fix applied:** The rider "My orders" 500 was caused by JSON serialization (circular reference: `Order` → `OrderItem` → `Order`). The backend now ignores the back-reference on `OrderItem.order` and keeps the read transaction open so lazy loading works.
- **What to test:** Log in as a **rider** → open Rider Dashboard. You should see either a list of your orders or an empty "My orders" section with no server error. Use **Retry** if the list was empty and you expect orders.

---

## 2. Will the customer see the business in “Nearby Businesses”?

**Yes, if these are true:**

1. **Business has a location set**
   - The **business** user must have set their location (e.g. via Business onboarding or Business profile with “Get current location” or equivalent).
   - Location is stored in the DB and used for the “nearby” search.

2. **Customer’s location is used for the search**
   - When the **customer** opens the app, the app gets the device location (or uses a default, e.g. Bangalore) and calls:
     - `GET /api/customer/businesses/nearby?latitude=...&longitude=...&radius=...`
   - Default `radius` from backend config is **5000 m (5 km)**. So the business will appear only if it is within that distance of the customer’s coordinates.

**How to test with one customer and one business:**

1. Log in as **business** → set/update profile with a location:
   - **Use current location** (GPS), or **Set on map** (drag a pin on the map to set exact location).
2. Log in as **customer** → set **My address** (app bar icon “My address”): enter address text and set location (current or pick on map). Save. Nearby businesses will use this location.
3. Alternatively, if the customer has not set an address, the app uses **device location** for nearby search.
4. Ensure the customer’s search location (saved address or device) is within 5 km of the business. Then open “Nearby Businesses” and you should see the business.
5. If you don’t see the business, try increasing `radius` in backend `trazzo.default-search-radius` (e.g. 10000 for 10 km) or double-check business and customer locations.

---

## 3. Google API setup

- **What’s used:**  
  - **Device location:** `geolocator` (device GPS). No Google API key needed for this.  
  - **Map display:** `google_maps_flutter` + Google Maps SDK. This **does** need a Google API key.

- **Setup:**
  - **iOS:** Copy `ios/Runner/GoogleMaps-Key.xcconfig.example` to `ios/Runner/GoogleMaps-Key.xcconfig` and set `GOOGLE_MAPS_API_KEY` to your key. The key is read from `Info.plist` (`GoogleMapsAPIKey`).
  - **Android:** In `AndroidManifest.xml`, set the meta-data value for `com.google.android.geo.API_KEY` to your key (replace `YOUR_GOOGLE_MAPS_API_KEY`).

- **Google Cloud:** Enable **Maps SDK for iOS** and **Maps SDK for Android** (and any other APIs you use, e.g. Places if you add place search later). Restrict the key by app package/bundle ID if possible.

- **Nearby businesses:** Served by **your backend** (PostGIS), not by Google Places. So “nearby” works without a Places API key; only map **display** needs the Maps API key.

---

## 4. Expected maps functionality (for manual testing)

- **Current behaviour (to expect when testing):**
  - **Customer:** Can set **My address** (address text + location via “Current” or “Pick on map”). Nearby businesses use this saved location when set; otherwise device location. Then `/api/customer/businesses/nearby` is called with that lat/lng.
  - **Business:** Can set location in onboarding/profile via **Use current location** or **Set on map** (drag pin). That location is stored and used for the nearby search.
  - **Rider:** Can update location for assignment; no map widget is required for the rider dashboard “My orders” to work.

- **If you use a map widget (e.g. `GoogleMap`):**
  - Map should load when the API key is set correctly in iOS/Android.
  - You can show: user position, business markers, delivery route, etc., depending on what you implement. The backend already returns lat/lng for businesses and orders, so you can place markers from that data.

- **Summary:**  
  - **Rider dashboard:** Fixed; no 500 on “My orders”.  
  - **Customer sees business in nearby:** Yes, if business has location and is within the search radius of the customer’s location.  
  - **Google API:** Needed only for map display (Maps SDK); nearby search is backend-only.
