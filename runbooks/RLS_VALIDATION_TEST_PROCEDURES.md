# RLS Validation Test Procedures

**Date:** October 31, 2025
**Purpose:** Validate cross-tenant isolation and RLS policy enforcement after Migration 0006/0007
**Status:** READY TO EXECUTE
**Estimated Time:** 30-45 minutes

---

## Prerequisites

- ✅ Migration 0006 applied (RLS enabled, comprehensive policies)
- ✅ Migration 0007 applied (inventory_events INSERT policy)
- ✅ Production database accessible
- ✅ Portal accessible at `https://portal.mystoragevalet.com`
- ✅ 2 test email addresses available

---

## Test 1: Cross-Tenant Isolation

### Objective
Verify User A cannot access User B's data through RLS policies.

### Setup

1. **Create Test User A**
   - Navigate to `https://portal.mystoragevalet.com/login`
   - Enter email: `test-user-a@{your-domain}.com`
   - Click "Send Magic Link"
   - Check email, click magic link
   - Verify login successful
   - Note User A's UUID from browser console:
     ```javascript
     // In browser console
     const { data: { user } } = await supabase.auth.getUser();
     console.log('User A ID:', user.id);
     ```
   - **Record User A UUID:** `_______________________`

2. **Create Test Item for User A**
   - Click "+" FAB button on Dashboard
   - Create item:
     - Label: "User A Test Item"
     - Description: "Cross-tenant isolation test"
     - Category: Electronics
     - Weight: 10 lbs
     - Dimensions: 12" x 12" x 12"
     - Value: $500
   - Upload 1 photo (any image)
   - Click "Add Item"
   - Verify item appears on dashboard
   - **Record Item ID** (from URL or browser console): `_______________________`

3. **Create Test User B**
   - Open incognito/private window
   - Navigate to `https://portal.mystoragevalet.com/login`
   - Enter email: `test-user-b@{your-domain}.com`
   - Click "Send Magic Link"
   - Check email, click magic link
   - Verify login successful
   - Note User B's UUID:
     ```javascript
     const { data: { user } } = await supabase.auth.getUser();
     console.log('User B ID:', user.id);
     ```
   - **Record User B UUID:** `_______________________`

4. **Create Test Item for User B**
   - Create item:
     - Label: "User B Test Item"
     - Description: "Different user's item"
     - Category: Furniture
     - Weight: 50 lbs
     - Dimensions: 24" x 24" x 24"
     - Value: $1000
   - Upload 1 photo
   - Click "Add Item"
   - **Record Item ID:** `_______________________`

### Test Execution

**Test 1.1: Dashboard Isolation**
- [ ] As User A, view Dashboard
- [ ] Verify: Only "User A Test Item" visible
- [ ] Verify: "User B Test Item" NOT visible
- [ ] As User B, view Dashboard
- [ ] Verify: Only "User B Test Item" visible
- [ ] Verify: "User A Test Item" NOT visible

**Result:** ☐ PASS / ☐ FAIL

**Test 1.2: Direct API Access Attempt (Browser Console)**

As User A, attempt to fetch User B's item:
```javascript
// Run in browser console while logged in as User A
const USER_B_ITEM_ID = 'paste-user-b-item-id-here';

const { data, error } = await supabase
  .from('items')
  .select('*')
  .eq('id', USER_B_ITEM_ID)
  .single();

console.log('Data:', data);
console.log('Error:', error);
// Expected: data = null, no error (RLS silently filters)
```

- [ ] Verify: `data` is `null` or empty
- [ ] Verify: No data leaked about User B's item

**Result:** ☐ PASS / ☐ FAIL

**Test 1.3: Profile Access Attempt**

As User A, attempt to fetch User B's profile:
```javascript
const USER_B_ID = 'paste-user-b-uuid-here';

const { data, error } = await supabase
  .from('customer_profile')
  .select('*')
  .eq('user_id', USER_B_ID)
  .single();

console.log('Data:', data);
console.log('Error:', error);
// Expected: data = null (RLS blocks)
```

- [ ] Verify: `data` is `null`
- [ ] Verify: User B's email/name not exposed

**Result:** ☐ PASS / ☐ FAIL

**Test 1.4: Photo Access Attempt**

As User A, attempt to access User B's photo:
```javascript
// Get User B's item photo path first (via SQL as service_role):
// SELECT photo_paths FROM items WHERE user_id = '<user_b_id>';

const USER_B_PHOTO_PATH = 'paste-user-b-photo-path-here';

const { data, error } = await supabase.storage
  .from('item-photos')
  .download(USER_B_PHOTO_PATH);

console.log('Downloaded:', data);
console.log('Error:', error);
// Expected: error.message contains "not allowed" or similar
```

