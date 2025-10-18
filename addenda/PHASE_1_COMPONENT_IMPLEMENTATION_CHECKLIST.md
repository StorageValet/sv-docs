# Phase-1 Component Implementation Checklist

**Status**: ACTIVE
**Version**: 1.0
**Date**: 2025-10-18
**Purpose**: Track frontend component development for Phase-1 features

---

## Sprint 1: Core CRUD Operations

### Multi-Photo Support
- [ ] **lib/supabase.ts** - Multi-photo helpers
  - [ ] `uploadItemPhotos(userId: string, files: File[]): Promise<string[]>` - Upload 1-5 photos, return paths
  - [ ] `getItemPhotoUrls(photoPaths: string[]): Promise<string[]>` - Generate signed URLs for array
  - [ ] `deleteItemPhoto(photoPath: string): Promise<void>` - Remove single photo from storage
  - [ ] Update `validatePhotoFile()` to handle array validation

### Item Creation & Editing
- [ ] **components/AddItemModal.tsx** - Enhanced for multi-photo
  - [ ] Support 1-5 photo uploads (array state)
  - [ ] Photo preview gallery during upload
  - [ ] Remove photo button for each preview
  - [ ] Validation: max 5 photos, each ≤5MB
  - [ ] Write to `photo_paths[]` array
  - [ ] Backward compatibility: read from `photo_path` if `photo_paths` empty

- [ ] **components/EditItemModal.tsx** - NEW
  - [ ] Load existing item data
  - [ ] Reuse AddItemModal form logic (shared form component?)
  - [ ] Check `physical_locked_at` - disable weight/dimensions if locked
  - [ ] Show lock icon 🔒 on locked fields with tooltip
  - [ ] Support adding photos (up to 5 total)
  - [ ] Support removing photos (min 1 must remain)
  - [ ] Update mutation with validation
  - [ ] Success toast notification

### Item Deletion
- [ ] **components/DeleteConfirmModal.tsx** - NEW
  - [ ] Display item details (label, photo, QR code)
  - [ ] Warning text: "This will delete X photos and movement history"
  - [ ] Confirm button (destructive styling)
  - [ ] Cancel button
  - [ ] Loading state during deletion
  - [ ] Success toast notification
  - [ ] Error handling

### Dashboard Integration
- [ ] **pages/Dashboard.tsx** - Add CRUD buttons
  - [ ] "Edit" button on ItemCard (or click-to-edit)
  - [ ] "Delete" button on ItemCard (trash icon)
  - [ ] Wire up EditItemModal
  - [ ] Wire up DeleteConfirmModal
  - [ ] Invalidate queries after edit/delete

### Database Trigger (in Migration 0004)
- [ ] `prevent_physical_edits_after_pickup()` trigger function
- [ ] Blocks UPDATE on weight/dimensions if `physical_locked_at IS NOT NULL`
- [ ] Returns helpful error message

---

## Sprint 2: Batch Operations & Service Flows

### Item Status Display
- [ ] **components/ItemCard.tsx** - Status badge
  - [ ] Display status badge (Home / In-Transit / Stored)
  - [ ] Color coding: green (home), yellow (in-transit), blue (stored)
  - [ ] Icon for each status
  - [ ] Responsive sizing

### Batch Selection
- [ ] **pages/Dashboard.tsx** - Multi-select UI
  - [ ] Checkbox column on item grid
  - [ ] "Select All" checkbox in header
  - [ ] Selected count badge (e.g., "3 items selected")
  - [ ] "Schedule Pickup" button (enabled if any Home items selected)
  - [ ] "Schedule Redelivery" button (enabled if any Stored items selected)
  - [ ] Clear selection button
  - [ ] Pass `selectedItemIds` to Schedule page via navigate state

### Service Scheduling Refactor
- [ ] **pages/Schedule.tsx** - Tabbed interface
  - [ ] Tab UI: Pickup | Redelivery | Containers
  - [ ] Accept `selectedItemIds` from Dashboard (via location.state)
  - [ ] Show selected items summary (read-only list)
  - [ ] Tab 1: Pickup flow
    - [ ] Date/time picker (48h minimum from config)
    - [ ] Special instructions textarea
    - [ ] Submit creates action with `service_type='pickup'`, `item_ids[]`
  - [ ] Tab 2: Redelivery flow
    - [ ] Similar to pickup
    - [ ] Filter: only items with status='stored'
    - [ ] Submit creates action with `service_type='redelivery'`
  - [ ] Tab 3: Container Delivery flow
    - [ ] Container type selector (Bins / Totes / Crates)
    - [ ] Quantity spinner for each type
    - [ ] Delivery date picker
    - [ ] Submit creates action with `service_type='container_delivery'`
    - [ ] Store container details in `details` jsonb

