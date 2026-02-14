# Payment Setup – What We Need From You

To make **Trazzo-as-intermediary** payment work (customer pays Trazzo on delivery → we settle to business + rider), we use a **licensed Payment Aggregator** (e.g. **Razorpay** or **Cashfree**). Below is what we need from you.

---

## 1. PA account

- **Sign up** for [Razorpay](https://razorpay.com) or [Cashfree](https://www.cashfree.com) (Dashboard → create account).
- Complete **business KYC** as required by the PA.
- **Add a bank account** for receiving settlements (and for payouts to business/rider if you use same account, or separate payout accounts as per PA setup).

---

## 2. API keys

We use **environment variables** (never committed to git):

| Variable | Description | Example |
|----------|-------------|---------|
| `RAZORPAY_KEY_ID` | Key ID from Dashboard → API Keys | `rzp_test_xxxx` |
| `RAZORPAY_KEY_SECRET` | Key Secret from Dashboard → API Keys | `xxxx` |

*(Or equivalent for Cashfree: `CASHFREE_APP_ID`, `CASHFREE_SECRET`.)*

- Use **Test** keys first; switch to **Live** when going to production.
- Store these in your **run script** (e.g. `run-backend.sh`), **IDE run config**, or **deployment** env (e.g. GitHub Secrets). The backend reads `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, and `PAYMENT_WEBHOOK_SECRET` from the environment.

---

## 3. Webhook URL and secret

- We expose a **webhook endpoint** in the backend, e.g. `POST /api/payment/webhook`.
- You need to **register this URL** in the PA Dashboard (Razorpay → Settings → Webhooks, or Cashfree equivalent).
- Use your **public URL** (ngrok / deployed domain), e.g. `https://your-domain.com/api/payment/webhook`.
- **Webhook secret:** Generate or copy the **webhook secret** from the PA Dashboard and set:

| Variable | Description |
|----------|-------------|
| `PAYMENT_WEBHOOK_SECRET` | Secret used to verify webhook signatures |

We use this to verify that incoming webhooks are from the PA.

---

## 4. Flow we implement

1. **Create payment order**  
   When the customer is ready to pay (e.g. “Pay on delivery” / rider at door), backend creates a **PA order** (Razorpay Orders API or Cashfree equivalent) for the offer amount.

2. **Customer pays**  
   We use **Razorpay Checkout** (hosted payment page) or **Razorpay Payment Links** with UPI enabled. Customer can:
   - **Scan QR code** (if using Payment Links) and pay via any UPI app (PhonePe, Google Pay, Paytm, BHIM, etc.)
   - **Enter UPI ID** or **mobile number** on checkout page → opens their UPI app → completes payment
   - **Use Turbo UPI** (in-app flow) for seamless experience without leaving your app
   
   Razorpay supports all major UPI apps and handles the UPI integration for you.

3. **Webhook**  
   PA sends `order.paid` (or equivalent) to our webhook. We:
   - Verify signature using `PAYMENT_WEBHOOK_SECRET`.
   - Mark order as **payment received**.
   - Allow rider to **Mark delivered** (or trigger your delivery-completion logic).

4. **Settlement**  
   We instruct the PA to **payout** to business and rider (e.g. Razorpay Route, Cashfree Payouts). Trazzo keeps the platform fee. *Settlement automation can be implemented in a later phase.*

---

## 5. Mock mode (no PA keys)

- If **no** `RAZORPAY_KEY_ID` / `RAZORPAY_KEY_SECRET` are set, we run in **mock** mode:
  - “Pay on delivery” uses the existing **mock UPI** flow (no real money).
  - No webhook; payment is simulated.
- Use mock mode for **local/dev** and **testing** until you have PA keys and webhook URL.

---

## 6. Checklist – what you provide

- [ ] PA account (Razorpay or Cashfree) created and KYC done  
- [ ] Bank account added for settlements  
- [ ] **API keys** (Test first): `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET` (or Cashfree equivalents)  
- [ ] **Webhook URL** registered in PA Dashboard → our `POST /api/payment/webhook`  
- [ ] **Webhook secret** → `PAYMENT_WEBHOOK_SECRET` in env  
- [ ] Backend `.env` or deployment config updated with the above  

---

## 7. UPI with Razorpay

**Yes, Razorpay fully supports UPI!** Here's how it works:

### UPI Payment Methods Available:

1. **Collect Flow** (most common for "pay on delivery")
   - Customer enters **UPI ID** (e.g. `yourname@paytm`) or **mobile number** on checkout
   - Payment request sent to their UPI app
   - Customer approves in their UPI app (PhonePe, Google Pay, Paytm, BHIM, etc.)
   - Payment completes

2. **Payment Links** (good for delivery scenarios)
   - Generate a **QR code** or **payment link** via Razorpay API
   - Customer scans QR or opens link → enters UPI ID → pays
   - Works well when rider shows QR code at door

3. **Turbo UPI** (in-app, seamless)
   - Customer pays **within your app** without switching to UPI app
   - Better UX, higher success rates
   - Requires Razorpay SDK integration

4. **Intent Flow**
   - Customer selects UPI app → app opens automatically → prefilled details → pay

### For "Pay on Delivery" Scenario:

**Recommended:** Use **Razorpay Payment Links** or **Checkout with UPI**:
- When rider arrives → customer opens app → "Pay now" → Razorpay Checkout opens
- Customer enters UPI ID or scans QR → pays via their UPI app
- Payment confirmed → rider marks delivered

**Alternative:** Generate **QR code** via Razorpay API → rider shows QR → customer scans → pays

### Supported UPI Apps:
- PhonePe, Google Pay, Paytm, BHIM, Amazon Pay, WhatsApp Pay, and all NPCI-approved UPI apps

---

## 8. References

- [Razorpay Orders API](https://razorpay.com/docs/api/orders/)
- [Razorpay UPI Documentation](https://razorpay.com/docs/payments/payment-methods/upi/)
- [Razorpay Payment Links](https://razorpay.com/docs/payments/payment-links/)
- [Razorpay Webhooks](https://razorpay.com/docs/webhooks/)
- [Razorpay Route (payouts)](https://razorpay.com/docs/route/)

---

**Summary:** You provide **PA account**, **API keys**, **webhook URL + secret**. We implement create-order, checkout integration, and webhook handling; you switch from mock to live by setting env vars. The backend exposes `POST /api/payment/webhook` (public) and `GET /api/payment/config` (authenticated); use the webhook URL when registering in the PA Dashboard.
