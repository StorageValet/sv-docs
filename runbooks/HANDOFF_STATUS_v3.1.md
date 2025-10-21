# Storage Valet v3.1 — Handoff Status & Checkpoint

**Date:** 2025-10-11
**Status:** ✅ CODE COMPLETE | ⏳ AWAITING SECRETS FOR STAGING DEPLOYMENT
**Phase:** Ready for Phase 0.6 Gate 5 validation

---

## Current Phase 0.6 Gate Status

| Gate | Status | Implementation | Notes |
|------|--------|---------------|-------|
| **1. Customer Portal Session** | ✅ READY | Service role auth; billing.customers lookup | Code complete; needs staging test |
| **2. Storage RLS + Signed URLs** | ✅ READY | split_part policies; 1h signed URLs | Code complete; needs bucket creation |
| **3. Checkout Function** | ✅ READY | No client secrets; metadata support | Code complete; needs staging test |
| **4. Webhook Idempotency** | ✅ READY | Unique index + log-first pattern | Code complete; needs staging test |
| **5. Magic Link ≤120s** | ⏳ PENDING | Supabase built-in email | **BLOCKING: Requires live test across 5 providers** |
| **6. Photo Validation** | ✅ READY | Client: ≤5MB, JPG/PNG/WebP; HEIC rejected | Code complete; needs upload test |

**Summary:** 5/6 gates code-complete. Gate 5 requires staging deployment + live email provider testing.

---

## Repository Status

### sv-db (`~/code/sv-db`)
- **Migrations:** 2 files
  - `0001_init.sql` — Core schema + RLS + unique index for idempotency
  - `0002_storage_rls.sql` — Storage bucket + split_part policies
- **Seeds:** 1 file
  - `config_pricing.sql` — Single-tier $299/month + config tables
- **Git commits:** 3 (initial + 2 fixes)

### sv-edge (`~/code/sv-edge`)
- **Edge Functions:** 3 files
  - `create-portal-session/index.ts` — Stripe Customer Portal session generator
  - `create-checkout/index.ts` — Stripe Checkout Session creator (Webflow CTA)
  - `stripe-webhook/index.ts` — Idempotent webhook handler with signature verification
- **Git commits:** 2 (initial + auth fixes)

### sv-portal (`~/code/sv-portal`)
- **Files in src/:** 11 (≤12 ✓)
- **Production deps:** 6 (exact match ✓)
- **Routes:** 4 (`/login`, `/dashboard`, `/schedule`, `/account`) ✓
- **Core LOC:** ~450 (<500 ✓)
- **Git commits:** 3 (initial + env updates)

**Dependencies (6):**
1. @supabase/supabase-js
2. @tanstack/react-query
3. react
4. react-dom
5. react-router-dom
6. tailwindcss

**Routes (4):**
- `/login` — Magic link auth
- `/dashboard` — Items list with signed-URL photos
- `/schedule` — Pickup/delivery scheduling (48h minimum)
- `/account` — Profile + Stripe Customer Portal

---

## Constraint Compliance

| Constraint | Required | Actual | Status |
|-----------|----------|--------|--------|
| Portal files in src/ | ≤12 | 11 | ✅ PASS |
| Production deps | 6 | 6 | ✅ PASS |
| Routes | 4 | 4 | ✅ PASS |
| Pricing tiers | 1 ($299) | 1 | ✅ PASS |
| RLS policies | split_part | ✓ | ✅ PASS |
| Webhook idempotency | Unique index | ✓ | ✅ PASS |
| Service role auth | Edge Functions | ✓ | ✅ PASS |
| Language | "as needed" | ✓ | ✅ PASS |

---

## Required Secrets/Environment Variables (PENDING)

**Status:** All placeholders (`REPLACE_ME_*`) must be filled before deployment.

### Supabase Project
- `PROJECT_REF` — For `supabase link` command

### Supabase Edge Secrets (6)
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `STRIPE_SECRET_KEY` (TEST mode)
- `STRIPE_WEBHOOK_SECRET` (TEST mode)
- `STRIPE_PRICE_PREMIUM299` (TEST mode)
- `APP_URL`

### Vercel Portal Environment Variables (4)
- `VITE_SUPABASE_URL` (public)
- `VITE_SUPABASE_ANON_KEY` (public)
- `VITE_APP_URL` (public)
- `VITE_STRIPE_PUBLISHABLE_KEY` (TEST mode, public)

### Vercel Project
- `VERCEL_PROJECT_NAME` — For CLI commands

### Stripe TEST Mode (to be created)
- Test Product: "Storage Valet Premium (Test)" @ $299/month
- Test Webhook Endpoint → `{SUPABASE_URL}/functions/v1/stripe-webhook`

---

## Documentation Files Ready

