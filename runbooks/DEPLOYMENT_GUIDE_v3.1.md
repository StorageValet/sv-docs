# Storage Valet v3.1 — Deployment Guide

**Status:** Ready for deployment
**Date:** 2025-10-11
**Repos:** `sv-db`, `sv-edge`, `sv-portal`

---

## Prerequisites

- [ ] Supabase project created (or use existing)
- [ ] Stripe account with live/test mode configured
- [ ] Vercel account for portal hosting
- [ ] GitHub account for repo hosting
- [ ] Domain configured: `portal.mystoragevalet.com`

---

## 1. Supabase Setup

### 1.1 Apply Migrations

```bash
cd ~/code/sv-db

# Link to your Supabase project
supabase link --project-ref YOUR_PROJECT_REF

# Push migrations
supabase db push

# Apply seeds
supabase db seed
```

**Migrations applied:**
- `0001_init.sql`: Core schema (customer_profile, items, actions, billing tables) + RLS policies
- `0002_storage_rls.sql`: Storage bucket + owner-only RLS policies

### 1.2 Set Secrets (Edge Functions)

```bash
cd ~/code/sv-edge

# Set Stripe secrets
supabase secrets set STRIPE_SECRET_KEY=sk_live_xxxxx
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_xxxxx
supabase secrets set STRIPE_PRICE_PREMIUM299=price_live_xxxxx

# Set app URL (portal domain)
supabase secrets set APP_URL=https://portal.mystoragevalet.com

# Set Supabase URL and service role key (auto-set by Supabase CLI)
supabase secrets set SUPABASE_URL=https://YOUR_PROJECT.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

### 1.3 Deploy Edge Functions

```bash
cd ~/code/sv-edge

# Deploy all functions
supabase functions deploy create-checkout
supabase functions deploy create-portal-session
supabase functions deploy stripe-webhook
```

**Verify deployment:**
```bash
supabase functions list
```

---

## 2. Stripe Configuration

### 2.1 Create Product & Price

1. Go to Stripe Dashboard → Products
2. Create product: **Storage Valet Premium**
3. Add recurring price: **$299/month**
4. Copy Price ID → `price_live_xxxxx` (set in Supabase secrets above)

### 2.2 Configure Webhook

1. Go to Stripe Dashboard → Developers → Webhooks
2. Add endpoint: `https://YOUR_PROJECT.supabase.co/functions/v1/stripe-webhook`
3. Select events:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
4. Copy **Signing secret** → `whsec_xxxxx` (set in Supabase secrets above)

---

## 3. Portal Deployment (Vercel)

### 3.1 Push to GitHub

```bash
cd ~/code/sv-portal

# Add remote (if not already added)
git remote add origin git@github.com:YOUR_ORG/sv-portal.git
git push -u origin main
```

### 3.2 Import to Vercel

1. Go to Vercel Dashboard → Import Project
2. Select `sv-portal` repo from GitHub
3. Framework preset: **Vite**
4. Build command: `npm run build`
5. Output directory: `dist`

### 3.3 Set Environment Variables

Add these in Vercel → Settings → Environment Variables:

```bash
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key
VITE_APP_URL=https://portal.mystoragevalet.com
```

### 3.4 Configure SPA Rewrites

Add `vercel.json` to sv-portal root:

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/" }
  ]
}
```

Commit and push:
```bash
git add vercel.json
git commit -m "Add Vercel SPA rewrites config"
git push
```

### 3.5 Configure Domain

1. Vercel → Settings → Domains
2. Add domain: `portal.mystoragevalet.com`
3. Update DNS:
   - Type: `CNAME`
   - Name: `portal`
   - Value: `cname.vercel-dns.com`

---

## 4. Webflow Integration

### 4.1 CTA Button Setup

Add this JavaScript to Webflow CTA button:

```javascript
document.getElementById('cta-button').addEventListener('click', async () => {
  const email = document.getElementById('email-input').value; // optional

  const response = await fetch(
    'https://YOUR_PROJECT.supabase.co/functions/v1/create-checkout',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email })
    }
  );

  const { url } = await response.json();
  window.location.href = url; // Redirect to Stripe Checkout
});
```

---

## 5. Post-Deployment Verification (Phase 0.6 Gates)

### Gate 1: Customer Portal Session

```bash
# Test from portal /account page
# Click "Manage Billing" → should redirect to Stripe Customer Portal
```

**Expected:** User redirected to `https://billing.stripe.com/p/session/xxxxx`