- [ ] Verify: Download fails with permission error
- [ ] Verify: Photo data not accessible

**Result:** ☐ PASS / ☐ FAIL

**Test 1.5: Update Attempt**

As User A, attempt to update User B's item:
```javascript
const USER_B_ITEM_ID = 'paste-user-b-item-id-here';

const { data, error } = await supabase
  .from('items')
  .update({ label: 'HACKED BY USER A' })
  .eq('id', USER_B_ITEM_ID);

console.log('Update result:', data);
console.log('Error:', error);
// Expected: No rows updated (RLS blocks)
```

- [ ] Verify: No rows updated
- [ ] Verify: User B's item unchanged (check in User B's session)

**Result:** ☐ PASS / ☐ FAIL

**Test 1.6: Delete Attempt**

As User A, attempt to delete User B's item:
```javascript
const USER_B_ITEM_ID = 'paste-user-b-item-id-here';

const { data, error } = await supabase
  .from('items')
  .delete()
  .eq('id', USER_B_ITEM_ID);

console.log('Delete result:', data);
console.log('Error:', error);
// Expected: No rows deleted (RLS blocks)
```

- [ ] Verify: No rows deleted
- [ ] Verify: User B's item still exists

**Result:** ☐ PASS / ☐ FAIL

---

## Test 2: Timeline Write Test (RLS INSERT Policy)

### Objective
Verify authenticated users can insert inventory_events under RLS (Migration 0007 fix).

### Test Execution

**Test 2.1: Manual Event Insert**

As User A, insert timeline event via browser console:
```javascript
const { data: { user } } = await supabase.auth.getUser();
const USER_A_ITEM_ID = 'paste-user-a-item-id-here';

const { data, error } = await supabase
  .from('inventory_events')
  .insert({
    user_id: user.id,
    item_id: USER_A_ITEM_ID,
    event_type: 'test_manual_insert',
    event_data: { test: true, timestamp: new Date().toISOString() }
  })
  .select()
  .single();

console.log('Insert result:', data);
console.log('Error:', error);
// Expected: data contains inserted event, error is null
```

- [ ] Verify: Insert succeeds
- [ ] Verify: `data` contains event with correct `user_id` and `item_id`
- [ ] Verify: No RLS permission errors

**Result:** ☐ PASS / ☐ FAIL

**Test 2.2: Edit Item (Auto-Logging)**

As User A, edit an item to trigger automatic event logging:
- [ ] Click item to view details
- [ ] Click "Edit" button
- [ ] Change description to "Updated via RLS test"
- [ ] Click "Save Changes"
- [ ] Verify: Success toast appears
- [ ] Navigate to item timeline/history view
- [ ] Verify: "Item updated" event appears in timeline

**Result:** ☐ PASS / ☐ FAIL

**Test 2.3: Timeline Read Access**

As User A, verify you can read your own timeline:
```javascript
const USER_A_ITEM_ID = 'paste-user-a-item-id-here';

const { data, error } = await supabase
  .from('inventory_events')
  .select('*')
  .eq('item_id', USER_A_ITEM_ID)
  .order('created_at', { ascending: false });

console.log('Events:', data);
console.log('Error:', error);
// Expected: data contains array of events, error is null
```

- [ ] Verify: Events retrieved successfully
- [ ] Verify: All events have matching `user_id`

**Result:** ☐ PASS / ☐ FAIL

**Test 2.4: Cross-Tenant Timeline Isolation**

As User A, attempt to read User B's timeline:
```javascript
const USER_B_ITEM_ID = 'paste-user-b-item-id-here';

const { data, error } = await supabase
  .from('inventory_events')
  .select('*')
  .eq('item_id', USER_B_ITEM_ID);

console.log('Events:', data);
console.log('Error:', error);
// Expected: data = [] (empty array), RLS filters out User B's events
```

- [ ] Verify: No events returned (empty array)
- [ ] Verify: User B's timeline not accessible

**Result:** ☐ PASS / ☐ FAIL

---

## Test 3: Subscription Badge Verification

### Objective
Verify all 9 subscription states render correctly in Account.tsx.

### Prerequisites
- Requires service_role access to modify `customer_profile.subscription_status`
- Run in Supabase SQL Editor with service_role credentials

### Test Execution

For each subscription state, run SQL update and verify badge:

**Test 3.1: Active State**
```sql
UPDATE customer_profile
SET subscription_status = 'active'::subscription_status_enum
WHERE user_id = '<test_user_a_id>';
```
- [ ] Refresh `/account` page
- [ ] Verify: Green badge "Active"
- [ ] Screenshot: `badge-active.png`

