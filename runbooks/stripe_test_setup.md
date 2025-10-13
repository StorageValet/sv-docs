# Storage Valet v3.1 — Stripe TEST Mode Setup

**Purpose:** Configure Stripe in TEST mode for staging deployment and Gate 5 validation.

**IMPORTANT:** All steps below must be performed in **TEST mode** (toggle in top right of Stripe Dashboard).

---

## Checklist

### 1. Create $299/month Test Product & Price

- [ ] Go to Stripe Dashboard → Products
- [ ] Ensure **Test mode** is active (top right toggle)
- [ ] Click **+ Add product**
- [ ] Configure:
  - **Name:** Storage Valet Premium (Test)
  - **Description:** Premium concierge storage with pickup and delivery as needed
  - **Pricing model:** Standard pricing
  - **Price:** $299.00 USD
  - **Billing period:** Monthly
  - **Recurring:** Yes
- [ ] Click **Save product**
- [ ] Copy **Price ID** (starts with `price_test_...`)
  - Example: `price_test_1ABCdefGHIjklMNO`
- [ ] Paste into `secrets_needed.md` → `STRIPE_PRICE_PREMIUM299`

---

### 2. Get Test API Keys

- [ ] Go to Stripe Dashboard → Developers → API Keys
- [ ] Ensure **Test mode** is active
- [ ] Copy **Publishable key** (starts with `pk_test_...`)
  - Paste into `secrets_needed.md` → `VITE_STRIPE_PUBLISHABLE_KEY`
- [ ] Copy **Secret key** (starts with `sk_test_...`)
  - Click **Reveal test key token** if hidden
  - Paste into `secrets_needed.md` → `STRIPE_SECRET_KEY`

---

### 3. Create Webhook Endpoint (After Deploying Edge Functions)

**Prerequisites:** Edge Functions must be deployed to Supabase first to get webhook URL.

- [ ] Deploy `stripe-webhook` Edge Function:
  ```bash
  cd ~/code/sv-edge
  supabase functions deploy stripe-webhook
  ```
- [ ] Get webhook URL (format: `https://YOUR_PROJECT.supabase.co/functions/v1/stripe-webhook`)
- [ ] Go to Stripe Dashboard → Developers → Webhooks
- [ ] Ensure **Test mode** is active
- [ ] Click **+ Add endpoint**
- [ ] Configure:
  - **Endpoint URL:** `https://REPLACE_ME_SUPABASE_URL.supabase.co/functions/v1/stripe-webhook`
  - **Description:** Storage Valet Webhook (Staging)
  - **Events to send:**
    - [x] `checkout.session.completed`
    - [x] `customer.subscription.created`
    - [x] `customer.subscription.updated`
    - [x] `customer.subscription.deleted`
    - [x] `invoice.payment_succeeded`
    - [x] `invoice.payment_failed`
- [ ] Click **Add endpoint**
- [ ] Copy **Signing secret** (starts with `whsec_...`)
  - Paste into `secrets_needed.md` → `STRIPE_WEBHOOK_SECRET`
- [ ] Update Supabase secrets:
  ```bash
  supabase secrets set STRIPE_WEBHOOK_SECRET="whsec_..."
  ```

---

### 4. Test Checkout Flow (Manual)

- [ ] Get create-checkout Edge Function URL:
  ```
  https://REPLACE_ME_SUPABASE_URL.supabase.co/functions/v1/create-checkout
  ```
- [ ] Test with curl:
  ```bash
  curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/create-checkout \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com"}'
  ```
- [ ] Expected response:
  ```json
  {
    "url": "https://checkout.stripe.com/c/pay/cs_test_..."
  }
  ```
- [ ] Open URL in browser
- [ ] Use Stripe test card: `4242 4242 4242 4242`
  - Any future expiry date
  - Any 3-digit CVC
  - Any ZIP code
- [ ] Complete checkout
- [ ] Verify webhook fired:
  - Check Stripe Dashboard → Developers → Webhooks → Your endpoint → Recent events
  - Check Supabase logs: `supabase functions logs stripe-webhook`

---

### 5. Test Webhook Idempotency (Gate 4)

**Goal:** Verify duplicate events are ignored.

#### Option A: Using Stripe CLI