---

## Sprint 3: Search, Filters & Account

### Search Functionality
- [ ] **components/SearchBar.tsx** - NEW
  - [ ] Text input with search icon
  - [ ] Debounced onChange (300ms delay)
  - [ ] Clear button (X icon)
  - [ ] Keyboard shortcut: Cmd/Ctrl+K to focus
  - [ ] Placeholder: "Search items..."
  - [ ] Search across: label, description, tags, category

### Filter System
- [ ] **components/FilterChips.tsx** - NEW
  - [ ] Status chips: All | Home | In-Transit | Stored
  - [ ] Category chips: All | Furniture | Electronics | Documents | etc.
  - [ ] Active state styling (filled background)
  - [ ] Click to toggle filter
  - [ ] "Clear All Filters" button
  - [ ] Filter count badge (e.g., "2 filters active")

### Dashboard Integration
- [ ] **pages/Dashboard.tsx** - Search & Filter
  - [ ] Integrate SearchBar at top of page
  - [ ] Integrate FilterChips below search
  - [ ] Filter items client-side (or server if >100 items)
  - [ ] Show filtered count: "Showing 12 of 45 items"
  - [ ] Empty state: "No items match your search"

### View Toggle
- [ ] **pages/Dashboard.tsx** - Grid/List toggle
  - [ ] Toggle button: Grid icon | List icon
  - [ ] Grid view: Current 3-column responsive layout
  - [ ] List view: Compact rows with inline metadata
  - [ ] Persist preference in localStorage (`viewMode`)
  - [ ] Load preference on mount

### Account Profile Editor
- [ ] **components/ProfileEditForm.tsx** - NEW
  - [ ] Editable fields:
    - [ ] Full name (text input)
    - [ ] Phone (formatted input with validation)
    - [ ] Delivery address (structured: street, city, state, zip, unit)
    - [ ] Delivery instructions (textarea)
  - [ ] Validation:
    - [ ] Phone format: (XXX) XXX-XXXX
    - [ ] Required: name, phone, street, city, state, zip
    - [ ] Optional: unit, instructions
  - [ ] Save button with loading state
  - [ ] Cancel button (revert changes)
  - [ ] Success toast notification
  - [ ] Error handling

- [ ] **pages/Account.tsx** - Profile editor integration
  - [ ] Replace read-only profile card with ProfileEditForm
  - [ ] Keep "Manage Billing" button (unchanged from v3.1)
  - [ ] Keep plan details card
  - [ ] Layout: Profile section → Billing section

### Category Support
- [ ] **Predefined categories**: Furniture, Electronics, Documents, Clothing, Kitchen, Sports, Other
- [ ] **components/AddItemModal.tsx** - Category dropdown
  - [ ] Select dropdown with category options
  - [ ] Optional field (can be null)
- [ ] **components/EditItemModal.tsx** - Category dropdown
  - [ ] Same as Add modal
- [ ] **components/FilterChips.tsx** - Category chips
  - [ ] Dynamic category chips based on available categories
  - [ ] Show count per category (e.g., "Electronics (5)")

---

## Sprint 4: Movement History & QR Codes

### Event Logging
- [ ] **lib/supabase.ts** - Event helpers
  - [ ] `logInventoryEvent(itemId, eventType, eventData)` - Insert event
  - [ ] Event types:
    - [ ] `created` - Item created
    - [ ] `updated` - Item updated (include changed fields in eventData)
    - [ ] `deleted` - Item deleted
    - [ ] `pickup_scheduled` - Pickup action created
    - [ ] `redelivery_scheduled` - Redelivery action created
    - [ ] `delivered` - Item delivered to warehouse (future: from ops)
    - [ ] `returned` - Item returned to customer (future: from ops)
  - [ ] Auto-log on all CRUD operations
  - [ ] Auto-log when actions created

### Movement Timeline
- [ ] **components/ItemTimeline.tsx** - NEW
  - [ ] Query `inventory_events` by item_id
  - [ ] Display chronological timeline (newest first)
  - [ ] Event icons for each type
  - [ ] Format: "Created • Oct 17, 2025 at 2:30 PM"
  - [ ] Event descriptions:
    - [ ] "Item created"
    - [ ] "Updated: changed description, category"
    - [ ] "Pickup scheduled for Oct 20, 2025"
    - [ ] "Delivered to warehouse"
    - [ ] etc.
  - [ ] Responsive layout (vertical timeline)
  - [ ] Empty state: "No activity yet"

