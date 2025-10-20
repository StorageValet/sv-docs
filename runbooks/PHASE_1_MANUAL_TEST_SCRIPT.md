# Phase 1 Manual Test Script — Storage Valet Customer Portal

**Version:** 1.0
**Date:** 2025-10-20
**Status:** ACTIVE
**Tester:** _________________
**Test Environment:** ☐ Staging  ☐ Production
**Test Date:** _________________

---

## Purpose

This script provides step-by-step instructions for manually testing all Phase 1 features. Execute every test in order and mark PASS ✅ or FAIL ❌. Document any failures in the Bug Tracking section at the end.

**Estimated Time:** 2-3 hours for complete run-through

---

## Pre-Test Setup

### Required Accounts
- [ ] Create Test User A: `testuser-a+[random]@gmail.com`
- [ ] Create Test User B: `testuser-b+[random]@gmail.com`
- [ ] Both accounts should complete Stripe checkout (test mode)
- [ ] Both accounts should have active subscriptions

### Required Test Data
- [ ] Prepare 5 test photos (JPG format, various sizes <5MB)
- [ ] Prepare 1 oversized photo (>5MB) for validation testing
- [ ] Prepare 1 HEIC photo for format rejection testing

### Browser Setup
- [ ] Clear browser cache and cookies
- [ ] Open browser dev tools (F12) to monitor console errors
- [ ] Have a second browser ready for cross-user testing

---

## Test Section 1: Authentication & Account Setup

### Test 1.1: Magic Link Authentication (User A)

**Steps:**
1. Navigate to portal URL
2. Enter Test User A email address
3. Click "Send Magic Link"
4. Check email inbox (wait up to 120 seconds)
5. Click magic link
6. Verify redirect to `/dashboard`

**Expected Results:**
- [ ] Magic link received within 120 seconds
- [ ] Link redirects to dashboard successfully
- [ ] User is logged in (see email/profile in nav)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 1.2: Profile Information Display

**Steps:**
1. Click "Account" in navigation
2. Verify subscription status displays
3. Verify profile form loads with empty fields

**Expected Results:**
- [ ] Subscription status shows "active"
- [ ] Profile form displays all fields: Full Name, Phone, Address (Street, City, State, ZIP, Unit), Delivery Instructions
- [ ] "Manage Billing" button visible
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 1.3: Profile Editing & Persistence

**Steps:**
1. Fill out profile form:
   - Full Name: "Test User Alpha"
   - Phone: "555-123-4567"
   - Street: "123 Main Street"
   - City: "Springfield"
   - State: "IL"
   - ZIP: "62701"
   - Unit: "Apt 4B"
   - Delivery Instructions: "Leave at back door. Gate code: #1234"
2. Click "Save Profile"
3. Wait for success message
4. Refresh the page
5. Navigate back to Account page

**Expected Results:**
- [ ] "Profile updated successfully!" message appears
- [ ] After refresh, all fields retain saved values
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 1.4: Stripe Customer Portal Integration

**Steps:**
1. On Account page, click "Manage Billing"
2. Wait for redirect (may take 2-3 seconds)
3. Verify Stripe Customer Portal loads
4. **DO NOT** cancel subscription
5. Click "Back to [Your Site]" or navigate back to portal

**Expected Results:**
- [ ] Stripe Customer Portal opens in same tab
- [ ] Portal displays correct subscription ("Storage Valet Premium")
- [ ] Return link works
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 2: Item Creation & Basic CRUD

### Test 2.1: Initial Dashboard State (Empty)

**Steps:**
1. Navigate to Dashboard
2. Observe empty state

**Expected Results:**
- [ ] Insurance coverage bar displays (100% full, green)
- [ ] Text shows "$3,000 plan"
- [ ] Empty state message: "No items yet..."
- [ ] "Add Item" button visible
- [ ] Floating "+" button visible (bottom-right corner)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 2.2: Create First Item (Single Photo)

**Steps:**
1. Click floating "+" button
2. Modal opens with "Add New Item" form
3. Upload 1 photo (JPG, <5MB)
4. Fill form:
   - Label: "Box of Books"
   - Description: "Reference books from home office"
   - Estimated Value: "500"
   - Weight: "25"
   - Length: "24"
   - Width: "18"
   - Height: "12"
   - Tags: "books, office, fragile"
   - Category: "Household"