- [ ] Install Stripe CLI: https://stripe.com/docs/stripe-cli
- [ ] Login to Stripe:
  ```bash
  stripe login
  ```
- [ ] Forward webhooks to local or deployed Edge Function:
  ```bash
  # For deployed function:
  stripe listen --forward-to https://YOUR_PROJECT.supabase.co/functions/v1/stripe-webhook
  ```
- [ ] In another terminal, trigger test event:
  ```bash
  stripe trigger checkout.session.completed
  ```
- [ ] Copy event ID from output (e.g., `evt_test_abc123...`)
- [ ] Trigger same event again using Stripe CLI:
  ```bash
  stripe events resend evt_test_abc123...
  ```
- [ ] Check Supabase logs:
  ```bash
  supabase functions logs stripe-webhook --tail
  ```
- [ ] Expected output:
  ```
  First event: "Checkout completed for test@example.com (user_id: ...)"
  Second event: "Duplicate event evt_test_abc123..., skipping"
  ```
- [ ] Verify database:
  ```sql
  SELECT COUNT(*) FROM billing.webhook_events WHERE event_id = 'evt_test_abc123...';
  -- Should return 1 (not 2)
  ```

#### Option B: Using Stripe Dashboard

- [ ] Complete a test checkout (see step 4)
- [ ] Go to Stripe Dashboard → Developers → Events
- [ ] Find `checkout.session.completed` event
- [ ] Click event → Copy event ID
- [ ] Go to Stripe Dashboard → Developers → Webhooks → Your endpoint
- [ ] Click **Send test webhook**
- [ ] Select the same `checkout.session.completed` event
- [ ] Click **Send test webhook**
- [ ] Check logs for duplicate detection message

---

### 6. Test Magic Link Deliverability (Gate 5)

**Prerequisites:** Webhook must be working and creating users.

**Providers to test:**
1. Gmail
2. Outlook/Hotmail
3. iCloud
4. Yahoo
5. Proton Mail

**Procedure for each provider:**

- [ ] Create test account: `storagevalettest+{provider}@gmail.com` (use Gmail + aliases)
- [ ] Complete Stripe checkout with test email
- [ ] Start timer
- [ ] Wait for magic link email
- [ ] Record time from checkout to email receipt
- [ ] Open magic link
- [ ] Verify redirect to portal `/dashboard`
- [ ] Record result in table:

| Provider | Test Email | Send Time | Receive Time | Duration (sec) | Pass/Fail |
|----------|-----------|-----------|--------------|--------------|-----------|
| Gmail | test+gmail@example.com | - | - | - | ☐ |
| Outlook | test@outlook.com | - | - | - | ☐ |
| iCloud | test@icloud.com | - | - | - | ☐ |
| Yahoo | test@yahoo.com | - | - | - | ☐ |
| Proton | test@proton.me | - | - | - | ☐ |

**Success criteria:** All providers ≤120 seconds.

---

## Stripe CLI Quick Reference

```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe

# Login
stripe login

# Test webhook locally
stripe listen --forward-to http://localhost:54321/functions/v1/stripe-webhook

# Trigger events
stripe trigger checkout.session.completed
stripe trigger customer.subscription.created
stripe trigger customer.subscription.updated
stripe trigger invoice.payment_succeeded

# Resend event (idempotency test)
stripe events resend evt_test_abc123...

# View events
stripe events list --limit 10
```

---

## Troubleshooting

### Webhook 400 Error: Missing signature
- Verify `STRIPE_WEBHOOK_SECRET` is set in Supabase Edge secrets
- Check Stripe Dashboard → Webhooks → Signing secret matches

### Webhook 401 Error: Signature verification failed
- Secret key mismatch between Stripe and Edge Function
- Regenerate signing secret in Stripe Dashboard and update Supabase secrets

### Magic link not arriving
- Check Supabase Dashboard → Authentication → Email Templates
- Verify Supabase Auth email provider is enabled (default SMTP)
- Check spam folder
- Test with different email provider

### Checkout URL not redirecting
- Verify `APP_URL` is set correctly in Edge secrets
- Check success_url in `create-checkout` function
- Ensure Vercel deployment is live

---

**Status:** ⏳ AWAITING TEST COMPLETION

**Next:** After all tests pass, proceed to production deployment with live Stripe keys.