---

### Gate 2: Storage RLS + Signed URLs

```bash
# Upload photo as User A
# Attempt to access User A's photo as User B using direct URL
# Expected: 403 Forbidden (RLS blocks cross-tenant access)

# Access via signed URL as User A
# Expected: 200 OK, image renders
```

---

### Gate 3: Checkout Function

```bash
# Test Webflow CTA or direct API call
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/create-checkout \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# Expected: { "url": "https://checkout.stripe.com/c/pay/..." }
```

---

### Gate 4: Webhook Idempotency

```bash
# Use Stripe CLI to replay same event twice
stripe trigger checkout.session.completed
stripe trigger checkout.session.completed  # Same event ID

# Check Supabase logs
supabase functions logs stripe-webhook

# Expected: Second event logs "Duplicate event {id}, skipping"
```

---

### Gate 5: Magic Link Deliverability

Test across 5 providers:
1. Gmail
2. Outlook/Hotmail
3. iCloud
4. Yahoo
5. Proton Mail

**Procedure:**
1. Sign up with each email provider
2. Trigger magic link from `/login`
3. Measure time from request to inbox receipt
4. **Success criteria:** All emails arrive within ≤120 seconds

---

### Gate 6: Photo Validation

```bash
# Test in portal Dashboard → Upload item photo

# Test 1: Upload 6MB file
# Expected: Client-side error "File size must be ≤5MB"

# Test 2: Upload HEIC file
# Expected: Client-side error "Only JPG, PNG, and WebP formats are allowed"

# Test 3: Upload 3MB JPG
# Expected: Success, photo uploaded and rendered via signed URL
```

---

## 6. Go/No-Go Checklist

| Item | Pass | Fail | Notes |
|------|------|------|-------|
| Magic links arrive ≤120s (5 providers) | ☐ | ☐ | |
| Customer Portal opens from /account | ☐ | ☐ | |
| Checkout → webhook → profile upsert (idempotent) | ☐ | ☐ | |
| Dashboard shows items with signed URL photos | ☐ | ☐ | |
| RLS blocks cross-tenant photo access | ☐ | ☐ | |
| Vercel SPA deep links work (no 404 on refresh) | ☐ | ☐ | |
| 50 items render in <5s | ☐ | ☐ | |

**Decision:** ☐ GO  ☐ NO-GO

---

## 7. Rollback Procedure

If any Go/No-Go item fails:

1. **Vercel:** Revert to previous deployment
2. **Supabase Edge:** Redeploy previous version or disable functions
3. **Stripe:** Disable webhook endpoint
4. **Webflow:** Remove CTA button integration

---

## 8. Environment Variables Summary

### Supabase Secrets
```
STRIPE_SECRET_KEY=sk_live_xxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxx
STRIPE_PRICE_PREMIUM299=price_live_xxxxx
APP_URL=https://portal.mystoragevalet.com
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_SERVICE_ROLE_KEY=xxxxx
```

### Vercel Environment Variables
```
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=xxxxx
VITE_APP_URL=https://portal.mystoragevalet.com
```

---

## 9. Monitoring & Logs

### Supabase Edge Function Logs
```bash
supabase functions logs stripe-webhook --tail
supabase functions logs create-checkout --tail
supabase functions logs create-portal-session --tail
```

### Vercel Logs
- View in Vercel Dashboard → Deployments → Logs

### Stripe Webhook Logs
- View in Stripe Dashboard → Developers → Webhooks → Endpoint Details

---

## 10. Post-Launch Tasks

- [ ] Enable SendGrid for email delivery (optional upgrade from Supabase built-in)
- [ ] Set up Retool for staff QR printing
- [ ] Configure monitoring/alerting (Sentry, LogRocket, etc.)
- [ ] Load test with 50+ items per user
- [ ] Review Supabase advisors for security/performance recommendations

---

**Deployment complete! Proceed to Phase 0.6 gate validation.**