5. Click "Add Item"
6. Wait for modal to close

**Expected Results:**
- [ ] Modal closes automatically
- [ ] Item appears in dashboard grid
- [ ] Photo displays correctly
- [ ] QR code generated (format: SV-2025-XXXXXX)
- [ ] Cubic feet calculated correctly (3.0 ft³)
- [ ] Insurance bar shrinks (~83% remaining)
- [ ] Status badge shows "Home" (or default status)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________
**QR Code:** _________________

---

### Test 2.3: Create Item with Multiple Photos (2-5)

**Steps:**
1. Click "+" button
2. Upload 3 photos using file picker (select multiple)
3. Verify preview shows all 3 thumbnails
4. Fill form:
   - Label: "Winter Clothing Bin"
   - Description: "Coats, sweaters, and winter accessories"
   - Estimated Value: "800"
   - Weight: "15"
   - Length: "20"
   - Width: "16"
   - Height: "14"
   - Tags: "clothing, seasonal"
   - Category: "Clothing"
5. Click "Add Item"

**Expected Results:**
- [ ] All 3 photos preview correctly before submit
- [ ] Item created successfully
- [ ] Item card shows first photo as primary
- [ ] Insurance bar shrinks further (~57% remaining)
- [ ] Both items now visible in dashboard
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 2.4: Photo Validation (Size Limit)

**Steps:**
1. Click "+" button
2. Upload oversized photo (>5MB)
3. Observe error message

**Expected Results:**
- [ ] Error message displays: "File exceeds 5MB limit" (or similar)
- [ ] Photo is rejected
- [ ] Form does not submit
- [ ] No console errors (validation handled gracefully)

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 2.5: Photo Validation (Format Restriction)

**Steps:**
1. Click "+" button
2. Upload HEIC photo (iPhone default format)
3. Observe error message

**Expected Results:**
- [ ] Error message displays: "Only JPG, PNG, WebP allowed" (or similar)
- [ ] Photo is rejected
- [ ] Form does not submit
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 2.6: Photo Validation (Max 5 Photos)

**Steps:**
1. Click "+" button
2. Attempt to upload 6 photos at once
3. Observe error message

**Expected Results:**
- [ ] Error message displays: "Maximum 5 photos" (or similar)
- [ ] Only first 5 photos accepted, or all rejected
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 2.7: Create 10 More Items (Data Population)

**Purpose:** Populate dashboard for search/filter testing

**Steps:**
1. Create 10 additional items using quick form fills
2. Vary the following:
   - Status: 3 "Home", 4 "Stored", 3 "In Transit" (manually set in database if needed)
   - Categories: Mix of "Household", "Clothing", "Electronics", "Seasonal"
   - Values: Range from $100 to $2000
3. Use 1-3 photos per item

**Expected Results:**
- [ ] All 10 items created successfully
- [ ] Dashboard displays 12 total items (2 from earlier + 10 new)
- [ ] Insurance bar reflects cumulative value
- [ ] Performance: Dashboard loads in <5 seconds
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 3: Item Editing & Multi-Photo Management

### Test 3.1: Edit Item (Non-Physical Fields)

**Steps:**
1. Click any item card
2. Click "Edit" button
3. Edit modal opens
4. Change the following:
   - Label: Add " (UPDATED)" to end
   - Description: Add " - Edited for testing"
   - Estimated Value: Increase by $100
   - Tags: Add ", updated"
5. Click "Save Changes"

**Expected Results:**
- [ ] Modal closes
- [ ] Item card reflects updated label
- [ ] Insurance bar adjusts for new value
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 3.2: Add Photos to Existing Item

**Steps:**
1. Edit the "Box of Books" item (has 1 photo)
2. In edit modal, upload 2 additional photos
3. Verify preview shows 3 photos total (1 existing + 2 new)
4. Click "Save Changes"

**Expected Results:**
- [ ] Edit modal shows existing photo thumbnail
- [ ] New photos preview correctly
- [ ] After save, item now has 3 photos
- [ ] All 3 photos load on item card (or in gallery)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 3.3: Remove Photos from Existing Item

