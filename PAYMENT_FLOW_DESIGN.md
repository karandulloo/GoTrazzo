# Payment Flow Design (Pay on Delivery / UPI)

**Current:** Business sends an **Offer** (amount) in chat. Customer pays **on delivery** to the rider (e.g. UPI).  
**Open:** How the amount is split between **business**, **rider**, and **Trazzo (platform)**.

---

## 1. Flow today

1. Customer chats with business: e.g. “I want one drill machine.”
2. Business replies: “Yes we have.”
3. Business taps **Make an offer** → enters amount (e.g. ₹1,500) → **Pay on delivery (UPI)**.
4. Customer sees offer in chat (amount + “Pay on delivery (UPI)”).
5. **Later:** Delivery happens; customer pays rider via UPI on arrival.

---

## 2. What we need to decide

**Customer pays rider (UPI) on delivery.** After that:

- **Rider** receives the money (e.g. UPI to rider’s number / VA).
- We need rules for:
  - **Business share** (e.g. product price minus platform cut).
  - **Rider share** (delivery fee).
  - **Trazzo share** (commission / fee).

### Option A – Rider collects full amount

- Customer pays **full offer amount** to rider (UPI).
- Rider keeps **delivery fee**; forwards **rest to business** (manual or via Trazzo).
- **Trazzo** fee: taken from business share (e.g. % of order) or from rider fee.

### Option B – Trazzo as intermediary (recommended for dispute control)

- Customer pays **Trazzo** (e.g. UPI to platform VPA) on delivery.
- Trazzo **holds** the amount, then **settles**:
  - To **business** (offer amount minus commission).
  - To **rider** (delivery fee).
  - **Trazzo** keeps platform fee.
- **Why this helps:** If the business sends the wrong product, or the rider makes a mistake (non‑delivery, damage, etc.), Trazzo can **hold or adjust** settlement (partial refund to customer, delayed release to business/rider) and resolve disputes before money moves. See **§ 6** (India legal) and **§ 7** (technical trade‑offs).

### Option C – Direct to business + rider fee

- Customer pays **business** (UPI) for the order.
- Separately, customer (or business) pays **rider** delivery fee.
- **Trazzo** fee: from business (e.g. % of order).

---

## 3. Implementation notes (for later)

- **UPI:** Use a UPI SDK / intent (e.g. `upi://pay`) or PG like Razorpay, PhonePe TPAP, etc.
- **Settlement:** Manual (rider → business) vs **automated** (trail in DB, payouts via PG / bank).
- **Offer → Order:** When business sends an offer, we could create a lightweight **order** (amount, “pay on delivery”) so that:
  - Rider assignment and delivery flow can hook into it.
  - Settlements are computed from a single source of truth.

---

## 4. Summary

| Step | Who | What |
|------|-----|------|
| 1 | Customer | Chats, gets offer (amount + pay on delivery). |
| 2 | Business | Sends **Make an offer** (amount, UPI on delivery). |
| 3 | Delivery | Customer pays **Trazzo** (or rider) via UPI on arrival. |
| 4 | Settlement | Trazzo settles to business, rider; keeps platform fee. |

---

## 5. Trazzo as intermediary – why it helps with disputes

**Your idea:** Trazzo receives payment → holds → settles to business and rider (and keeps platform fee). That gives you **control** when something goes wrong.

| Issue | Trazzo holds funds | Trazzo doesn’t hold |
|-------|--------------------|---------------------|
| **Wrong product** | Hold business share; refund customer (full/partial); adjust settlement. | Customer paid business/rider directly; you have no leverage. |
| **Rider mistake** (non‑delivery, damage, lost) | Hold/deduct rider share; refund customer if needed; pay business. | Hard to claw back from rider; customer may blame platform anyway. |
| **Fraud / chargeback** | You can reverse or withhold settlement while you investigate. | Money already gone; recovery is difficult. |

**Takeaway:** Holding funds lets you **enforce** policies (refunds, penalties, delayed release) and align with **consumer protection** expectations. You become the **accountable** party, so you need clear terms, dispute flows, and compliance (see **§ 6**).

---

## 6. India – legal and regulatory considerations

*This is not legal advice. Engage a lawyer for your specific structure and geography.*

### 6.1 Payment aggregation (RBI)

- If you **collect** from customers and **disburse** to businesses/riders, you’re in **payment aggregation** territory.
- **RBI** regulates **Payment Aggregators (PAs)**. Typically you either:
  - **Get PA authorization**, or  
  - **Use a licensed PA** (Razorpay, Paytm, Cashfree, etc.) to collect and disburse. You integrate via APIs; they handle regulatory compliance.
