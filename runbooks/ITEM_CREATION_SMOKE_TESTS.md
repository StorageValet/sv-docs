# Item Creation Feature — E2E Smoke Tests

**Purpose:** Validate the critical item creation feature before Phase 0.7 sign-off.
**Owner:** Zach
**Date Added:** 2025-10-17
**Prerequisites:** Portal deployed to Vercel, test user with active Stripe subscription

---

## Test Setup

1. **Environment:** Vercel preview or production URL
2. **Test Account:** User with active subscription (subscription_status = 'active')
3. **Browser:** Chrome/Safari (test both mobile + desktop viewports)
4. **Stripe:** Customer Portal link working (from /account page)

---

## Smoke Test Checklist

### 1. Insurance Bar Display
- [ ] Login to Dashboard
- [ ] Insurance progress bar visible (shows "Insurance Coverage" + "$3,000 plan")
- [ ] Bar shows 100% remaining (full green bar) for new account with zero items
- [ ] **No dollar amounts** displayed to user (only "Remaining coverage shown as a bar")

### 2. Add Item — Happy Path
- [ ] Click floating "+" button (bottom-right)
- [ ] Modal opens with title "Add New Item"
- [ ] Fill out form with valid data:
  - **Photo:** Upload JPG/PNG (2-3MB, valid)
  - **Title:** "Box of Books" (min 3 chars)
  - **Description:** "Reference books from home office" (min 3 chars)
  - **Estimated Value:** "$500" or "500"
  - **Weight:** "25" lbs
  - **Dimensions:** Length "24", Width "18", Height "12" inches
  - **Tags:** "books, office" (optional)
- [ ] Click "Add Item"
- [ ] Modal closes automatically
- [ ] New item appears in Dashboard grid
- [ ] Item card shows:
  - Photo thumbnail
  - Title + description
  - QR code (e.g., "QR: SV-2025-000001")
  - Cubic feet (e.g., "3.0 ft³")
  - Weight (e.g., "25 lbs")
  - Value (e.g., "$500.00 value")

### 3. Insurance Bar Update
- [ ] After adding $500 item, insurance bar reduces slightly
- [ ] Bar now shows ~83% remaining (500/3000 = 16.7% used)
- [ ] Still no raw dollar amounts shown to user

### 4. Multiple Items
- [ ] Add second item with different value (e.g., $1,200)
- [ ] Both items appear in grid
- [ ] Insurance bar updates to ~43% remaining (1700/3000 used)
- [ ] Items sorted by creation date (newest first)

### 5. Validation — Photo Upload
- [ ] Try uploading **> 5MB** photo → Should block with error: "Photo must be ≤ 5MB"
- [ ] Try uploading **non-image** (e.g., .txt, .pdf) → Should block with error: "Photo must be JPG, PNG, or WebP"
- [ ] Try submitting **without photo** → Should block with error: "A photo is required"

### 6. Validation — Required Fields
- [ ] Try empty title → Should block: "Label: min 3 characters"
- [ ] Try empty description → Should block: "Description: min 3 characters"
- [ ] Try zero value ("$0") → Should block: "Enter a valid dollar amount"
- [ ] Try zero weight ("0") → Should block: "Weight (lbs) must be > 0"
- [ ] Try zero dimensions (0 × 0 × 0) → Should block: "Length (in) must be > 0"

### 7. Validation — Negative Values
- [ ] Try negative value ("-100") → Should block: "Enter a valid dollar amount"
- [ ] Try negative weight ("-5") → Should block: "Weight (lbs) must be > 0"
- [ ] Try negative dimensions → Should block: "Length (in) must be > 0"

### 8. Database — QR Code Assignment
- [ ] Check database (Supabase SQL Editor):
  ```sql
  SELECT qr_code, label, estimated_value_cents, cubic_feet
  FROM public.items
  ORDER BY created_at DESC
  LIMIT 5;
  ```
- [ ] Every item has unique QR code (format: SV-YYYY-XXXXXX)
- [ ] cubic_feet auto-calculated correctly (L×W×H/1728)
- [ ] All required fields present (photo_path, estimated_value_cents, weight_lbs, dimensions)

### 9. RLS Security — Owner-Only Access
- [ ] Create second test account (different user)
- [ ] Login with User B
- [ ] Confirm User B **cannot** see User A's items
- [ ] Confirm User B can only create items for themselves
- [ ] Check database directly (as admin):
  ```sql
  SELECT user_id, label FROM public.items;
  ```
- [ ] Confirm items correctly scoped to respective users

### 10. Insurance Function — RLS Isolation
- [ ] As User A, check insurance query returns only User A's total:
  ```sql
  SELECT * FROM public.fn_my_insurance();
  ```
- [ ] Confirm total_item_value_cents matches sum of User A's items only
- [ ] As User B, confirm fn_my_insurance() returns User B's data only

### 11. Photo Storage — Signed URLs
- [ ] Refresh Dashboard page
- [ ] Confirm all item photos load correctly (signed URLs working)
- [ ] Check browser network tab: URLs should be `*.supabase.co/storage/v1/object/sign/...`
- [ ] Confirm URLs expire after 1 hour (token in query string)

### 12. Performance — Large Item Count
- [ ] (Optional if time permits) Add 20+ items
- [ ] Confirm Dashboard loads quickly (< 2s)
- [ ] Confirm indexes are being used (check Supabase logs or pg_stat_user_indexes)

---

## Acceptance Criteria

**PASS if:**
- All 12 test sections complete with zero failures
- Insurance tracking accurate across multiple items
- All validation blocks invalid input (client + database)
- RLS enforces owner-only access
- QR codes auto-generated and unique
- Photos load via signed URLs

**FAIL if:**
- User can bypass required field validation
- Insurance bar shows raw dollar amounts
- RLS allows cross-user data access
- QR codes missing or duplicated
- Photos fail to load or storage errors occur

---

## Notes

- Run this checklist **after** Vercel deployment
- Document any failures in GitHub Issues
- If blocked by Stripe subscription test data, use Stripe test mode customer portal
- For production testing, use real credit card in Stripe test mode (e.g., 4242 4242 4242 4242)

---

## Sign-Off

| Role | Name | Date | Pass/Fail |
|------|------|------|-----------|
| Developer | Claude Code | 2025-10-17 | ◻︎ |
| Product Owner | Zach | TBD | ◻︎ |

---

**Next Steps After PASS:**
1. Tag repos as `phase-0.6.1-item-creation-complete`
2. Update `FINAL_VALIDATION_CHECKLIST_v3.1.md` with item creation sign-off
3. Proceed to Phase 0.7 (security rotation + branded email)
