# Storage Valet — Phase 0.6 Checkpoint (v3.1)

> **Status:** ✅ Phase 0.6 VERIFIED & COMPLETE  
> **Date:** 2025‑10‑13 (ET)  
> **Scope Source of Truth:** SV v3.1 (single $299 plan; Webflow marketing‑only; Vite+React+TS portal — 4 routes; Supabase Auth/Postgres+RLS/Storage/Edge; Stripe Hosted Checkout + Hosted Customer Portal; caps: `src ≤ 12 files`, `deps ≤ 6`, core `< 500 LOC`; “as needed” language; no Dropbox paths.)

---

## 0) Document Outline (for quick scan)
1. Executive Snapshot
2. What Changed Since Last Checkpoint
3. System Architecture (v3.1 conformance)
4. Proof of Readiness (Gates 1–5 results)
5. Known Deviations (with justification)
6. Risks & Watch‑outs (with mitigations)
7. Phase 0.7 Plan (linear checklist)
8. Acceptance Criteria (Phase 0.7 → Go/No‑Go)
9. Artifacts & Repos (links & tag baseline)
10. Appendix A: Current Config / Env keys (redacted)

---

## 1) Executive Snapshot
- **Outcome:** Phase 0.6 passed. Gate‑5 (email deliverability) validated across **Gmail (4s), Outlook (4s), iCloud (8s), Yahoo (10s), Proton (6s)**.
- **Repos:** `sv-db`, `sv-edge`, `sv-portal`, `sv-docs` created/pushed under **StorageValet** (private); all tagged **`phase-0.6-consolidated`**.
- **Workspace:** `~/code` clean; planning folder archived; filenames normalized (ASCII‑only) to prevent script/CI friction.
- **Portal:** Vercel preview live; 4 routes present (`/login`, `/dashboard`, `/schedule`, `/account`). Stripe Hosted Checkout + Hosted Customer Portal wired.
- **Webhooks:** Signature verification + idempotency proven; duplicates safely ignored.

**Next milestone:** Phase 0.7 (security hardening + branded email + UI polish + final readiness checks).

---

## 2) What Changed Since Last Checkpoint
- **Webhook implementation finalized:**
  - Moved to **`constructEventAsync`** (Edge/Deno requirement).
  - Ensured **raw body** (`req.text()`) before verification.
  - **Idempotency** via unique index on `billing.webhook_events(event_id)` and `INSERT … ON CONFLICT DO NOTHING`.
  - **Direct Postgres client** used server‑side for `billing.*` writes to avoid PostgREST schema exposure limits. Connection opened/closed per request using pooled URL.
- **Operational hygiene:**
  - Consolidated documentation into `sv-docs`; archived pre‑repo planning.
  - Removed emojis from filenames; added pointers from code repos to docs.
  - Tagged baseline `phase-0.6-consolidated` across all repos.

---

## 3) System Architecture — v3.1 Conformance
- **Marketing site:** Webflow (marketing‑only).  
- **Portal:** Vite+React+TypeScript (4 routes only).  
- **Backend:** Supabase (Auth, Postgres with RLS, Storage, Edge Functions).  
- **Payments:** Stripe **Hosted Checkout** (single $299 plan) + **Hosted Customer Portal**.  
- **Constraints:** `src ≤ 12 files`, `deps ≤ 6`, core `< 500 LOC` — currently within limits.  
- **Language & copy:** “as needed” phrasing; premium tone; no “on‑demand” language.

---

## 4) Proof of Readiness — Gates 1–5
- **Gate 1: Repo & Build hygiene** — ✅ Repos structured; build passes; env examples present.
- **Gate 2: Auth & RLS** — ✅ Basic RLS policies set; Storage bucket RLS updated for item photos.
- **Gate 3: Hosted Checkout flow** — ✅ Creates subscription; redirects; post‑checkout return works.
- **Gate 4: Webhook idempotency** — ✅ First insert succeeds; duplicate deliveries rejected; logs confirm.
- **Gate 5: Email deliverability ≤120s** — ✅ Gmail 4s; Outlook 4s; iCloud 8s; Yahoo 10s; Proton 6s.

---

## 5) Known Deviations (with justification)
1. **Webhook writes via direct Postgres client (Edge) instead of `supabase-js`** for `billing.*`:
   - *Why:* PostgREST by default exposes `public`/`graphql_public`, not `billing`. Direct PG ensures minimal surface + reliable writes.
   - *Risk:* Connection management & pool usage.
   - *Mitigation:* Use pooled URL; open/close per request; keep operation short & idempotent.
