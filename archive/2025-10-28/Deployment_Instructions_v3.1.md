
STATUS: REPLACE — Supersedes prior versions. Source of truth: SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md.
Version: v3.1 • Date: 2025-10-11
Title: Storage Valet — Deployment Runbook (Current)

## Supabase
- Enable **RLS** on all customer-facing tables.
- Create/config `config_*` tables (pricing, schedule windows, media limits, referrals).
- **Secrets:** set Stripe keys + webhook secret.
- Deploy Edge Functions:  
  - `stripe-webhook` (verify signature, idempotency insert, profile upsert, magic link)  
  - `create-checkout` (Webflow CTA → Checkout Session; no secrets in Webflow)  
  - `create-portal-session` (user → Stripe customer → Hosted Customer Portal URL)

## Vercel
- Environment variables:  
  - `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`  
  - `VITE_STRIPE_PUBLISHABLE_KEY`  
  - `VITE_APP_URL` (portal base URL)
- Configure **SPA rewrites** so deep links don’t 404.
- Domain: point `portal.mystoragevalet.com` to Vercel.

## Stripe
- Subscribe webhook to:  
  - `checkout.session.completed`  
  - `customer.subscription.*`  
  - `invoice.payment_*`
- Verify **webhook signature**; point to Supabase Edge URL.

## Webflow
- CTA invokes **`create-checkout`** endpoint (no secrets in Webflow).
- Success redirect → `https://portal.mystoragevalet.com/` (or equivalent).

## Post-Deploy Smoke Test (map 1:1 to Validation Checklist)
- Hosted Customer Portal opens from `/account` via `create-portal-session`.
- Checkout→webhook→profile upsert hits once (**idempotent**).
- Magic links ≤120s across 5 providers.
- Photos render via **signed URLs** under **RLS** (cross-tenant blocked).
- SPA deep links OK; 50 items render <5s.

**Notes:**  
- Any contradiction defers to `SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md`.  
- Do not add routes, features, or libraries as part of deployment.
