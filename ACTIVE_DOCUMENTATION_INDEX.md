# Active Documentation Index - Storage Valet

**Last Updated:** Oct 28, 2025
**Purpose:** Quick reference for AI agents - ONLY read docs listed here

---

## ⚠️ CRITICAL: Read This First

**18 outdated docs archived on Oct 28, 2025** to `~/code/sv-docs-archive-oct28-2025/`

**DO NOT reference archived docs.** They contain outdated:
- Old pricing models
- Phase 0.x information (project is now Phase 1)
- Superseded deployment statuses
- Historical session summaries
- Resolved decision documents

---

## 📋 Required Reading (Always Check These)

### 1. Foundational Architecture
**File:** `SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md`
- Original architectural plan (Oct 10)
- Defines non-negotiable constraints
- Single source of truth for v3.1 scope
- **Must read** before making any architectural decisions

### 2. Phase 1 Strategic Context
**File:** `PHASE_1_STRATEGIC_SHIFT.md` (Oct 18)
- Why original constraints were relaxed
- Current state: ~22 files, 8 deps, ~1,800 LOC
- Justification for Phase 1 feature set

### 3. Current Validation Checklist
**File:** `FINAL_VALIDATION_CHECKLIST_v3.1_PHASE1.md` (Oct 18)
- Phase 1 gates and requirements
- Testing criteria
- Go/No-Go decision framework

### 4. Launch Readiness
**File:** `LINE_IN_THE_SAND_Go-NoGo_v3.1_PHASE1.md` (Oct 24)
- Current launch status
- Blocking issues
- Decision criteria

### 5. Launch Guide
**File:** `PHASE_1_LAUNCH_GUIDE.md` (Oct 20)
- Deployment procedures
- Launch checklist
- Rollback procedures

---

## 🛠️ Active Runbooks (Operations)

### Testing
- **`PHASE_1_MANUAL_TEST_SCRIPT.md`** (Oct 20) - 90+ test cases, 13 sections
- **`BUG_TRACKING_TEMPLATE.md`** (Oct 20) - Bug reporting format
- **`ITEM_CREATION_SMOKE_TESTS.md`** (Oct 17) - Item creation validation

### Deployment
- **`PRODUCTION_DEPLOYMENT_CHECKLIST.md`** (Oct 20) - Deploy steps
- **`DEPLOYMENT_STATUS_2025-10-24.md`** (Oct 24) - Current infrastructure state

### Operations
- **`BUILD_SUMMARY_v3.1.md`** (Oct 21) - Build status
- **`HANDOFF_STATUS_v3.1.md`** (Oct 21) - Team handoff info
- **`Business_Context_and_Requirements_v3.1.md`** (Oct 21) - Detailed Phase 0.6+ status

### Stripe Integration
- **`FINAL_WEBHOOK_TEST_PLAN.md`** (Oct 13) - Webhook testing
- **`WEBHOOK_TEST_GUIDE.md`** (Oct 13) - Webhook setup
- **`stripe_test_setup.md`** (Oct 11) - Stripe configuration
- **`secrets_needed.md`** (Oct 11) - Required secrets

---

## 📚 Platform-Specific Docs (Very Recent - Oct 28)

**All created Oct 28, 2025:**
- `platform-docs/README.md` - Platform overview
- `platform-docs/MCP_AND_DOCUMENTATION_SETUP_GUIDE.md` - MCP setup
- `platform-docs/SYSTEM_SETUP_COMPLETE.md` - System status
- `platform-docs/QUICK_MCP_REFERENCE.md` - MCP quick ref
- `platform-docs/supabase/README.md` - Supabase patterns
- `platform-docs/stripe/README.md` - Stripe integration
- `platform-docs/vercel/README.md` - Vercel deployment
- `platform-docs/react/README.md` - React patterns

---

## 📖 Addenda (Phase 1 Specs)

- `addenda/PHASE_1_COMPONENT_IMPLEMENTATION_CHECKLIST.md` (Oct 18)
- `addenda/PHASE_1_PHYSICAL_DATA_REQUIREMENTS.md` (Oct 18)

---

## ❌ DO NOT Read (Archived)

**These docs are in `~/code/sv-docs-archive-oct28-2025/` - DO NOT reference:**

### Session Summaries (Historical Only)
- SESSION_SUMMARY_2025-10-24-PRODUCTION-VERIFICATION.md
- DOCUMENTATION_STATUS_AND_ACTION_ITEMS_2025-10-24.md
- DOCUMENTATION_AUDIT_2025-10-18.md

### Superseded Versions
- Business_Context_and_Requirements_v3.1.md (root - older version)
- DEPLOYMENT_STATUS_2025-10-20.md (older deployment status)
- LINE_IN_THE_SAND_Go-NoGo_v3.1.md (pre-Phase 1 version)
- FINAL_VALIDATION_CHECKLIST_v3.1.md (pre-Phase 1 version)
- Deployment_Instructions_v3.1.md (old instructions)
- DEPLOYMENT_GUIDE_v3.1.md (superseded by PRODUCTION_DEPLOYMENT_CHECKLIST)

### Resolved Decisions
- DECISION_REQUIRED_2025-10-24-BILLING_FLOW_ARCHITECTURE_CRITICAL.md (50KB - decision made)

### Phase 0 Docs (Now in Phase 1)
- SPRINT_0_COMPLETION_SUMMARY.md
- PHASE_0.6_GATES_v3.1.md
- PHASE_0.6.1_ITEM_CREATION_STATUS.md
- storage_valet_master_checklist_phase_0.md

### One-Time Setup Guides (Complete)
- PERPLEXITY_END_TO_END_IMPLEMENTATION_GUIDE.md (56KB - setup complete)
- WEBFLOW_INTEGRATION_GUIDE_FOR_PERPLEXITY.md (16KB - setup complete)
- VERCEL_SETUP_COMPLETE_2025-10-13.md (setup complete)

### Agent-Specific Docs (Outdated)
- Claude Code Sub-Agents.md (old agent setup doc)

---

## 🎯 Quick Decision Matrix

**When you need to know about:**
- **Architecture constraints** → `SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md`
- **Current pricing** → Single tier $299/month (in Implementation Plan)
- **Phase 1 features** → `PHASE_1_STRATEGIC_SHIFT.md`
- **Testing requirements** → `PHASE_1_MANUAL_TEST_SCRIPT.md`
- **Deployment steps** → `PRODUCTION_DEPLOYMENT_CHECKLIST.md`
- **Current status** → `LINE_IN_THE_SAND_Go-NoGo_v3.1_PHASE1.md`
- **Stripe integration** → `platform-docs/stripe/README.md`
- **Database patterns** → `platform-docs/supabase/README.md`

---

## 📊 Documentation Stats (Post-Cleanup)

**Active docs:** 26 files (6 root + 12 runbooks + 8 platform-docs)
**Archived:** 18 files (historical context only)
**Reduction:** ~40% reduction in active documentation

**Result:** Agents now have clear, current documentation without noise from:
- Old pricing models
- Superseded versions
- Historical summaries
- Completed setup guides
- Phase 0 references

---

## 🔄 Maintenance

**When to update this index:**
- New major documents added to sv-docs
- Documents become outdated and are archived
- Phase transitions (e.g., Phase 1 → Phase 2)
- Major architectural changes

**Archive process:**
1. Move old docs to `~/code/sv-docs-archive-oct28-2025/`
2. Update this index
3. Test that agents reference correct docs only

---

**Last Archive Date:** Oct 28, 2025
**Next Review:** When Phase 1 launches (transition to Phase 2)