2. **Webhook endpoint JWT disabled** (Stripe signature only):
   - *Why:* Stripe can’t send JWT; signature verification is the correct auth guard here.
   - *Risk:* Public endpoint exposure.
   - *Mitigation:* Verify signature first; early 400 on mismatch; no side effects pre‑verify.

> Both deviations are within v3.1 scope and are implementation details, not scope creep.

---

## 6) Risks & Watch‑outs → Mitigations
- **R‑1: Secret exposure during earlier debugging**  
  *Mitigation:* Rotate Stripe webhook secret & any service keys; re‑deploy; add a rotation runbook.

- **R‑2: Email sender domain still generic (Supabase relay)**  
  *Mitigation:* Configure branded SMTP (Postmark/Resend/SES), publish SPF/DKIM/DMARC; smoke test one magic link.

- **R‑3: Dependency drift**  
  *Mitigation:* Pin Stripe SDK & postgres client versions in Edge functions, record in `sv-edge/README.md`.

- **R‑4: Future edits re‑introduce JSON parsing before signature verify**  
  *Mitigation:* Add a guard comment + unit test stub (where feasible) asserting `req.text()` → `constructEventAsync` order.

- **R‑5: RLS coverage gaps for new tables**  
  *Mitigation:* Add a short RLS checklist to every DB migration; smoke tests for read/write with anon vs. service role.

---

## 7) Phase 0.7 — Linear Checklist (owner • status)
**A. Security & Keys**
1. Rotate **Stripe Webhook Secret** (Dashboard → roll) → set in Supabase secrets → redeploy `stripe-webhook`.  
   *Owner:* Claude Code • *Status:* ◻︎ To‑do
2. Rotate **Stripe Secret Key** (test) if ever exposed in logs.  
   *Owner:* Claude Code • *Status:* ◻︎ To‑do
3. Rotate **Supabase Service Role** key if copied to transcripts.  
   *Owner:* Claude Code • *Status:* ◻︎ To‑do

**B. Branded Email**
4. Choose provider (**Postmark** recommended for transactional).  
   *Owner:* Zach • *Status:* ◻︎ To‑do
5. Add DNS: SPF, DKIM, DMARC for `mystoragevalet.com`.  
   *Owner:* Zach • *Status:* ◻︎ To‑do
6. Set Supabase SMTP secrets (`SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`, `SMTP_SENDER_EMAIL=noreply@mystoragevalet.com`, `SMTP_SENDER_NAME="Storage Valet"`).  
   *Owner:* Claude Code • *Status:* ◻︎ To‑do
7. Send **1× magic link** to Gmail to confirm branded sender/inbox placement.  
   *Owner:* Zach • *Status:* ◻︎ To‑do

**C. Portal UI/UX polish (within v3.1)**
8. Visual audit vs. brand palette (Oxford Blue, Teal, neutrals).  
   *Owner:* Zach • *Status:* ◻︎ To‑do
9. Copy audit for “as needed” language (no “on‑demand”).  
   *Owner:* Zach • *Status:* ◻︎ To‑do
10. `/account` → ensure **Hosted Customer Portal** link labeled clearly; no custom billing UI.  
   *Owner:* Me • *Status:* ◻︎ To‑do
11. Ensure **route cap (4)** and **file/dep/LOC caps** are still met after edits.  
   *Owner:* Me • *Status:* ◻︎ To‑do

**D. Stability & Ops**
12. Add minimal **logging** statements (info level) around webhook insert success/duplicate; avoid PII.  
   *Owner:* Me • *Status:* ◻︎ To‑do
13. Confirm **Edge function versions pinned**; document in `sv-edge/README.md`.  
   *Owner:* Me • *Status:* ◻︎ To‑do
14. Add a **smoke test** script (already present) to `sv-docs/runbooks` and run once.  
   *Owner:* Claude Code • *Status:* ◻︎ To‑do

**E. Finalize Phase 0.7**
15. Update `FINAL_VALIDATION_CHECKLIST_v3.1.md` with Phase 0.7 outcomes.  
   *Owner:* Me • *Status:* ◻︎ To‑do
16. Tag repos `phase-0.7-ready` and compile a short release note in `sv-docs`.  
   *Owner:* Me • *Status:* ◻︎ To‑do