**Steps:**
1. Edit an item with 3 photos
2. Click "×" button on 2nd photo thumbnail
3. Verify photo is removed from preview
4. Click "Save Changes"
5. Re-open edit modal

**Expected Results:**
- [ ] Photo removed from preview before save
- [ ] After save, item has 2 photos remaining
- [ ] Removed photo no longer appears in edit modal
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 3.4: Physical Lock Enforcement (Simulated Pickup)

**Purpose:** Test that dimensions/weight lock after pickup

**Manual Setup Required:**
1. In Supabase SQL Editor, run:
   ```sql
   UPDATE items
   SET physical_locked_at = NOW(), status = 'in_transit'
   WHERE label LIKE '%Box of Books%';
   ```
2. Refresh dashboard

**Steps:**
1. Edit the "Box of Books" item
2. Observe physical fields (Weight, Length, Width, Height)
3. Attempt to change weight value
4. Attempt to submit form

**Expected Results:**
- [ ] Lock icon (🔒) appears next to physical fields
- [ ] Warning message displays: "Physical data locked. Dimensions and weight cannot be changed..."
- [ ] Physical fields are disabled (greyed out)
- [ ] Non-physical fields (Label, Description, Value, Tags) remain editable
- [ ] Save works for non-physical changes
- [ ] Trigger blocks physical changes (verify in database)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 4: Item Deletion

### Test 4.1: Delete Item with Confirmation

**Steps:**
1. Click any item card
2. Click "Delete" button
3. Confirmation modal appears
4. Verify item preview shows correct item
5. Click "Delete Item" button
6. Confirm browser alert (if double-confirmation exists)

**Expected Results:**
- [ ] Confirmation modal displays item details and photo
- [ ] Warning message emphasizes "cannot be undone"
- [ ] After confirmation, modal closes
- [ ] Item removed from dashboard
- [ ] Insurance bar adjusts
- [ ] Photos deleted from storage (verify in Supabase Storage bucket)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 4.2: Cancel Deletion

**Steps:**
1. Click any item card
2. Click "Delete" button
3. Confirmation modal appears
4. Click "Cancel" button

**Expected Results:**
- [ ] Modal closes without deletion
- [ ] Item remains in dashboard
- [ ] No changes to data
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 5: Search & Filtering

### Test 5.1: Keyword Search (Label)

**Steps:**
1. In search bar, type "Books"
2. Wait 500ms for debounce
3. Observe filtered results

**Expected Results:**
- [ ] Only items with "Books" in label display
- [ ] Results update after debounce delay (no lag)
- [ ] Result count displays: "Showing X of Y items"
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 5.2: Keyword Search (Description)

**Steps:**
1. Search for text that appears only in description (e.g., "office")
2. Verify items with matching descriptions appear

**Expected Results:**
- [ ] Search matches description field
- [ ] Correct items filtered
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 5.3: Keyword Search (Tags)

**Steps:**
1. Search for a tag (e.g., "fragile")
2. Verify items with that tag appear

**Expected Results:**
- [ ] Search matches tags array
- [ ] Correct items filtered
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 5.4: Keyword Search (QR Code)

**Steps:**
1. Copy QR code from an item card (e.g., "SV-2025-000001")
2. Paste into search bar
3. Verify that specific item appears

**Expected Results:**
- [ ] Search matches QR code field
- [ ] Only matching item displays
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 5.5: Status Filter (Home)

**Steps:**
1. Clear search bar
2. Click Status filter dropdown
3. Select "Home"
4. Observe filtered items

**Expected Results:**
- [ ] Only items with status "home" display
- [ ] Result count updates
- [ ] Filter chip/dropdown shows active filter
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 5.6: Status Filter (In Transit)

**Steps:**
1. Select "In Transit" status
2. Observe filtered items

**Expected Results:**
- [ ] Only items with status "in_transit" display
- [ ] Result count updates
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 5.7: Status Filter (Stored)

**Steps:**
1. Select "Stored" status
2. Observe filtered items

**Expected Results:**
- [ ] Only items with status "stored" display
- [ ] Result count updates
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 5.8: Category Filter

