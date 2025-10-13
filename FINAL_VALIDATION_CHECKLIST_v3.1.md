
STATUS: REPLACE — Supersedes prior versions. Source of truth: SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md.
Version: v3.1 • Date: 2025-10-11
Title: Storage Valet — Final Validation Checklist (Go/No-Go)

## Phase 0.6 — Hard Gates (all required)
| Gate                                                                 | PASS ☐ / FAIL ☐ | Notes |
|----------------------------------------------------------------------|------------------|-------|
| 1) `create-portal-session` Edge Function opens Stripe **Hosted Customer Portal** from `/account` | ☐ / ☐ | |
| 2) **Signed-URL** photo policy + **Storage RLS**: owner-only access; signed URLs ~1h expiry | ☐ / ☐ | |
| 3) `create-checkout` Edge Function callable from **Webflow CTA** (no secrets in Webflow) | ☐ / ☐ | |
| 4) **Webhook idempotency**: unique `webhook_events(event_id)`, log-first, duplicate short-circuit | ☐ / ☐ | |
| 5) **Magic-link deliverability** ≤120s across Gmail/Outlook/iCloud/Yahoo/Proton | ☐ / ☐ | |
| 6) **Photo validation**: ≤5MB; JPG/PNG/WebP; HEIC rejected by default | ☐ / ☐ | |

## Go / No-Go (all must be green)
| Verification                                                         | PASS ☐ / FAIL ☐ | Notes |
|----------------------------------------------------------------------|------------------|-------|
| Magic links arrive ≤120s across 5 providers                          | ☐ / ☐ | |
| `/account` → Hosted Customer Portal opens via **server-generated session URL** | ☐ / ☐ | |
| Checkout → webhook → profile upsert is **idempotent** (no duplicates) | ☐ / ☐ | |
| Dashboard renders item photos via **signed URLs**; **RLS** isolation verified across accounts | ☐ / ☐ | |
| Vercel SPA deep-link routing works (no 404 on refresh)               | ☐ / ☐ | |
| 50 items render in <5s on commodity devices                          | ☐ / ☐ | |

## Decision
☐ **GO**  ☐ **NO-GO**

**Notes:**  
- If any “Hard Gate” fails → NO-GO.  
- Resolve discrepancies in favor of `SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md`.