- **Practical path:** Use a **PG + Payout** provider (e.g. Razorpay Route, Cashfree Payouts). You don’t hold bank/UPI float yourself; the PA does. You instruct “settle X to business, Y to rider” and retain your fee. Reduces regulatory burden on you.

### 6.2 Escrow‑like holding

- **Holding** customer money before releasing to seller/rider is **escrow‑like**.
- Escrow‑type arrangements can attract **specific rules** (depending on structure). Using a **licensed intermediary** (PA) that supports **escrow / settlement delay** is usually safer than you holding funds in your own accounts.

### 6.3 Consumer protection

- **Consumer Protection Act, 2019** and rules apply. Customers expect **refunds** for wrong product, non‑delivery, etc.
- If **Trazzo** is the **recipient of payment** (Option B), you’re the **facilitating platform**. Liability and redress often flow to the platform.
- **Mitigation:**
  - Clear **terms of use** and **refund / dispute policy**.
  - **SLA** for dispute resolution (e.g. 7–14 days).
  - Define when you release to business/rider (e.g. after “dispute window” or “delivery confirmed”).

### 6.4 GST and tax

- **Platform fee / commission** → **GST** applies (typically 18% for such services).
- **TCS** (Tax Collected at Source) may apply if you’re an **e‑commerce operator** under GST. A CA can confirm.
- **Contracts** with businesses and riders should cover **invoicing**, **GST**, and **TDS** if applicable.

### 6.5 Contracts

- **Business agreement:** When you settle, dispute handling, chargebacks, your right to withhold or reverse.
- **Rider agreement:** Same for delivery fee; liability for lost/damaged orders.
- **Customer terms:** Refund policy, limitation of liability, dispute process.

**Bottom line:** Trazzo‑as‑intermediary is **compatible** with Indian law **if** you use a **licensed PA** for collection and payout, and you have **clear terms + dispute process**. Doing it without PA compliance (you holding and moving funds directly) is **risky**.

---

## 7. Technical drawbacks of Trazzo‑as‑intermediary

| Area | Drawback | Mitigation |
|------|----------|------------|
| **Settlement logic** | When to release? Immediate vs after N days, or after “delivery confirmed” / “dispute window.” Complexity grows with partial refunds, multiple legs. | Define clear rules (e.g. release 24–48 h after delivery unless dispute). Use **state machine** for order + settlement status. |
| **Dispute handling** | Need flows: “customer says wrong product” → hold → investigate → refund / partial release. Support, policies, escalations. | Implement **dispute** entity and statuses; simple UI for support; eventually customer‑facing “raise dispute.” |
| **Reconciliation** | Every txn: customer → Trazzo → business + rider + Trazzo. Must reconcile with PG/PA, your DB, and bank. | **Idempotent** payouts; **audit log**; daily reconciliation jobs; use PA’s **webhooks** and **reports**. |
| **Integrations** | UPI collect + payouts → PG/PA APIs. More moving parts, failure modes (network, PA downtime). | Retries, idempotency, **webhook**‑driven status updates; fallback comms (email/SMS) when payout fails. |
| **Liquidity / float** | If you hold in **your** account: working capital, float management. | Prefer **PA‑led** settlement (e.g. Razorpay Route): they hold float; you instruct. Reduces your liquidity burden. |
| **Fraud / chargebacks** | Customer disputes after you’ve settled → you may have to **refund** from your side and **claw back** or absorb loss. | **Fraud checks** (velocity, risk signals); **delayed settlement** (e.g. 24–48 h) to allow dispute before release; reserve for chargebacks. |
| **Single point of failure** | All money flows through you. Outage, bug, or breach impacts everyone. | **Staging** environments; **gradual rollout**; **circuit breakers**; secure, minimal handling of sensitive data; PA handles actual money movement. |

**Summary:** The main technical cost is **complexity** (settlement rules, dispute flows, reconciliation) and **reliance** on PG/PA. Using a **licensed PA** for both collect and payout keeps you away from direct fund handling and reduces regulatory and operational risk.

---

## 8. Recommendation

1. **Adopt Trazzo‑as‑intermediary (Option B)** for **dispute control** and **consumer protection** alignment.
2. **Use a licensed PA** (e.g. Razorpay, Cashfree) for:
   - **Collect:** Customer pays **Trazzo** (via UPI card flow / intent / PA checkout) on delivery.
   - **Payout:** You instruct PA to **settle** to business and rider; PA handles compliance and float.
3. **Define settlement rules** up front: e.g. release 24–48 h after “delivery confirmed,” or after a short dispute window; implement **dispute** workflow before scaling.
4. **Legal:** Get **terms** and **refund/dispute policy** in place; consider **GST/TCS** with a CA; use **contracts** with businesses and riders.

**Next:** Choose a PA, design **collect + payout** APIs, then implement UPI collection and settlement logic (and later, dispute handling).