**Steps:**
1. Clear status filter (select "All Status")
2. Click Category filter dropdown
3. Select a category (e.g., "Electronics")
4. Observe filtered items

**Expected Results:**
- [ ] Only items with selected category display
- [ ] Result count updates
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 5.9: Combined Filters (Status + Category)

**Steps:**
1. Select Status: "Stored"
2. Select Category: "Household"
3. Observe filtered items

**Expected Results:**
- [ ] Only items matching BOTH filters display (AND logic)
- [ ] Result count updates
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 5.10: Combined Search + Filters

**Steps:**
1. Enter search term: "Winter"
2. Select Status: "Home"
3. Observe filtered items

**Expected Results:**
- [ ] Only items matching search AND status display
- [ ] Result count updates
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 5.11: Clear Filters

**Steps:**
1. With multiple filters active, click "Clear Filters" button
2. Observe dashboard

**Expected Results:**
- [ ] All filters reset to "All"
- [ ] Search bar clears
- [ ] All items display again
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 6: View Modes

### Test 6.1: Grid View

**Steps:**
1. Ensure Grid view is active (button highlighted)
2. Observe item layout

**Expected Results:**
- [ ] Items display in responsive grid (3 columns on desktop)
- [ ] Each item card shows photo, label, description, metadata
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 6.2: List View

**Steps:**
1. Click List view button
2. Observe item layout

**Expected Results:**
- [ ] Items display in single-column list
- [ ] Each item shows same information as grid
- [ ] View toggle button highlights "List"
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 6.3: View Mode Persistence

**Steps:**
1. Select List view
2. Refresh the page
3. Observe view mode after reload

**Expected Results:**
- [ ] List view persists after refresh (localStorage)
- [ ] OR defaults to Grid view (acceptable if not implemented)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 7: Batch Operations & Scheduling

### Test 7.1: Multi-Select Items

**Steps:**
1. Click checkboxes on 3 items with status "Home"
2. Click checkboxes on 2 items with status "Stored"
3. Observe batch action bar

**Expected Results:**
- [ ] Checkboxes toggle on/off correctly
- [ ] Selection count displays: "5 item(s) selected"
- [ ] Batch action bar appears at top of item list
- [ ] "Schedule Pickup" button shows count (3)
- [ ] "Schedule Redelivery" button shows count (2)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 7.2: Batch Pickup (Home Items Only)

**Steps:**
1. With 3 "Home" items selected, click "Schedule Pickup (3)"
2. Verify redirect to Schedule page
3. Verify "Pickup" tab is active
4. Verify selected item count displays

**Expected Results:**
- [ ] Redirects to `/schedule` with state
- [ ] Pickup tab active by default
- [ ] Text shows "3 Item(s) Selected"
- [ ] Form ready to fill
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 7.3: Schedule Pickup Form Submission

**Steps:**
1. On Schedule page (Pickup tab), fill form:
   - Requested Date & Time: 3 days from now at 10:00 AM
   - Special Instructions: "Call when arriving. Use front entrance."
2. Click "Submit Request"

**Expected Results:**
- [ ] Success message displays
- [ ] Redirects back to Dashboard
- [ ] Selection cleared
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 7.4: 48-Hour Notice Enforcement

**Steps:**
1. Select 1 item (any status)
2. Navigate to Schedule page
3. Enter date/time LESS than 48 hours from now (e.g., tomorrow)
4. Click "Submit Request"

**Expected Results:**
- [ ] Error message displays: "Please schedule at least 48 hours in advance"
- [ ] Form does not submit
- [ ] No database record created
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 7.5: Batch Redelivery (Stored Items Only)

**Steps:**
1. Return to Dashboard
2. Select 2 items with status "Stored"
3. Click "Schedule Redelivery (2)"
4. Verify redirect to Schedule page
5. Verify "Redelivery" tab active

**Expected Results:**
- [ ] Redirects to `/schedule`
- [ ] Redelivery tab active
- [ ] Shows "2 Item(s) Selected"
- [ ] Form ready
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 7.6: Schedule Redelivery Form Submission

