
STATUS: REPLACE — Supersedes prior versions. Source of truth: SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md.
Version: v3.1 • Date: 2025-10-11
Title: Storage Valet — Final Validation Checklist (Go/No-Go)

## Phase 0.6 — Hard Gates (all required)
| Gate                                                                 | PASS ☑ / FAIL ☐ | Notes |
|----------------------------------------------------------------------|------------------|-------|
| 1) `create-portal-session` Edge Function opens Stripe **Hosted Customer Portal** from `/account` | ☑ / ☐ | Verified 2025-10-13 |
| 2) **Signed-URL** photo policy + **Storage RLS**: owner-only access; signed URLs ~1h expiry | ☑ / ☐ | Verified 2025-10-13 |
| 3) `create-checkout` Edge Function callable from **Webflow CTA** (no secrets in Webflow) | ☑ / ☐ | Verified 2025-10-13 |
| 4) **Webhook idempotency**: unique `webhook_events(event_id)`, log-first, duplicate short-circuit | ☑ / ☐ | Verified 2025-10-13 |
| 5) **Magic-link deliverability** ≤120s across Gmail/Outlook/iCloud/Yahoo/Proton | ☑ / ☐ | Gmail 4s, Outlook 4s, iCloud 8s, Yahoo 10s, Proton 6s |
| 6) **Photo validation**: ≤5MB; JPG/PNG/WebP; HEIC rejected by default | ☑ / ☐ | Implemented in AddItemModal |

## Phase 0.6.1 — Item Creation Feature (Code Complete)
| Item                                                                 | PASS ☐ / FAIL ☐ | Notes |
|----------------------------------------------------------------------|------------------|-------|
| 1) **Migration 0003** applied: required fields (value, weight, dims) + insurance tracking | ☑ / ☐ | Applied 2025-10-17 |
| 2) **QR code auto-generation**: format SV-YYYY-XXXXXX, unique, sequential | ☑ / ☐ | Tested: SV-2025-000001, SV-2025-000002 |
| 3) **AddItemModal component**: photo upload + all required field validation | ☑ / ☐ | Built, TypeScript compiles |
| 4) **Dashboard integration**: insurance bar + FAB button + modal | ☑ / ☐ | Code complete, not yet deployed |
| 5) **ItemCard metadata display**: QR, cubic feet, weight, value | ☑ / ☐ | Code complete, not yet deployed |
| 6) **Performance indexes**: user_created_at, tags_gin, details_gin | ☑ / ☐ | Applied to database |
| 7) **Brand colors applied**: Velvet Night, Deep Harbor, Chalk Linen, etc. | ☑ / ☐ | Tailwind config updated |
| 8) **Insurance tracking**: $3,000 cap, progress bar, no dollar amounts shown | ☑ / ☐ | View + function created, tested |
| 9) **Vercel deployment**: latest code served in production | ☐ / ☐ | **BLOCKER:** Manual redeploy needed |
| 10) **E2E testing**: smoke test checklist (12 sections) executed | ☐ / ☐ | Pending deployment fix |

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