### QR Code Display
- [ ] **Add dependency**: `qrcode.react` or `react-qr-code`
  - [ ] Run `npm install qrcode.react`
  - [ ] Update package.json

- [ ] **components/QRCodeDisplay.tsx** - NEW
  - [ ] Generate QR from `item.qr_code` text (e.g., "SV-2025-000001")
  - [ ] Large, scannable QR code (256x256 or larger)
  - [ ] Item metadata below QR: label, QR code text
  - [ ] Print button (opens print dialog)
  - [ ] Download as PNG button (triggers download)
  - [ ] Close button (if modal)
  - [ ] Print-friendly CSS (@media print)

- [ ] **components/ItemCard.tsx** - QR access
  - [ ] "View QR" button or icon
  - [ ] Opens QRCodeDisplay modal

### Item Detail View
- [ ] **components/ItemDetailModal.tsx** - NEW (or enhance ItemCard)
  - [ ] Large photo gallery (all photos, carousel)
  - [ ] Item metadata (all fields)
  - [ ] QR code display (inline or button to open QRCodeDisplay)
  - [ ] Movement timeline (ItemTimeline component)
  - [ ] Edit/Delete buttons
  - [ ] Close button
  - [ ] Responsive layout (mobile-friendly)

---

## Testing Checklist (All Sprints)

### Sprint 1 Testing
- [ ] Create item with 3 photos → success
- [ ] Create item with 6 photos → error (max 5)
- [ ] Upload 8MB photo → error (max 5MB)
- [ ] Upload HEIC photo → error (format rejected)
- [ ] Edit item: change description, add 2 more photos → success
- [ ] Edit locked item: physical fields disabled → success
- [ ] Delete item → confirmation modal → deleted with cascade
- [ ] RLS: User A can't edit/delete User B's items → verified

### Sprint 2 Testing
- [ ] Select 5 Home items, schedule pickup → single action with item_ids[5]
- [ ] Select 3 Stored items, schedule redelivery → single action
- [ ] Request 10 bins + 5 totes → container_delivery action
- [ ] Validation: can't schedule pickup for Stored items → error
- [ ] Validation: 48h minimum notice enforced → error if sooner
- [ ] RLS: User A can't see User B's actions → verified

### Sprint 3 Testing
- [ ] Search "box" → returns matching items
- [ ] Filter by "Stored" → only stored items shown
- [ ] Filter by "Electronics" + "Stored" → AND logic works
- [ ] Toggle grid/list view → persists on refresh
- [ ] Edit profile: update name, phone, address → saves successfully
- [ ] Invalid phone format → error
- [ ] RLS: User A can't edit User B's profile → verified

### Sprint 4 Testing
- [ ] Create item → event logged as "created"
- [ ] Edit item → event logged as "updated" with changes
- [ ] Schedule pickup → event logged as "pickup_scheduled"
- [ ] Timeline shows all events chronologically → success
- [ ] QR code scannable with phone camera → verified
- [ ] Print QR → clean print layout
- [ ] Download QR as PNG → file downloads
- [ ] RLS: User A can't see User B's events → verified

---

## Component Dependencies Summary

### New Dependencies to Add
1. `qrcode.react` or `react-qr-code` (QR code generation)
2. `date-fns` (optional, for date formatting in timeline)

### Existing Dependencies (Keep)
1. `@supabase/supabase-js` (backend)
2. `@tanstack/react-query` (data fetching)
3. `react` (UI library)
4. `react-dom` (DOM rendering)
5. `react-router-dom` (routing)
6. `tailwindcss` (styling)

**Total Dependencies**: 8 prod deps (up from 6, still very lean)

---

## File Count Summary

### New Components (11 files)
1. EditItemModal.tsx
2. DeleteConfirmModal.tsx
3. SearchBar.tsx
4. FilterChips.tsx
5. ProfileEditForm.tsx
6. ItemTimeline.tsx
7. QRCodeDisplay.tsx
8. ItemDetailModal.tsx (optional, can enhance ItemCard instead)

### Modified Components (5 files)
1. AddItemModal.tsx (multi-photo)
2. ItemCard.tsx (status badge, QR button, edit/delete buttons)
3. Dashboard.tsx (search, filters, batch selection)
4. Schedule.tsx (tabs, batch flows)
5. Account.tsx (profile editor)

### Modified Utilities (1 file)
1. lib/supabase.ts (multi-photo helpers, event logging)

**Total New Files**: ~11
**Total Modified Files**: ~6
**Previous File Count**: 11 src files
**New File Count**: ~22 src files

---

## Success Criteria

All checklist items above must be ☑ before Phase-1 launch.