**Steps:**
1. Fill form:
   - Requested Date & Time: 4 days from now at 2:00 PM
   - Special Instructions: "Deliver to garage. Code: #5678"
2. Click "Submit Request"

**Expected Results:**
- [ ] Success message displays
- [ ] Redirects to Dashboard
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 7.7: Request Empty Containers

**Steps:**
1. Navigate to Schedule page (via nav or button)
2. Click "Request Containers" tab
3. Fill form:
   - Bins: 2
   - Totes: 3
   - Crates: 1
   - Requested Date & Time: 5 days from now at 11:00 AM
   - Special Instructions: "Leave containers on front porch"
4. Click "Submit Request"

**Expected Results:**
- [ ] Form accepts numeric inputs
- [ ] Success message displays
- [ ] Redirects to Dashboard
- [ ] Database record created with service_type = 'container_delivery'
- [ ] Details JSONB contains bins, totes, crates counts
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 7.8: Clear Selection

**Steps:**
1. Select 5 items
2. Click "Clear Selection" button in batch action bar

**Expected Results:**
- [ ] All checkboxes deselect
- [ ] Batch action bar disappears
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 8: Event Logging & Timeline

### Test 8.1: View Item Timeline

**Steps:**
1. Click any item card to open details modal
2. Observe the timeline section

**Expected Results:**
- [ ] Timeline displays chronologically (newest first)
- [ ] "item_created" event appears
- [ ] If item was edited, "item_updated" event appears
- [ ] Event timestamps display correctly (e.g., "Oct 20, 2025")
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 8.2: Event Logging on Creation

**Steps:**
1. Create a new item
2. Immediately open item details modal
3. Check timeline

**Expected Results:**
- [ ] "item_created" event logged automatically
- [ ] Event timestamp matches creation time
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 8.3: Event Logging on Update

**Steps:**
1. Edit an existing item (change label)
2. Save changes
3. Open item details modal
4. Check timeline

**Expected Results:**
- [ ] "item_updated" event appears
- [ ] Event timestamp matches update time
- [ ] Timeline shows both "item_created" and "item_updated"
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 8.4: Event Logging on Deletion

**Note:** Deletion logs event BEFORE deleting, then cascades delete events table

**Steps:**
1. Note the label of an item you plan to delete
2. Delete the item
3. Query `inventory_events` table in Supabase:
   ```sql
   SELECT * FROM inventory_events
   WHERE event_type = 'item_deleted'
   ORDER BY created_at DESC LIMIT 5;
   ```

**Expected Results:**
- [ ] "item_deleted" event exists in database
- [ ] Event_data JSONB contains item label
- [ ] Event is NOT visible in timeline (item deleted, cascade)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 9: QR Code Functionality

### Test 9.1: QR Code Display

**Steps:**
1. Open any item details modal
2. Observe QR code section

**Expected Results:**
- [ ] QR code renders as image/SVG
- [ ] QR code value displayed as text (e.g., "SV-2025-000001")
- [ ] Item label displays above QR code
- [ ] "Download PNG" button visible
- [ ] "Print" button visible
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 9.2: QR Code Download

**Steps:**
1. In item details modal, click "Download PNG"
2. Check browser downloads folder

**Expected Results:**
- [ ] PNG file downloads automatically
- [ ] Filename format: `[QR_CODE]_[LABEL].png` (e.g., "SV-2025-000001_Box-of-Books.png")
- [ ] Image opens correctly in image viewer
- [ ] QR code is scannable (test with phone)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 9.3: QR Code Print

**Steps:**
1. In item details modal, click "Print"
2. Observe print preview/dialog

