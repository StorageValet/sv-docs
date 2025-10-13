
STATUS: REPLACE — Supersedes prior versions. Source of truth: SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md.
Version: v3.1 • Date: 2025-10-11
Title: Storage Valet — Context & Requirements (Short)

## Positioning & Promise
- Premium, concierge-style storage focused on **trust**, **reliability**, and **time saved**.  
- Customer language uses **“as needed”** scheduling; never “on-demand”.

## Pricing & Billing
- **Single tier $299/month**.  
- Setup fee **configurable in DB**; **disabled by default**.  
- Billing UX: **Stripe Hosted Checkout** (subscription creation) + **Hosted Customer Portal** (self-serve billing).

## Product Surfaces
- **Webflow** for marketing only (public). CTAs hand off to `create-checkout`.  
- **Portal**: **Vite + React + TypeScript** with exactly **4 routes**: `/login`, `/dashboard`, `/schedule`, `/account`.

## Data & Security
- **Supabase** Auth + Postgres with **Row-Level Security** on all customer data.  
- **Storage**: private bucket for item photos; render via **time-limited signed URLs**.  
- **Edge Functions** used **only** where secrets are required (Stripe).

## Operations
- **Retool** for staff/admin (webhook viewer, QR printing).  
- No custom admin unless explicitly added later.

## Engineering Constraints
- ≤ **12 files**, **6 dependencies**, **<500 LOC** core.  
- No custom payment forms; no extra routes; no mock layers.  
- Any contradiction defers to `SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md`.