**Test 3.2: Trialing State**
```sql
UPDATE customer_profile
SET subscription_status = 'trialing'::subscription_status_enum
WHERE user_id = '<test_user_a_id>';
```
- [ ] Refresh `/account`
- [ ] Verify: Blue badge "Trial Period"
- [ ] Screenshot: `badge-trialing.png`

**Test 3.3: Past Due State**
```sql
UPDATE customer_profile
SET subscription_status = 'past_due'::subscription_status_enum,
    last_payment_failed_at = NOW()
WHERE user_id = '<test_user_a_id>';
```
- [ ] Refresh `/account`
- [ ] Verify: Red badge "Past Due"
- [ ] Verify: Red payment error alert displays
- [ ] Screenshot: `badge-past-due.png`

**Test 3.4: Unpaid State**
```sql
UPDATE customer_profile
SET subscription_status = 'unpaid'::subscription_status_enum,
    last_payment_failed_at = NOW()
WHERE user_id = '<test_user_a_id>';
```
- [ ] Refresh `/account`
- [ ] Verify: Red badge "Unpaid"
- [ ] Verify: Red payment error alert displays
- [ ] Screenshot: `badge-unpaid.png`

**Test 3.5: Incomplete State**
```sql
UPDATE customer_profile
SET subscription_status = 'incomplete'::subscription_status_enum
WHERE user_id = '<test_user_a_id>';
```
- [ ] Refresh `/account`
- [ ] Verify: Yellow badge "Setup Incomplete"
- [ ] Verify: Yellow setup alert displays
- [ ] Screenshot: `badge-incomplete.png`

**Test 3.6: Incomplete Expired State**
```sql
UPDATE customer_profile
SET subscription_status = 'incomplete_expired'::subscription_status_enum
WHERE user_id = '<test_user_a_id>';
```
- [ ] Refresh `/account`
- [ ] Verify: Orange badge "Setup Expired"
- [ ] Verify: Yellow setup alert displays
- [ ] Screenshot: `badge-incomplete-expired.png`

**Test 3.7: Paused State**
```sql
UPDATE customer_profile
SET subscription_status = 'paused'::subscription_status_enum
WHERE user_id = '<test_user_a_id>';
```
- [ ] Refresh `/account`
- [ ] Verify: Gray badge "Paused"
- [ ] Screenshot: `badge-paused.png`

**Test 3.8: Canceled State**
```sql
UPDATE customer_profile
SET subscription_status = 'canceled'::subscription_status_enum
WHERE user_id = '<test_user_a_id>';
```
- [ ] Refresh `/account`
- [ ] Verify: Gray badge "Canceled"
- [ ] Screenshot: `badge-canceled.png`

**Test 3.9: Inactive State**
```sql
UPDATE customer_profile
SET subscription_status = 'inactive'::subscription_status_enum
WHERE user_id = '<test_user_a_id>';
```
- [ ] Refresh `/account`
- [ ] Verify: Gray badge "Inactive"
- [ ] Screenshot: `badge-inactive.png`

---

## Cleanup

**Remove Test Users & Data:**
```sql
-- Run as service_role in Supabase SQL Editor
DELETE FROM auth.users WHERE email LIKE '%@storage-valet-test.%';
-- Cascade deletes will remove customer_profile, items, inventory_events
```

**Reset Production User Status (if modified):**
```sql
UPDATE customer_profile
SET subscription_status = 'inactive'::subscription_status_enum
WHERE user_id = '<production_user_id>';
```

---

## Success Criteria

**All tests must PASS:**
- ✅ Test 1: Cross-Tenant Isolation (6/6 subtests pass)
- ✅ Test 2: Timeline Writes Under RLS (4/4 subtests pass)
- ✅ Test 3: Badge Verification (9/9 states render correctly)

**If any test FAILS:**
- Document failure details
- Check RLS policy definitions
- Verify migration 0006/0007 applied correctly
- Escalate to engineering team

---

## Test Results Summary

**Executed By:** _______________________
**Date/Time:** _______________________
**Duration:** _______ minutes

| Test Suite | Result | Notes |
|------------|--------|-------|
| 1. Cross-Tenant Isolation | ☐ PASS / ☐ FAIL | |
| 2. Timeline Writes (RLS) | ☐ PASS / ☐ FAIL | |
| 3. Badge Verification | ☐ PASS / ☐ FAIL | |

**Overall Status:** ☐ ALL PASS / ☐ FAILURES DETECTED

**Action Items:**
- [ ] Update security incident log with test results
- [ ] Archive screenshots in `sv-docs/runbooks/test-results/`
- [ ] Mark validation complete in deployment checklist

---

**End of Test Procedures**
