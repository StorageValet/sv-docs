# Phase-1 Physical Data Requirements (Addendum to v3.1)

**Status**: ACTIVE
**Version**: 1.0
**Date**: 2025-10-18
**Supersedes**: None (extends v3.1)

---

## Purpose

Make weight and dimensions non-negotiable for every item/container. Compute cubic feet for capacity and logistics. Lock these values after pickup confirmation to maintain data integrity for operations and insurance.

---

## Requirements

### Physical Data Fields (Already Implemented in Migration 0003)

**Required Fields** (all must be > 0):
- `weight_lbs` — numeric(7,2), NOT NULL, CHECK (weight_lbs > 0)
- `length_inches` — numeric(7,2), NOT NULL, CHECK (length_inches > 0)
- `width_inches` — numeric(7,2), NOT NULL, CHECK (width_inches > 0)
- `height_inches` — numeric(7,2), NOT NULL, CHECK (height_inches > 0)

**Derived Field** (auto-calculated):
- `cubic_feet` — numeric, GENERATED ALWAYS AS (((length_inches × width_inches × height_inches) / 1728.0)) STORED

### Photo Requirements (Phase-1 Enhancement)

**Multi-Photo Support**:
- Minimum: 1 photo per item
- Maximum: 5 photos per item
- File size: ≤5MB each
- Formats: JPG, PNG, WebP only
- HEIC: Rejected with friendly error message

**Storage**:
- Private bucket: `item-photos`
- Path format: `{user_id}/{timestamp}_{index}.{ext}`
- Render via signed URLs (1-hour expiry)
- RLS enforced: owner-only access

### Physical Data Lock

**Lock Trigger**: When first pickup action involving the item is marked as `completed`.

**Locked Fields**:
- `weight_lbs`
- `length_inches`
- `width_inches`
- `height_inches`
- `cubic_feet` (auto-derived, so locked implicitly)

**Lock Mechanism**:
- Column: `physical_locked_at` (timestamptz)
- Set to `now()` when pickup completed
- Trigger: `prevent_physical_edits_after_pickup()` blocks updates if `physical_locked_at IS NOT NULL`

**UI Behavior**:
- Locked items show lock icon 🔒
- Physical fields disabled in edit modal
- Tooltip: "Physical dimensions locked after pickup confirmation"

**Unlocking** (admin-only, via Retool):
- Staff can clear `physical_locked_at` if customer provides corrected measurements with photo evidence
- Requires supervisor approval
- Logged in `inventory_events` as `physical_unlock` event

---

## Validation

### Client-Side (Portal)
- Inline validation on Add/Edit forms
- Real-time cubic feet preview as user types dimensions
- Error messages for invalid values (zero, negative, too large)
- Photo upload validation (size, format)

### Server-Side (Database)
- Column CHECK constraints enforce `> 0` for all physical fields
- NOT NULL constraints prevent missing data
- Trigger blocks physical edits if `physical_locked_at` is set
- RLS policies: owner-only reads/writes
- Storage RLS: owner-only photo access

### Business Rules
1. **Insurance Requirement**: If `estimated_value_cents > 10000` (>$100), at least 1 photo required
2. **Capacity Calculation**: `SUM(cubic_feet)` per customer vs. allocated storage space
3. **Weight Limits**: Single item max 500 lbs (soft limit, warn user); truck capacity planning uses total weight

---

## Operations & Analytics Use Cases

### Capacity Dashboards (Retool)
- **Per-Customer View**: SUM(cubic_feet) vs. plan allocation (e.g., 100 ft³ included)
- **Warehouse View**: Total cubic feet stored; utilization %
- **Forecasting**: Cubic feet growth rate; capacity needs

### Route Planning
- **Daily Pickup/Delivery**: Total weight per route for truck/crew capacity
- **Optimization**: Geographic clustering + weight constraints
- **Safety**: Flag items >100 lbs for 2-person lift

### Insurance Exposure
- **Total At-Risk Value**: SUM(estimated_value_cents) per customer vs. $3,000 cap
- **Underinsured Items**: Items >$100 without photos
- **Claims Support**: Physical data + photos for damage assessment

### Margin Analysis
- **Storage Density**: Revenue per cubic foot
- **High-Value Items**: Items >$500 requiring extra care
- **Inefficient Storage**: Large, low-value items (e.g., mattresses)

---

## Migration Path

### Existing Data (Pre-Phase-1)
All items created after Migration 0003 (Oct 17, 2025) already have:
- ✅ Physical dimensions (required, validated)
- ✅ Cubic feet (auto-calculated)
- ✅ Single photo (required)

### Phase-1 Enhancements
- ✅ Add `photo_paths text[]` for multi-photo support
- ✅ Backfill existing `photo_path` → `photo_paths[1]`
- ✅ Relax `photo_path NOT NULL` (keep for backward compatibility)
- ✅ Add `physical_locked_at timestamptz`
- ✅ Add trigger to enforce lock

### Future Data
All new items (Phase-1 onward) will:
- Use `photo_paths[]` (1-5 photos)
- Have `physical_locked_at` set when first pickup completes
- Support full edit/delete until locked

---

## Go/No-Go Criteria

**Phase-1 Launch Requirements**:
- [ ] New item creation requires weight + dimensions (all > 0)
- [ ] Cubic feet auto-computed with ±0.01 accuracy tolerance
- [ ] Multi-photo upload (1-5) works; >5MB or invalid format rejected
- [ ] Physical fields lock after first pickup completion
- [ ] Locked items show lock icon; edit modal disables physical fields
- [ ] RLS verified: User A can't edit User B's physical data
- [ ] Storage RLS verified: User A can't access User B's photos

---

## Examples

### Valid Item Entry
```
Label: "Box of Books"
Weight: 25 lbs
Dimensions: 24" × 18" × 12"
Cubic Feet: 3.00 (auto-calculated)
Photos: 2 uploaded (front, label closeup)
Estimated Value: $50
Status: home
```

### Locked Item (After Pickup)
```
Label: "Box of Books"
Physical Data: 🔒 Locked (Oct 20, 2025)
  Weight: 25 lbs
  Dimensions: 24" × 18" × 12"
  Cubic Feet: 3.00
Photos: 3 (can still add/remove)
Estimated Value: $50 (editable)
Status: stored
```

### Invalid Entries (Rejected)
```
❌ Weight: 0 lbs (must be > 0)
❌ Dimensions: 24" × 18" × 0" (height must be > 0)
❌ Photos: 6 uploaded (max 5 allowed)
❌ Photo: 8MB file (max 5MB per photo)
❌ Photo: .heic format (must be JPG/PNG/WebP)
```

---

## References

- **v3.1 Master Plan**: `SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md`
- **Migration 0003**: `sv-db/migrations/0003_item_req_insurance_qr.sql`
- **Migration 0004**: `sv-db/migrations/0004_phase1_inventory_enhancements.sql`
- **Validation Checklist**: `FINAL_VALIDATION_CHECKLIST_v3.1_PHASE1.md`
