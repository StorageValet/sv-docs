# Bug Tracking Template — Storage Valet Phase 1

**Version:** 1.0
**Date Created:** 2025-10-20
**Status:** ACTIVE

---

## Purpose

This template provides a structured format for tracking bugs discovered during Phase 1 testing. Each bug should be documented with sufficient detail to reproduce and fix.

---

## Bug Entry Template

### Bug ID: BUG-001
**Reported By:** _________________
**Date Reported:** _________________
**Test Reference:** Test Section X.Y from Manual Test Script
**Environment:** ☐ Staging  ☐ Production
**Browser/Device:** _________________

**Severity:**
- [ ] **Critical** - System crash, data loss, security breach, complete feature failure
- [ ] **High** - Major feature broken, no workaround, impacts multiple users
- [ ] **Medium** - Feature partially broken, workaround exists, impacts some users
- [ ] **Low** - Cosmetic issue, minor inconvenience, does not impact functionality

**Category:**
- [ ] Authentication
- [ ] Item Management (CRUD)
- [ ] Search & Filters
- [ ] Batch Operations
- [ ] Profile Management
- [ ] QR Codes
- [ ] Event Logging
- [ ] Security (RLS)
- [ ] Performance
- [ ] UI/UX
- [ ] Mobile Responsiveness
- [ ] Other: _________________

**Summary:**
_Brief one-line description of the bug_

**Steps to Reproduce:**
1.
2.
3.

**Expected Behavior:**
_What should happen_

**Actual Behavior:**
_What actually happens_

**Screenshots/Videos:**
_Attach or link to visual evidence_

**Console Errors:**
```
Paste any console errors here
```

**Database Errors:**
```sql
Paste any database errors here
```

**Impact:**
_Who does this affect? How many users? What workflows are blocked?_

**Workaround:**
_Is there a temporary workaround users can use?_

**Root Cause Analysis:**
_Once investigated, document the technical cause_

**Fix Applied:**
_Description of the fix implemented_

**Fix Verified By:** _________________
**Date Fixed:** _________________
**Status:** ☐ Open  ☐ In Progress  ☐ Fixed  ☐ Verified  ☐ Closed

---

## Active Bugs

### BUG-001: [Title]
**Status:** Open
**Severity:** Critical
**Assigned To:** _________________
**Summary:** _________________
**Link to Details:** [Expand above template or link to issue tracker]

---

### BUG-002: [Title]
**Status:** Open
**Severity:** High
**Assigned To:** _________________
**Summary:** _________________

---

## Bug Summary Dashboard

| Bug ID | Summary | Severity | Status | Assigned To | Date Reported | Date Fixed |
|--------|---------|----------|--------|-------------|---------------|------------|
| BUG-001 | | Critical | Open | | YYYY-MM-DD | |
| BUG-002 | | High | Open | | YYYY-MM-DD | |
| BUG-003 | | Medium | Fixed | | YYYY-MM-DD | YYYY-MM-DD |
| BUG-004 | | Low | Closed | | YYYY-MM-DD | YYYY-MM-DD |

---

## Bug Statistics

**Total Bugs Reported:** _______
**Critical:** _______
**High:** _______
**Medium:** _______
**Low:** _______

**Open:** _______
**In Progress:** _______
**Fixed (Not Verified):** _______
**Verified:** _______
**Closed:** _______

---

## Common Bug Patterns

_As testing progresses, document recurring themes or patterns:_

Example:
- **RLS Policy Issues:** Multiple bugs related to permission errors on [table name]
- **Photo Upload:** Issues with [specific file types] on [specific browsers]
- **Search Performance:** Lag when searching with [specific conditions]

---

## Testing Notes

_Document any general observations, test environment quirks, or lessons learned:_

Example:
- Test User A email: testuser-a+20251020@gmail.com
- Staging Supabase URL: https://xxxxx.supabase.co
- Staging Vercel URL: https://sv-portal-staging.vercel.app
- Test Stripe cards: 4242 4242 4242 4242 (success), 4000 0000 0000 0002 (decline)

---

## Triage Meeting Notes

**Date:** _________________
**Attendees:** _________________

**Decisions:**
- BUG-XXX: Prioritize for hotfix
- BUG-YYY: Defer to Phase 2
- BUG-ZZZ: Close as "Won't Fix" (rationale: _________________)

---

## Resolved Bugs Archive

_Move resolved and verified bugs here for record-keeping:_

### BUG-003: Profile form not saving address
**Status:** Closed
**Severity:** High
**Root Cause:** JSONB field not properly serialized
**Fix:** Updated ProfileEditForm.tsx line 58-64 to properly structure delivery_address object
**Date Fixed:** 2025-10-22
**Verified By:** Tester Name

---

## Bug Reporting Guidelines

**For Testers:**
1. Check if bug already reported before creating new entry
2. Provide as much detail as possible (steps to reproduce are critical)
3. Include screenshots/videos when applicable
4. Assign severity based on impact, not personal preference
5. Test on clean browser session (clear cache/cookies) to confirm reproducibility

**For Developers:**
1. Update bug status when you start working on it (Open → In Progress)
2. Document root cause analysis once identified
3. Update bug with fix description and commit hash
4. Mark as "Fixed" and notify tester for verification
5. Only close bug after tester verifies fix in test environment

---

## Integration with GitHub Issues (Optional)

If using GitHub Issues for tracking:

**Labeling Convention:**
- `bug` - All bugs
- `critical` - Critical severity
- `high-priority` - High severity
- `medium-priority` - Medium severity
- `low-priority` - Low severity
- `phase-1` - Phase 1 related
- `security` - Security-related bugs
- `performance` - Performance-related bugs
- `ux` - UI/UX issues

**Milestone:** Phase 1 Launch

---

**Last Updated:** YYYY-MM-DD
**Maintained By:** _________________