---

## 8) Acceptance Criteria — Phase 0.7 → Go/No‑Go
- **Secrets rotated** and verified (Stripe test event succeeds with new `whsec_…`).
- **Branded SMTP** active: magic link arrives from `noreply@mystoragevalet.com` in Inbox within ≤60s (Gmail proof acceptable for 0.7).
- **Portal conformance:** 4 routes only; caps respected; hosted Stripe links correct; copy/branding matches v3.1.
- **Ops baseline:** Minimal logs present; dependency versions pinned and documented; smoke tests pass.

Go/No‑Go Rule: all four criteria must be green to declare Phase 0.7 complete.

---

## 9) Artifacts & Repos (baseline)
- **GitHub (private):** `StorageValet/sv-docs`, `sv-db`, `sv-edge`, `sv-portal`  
- **Tag:** `phase-0.6-consolidated` (locked baseline)  
- **Docs:** Gate‑5 results table recorded in Implementation Plan; Validation Checklist marked pass.

---

## 10) Appendix A — Current Config (redacted/structure)
- **Supabase:** `PROJECT_REF=gmjucacmbrumncfnnhua`  
- **Edge Functions:** `stripe-webhook` (public/verify Stripe sigs), `create-checkout`, `create-portal-session`, `storage`  
- **Email:** Supabase relay (staging) → **to be replaced** by branded SMTP in Phase 0.7  
- **Stripe:** Hosted Checkout for **$299 plan**; Hosted Customer Portal enabled

---

# Project Tracker — Linear View

### Phase 0.6 (Complete)
- [x] Repo hygiene & limits enforced (routes/files/deps/LOC)
- [x] Hosted Checkout wiring & return flow
- [x] Webhook: signature verify + idempotency (unique index)
- [x] Deliverability Gate‑5 across 5 providers
- [x] Consolidation to 4 repos; planning archived; filenames sanitized

### Phase 0.6.1 — Item Creation (Code Complete, Deployment Blocked)
- [x] Migration 0003: Required fields (value, weight, dimensions) + insurance tracking
- [x] Auto-generated QR codes (format: SV-YYYY-XXXXXX)
- [x] AddItemModal component with validation (photo ≤5MB, all required fields)
- [x] Dashboard integration: Insurance progress bar + FAB button
- [x] ItemCard displays QR, cubic feet, weight, value
- [x] Performance indexes (user_created_at, tags_gin, details_gin)
- [x] Storage Valet brand colors applied (Velvet Night, Deep Harbor, etc.)
- [x] E2E smoke test checklist created (12 test sections)
- [ ] **BLOCKER:** Vercel deployment showing old code (manual redeploy needed)
- [ ] End-to-end testing (pending deployment fix)
- [ ] Tag repos `phase-0.6.1-item-creation`

**Status:** All code committed and pushed. Vercel deployment issue preventing user testing.
**See:** `runbooks/PHASE_0.6.1_ITEM_CREATION_STATUS.md` for complete details and fix instructions.

### Phase 0.7 (Pending)
- [ ] Rotate Stripe **webhook** secret & redeploy
- [ ] (If needed) Rotate Stripe **secret key** / Supabase **service role**
- [ ] Configure **branded SMTP** (Postmark/Resend/SES) & DNS (SPF/DKIM/DMARC)
- [ ] Magic‑link smoke test from `noreply@mystoragevalet.com`
- [ ] Visual/copy audit against v3.1 brand rules
- [ ] Confirm **Hosted Customer Portal** link & no custom billing UI
- [ ] Ensure route/file/dep/LOC caps still satisfied
- [ ] Pin dependency versions; add lightweight logs; run smoke tests
- [ ] Update Validation Checklist; tag `phase-0.7-ready`

### Phase 0.8 (Release)
- [ ] Custom domain bindings (Webflow + Vercel)  
- [ ] Production Stripe keys & live mode switch (after final test)  
- [ ] Launch runbook: comms, rollback notes, and first‑customer flow rehearsal

---

## Notes for the Team
- We are **not** adding features beyond v3.1. Any ambiguity resolves in favor of v3.1 constraints.
- Keep logs sparse and non‑PII; lean on Stripe’s event viewer for deep dives.
- Treat `sv-docs` as the **only** place to update specs/checklists; do not fork or duplicate documentation.

