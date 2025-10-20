# Phase 1 Launch Guide — Storage Valet Customer Portal

**Version:** 1.0
**Date:** October 20, 2025
**Status:** Phase 1 Code Complete → Testing & Deployment Phase

---

## 🎯 Quick Start

**New to this project?** Start here:
1. Read the [Executive Summary](#executive-summary) (2 minutes)
2. Review [What's Built](#whats-built-phase-1-features) (5 minutes)
3. Follow the [Critical Path](#critical-path-to-launch) (action items)

**Ready to test?** Jump to:
- [PHASE_1_MANUAL_TEST_SCRIPT.md](./runbooks/PHASE_1_MANUAL_TEST_SCRIPT.md) (90+ test cases)

**Ready to deploy?** Jump to:
- [PRODUCTION_DEPLOYMENT_CHECKLIST.md](./runbooks/PRODUCTION_DEPLOYMENT_CHECKLIST.md) (Complete deployment steps)

---

## Executive Summary

### Current Status (October 20, 2025)

**✅ Code Complete:** All Phase 1 features are implemented and committed to Git (last commit: Oct 18)

**⏳ Testing:** Not yet started (manual test script created)

**❌ Production:** Not yet deployed

**🎯 Target Launch:** November 1-5, 2025 (estimated 10-15 days from now)

### What's Next

1. **This Week (Oct 21-25):** Complete manual testing and fix bugs
2. **Next Week (Oct 28-Nov 1):** Deploy to production and launch with beta users

### Key Deliverables for Launch

| Document | Purpose | Status |
|----------|---------|--------|
| [PHASE_1_MANUAL_TEST_SCRIPT.md](./runbooks/PHASE_1_MANUAL_TEST_SCRIPT.md) | Step-by-step testing guide | ✅ Created |
| [BUG_TRACKING_TEMPLATE.md](./runbooks/BUG_TRACKING_TEMPLATE.md) | Bug documentation | ✅ Created |
| [DEPLOYMENT_STATUS_2025-10-20.md](./runbooks/DEPLOYMENT_STATUS_2025-10-20.md) | Current environment audit | ✅ Created |
| [PRODUCTION_DEPLOYMENT_CHECKLIST.md](./runbooks/PRODUCTION_DEPLOYMENT_CHECKLIST.md) | Production deployment steps | ✅ Created |
| [FINAL_VALIDATION_CHECKLIST_v3.1_PHASE1.md](./FINAL_VALIDATION_CHECKLIST_v3.1_PHASE1.md) | Go/No-Go criteria | ⏳ Needs execution |

---

## What's Built: Phase 1 Features

### ✅ Core Features (Implemented Oct 18, 2025)

**Authentication & Account:**
- Magic link login (no passwords)
- Profile editing (name, phone, address, delivery instructions)
- Stripe Customer Portal integration (manage billing)
- Subscription status display

**Item Management:**
- Create items with multi-photo upload (1-5 photos per item)
- Edit items (label, description, value, weight, dimensions, tags, photos)
- Delete items with confirmation
- Physical data lock after pickup (prevents dimension edits)
- Auto-generated QR codes (SV-YYYY-XXXXXX format)
- QR code print and download
- Item status tracking (Home / In-Transit / Stored)
- Event logging and timeline (item created, updated, deleted)

**Dashboard:**
- Grid and list view modes
- Real-time search (label, description, tags, QR code, category)
- Status filter (All / Home / In-Transit / Stored)
- Category filter (dynamic from items)
- Insurance coverage visualization ($3,000 cap)
- Multi-select for batch operations
- Responsive design (mobile & desktop)

**Batch Operations & Scheduling:**
- Batch pickup scheduling (Home items only)
- Batch redelivery scheduling (Stored items only)
- Request empty containers (bins, totes, crates)
- 48-hour minimum notice enforcement
- Service notes/special instructions

**Data & Security:**
- Row-Level Security (RLS) on all tables
- Private photo storage with 1-hour signed URLs
- Photo validation (≤5MB, JPG/PNG/WebP only)
- Cross-user data isolation
- Automatic event logging

---

## Repository Structure

```
~/code/
├── sv-portal/          # React frontend (Vite + TypeScript)
│   ├── src/
│   │   ├── components/  # 11 components (AddItemModal, EditItemModal, etc.)
│   │   ├── pages/       # 4 pages (Dashboard, Schedule, Account, Login)
│   │   └── lib/         # Supabase client + helpers
│   └── package.json     # 8 dependencies, v3.1.0
│
├── sv-db/              # Database migrations
│   ├── migrations/
│   │   ├── 0001_init.sql                        # ✅ Applied
│   │   ├── 0002_storage_rls.sql                 # ✅ Applied
│   │   ├── 0003_item_req_insurance_qr.sql       # ✅ Applied (Oct 17)
│   │   └── 0004_phase1_inventory_enhancements.sql # ⚠️ NEEDS VERIFICATION
│   └── scripts/validate_migration_0004.sh       # Validation script
│
├── sv-edge/            # Supabase Edge Functions (Deno)
│   └── functions/
│       ├── stripe-webhook/           # Webhook handler (idempotency)
│       ├── create-checkout/          # Checkout session creation
│       └── create-portal-session/    # Customer Portal access
│
└── sv-docs/            # Documentation (this folder)
    ├── PHASE_1_LAUNCH_GUIDE.md       # ← You are here
    ├── SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md # Master spec
    ├── FINAL_VALIDATION_CHECKLIST_v3.1_PHASE1.md       # Go/No-Go checklist
    ├── LINE_IN_THE_SAND_Go-NoGo_v3.1_PHASE1.md        # Task list
    └── runbooks/
        ├── PHASE_1_MANUAL_TEST_SCRIPT.md               # ← START HERE for testing
        ├── BUG_TRACKING_TEMPLATE.md                    # Bug documentation
        ├── DEPLOYMENT_STATUS_2025-10-20.md             # Current status
        └── PRODUCTION_DEPLOYMENT_CHECKLIST.md          # ← Use for deployment
```

---

## Critical Path to Launch

### 🔴 WEEK 1: Testing & Bug Fixes (Oct 21-25)

**Day 1 (Oct 21): Environment Verification**
- [ ] Verify current deployments (Vercel, Supabase, Stripe)
- [ ] Update [DEPLOYMENT_STATUS](./runbooks/DEPLOYMENT_STATUS_2025-10-20.md) with findings
- [ ] Apply Migration 0004 to staging if not already done
- [ ] Redeploy sv-portal to Vercel with cache clear
- [ ] Smoke test: Can you log in and see Phase 1 features?

**Day 2-3 (Oct 22-23): Execute Manual Tests**
- [ ] Create 2 test accounts (User A and User B)
- [ ] Execute [PHASE_1_MANUAL_TEST_SCRIPT.md](./runbooks/PHASE_1_MANUAL_TEST_SCRIPT.md)
  - Sections 1-7 (Day 2)
  - Sections 8-13 (Day 3)
- [ ] Document bugs in [BUG_TRACKING_TEMPLATE.md](./runbooks/BUG_TRACKING_TEMPLATE.md)

**Day 4 (Oct 24): Bug Triage & Fixes**
- [ ] Review all bugs found
- [ ] Prioritize: Critical → High → Medium → Low
- [ ] Fix all critical and high-priority bugs
- [ ] Commit fixes to Git
- [ ] Redeploy and re-test fixed bugs

**Day 5 (Oct 25): Final Validation**
- [ ] Complete [FINAL_VALIDATION_CHECKLIST](./FINAL_VALIDATION_CHECKLIST_v3.1_PHASE1.md)
- [ ] All "Hard Gates" must be passing
- [ ] Pass rate ≥95% on manual tests
- [ ] Make **Go/No-Go decision**

---

### 🟡 WEEK 2: Production Deployment (Oct 28-Nov 1)

**Day 6 (Oct 28): Production Preparation**
- [ ] Backup production Supabase database
- [ ] Apply Migration 0004 to production
- [ ] Run validation script
- [ ] Switch Stripe to LIVE mode
- [ ] Update all production secrets (Stripe keys, Supabase secrets, Vercel env vars)

**Day 7 (Oct 29): Production Deployment**
- [ ] Follow [PRODUCTION_DEPLOYMENT_CHECKLIST](./runbooks/PRODUCTION_DEPLOYMENT_CHECKLIST.md) step-by-step
- [ ] Deploy sv-edge functions to production
- [ ] Deploy sv-portal to Vercel production
- [ ] Verify DNS and SSL
- [ ] Execute production smoke tests (Section 10 of checklist)

**Day 8 (Oct 30): Beta Testing**
- [ ] Invite 2-3 beta customers
- [ ] Monitor usage and errors closely
- [ ] Gather feedback via survey or calls
- [ ] Fix any critical issues discovered

**Day 9-10 (Oct 31-Nov 1): Full Launch**
- [ ] Address beta feedback (if critical)
- [ ] Send launch email to all customers
- [ ] Update marketing website
- [ ] Monitor for first 48 hours
- [ ] Celebrate! 🎉

---

## Testing Guide

### Who Should Test?

**Recommended:** Zach (project owner) + 1-2 team members or friends

**Why?** Testing is critical. One person can do it, but two people are better (catch more bugs).

### How Long Does Testing Take?

- **Manual Test Script:** 2-3 hours for one complete run-through
- **Bug Fixes:** 1-2 hours (depends on number of bugs found)
- **Validation Checklist:** 1 hour
- **Total:** ~5-7 hours spread over 3-4 days

### What If You Find Bugs?

1. **Don't panic.** Bugs are normal and expected.
2. **Document in Bug Tracking Template:** Use [BUG_TRACKING_TEMPLATE.md](./runbooks/BUG_TRACKING_TEMPLATE.md)
3. **Prioritize:**
   - **Critical:** Blocks launch (e.g., cannot log in, data loss, security breach)
   - **High:** Major feature broken (e.g., cannot create items)
   - **Medium:** Feature partially broken (e.g., search doesn't work for tags)
   - **Low:** Cosmetic issue (e.g., button alignment off)
4. **Fix critical and high bugs** before launch
5. **Defer medium and low bugs** to Phase 2 (if acceptable)

### What If Testing Reveals Major Issues?

**Delay launch.** Better to launch late and working than on-time and broken.

**Example Go/No-Go Scenarios:**

| Scenario | Decision |
|----------|----------|
| 95% of tests pass, 2 low-priority bugs | ✅ GO - Launch, fix bugs in Phase 1.1 |
| 85% of tests pass, 5 medium bugs, 1 high bug | ❌ NO-GO - Fix high bug, re-test |
| Users can't log in | ❌ NO-GO - Critical blocker |
| Search doesn't work | ❌ NO-GO - High priority feature |
| Button styling is off | ✅ GO - Cosmetic issue, fix later |

---

## Deployment Guide

### Pre-Deployment Checklist (Quick Version)

Before deploying to production:
- [ ] All tests passed (≥95%)
- [ ] All critical bugs fixed
- [ ] Database backup created
- [ ] Migration 0004 applied to production
- [ ] Stripe switched to LIVE mode (real money!)
- [ ] All production secrets updated (Stripe keys, Supabase secrets, Vercel env vars)
- [ ] DNS configured for `portal.mystoragevalet.com`
- [ ] Webflow CTA tested

### Deployment Day Checklist (Quick Version)

1. [ ] Deploy Edge Functions to Supabase production
2. [ ] Deploy sv-portal to Vercel production (clear cache!)
3. [ ] Verify site loads at `https://portal.mystoragevalet.com`
4. [ ] Run smoke tests (login, create item, edit, delete, search, schedule)
5. [ ] Test magic link deliverability (Gmail, Outlook, etc.)
6. [ ] Test Stripe Checkout and Customer Portal
7. [ ] Verify RLS (cross-user isolation)
8. [ ] Monitor error logs for 2 hours

### Rollback Plan

**If something goes wrong:**
1. Vercel: Promote previous deployment to production
2. Supabase: Restore database backup (if needed)
3. Notify users if downtime exceeds 30 minutes

---

## Support & Troubleshooting

### Common Issues & Solutions

**Issue:** Vercel shows old code
- **Solution:** Deploy with "Use existing build cache" unchecked

**Issue:** Photos not loading
- **Solution:** Check signed URLs are being generated (inspect network tab)

**Issue:** Users can't log in
- **Solution:** Check Supabase Auth settings, verify email deliverability

**Issue:** Stripe checkout fails
- **Solution:** Verify Stripe webhook endpoint is active and receiving events

**Issue:** Cross-user data visible (RLS broken)
- **Solution:** Verify RLS policies applied to all tables

---

## Key Documents Reference

### Planning & Specs
- [SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md](./SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md) - Master specification
- [Business_Context_and_Requirements_v3.1.md](./Business_Context_and_Requirements_v3.1.md) - Business case
- [PHASE_1_STRATEGIC_SHIFT.md](./PHASE_1_STRATEGIC_SHIFT.md) - Phase 1 rationale

### Testing
- [PHASE_1_MANUAL_TEST_SCRIPT.md](./runbooks/PHASE_1_MANUAL_TEST_SCRIPT.md) - 90+ test cases ⭐ **START HERE**
- [BUG_TRACKING_TEMPLATE.md](./runbooks/BUG_TRACKING_TEMPLATE.md) - Bug documentation
- [FINAL_VALIDATION_CHECKLIST_v3.1_PHASE1.md](./FINAL_VALIDATION_CHECKLIST_v3.1_PHASE1.md) - Go/No-Go criteria

### Deployment
- [PRODUCTION_DEPLOYMENT_CHECKLIST.md](./runbooks/PRODUCTION_DEPLOYMENT_CHECKLIST.md) - Complete deployment ⭐ **USE THIS**
- [DEPLOYMENT_STATUS_2025-10-20.md](./runbooks/DEPLOYMENT_STATUS_2025-10-20.md) - Current status
- [Deployment_Instructions_v3.1.md](./Deployment_Instructions_v3.1.md) - Concise deployment guide
- [runbooks/secrets_needed.md](./runbooks/secrets_needed.md) - Environment variables

### Operations
- [LINE_IN_THE_SAND_Go-NoGo_v3.1_PHASE1.md](./LINE_IN_THE_SAND_Go-NoGo_v3.1_PHASE1.md) - Task tracking

---

## Success Criteria

### Minimum Requirements for Launch (All Must Pass)

**Security:**
- ✅ RLS verified (no cross-tenant access)
- ✅ Signed URLs expire after 1 hour
- ✅ No secrets exposed in frontend

**Performance:**
- ✅ 50 items load in <5 seconds
- ✅ Search/filter responsive (<1 second)

**Functionality:**
- ✅ Magic links deliver in <120s
- ✅ All CRUD operations work
- ✅ Multi-photo upload works (1-5 photos)
- ✅ Batch operations save correctly
- ✅ QR codes generate and print
- ✅ Physical lock enforced
- ✅ Event timeline displays
- ✅ Profile editing persists
- ✅ Stripe Customer Portal opens
- ✅ Checkout creates user and sends magic link

**Compatibility:**
- ✅ Chrome, Safari, Firefox (desktop)
- ✅ Mobile Safari (iOS)
- ✅ Mobile Chrome (Android)

---

## Team & Contacts

**Project Owner:** Zach Brown
**Developer:** Claude (AI Assistant via claude.ai)

**Infrastructure:**
- **Supabase:** [Project ID / Email]
- **Vercel:** [Email]
- **Stripe:** [Email]
- **Webflow:** [Email]

**Support:**
- **Customer Support Email:** support@mystoragevalet.com (or TBD)

---

## Timeline Summary

| Phase | Duration | Target Dates | Status |
|-------|----------|--------------|--------|
| Phase 0.6 (Foundation) | Complete | Oct 13, 2025 | ✅ Done |
| Phase 0.6.1 (Item Creation) | Complete | Oct 17, 2025 | ⚠️ Needs verification |
| Sprint 0 (Database Schema) | Complete | Oct 18, 2025 | ⚠️ Migration 0004 needs verification |
| Sprints 1-4 (Full Features) | Complete | Oct 18, 2025 | ✅ Code complete |
| **Manual Testing** | 3-5 days | Oct 21-25, 2025 | ⏳ Pending |
| **Bug Fixes** | 1-2 days | Oct 24-25, 2025 | ⏳ Pending |
| **Production Deployment** | 2-3 days | Oct 28-30, 2025 | ❌ Not started |
| **Beta Testing** | 2-3 days | Oct 30-Nov 1, 2025 | ❌ Not started |
| **Full Launch** | Nov 1, 2025 | Nov 1-5, 2025 | ❌ Not started |

---

## Questions?

If you have questions while testing or deploying, refer to:
1. The specific document for your task (test script, deployment checklist, etc.)
2. The master spec: [SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md](./SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md)
3. Claude Code (AI Assistant) for real-time help

---

## Next Action

**Ready to begin?**

👉 **Start here:** [PHASE_1_MANUAL_TEST_SCRIPT.md](./runbooks/PHASE_1_MANUAL_TEST_SCRIPT.md)

1. Read the pre-test setup section
2. Create 2 test accounts
3. Start executing test cases
4. Document any issues
5. Report back with results

**Good luck! You've got this.** 🚀

---

**Document Version:** 1.0
**Last Updated:** October 20, 2025
**Next Review:** After testing completion (Oct 25, 2025)