**Expected Results:**
- [ ] Print dialog opens (or print preview window)
- [ ] QR code visible in preview
- [ ] Item label and QR code text visible
- [ ] Layout is print-friendly (not cut off)
- [ ] Cancel print (don't waste paper)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 9.4: QR Code Scannability

**Steps:**
1. Download QR code as PNG
2. Open PNG on computer screen
3. Use smartphone camera app to scan QR code

**Expected Results:**
- [ ] Phone camera recognizes QR code
- [ ] QR value displays correctly (SV-YYYY-XXXXXX)
- [ ] OR QR scanner app reads code successfully
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 10: Security & RLS (Row-Level Security)

### Test 10.1: Cross-User Item Isolation (Read)

**Setup:**
1. Keep User A logged in (Browser 1)
2. Open incognito/private window (Browser 2)
3. Log in as User B

**Steps:**
1. In Browser 1 (User A), note item IDs from dashboard
2. In Browser 2 (User B), attempt to view User A's items by:
   - Searching for User A's item label
   - Manually navigating to URL with User A's item ID (if URL structure allows)
   - Attempting to fetch via console: `supabase.from('items').select('*').eq('id', '[USER_A_ITEM_ID]')`

**Expected Results:**
- [ ] User B sees ZERO results
- [ ] User B cannot access User A's items by any method
- [ ] No item data leaks across accounts
- [ ] Console shows RLS policy blocking query (or empty result)
- [ ] No console errors (just empty results)

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 10.2: Cross-User Item Isolation (Edit)

**Steps:**
1. As User B (Browser 2), attempt to update User A's item via console:
   ```javascript
   await supabase.from('items')
     .update({ label: 'HACKED' })
     .eq('id', '[USER_A_ITEM_ID]')
   ```

**Expected Results:**
- [ ] Update fails (RLS policy blocks)
- [ ] Error message indicates permission denied
- [ ] User A's item remains unchanged
- [ ] No console errors (just RLS block)

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 10.3: Cross-User Item Isolation (Delete)

**Steps:**
1. As User B (Browser 2), attempt to delete User A's item via console:
   ```javascript
   await supabase.from('items')
     .delete()
     .eq('id', '[USER_A_ITEM_ID]')
   ```

**Expected Results:**
- [ ] Delete fails (RLS policy blocks)
- [ ] Error message indicates permission denied
- [ ] User A's item remains in database
- [ ] No console errors (just RLS block)

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 10.4: Cross-User Profile Isolation

**Steps:**
1. As User B, attempt to read User A's profile via console:
   ```javascript
   await supabase.from('customer_profile')
     .select('*')
     .neq('user_id', '[USER_B_ID]')
   ```

**Expected Results:**
- [ ] Query returns empty (User B cannot see User A's profile)
- [ ] RLS blocks access
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 10.5: Photo Access via Signed URLs

**Steps:**
1. As User A, inspect item photo URL (right-click → Copy Image Address)
2. Note the signed URL (should contain `?token=...`)
3. Wait 1 hour (or manually expire token in Supabase if possible)
4. Refresh page and check if photo still loads

**Expected Results:**
- [ ] Photo URLs contain signed token parameter
- [ ] Token expires after ~1 hour
- [ ] After expiry, photo fails to load (expected behavior)
- [ ] New signed URL generated on page refresh
- [ ] No console errors (except expected 403 after expiry)

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 10.6: Cross-User Photo Access

**Steps:**
1. As User A, copy a photo URL (with signed token)
2. As User B (in incognito), paste URL directly in browser

**Expected Results:**
- [ ] Photo fails to load (RLS blocks access)
- [ ] OR signed URL only works for owner (best case)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 11: Performance & Responsiveness

### Test 11.1: Dashboard Load Time (50+ Items)

**Setup:**
1. Create 50 total items (using quick adds)

**Steps:**
1. Clear browser cache
2. Open dev tools → Network tab
3. Navigate to Dashboard
4. Measure page load time (DOMContentLoaded)

**Expected Results:**
- [ ] Dashboard loads in <5 seconds
- [ ] All items render without lag
- [ ] Photos load progressively (lazy loading acceptable)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Load Time:** _________ seconds

---

### Test 11.2: Search Performance (100+ Items)

**Setup:**
1. Create 100 total items (or use script to bulk-insert)

**Steps:**
1. Type search query in search bar
2. Observe response time after debounce

**Expected Results:**
- [ ] Search results appear within 1 second of debounce
- [ ] No UI lag or freezing
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 11.3: Filter Performance (100+ Items)

**Steps:**
1. With 100+ items loaded, toggle status filters
2. Observe filter response time

**Expected Results:**
- [ ] Filters apply instantly (<500ms)
- [ ] No UI lag
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Test Section 12: Cross-Browser & Mobile Compatibility

### Test 12.1: Chrome (Desktop)

**Steps:**
1. Open portal in Google Chrome
2. Run through key workflows (login, add item, edit, delete, search)

**Expected Results:**
- [ ] All features work correctly
- [ ] No visual glitches
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Version:** _________________

---

### Test 12.2: Safari (Desktop)

**Steps:**
1. Open portal in Safari
2. Run through key workflows

**Expected Results:**
- [ ] All features work correctly
- [ ] Photo upload works
- [ ] No visual glitches
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Version:** _________________

---

### Test 12.3: Firefox (Desktop)

**Steps:**
1. Open portal in Firefox
2. Run through key workflows

**Expected Results:**
- [ ] All features work correctly
- [ ] No visual glitches
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Version:** _________________

---

### Test 12.4: Mobile Safari (iOS)

**Steps:**
1. Open portal on iPhone/iPad
2. Test touch interactions (tap, scroll, swipe)
3. Test photo upload from camera/library

**Expected Results:**
- [ ] Layout responsive (no horizontal scroll)
- [ ] Buttons large enough to tap
- [ ] Photo upload works from mobile
- [ ] All features accessible
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Device:** _________________

---

### Test 12.5: Mobile Chrome (Android)

**Steps:**
1. Open portal on Android device
2. Test touch interactions
3. Test photo upload from camera/gallery

**Expected Results:**
- [ ] Layout responsive
- [ ] Buttons large enough to tap
- [ ] Photo upload works from mobile
- [ ] All features accessible
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Device:** _________________

---

## Test Section 13: Edge Cases & Error Handling

### Test 13.1: Offline Behavior

**Steps:**
1. Disconnect from internet (turn off Wi-Fi)
2. Attempt to load dashboard
3. Attempt to create item
4. Reconnect to internet

**Expected Results:**
- [ ] Error message displays (network error)
- [ ] App does not crash
- [ ] After reconnect, app resumes normal operation
- [ ] No data loss

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 13.2: Session Expiry

**Steps:**
1. Log in as User A
2. Wait for session to expire (or manually expire JWT in Supabase)
3. Attempt to perform action (e.g., create item)

**Expected Results:**
- [ ] Error message displays (session expired)
- [ ] Redirect to login page
- [ ] After re-login, user returns to previous page (if possible)
- [ ] No data loss

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 13.3: Very Long Text Inputs

**Steps:**
1. Create item with:
   - Label: 500 characters
   - Description: 5000 characters
   - Tags: 50 tags

**Expected Results:**
- [ ] Form accepts input (or validates max length)
- [ ] Item card truncates long text appropriately
- [ ] No layout breaking
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

### Test 13.4: Special Characters in Inputs

**Steps:**
1. Create item with special characters:
   - Label: "Box #1 <Test> & "Quotes" 'Apostrophe'"
   - Description: "Test with émojis: 🎉📦✨ and symbols: @#$%^&*()"

**Expected Results:**
- [ ] Special characters save correctly
- [ ] Characters display correctly (no encoding issues)
- [ ] No XSS vulnerabilities (HTML not rendered)
- [ ] No console errors

**Status:** ☐ PASS ✅  ☐ FAIL ❌
**Notes:** _________________________________

---

## Bug Tracking Section

**Instructions:** Document any failures from tests above. Use one row per bug.

| Test # | Bug Description | Severity | Steps to Reproduce | Expected | Actual | Status |
|--------|----------------|----------|-------------------|----------|--------|--------|
| ___ | _____________ | Critical / High / Medium / Low | _____________ | _______ | ______ | Open / Fixed |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |

---

## Final Sign-Off

**Total Tests:** 90+
**Tests Passed:** _______
**Tests Failed:** _______
**Pass Rate:** _______%

**Go/No-Go Decision:** ☐ GO ✅  ☐ NO-GO ❌

**Tester Signature:** _______________________
**Date:** _______________________

**Notes:**
________________________________________________________________
________________________________________________________________
________________________________________________________________

---

**Next Steps:**
- If GO: Proceed to production deployment
- If NO-GO: Review bugs, prioritize fixes, re-test

