
STATUS: REPLACE — Supersedes prior versions. Source of truth: SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md.
Version: v3.1 • Date: 2025-10-11
Title: Storage Valet — LINE IN THE SAND (Go/No-Go Task List)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| Implement `create-portal-session` Edge Function and link from `/account` |  |  | YES | TODO |  |
| Enforce signed-URL photo policy + Storage RLS (owner-only) |  |  | YES | TODO |  |
| Implement `create-checkout` Edge Function (Webflow CTA) |  |  | YES | TODO |  |
| Add webhook idempotency: unique `webhook_events(event_id)` with log-first |  |  | YES | TODO |  |
| Prove magic-link deliverability ≤120s across 5 providers |  |  | YES | TODO |  |
| Enforce photo validation (≤5MB; JPG/PNG/WebP; reject HEIC) |  |  | YES | TODO |  |
| Configure Vercel SPA rewrites and domain |  |  | YES | TODO |  |
| Post-deploy smoke tests (map to checklist) |  |  | YES | TODO |  |
