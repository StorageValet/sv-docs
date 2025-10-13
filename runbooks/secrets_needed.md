# Storage Valet v3.1 — Secrets & Environment Variables (Staging)

**Purpose:** Single source of truth for all secrets and public keys required for staging deployment and Gate 5 testing.

**Status:** ⏳ AWAITING VALUES — Replace all `REPLACE_ME_*` placeholders before deployment.

---

## Required Secrets & Variables

| System | Variable | Purpose | Where Set | Value/Placeholder |
|--------|----------|---------|-----------|-------------------|
| **Supabase Edge (Staging)** | | | | |
| Edge | `SUPABASE_URL` | Supabase project URL | `supabase secrets set` | `REPLACE_ME_SUPABASE_URL`<br>(e.g., https://xxxxx.supabase.co) |
| Edge | `SUPABASE_SERVICE_ROLE_KEY` | Admin access for Auth/DB ops | `supabase secrets set` | `REPLACE_ME_SERVICE_ROLE_KEY`<br>(from Supabase Dashboard → Settings → API → service_role secret) |
| Edge | `STRIPE_SECRET_KEY` | Stripe API secret (TEST mode) | `supabase secrets set` | `REPLACE_ME_STRIPE_SECRET_TEST`<br>(e.g., sk_test_...) |
| Edge | `STRIPE_WEBHOOK_SECRET` | Webhook signature verification | `supabase secrets set` | `REPLACE_ME_WEBHOOK_SECRET_TEST`<br>(e.g., whsec_...) |
| Edge | `STRIPE_PRICE_PREMIUM299` | Price ID for $299/month test product | `supabase secrets set` | `REPLACE_ME_PRICE_TEST_299`<br>(e.g., price_test_...) |
| Edge | `APP_URL` | Portal base URL (staging) | `supabase secrets set` | `REPLACE_ME_STAGING_PORTAL_URL`<br>(e.g., https://sv-portal-staging.vercel.app) |
| **Vercel (Portal Staging)** | | | | |
| Portal | `VITE_SUPABASE_URL` | Supabase project URL (public) | Vercel env vars | `REPLACE_ME_SUPABASE_URL`<br>(same as Edge SUPABASE_URL) |
| Portal | `VITE_SUPABASE_ANON_KEY` | Supabase anon/public key | Vercel env vars | `REPLACE_ME_ANON_KEY`<br>(from Supabase Dashboard → Settings → API → anon public) |
| Portal | `VITE_APP_URL` | Portal base URL (staging) | Vercel env vars | `REPLACE_ME_STAGING_PORTAL_URL`<br>(same as Edge APP_URL) |
| Portal | `VITE_STRIPE_PUBLISHABLE_KEY` | Stripe publishable key (TEST mode) | Vercel env vars | `REPLACE_ME_STRIPE_PK_TEST`<br>(e.g., pk_test_...) |
| **Stripe (TEST Mode)** | | | | |
| Stripe | Test Secret Key | For Edge Functions | Stripe Dashboard → Developers → API Keys (Test) | `REPLACE_ME_STRIPE_SECRET_TEST`<br>(copy to Edge secrets) |
| Stripe | Test Publishable Key | For Portal | Stripe Dashboard → Developers → API Keys (Test) | `REPLACE_ME_STRIPE_PK_TEST`<br>(copy to Vercel env) |
| Stripe | Webhook Signing Secret | For signature verification | Stripe Dashboard → Webhooks → Signing secret | `REPLACE_ME_WEBHOOK_SECRET_TEST`<br>(after creating webhook endpoint) |
| Stripe | Price ID ($299/month) | Test subscription price | Create in Stripe Dashboard → Products | `REPLACE_ME_PRICE_TEST_299`<br>(create test product with $299/month recurring price) |
| **Webflow CTA** | | | | |
| Webflow | Checkout Endpoint URL | Edge Function URL | Embed code | `REPLACE_ME_SUPABASE_URL/functions/v1/create-checkout`<br>(no secrets in Webflow) |
| Webflow | Success URL | Redirect after checkout | Embed code | `REPLACE_ME_STAGING_PORTAL_URL/dashboard` |
| Webflow | Cancel URL | Redirect if canceled | Embed code | `REPLACE_ME_STAGING_PORTAL_URL` or `https://mystoragevalet.com` |

---

## Optional: SendGrid (Not Required for Gate 5)

**Note:** Gate 5 uses Supabase built-in email. SendGrid can be added later for production if needed.

| System | Variable | Purpose | Where Set | Value/Placeholder |
|--------|----------|---------|-----------|-------------------|
| Supabase | `SENDGRID_API_KEY` | (Optional) Custom SMTP | Supabase Dashboard → Settings → Auth → SMTP | *(commented out; not blocking)* |
| Supabase | `SENDGRID_FROM_EMAIL` | (Optional) Sender address | Supabase Dashboard → Settings → Auth → SMTP | *(commented out; not blocking)* |

---

## How to Obtain Values

### Supabase Keys
1. Go to Supabase Dashboard → Your Project
2. Navigate to Settings → API
3. Copy:
   - Project URL → `SUPABASE_URL`
   - anon public key → `VITE_SUPABASE_ANON_KEY`
   - service_role secret → `SUPABASE_SERVICE_ROLE_KEY` (**never expose client-side**)

### Stripe TEST Mode Keys
1. Go to Stripe Dashboard → Developers → API Keys
2. Toggle to **Test Mode** (top right)
3. Copy:
   - Publishable key → `VITE_STRIPE_PUBLISHABLE_KEY`
   - Secret key → `STRIPE_SECRET_KEY`

### Stripe TEST Price ID ($299/month)
1. Go to Stripe Dashboard → Products
2. Ensure **Test Mode** is active
3. Create new product:
   - Name: "Storage Valet Premium (Test)"
   - Pricing: $299/month, recurring, monthly
4. Copy Price ID → `STRIPE_PRICE_PREMIUM299` (e.g., `price_test_1ABC...`)

### Stripe Webhook Secret
1. Go to Stripe Dashboard → Developers → Webhooks
2. Ensure **Test Mode** is active
3. Add endpoint: `https://REPLACE_ME_SUPABASE_URL.supabase.co/functions/v1/stripe-webhook`
4. Select events:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Copy Signing secret → `STRIPE_WEBHOOK_SECRET`

### Vercel Staging URL
1. Deploy sv-portal to Vercel (will generate staging URL automatically)
2. Copy deployment URL → `APP_URL` / `VITE_APP_URL`
3. Example: `https://sv-portal-git-main-yourorg.vercel.app`

---

## Checklist Before Deployment

- [ ] All `REPLACE_ME_*` placeholders replaced with actual values
- [ ] Stripe TEST mode active (not live mode)
- [ ] Supabase service_role key secured (never in portal or Webflow)
- [ ] Portal `.env.example` contains only public keys
- [ ] Webhook endpoint created in Stripe (test mode) pointing to Edge Function
- [ ] Vercel project created for sv-portal

---

**Next Step:** Fill in placeholders, then proceed to staging deployment scripts.
