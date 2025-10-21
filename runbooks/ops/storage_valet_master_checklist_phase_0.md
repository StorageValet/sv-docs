# Storage Valet — Master Checklist (Phase 0.7 → Launch)

> **Status:** Draft v1 — Ready for ongoing updates in `sv-docs/runbooks/`
> **Purpose:** Single source of truth to track every major technical and operational task from Phase 0.7 through final public launch.

---

## Legend
☐ = To do  |  🟡 = In progress  |  ✅ = Complete

**Owner Codes:**  
Z = Zach (CEO / PM)  
C = Claude Code (Dev / Terminal)  
G = ChatGPT (CTO / Systems Architect)  
E = External consultant / contractor

---

## Phase 0.7 — Security, Branding & UI Polish

### 🔐 Security & Secrets
- [ ] Rotate Stripe **Webhook Secret** (Dashboard → roll → Supabase `secrets set`)  
  **Owner:** C  |  **Repo:** `sv-edge`  |  **Runbook:** `secret-rotation.sh`
- [ ] Rotate **Stripe Secret Key** (if exposed)  
  **Owner:** C  |  **Repo:** `sv-edge`
- [ ] Rotate **Supabase Service Role** key  
  **Owner:** C  |  **Repo:** `sv-db`
- [ ] Confirm webhook redeployed and test event 200 OK  
  **Owner:** C  |  **Repo:** `sv-edge`

### ✉️ Email Branding (SMTP Setup)
- [ ] Choose provider (**Postmark**, **Resend**, or **SES**)  
  **Owner:** Z  |  **Runbook:** `email-branding-setup.md`
- [ ] Add DNS records (SPF, DKIM, DMARC) for `mystoragevalet.com`  
  **Owner:** Z  |  **System:** Google Domains / Cloudflare
- [ ] Add SMTP secrets in Supabase  
  **Owner:** C  |  **Repo:** `sv-edge`
- [ ] Test branded sender `noreply@mystoragevalet.com` (magic link <60s)  
  **Owner:** Z

### 🎨 Portal UI / UX Polish
- [ ] Audit color palette (Oxford Blue, Teal, Cream, Neutral Gray)  
  **Owner:** Z  |  **Repo:** `sv-portal`
- [ ] Verify copy follows approved “as needed” tone  
  **Owner:** Z  |  **Repo:** `sv-portal`
- [ ] `/account` → Confirm Hosted **Stripe Customer Portal** link active  
  **Owner:** G  |  **Repo:** `sv-portal`
- [ ] Validate portal limits (≤4 routes, ≤12 src files, ≤6 deps, core <500 LOC)  
  **Owner:** G  |  **Repo:** `sv-portal`
- [ ] Add soft shadows, padding, and hover states for polish  
  **Owner:** Z  |  **Repo:** `sv-portal`

### ⚙️ Stability & Operations
- [ ] Add light logging (webhook insert success / duplicate skip)  
  **Owner:** C  |  **Repo:** `sv-edge`
- [ ] Pin dependency versions (Stripe SDK, Postgres client)  
  **Owner:** C  |  **Repo:** `sv-edge`
- [ ] Run smoke tests (in `runbooks/ops/`)  
  **Owner:** C  |  **Repo:** `sv-edge` + `sv-portal`
- [ ] Update Validation Checklist with Phase 0.7 results  
  **Owner:** G  |  **Repo:** `sv-docs`
- [ ] Tag all repos `phase-0.7-ready`  
  **Owner:** G  |  **Repo:** all

---

## Phase 0.8 — Pre-Launch QA & Production Switch

### 🌐 Domain & Hosting
- [ ] Connect **Webflow** marketing domain → `www.mystoragevalet.com`  
  **Owner:** Z  |  **Platform:** Webflow
- [ ] Connect **Vercel** portal subdomain → `app.mystoragevalet.com`  
  **Owner:** C  |  **Platform:** Vercel
- [ ] Add DNS records (A, CNAME, TXT) for both  
  **Owner:** Z
- [ ] Verify SSL certs auto-provisioned and active  
  **Owner:** C

### 💳 Stripe (Production Mode)
- [ ] Switch to **live mode** in Stripe  
  **Owner:** C
- [ ] Replace `sk_test_` and `whsec_test_` with live keys in Supabase  
  **Owner:** C
- [ ] Redeploy `stripe-webhook` and confirm production event 200 OK  
  **Owner:** C

### 🧾 Final Validation & Docs
- [ ] Complete Phase 0.8 validation checklist  
  **Owner:** G  |  **Repo:** `sv-docs`
- [ ] Prepare Launch Runbook (checklist, rollback plan, comms outline)  
  **Owner:** G  |  **File:** `runbooks/ops/launch-plan.md`
- [ ] Internal “Day 0” simulation (register, pay, schedule pickup)  
  **Owner:** Z + C

---

## Phase 1.0 — Go-Live & Monitoring

### 🚀 Launch Day
- [ ] Announce “Storage Valet is live” on website & socials  
  **Owner:** Z  |  **Platform:** Webflow / IG / LinkedIn
- [ ] Activate production Stripe plan for first customer  
  **Owner:** Z
- [ ] Verify first webhook → DB insert → Dashboard entry  
  **Owner:** C

### 🩺 Post-Launch Stability
- [ ] Monitor Supabase logs for webhook errors  
  **Owner:** C  |  **Frequency:** Daily (first 7 days)
- [ ] Monitor Stripe dashboard for failed payments  
  **Owner:** Z
- [ ] Check email deliverability reports (Postmark/Resend analytics)  
  **Owner:** Z

### 🗂️ Continuous Improvement
- [ ] Document lessons learned from first 10 users  
  **Owner:** Z  |  **Repo:** `sv-docs/runbooks/`
- [ ] Plan Phase 1.1 improvements (after data collection)  
  **Owner:** G + Z

---

## Summary Snapshot
| Phase | Focus | Status | Next Milestone |
|-------|--------|---------|----------------|
| 0.6 | System readiness, consolidation | ✅ Complete | Verified 2025‑10‑13 |
| 0.7 | Secrets, branding, UI polish | ☐ In progress | Tag `phase-0.7-ready` |
| 0.8 | Production prep & QA | ☐ Pending | Launch dry run |
| 1.0 | Public launch | ☐ Pending | First 10 users + feedback |

---

**Reminder:**  All progress updates should be committed to `sv-docs/runbooks/Storage Valet Master Checklist (Phase 0.7 → Launch).md` with timestamped commit messages like:
> `docs: update Phase 0.7 checklist — rotated Stripe keys & SMTP configured (2025-10-15)`

