# UPI Integration with Razorpay – Quick Guide

**Yes, Razorpay fully supports UPI payments!** You don't need a separate UPI integration.

---

## How It Works

When you integrate **Razorpay**, UPI is **automatically included**. Here's the flow:

### 1. Customer Ready to Pay (Rider at Door)

**Option A: Razorpay Checkout (Recommended)**
```
Customer taps "Pay now" → 
Razorpay Checkout opens (web page or in-app) → 
Customer selects "UPI" → 
Enters UPI ID (e.g. yourname@paytm) or mobile number → 
Opens their UPI app → 
Approves payment → 
Done!
```

**Option B: Payment Link / QR Code**
```
Backend generates Razorpay Payment Link / QR → 
Rider shows QR code or sends link → 
Customer scans QR or opens link → 
Enters UPI ID → 
Pays via UPI app → 
Done!
```

### 2. What Customer Sees

- **Razorpay Checkout page** with payment options (Cards, UPI, Netbanking, etc.)
- Customer selects **"UPI"**
- Enters their **UPI ID** (e.g. `yourname@paytm`, `yourname@ybl`, `yourname@okaxis`) or **mobile number**
- Payment request sent to their UPI app
- Customer approves in **PhonePe / Google Pay / Paytm / BHIM** (any UPI app)
- Payment successful!

---

## Supported UPI Apps

Razorpay supports **all NPCI-approved UPI apps**:
- ✅ PhonePe
- ✅ Google Pay
- ✅ Paytm
- ✅ BHIM
- ✅ Amazon Pay
- ✅ WhatsApp Pay
- ✅ Any bank's UPI app (SBI Pay, HDFC PayZapp, etc.)

**You don't need to integrate each app separately** – Razorpay handles it!

---

## Implementation Steps

1. **Get Razorpay account** (as per `PAYMENT_SETUP.md`)
2. **Backend:** Create Razorpay Order → return checkout URL or payment link
3. **Mobile:** Open checkout URL or show QR code
4. **Customer:** Selects UPI → enters UPI ID → pays
5. **Webhook:** Razorpay notifies us → we mark payment received

---

## Example Flow for Your App

```
1. Rider arrives at customer location
2. Customer opens app → sees order → taps "Pay on delivery"
3. Backend creates Razorpay order → returns checkout URL
4. Mobile app opens Razorpay Checkout (in WebView or browser)
5. Customer selects "UPI" → enters UPI ID → pays via PhonePe/GPay/etc.
6. Razorpay webhook → our backend → order marked "Payment received"
7. Rider can now "Mark delivered"
```

---

## Benefits

- ✅ **No separate UPI integration** – included with Razorpay
- ✅ **All UPI apps supported** – customer uses their preferred app
- ✅ **Compliance handled** – Razorpay is RBI-licensed PA
- ✅ **Easy to implement** – just use Razorpay APIs
- ✅ **Good success rates** – UPI is fast and reliable

---

## Technical Details

- **Razorpay Checkout:** Hosted payment page (you redirect customer)
- **Payment Links:** Generate link/QR, customer pays, webhook confirms
- **Turbo UPI:** In-app UPI (better UX, requires SDK)
- **All methods support UPI** – customer chooses their preferred app

---

**Bottom line:** Use Razorpay → UPI is included automatically. No need for separate UPI integration!