| File | Location | Purpose |
|------|----------|---------|
| `secrets_needed.md` | `~/code/` | Master reference for all secrets/env vars |
| `set_supabase_secrets_staging.sh` | `~/code/` | Executable script to set Edge secrets |
| `set_vercel_env_staging.sh` | `~/code/` | Executable script to set Vercel env vars |
| `.env.example` | `~/code/sv-portal/` | Template with public keys only |
| `stripe_test_setup.md` | `~/code/` | Stripe TEST mode configuration checklist |
| `smoke-tests.sh` | `~/code/` | Automated smoke tests (post-deployment) |
| `DEPLOYMENT_GUIDE_v3.1.md` | `~/code/` | Full deployment instructions |
| `PHASE_0.6_GATES_v3.1.md` | `~/code/` | Gate implementation specs + validation |

---

## Exact Command Sequence (AFTER PLACEHOLDER_FORM.md PROVIDED)

**Prerequisites:** User provides filled `PLACEHOLDER_FORM.md` with all `Needed value` columns completed.

### Step 1: Apply Values to Scripts
```bash
# Update placeholders in:
# - ~/code/set_supabase_secrets_staging.sh
# - ~/code/set_vercel_env_staging.sh
# - Create ~/code/sv-portal/.env from .env.example with public values
```

### Step 2: Deploy Database Migrations
```bash
cd ~/code/sv-db
supabase link --project-ref {PROJECT_REF}
supabase db push
# Output: List of applied migrations (0001_init.sql, 0002_storage_rls.sql)
```

### Step 3: Set Edge Secrets & Deploy Functions
```bash
cd ~/code
./set_supabase_secrets_staging.sh
# Verify: supabase secrets list

cd ~/code/sv-edge
supabase functions deploy create-checkout
supabase functions deploy create-portal-session
supabase functions deploy stripe-webhook
# Output: HTTPS URLs for each function
```

### Step 4: Deploy Portal to Vercel
```bash
cd ~/code/sv-portal
vercel link  # Link to Vercel project
../set_vercel_env_staging.sh  # Set env vars
vercel --prod  # Deploy to production/staging
# Output: Staging URL (e.g., https://sv-portal-git-main-yourorg.vercel.app)
```

### Step 5: Configure Stripe Webhook
```bash
# Manual step in Stripe Dashboard:
# 1. Go to Developers → Webhooks (TEST mode)
# 2. Add endpoint: {SUPABASE_URL}/functions/v1/stripe-webhook
# 3. Select events: checkout.session.completed, customer.subscription.*, invoice.payment_*
# 4. Copy signing secret → update Supabase Edge secrets:
supabase secrets set STRIPE_WEBHOOK_SECRET="{copied_whsec_value}"
```

### Step 6: Test Webhook Idempotency (Gate 4)
```bash
# Option A: Stripe CLI
stripe trigger checkout.session.completed
# Copy event ID from output, then resend:
stripe events resend evt_test_abc123...

# Check logs:
supabase functions logs stripe-webhook --tail
# Expected: "Duplicate event evt_test_abc123..., skipping"

# Verify DB:
# SELECT COUNT(*) FROM billing.webhook_events WHERE event_id = 'evt_test_abc123...';
# Should return 1
```

### Step 7: Run Gate 5 Email Deliverability Test
```bash
# For each provider (Gmail, Outlook, iCloud, Yahoo, Proton):
# 1. Complete test checkout with provider email
# 2. Record send timestamp
# 3. Check inbox for magic link
# 4. Record receive timestamp
# 5. Calculate duration (sec)
# 6. Verify ≤120s

# Populate table:
# | Provider | Test Email | Send Time | Receive Time | Duration | Pass/Fail |
```

### Step 8: Generate Final Report
```bash
# Output required artifacts:
# 1. Applied migrations list
# 2. Edge function URLs + env var names (redacted)
# 3. Webhook idempotency proof (SQL + logs/JSON)
# 4. Portal staging URL + Customer Portal request snippet
# 5. Gate 5 table (fully populated)
# 6. Updated Phase 0.6 PASS/FAIL table with Gate 5 marked
```

---

## Files Confirmed Present & Up-to-Date

- ✅ `~/code/secrets_needed.md`
- ✅ `~/code/set_supabase_secrets_staging.sh` (executable)
- ✅ `~/code/set_vercel_env_staging.sh` (executable)
- ✅ `~/code/sv-portal/.env.example`
- ✅ `~/code/stripe_test_setup.md`
- ✅ `~/code/PLACEHOLDER_FORM.md` (awaiting user completion)

---

## Git Status

All repos have clean working trees with latest changes committed:

**sv-db:**
- Latest commit: `54556dd` — "Add explicit unique index for webhook idempotency"

**sv-edge:**
- Latest commit: `45547d1` — "Fix: Update Edge Functions to use service role auth pattern and consistent Stripe version"

**sv-portal:**
- Latest commit: `4af9825` — "Update .env.example with staging placeholders and security notes"

---

## Next Action Required

**USER:** Complete `PLACEHOLDER_FORM.md` table by filling in all `Needed value` columns with actual secrets/keys.

**CLAUDE:** After receiving filled table, execute deployment sequence (Steps 1-8 above) and generate final report artifacts.

---

**CHECKPOINT STATUS:** ✅ READY FOR DEPLOYMENT
**BLOCKING ITEM:** PLACEHOLDER_FORM.md completion
**ETA TO GATE 5:** ~15-30 minutes after secrets provided (deployment + testing)
