# LINE IN THE SAND — Go/No-Go Task List (Phase 1.0 Extension)

**STATUS**: ACTIVE — Phase-1 Go/No-Go extension
**Version**: 1.1 (Updated Oct 24)
**Date**: 2025-10-18 (Last major revision)
**Last Updated**: 2025-10-24 (Status verification)
**Supersedes**: LINE_IN_THE_SAND_Go-NoGo_v3.1.md (extends for Phase-1)

---

## Phase 0.6 Tasks (COMPLETE ✅)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| Implement `create-portal-session` Edge Function and link from `/account` | Dev | Oct 13 | YES | ✅ DONE | Verified working |
| Enforce signed-URL photo policy + Storage RLS (owner-only) | Dev | Oct 13 | YES | ✅ DONE | Verified working |
| Implement `create-checkout` Edge Function (Webflow CTA) | Dev | Oct 13 | YES | ✅ DONE | Verified working |
| Add webhook idempotency: unique `webhook_events(event_id)` with log-first | Dev | Oct 13 | YES | ✅ DONE | Verified working |
| Prove magic-link deliverability ≤120s across 5 providers | Dev | Oct 13 | YES | ✅ DONE | All <10s |
| Enforce photo validation (≤5MB; JPG/PNG/WebP; reject HEIC) | Dev | Oct 13 | YES | ✅ DONE | Verified working |
| Configure Vercel SPA rewrites and domain | DevOps | Oct 13 | YES | ✅ DONE | Verified working |
| Post-deploy smoke tests (map to checklist) | QA | Oct 13 | YES | ✅ DONE | All passed |

---

## Phase 0.6.1 Tasks (COMPLETE ✅)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| Apply Migration 0003 (physical data + QR + insurance) | Dev | Oct 17 | YES | ✅ DONE | Applied successfully |
| Build AddItemModal with multi-field validation | Dev | Oct 17 | YES | ✅ DONE | Code complete |
| Integrate insurance tracking dashboard | Dev | Oct 17 | YES | ✅ DONE | Progress bar working |
| Deploy to Vercel with cache clear | DevOps | Oct 17 | YES | ✅ DONE | Fixed Oct 18, cache cleared |
| Run E2E smoke tests (12 sections) | QA | Oct 18 | YES | ✅ DONE | Verified Oct 24 |

---

## Phase 1.0 Tasks (CODE COMPLETE ✅, TESTING PENDING ⏳)

### A. Database & Schema (✅ ALL COMPLETE Oct 18, 2025)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| Weight+Dimensions required + `cubic_feet` computed | Dev | Oct 18 | YES | ✅ DONE | Migration 0003 (Oct 17) |
| Multi-photo schema: `photo_paths text[]` with backfill | Dev | Oct 18 | YES | ✅ DONE | Migration 0004 validated Oct 18 |
| Item status enum: home / in_transit / stored | Dev | Oct 18 | YES | ✅ DONE | Migration 0004 validated Oct 18 |
| Physical lock: `physical_locked_at` + trigger | Dev | Oct 18 | YES | ✅ DONE | Trigger tested & working Oct 18 |
| Batch operations: `actions.item_ids[]` + GIN index | Dev | Oct 18 | YES | ✅ DONE | GIN index verified Oct 18 |
| Service type: rename `kind` → `service_type` with extended CHECK | Dev | Oct 18 | YES | ✅ DONE | CHECK constraint verified Oct 18 |
| Movement history: `inventory_events` table with RLS | Dev | Oct 18 | YES | ✅ DONE | RLS policies verified Oct 18 |
| Profile expansion: name, phone, address, instructions | Dev | Oct 18 | YES | ✅ DONE | All 4 columns verified Oct 18 |

**Validation Results** (Oct 18, 2025):
- ✅ All schema changes applied successfully
- ✅ All 8 performance indexes created
- ✅ RLS enabled on all tables (items, customer_profile, actions, inventory_events)
- ✅ Physical lock trigger blocks dimension edits when `physical_locked_at IS NOT NULL`
- ✅ Photo backfill completed (existing `photo_path` → `photo_paths[1]`)
- ✅ Zero data loss, backward compatible

### B. Inventory CRUD (✅ ALL COMPLETE Oct 24, 2025)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| Multi-photo upload (1–5) with add/remove | Dev | Oct 19 | YES | ✅ DONE | Implemented in AddItemModal |
| Item edit modal with physical lock enforcement | Dev | Oct 19 | YES | ✅ DONE | EditItemModal component complete |
| Item delete with confirmation | Dev | Oct 19 | YES | ✅ DONE | DeleteConfirmModal component complete |
| Update Dashboard with edit/delete buttons | Dev | Oct 19 | YES | ✅ DONE | All modals wired and deployed |

### C. Batch Operations & Service Flows (✅ ALL COMPLETE Oct 24, 2025)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| Multi-select checkboxes on Dashboard | Dev | Oct 20 | YES | ✅ DONE | Batch selection UI implemented |
| Batch pickup flow (Home items only) | Dev | Oct 20 | YES | ✅ DONE | Filters by Home status |
| Batch redelivery flow (Stored items only) | Dev | Oct 20 | YES | ✅ DONE | Filters by Stored status |
| Empty-container request flow | Dev | Oct 20 | YES | ✅ DONE | Container types + quantities working |
| Refactor Schedule page with tabs | Dev | Oct 20 | YES | ✅ DONE | Pickup / Redelivery / Containers tabs complete |

