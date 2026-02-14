# Google Maps API Key Setup - Quick Guide

## ✅ API Key Added to App

Your API key has been added to:
- `ios/Runner/AppDelegate.swift`

---

## 🔧 **NEXT STEPS: Enable APIs in Google Cloud Console**

### Step 1: Go to Google Cloud Console
1. Visit: https://console.cloud.google.com/
2. Select your project (or create one if needed)

### Step 2: Enable Required APIs

Go to: **APIs & Services → Library**

Enable these APIs:

#### ✅ **1. Maps SDK for iOS** (REQUIRED)
- Search: "Maps SDK for iOS"
- Click "Enable"
- **This fixes your blank map!**

#### ✅ **2. Places API** (RECOMMENDED)
- Search: "Places API"
- Click "Enable"
- **For address autocomplete**

#### ✅ **3. Geocoding API** (RECOMMENDED)
- Search: "Geocoding API"
- Click "Enable"
- **For address to coordinates conversion**

#### ⏳ **4. Routes API** (OPTIONAL - Enable Later)
- Search: "Routes API"
- Click "Enable"
- **For order tracking (enable when needed)**

---

## 🔒 **IMPORTANT: Restrict Your API Key**

### Why Restrict?
- Prevents unauthorized usage
- Protects your API key
- Avoids unexpected charges

### How to Restrict:

1. Go to: **APIs & Services → Credentials**
2. Click on your API key
3. Under "API restrictions":
   - Select "Restrict key"
   - Check ONLY:
     - ✅ Maps SDK for iOS
     - ✅ Places API
     - ✅ Geocoding API
     - ✅ Routes API (if enabled)

4. Under "Application restrictions":
   - Select "iOS apps"
   - Add your bundle ID: `com.example.trazzoApp`
   - (You can find this in Xcode project settings)

5. Click "Save"

---

## ✅ **Verification Checklist**

- [ ] API key added to AppDelegate.swift ✅
- [ ] Maps SDK for iOS enabled
- [ ] Places API enabled (optional but recommended)
- [ ] Geocoding API enabled (optional but recommended)
- [ ] API key restricted to iOS apps
- [ ] Bundle ID added to restrictions

---

## 🚀 **Test Your Setup**

1. **Restart your app:**
   ```bash
   cd /Users/karandulloo/Desktop/Trazzo/mobile/trazzo_app
   flutter clean
   flutter run -d 00008110-001C71503452801E
   ```

2. **Check the map:**
   - Login as customer
   - Map should now display (not blank!)
   - You should see your location (blue dot)
   - Businesses should appear as markers

---

## 🐛 **Troubleshooting**

### Map Still Blank?
1. Check API key is correct in AppDelegate.swift
2. Verify Maps SDK for iOS is enabled
3. Check API key restrictions (should allow Maps SDK)
4. Restart app after changes

### API Key Errors?
- Make sure API key is not restricted too much
- Check bundle ID matches your app
- Verify APIs are enabled

### Still Having Issues?
- Check Google Cloud Console → APIs & Services → Dashboard
- Look for any error messages
- Verify billing account is set up (even if free tier)

---

## 💰 **Billing Setup**

Even though you're using free tier, Google requires billing account:

1. Go to: **Billing → Link a billing account**
2. Add a credit card (won't be charged if under free limits)
3. Set up billing alerts (optional but recommended)

**Note:** You won't be charged unless you exceed free tier limits (70k requests/month per API)

---

## 📝 **Summary**

✅ API key added to app
⏳ Enable APIs in Google Cloud Console
⏳ Restrict API key (recommended)
⏳ Test the map

**Next:** Run the app and see your map! 🗺️