### D. Search & Filters (✅ ALL COMPLETE Oct 24, 2025)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| Debounced search bar (keyword search) | Dev | Oct 21 | YES | ✅ DONE | SearchBar component implemented |
| Status filter chips (All / Home / In-Transit / Stored) | Dev | Oct 21 | YES | ✅ DONE | FilterChips component complete |
| Category filter chips | Dev | Oct 21 | YES | ✅ DONE | Category-based filtering working |
| Grid/list view toggle with persistence | Dev | Oct 21 | YES | ✅ DONE | localStorage persistence working |

### E. Account & Profile (✅ ALL COMPLETE Oct 24, 2025)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| Profile edit form (name, phone, address, instructions) | Dev | Oct 21 | YES | ✅ DONE | ProfileEditForm component complete |
| Update Account page with editable profile | Dev | Oct 21 | YES | ✅ DONE | Read-only card replaced with editable form |
| Validation (phone format, required fields) | Dev | Oct 21 | YES | ✅ DONE | Client-side validation working |

### F. Movement History & QR (✅ ALL COMPLETE Oct 24, 2025)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| Event logging helpers (create, update, delete, schedule) | Dev | Oct 22 | YES | ✅ DONE | lib/supabase.ts helpers complete |
| ItemTimeline component (chronological event display) | Dev | Oct 22 | YES | ✅ DONE | Timeline UI component complete |
| QR code display with print/download | Dev | Oct 22 | YES | ✅ DONE | QRCodeDisplay component with print/download |
| Add `qrcode.react` dependency | Dev | Oct 22 | YES | ✅ DONE | Dependency added to package.json |

### G. Testing & Validation (⏳ PENDING — PRIMARY FOCUS FOR NEXT SESSION)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| RLS verification (cross-user isolation) | QA | Oct 23 | YES | ⏳ READY | Part of manual test script |
| Performance test (50 items <5s) | QA | Oct 23 | YES | ⏳ READY | Benchmark in test script |
| Cross-browser test (Chrome, Safari, Firefox) | QA | Oct 23 | YES | ⏳ READY | Compatibility test ready |
| Mobile responsive check | QA | Oct 23 | YES | ⏳ READY | iOS + Android testing |
| Physical lock enforcement test | QA | Oct 23 | YES | ⏳ READY | Test case prepared |
| Batch operations data integrity | QA | Oct 23 | YES | ⏳ READY | Verify item_ids[] persistence |

### H. Deployment (⏳ BLOCKED ON TESTING)

| Task | Owner | Due | Blocking? | Status | Notes |
|------|-------|-----|-----------|--------|-------|
| Apply Migration 0004 to Supabase (staging) | DevOps | Oct 24 | YES | ✅ DONE | Applied and validated Oct 18 |
| Deploy Portal to Vercel (staging) | DevOps | Oct 24 | YES | ✅ DONE | Deployed Oct 24, all env vars set |
| Smoke test Phase-1 features (staging) | QA | Oct 24 | YES | ⏳ READY | Manual test script available |
| Apply Migration 0004 to Supabase (production) | DevOps | Oct 25 | YES | ⏳ BLOCKED | Blocked on testing completion |
| Deploy Portal to Vercel (production) | DevOps | Oct 25 | YES | ⏳ BLOCKED | Blocked on testing completion |
| Smoke test Phase-1 features (production) | QA | Oct 25 | YES | ⏳ BLOCKED | Blocked on testing completion |
| Tag repos `phase-1.0-complete` | DevOps | Oct 25 | YES | ⏳ BLOCKED | After go-live decision |

---

## Blocking Issues (Current)

### 🔴 CRITICAL
None

### 🟡 HIGH PRIORITY
None

### 🟢 MEDIUM PRIORITY
None

**Previous Issues (RESOLVED)**:
- ✅ Vercel deployment showing old code (Phase 0.6.1) — **RESOLVED Oct 18**
  - Fixed via manual redeploy with cache clear
- ✅ Migration 0004 not applied (Sprint 0) — **RESOLVED Oct 18**
  - Applied to staging and validated successfully

---

## Decision Criteria

**Phase 1.0 Launch Requirements** (all must be YES):
- [ ] All Phase-0.6 gates still passing ✅
- [ ] All Phase-0.6.1 features deployed and tested
- [ ] Migration 0004 applied successfully (no RLS breakage)
- [ ] All Phase-1.0 CRUD operations working under RLS
- [ ] Batch operations persisting correctly
- [ ] Physical lock enforcement working (UI + trigger)
- [ ] Search/filter performance acceptable
- [ ] Profile editing working
- [ ] Movement history logging automatically
- [ ] QR codes printable/downloadable
- [ ] Performance: 50 items <5s
- [ ] Security audit passed (RLS, signed URLs)
- [ ] Cross-browser compatibility verified
- [ ] Mobile responsive

**GO / NO-GO Decision Point**: Oct 25, 2025

---

## Escalation Path

**If blocking issue cannot be resolved**:
1. **Immediate**: Notify project lead
2. **Within 4 hours**: Escalate to CTO
3. **Within 8 hours**: Decide: delay launch OR ship without blocked feature

**Non-negotiable constraints** (never compromise):
- RLS security (zero cross-tenant access)
- Stripe Hosted flows (no custom card UI)
- Photo privacy (signed URLs only)
- Webhook idempotency (no duplicate processing)

---

## Notes

- All v3.1 architectural constraints remain in force
- Phase-1 extends functionality, not architecture
- Any discrepancy: defer to SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md
- Phase-1 addenda take precedence for new features only
