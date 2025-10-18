# Final Validation Checklist — Phase 1.0

**Status**: ACTIVE
**Version**: 1.0
**Date**: 2025-10-18
**Supersedes**: FINAL_VALIDATION_CHECKLIST_v3.1.md (extends with Phase-1 items)
**Source of Truth**: SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md + Phase-1 addenda

---

## Phase 0.6 — Hard Gates (all required, verified Oct 13, 2025)

| Gate | PASS ☑ / FAIL ☐ | Notes |
|------|------------------|-------|
| 1) `create-portal-session` Edge Function opens Stripe **Hosted Customer Portal** from `/account` | ☑ | Verified 2025-10-13 |
| 2) **Signed-URL** photo policy + **Storage RLS**: owner-only access; signed URLs ~1h expiry | ☑ | Verified 2025-10-13 |
| 3) `create-checkout` Edge Function callable from **Webflow CTA** (no secrets in Webflow) | ☑ | Verified 2025-10-13 |
| 4) **Webhook idempotency**: unique `webhook_events(event_id)`, log-first, duplicate short-circuit | ☑ | Verified 2025-10-13 |
| 5) **Magic-link deliverability** ≤120s across Gmail/Outlook/iCloud/Yahoo/Proton | ☑ | Gmail 4s, Outlook 4s, iCloud 8s, Yahoo 10s, Proton 6s |
| 6) **Photo validation**: ≤5MB; JPG/PNG/WebP; HEIC rejected by default | ☑ | Implemented in AddItemModal |

---

## Phase 0.6.1 — Item Creation Feature (Code Complete Oct 17, 2025)

| Item | PASS ☑ / FAIL ☐ | Notes |
|------|------------------|-------|
| 1) **Migration 0003** applied: required fields (value, weight, dims) + insurance tracking | ☑ | Applied 2025-10-17 |
| 2) **QR code auto-generation**: format SV-YYYY-XXXXXX, unique, sequential | ☑ | Tested: SV-2025-000001, SV-2025-000002 |
| 3) **AddItemModal component**: photo upload + all required field validation | ☑ | Built, TypeScript compiles |
| 4) **Dashboard integration**: insurance bar + FAB button + modal | ☑ | Code complete, deployed Oct 18 |
| 5) **ItemCard metadata display**: QR, cubic feet, weight, value | ☑ | Code complete, deployed Oct 18 |
| 6) **Performance indexes**: user_created_at, tags_gin, details_gin | ☑ | Applied to database |
| 7) **Brand colors applied**: Velvet Night, Deep Harbor, Chalk Linen, etc. | ☑ | Tailwind config updated |
| 8) **Insurance tracking**: $3,000 cap, progress bar, no dollar amounts shown | ☑ | View + function created, tested |
| 9) **Vercel deployment**: latest code served in production | ☐ | **Pending manual redeploy** |
| 10) **E2E testing**: smoke test checklist (12 sections) executed | ☐ | Pending deployment fix |

---

## Phase 1.0 — Enhanced Customer Portal (Target: Oct 25, 2025)

### I. Physical Data Integrity

| Requirement | PASS ☐ / FAIL ☐ | Notes |
|-------------|------------------|-------|
| New item requires `weight_lbs` and L/W/H; all > 0 | ☐ | Client + server validation |
| `cubic_feet` auto-computed correctly (±0.01 tolerance) | ☐ | GENERATED column formula verified |
| Physical fields lock after first pickup completion | ☐ | Trigger + UI enforcement |
| Locked items show lock icon; edit modal disables physical fields | ☐ | UI feedback clear |
| Locked items cannot modify weight/dimensions (server-side enforcement) | ☐ | Trigger blocks UPDATE |

### II. Multi-Photo Management

| Requirement | PASS ☐ / FAIL ☐ | Notes |
|-------------|------------------|-------|
| Multi-photo (1–5) upload works in Add Item | ☐ | Photo gallery component |
| Photos >5MB rejected with error message | ☐ | Client-side validation |
| Non-JPG/PNG/WebP formats rejected (HEIC, etc.) | ☐ | MIME type check |
| Existing single-photo items display correctly | ☐ | Backward compatibility |
| Add/remove photos after item creation | ☐ | Edit modal supports photo management |
| All photos render via signed URLs (1h expiry) | ☐ | Storage RLS enforced |
| Cross-tenant photo access blocked | ☐ | RLS verification |

### III. Inventory CRUD Operations

| Requirement | PASS ☐ / FAIL ☐ | Notes |
|-------------|------------------|-------|
| Create item with all required fields | ☐ | AddItemModal validation |
| Edit item: update description, category, value | ☐ | EditItemModal component |
| Edit item: cannot modify locked physical fields | ☐ | UI + trigger enforcement |
| Delete item with confirmation modal | ☐ | DeleteConfirmModal component |
| Delete cascades to photos and events | ☐ | Database FK constraints |
| RLS: User A cannot edit/delete User B's items | ☐ | Security verification |

### IV. Item Status & Movement

| Requirement | PASS ☐ / FAIL ☐ | Notes |
|-------------|------------------|-------|
| Status badge displays correctly (Home / In-Transit / Stored) | ☐ | Color-coded badges |
| Status auto-updates when pickup action completed | ☐ | Trigger or app logic |
| Status auto-updates when redelivery completed | ☐ | Trigger or app logic |
| Movement history timeline displays all events | ☐ | ItemTimeline component |
| Events logged automatically: create, update, delete | ☐ | Event logging helpers |
| Events logged for scheduled actions | ☐ | Pickup/redelivery tracking |

### V. Batch Operations & Service Scheduling

| Requirement | PASS ☐ / FAIL ☐ | Notes |
|-------------|------------------|-------|
| Multi-select items on Dashboard | ☐ | Checkbox selection UI |
| "Schedule Pickup" button enabled for Home items | ☐ | Conditional button state |
| "Schedule Redelivery" button enabled for Stored items | ☐ | Filter by status |
| Batch pickup persists `item_ids[]` array | ☐ | actions table schema |
| Batch redelivery persists `item_ids[]` array | ☐ | actions table schema |
| Empty-container request flow saves `service_type='container_delivery'` | ☐ | Service type validation |
| 48-hour minimum notice enforced (from `config_schedule`) | ☐ | Date picker validation |
| Batch actions appear as single request with multiple items | ☐ | UI display |

### VI. Search & Filtering

| Requirement | PASS ☐ / FAIL ☐ | Notes |
|-------------|------------------|-------|
| Keyword search works across label, description, tags | ☐ | Debounced search (300ms) |
| Status filter chips (All / Home / In-Transit / Stored) | ☐ | FilterChips component |
| Category filter chips work | ☐ | Category-based filtering |
| Combined filters work (e.g., Electronics + Stored) | ☐ | AND logic |
| Search results update in real-time | ☐ | React Query integration |
| Grid/list view toggle persists on refresh | ☐ | localStorage persistence |

### VII. Account & Profile Management

| Requirement | PASS ☐ / FAIL ☐ | Notes |
|-------------|------------------|-------|
| Profile fields editable: name, phone, address, instructions | ☐ | ProfileEditForm component |
| Profile updates persist to `customer_profile` table | ☐ | Save mutation |
| Validation: phone format, required fields | ☐ | Client-side validation |
| "Manage Billing" button still opens Stripe Customer Portal | ☐ | Unchanged from v3.1 |
| RLS: User A cannot edit User B's profile | ☐ | Security verification |

### VIII. QR Codes & Printing

| Requirement | PASS ☐ / FAIL ☐ | Notes |
|-------------|------------------|-------|
| QR code displays on ItemCard | ☐ | Already in Phase 0.6.1 |
| QR code printable (opens print dialog) | ☐ | QRCodeDisplay component |
| QR code downloadable as PNG | ☐ | Download button |
| QR code scannable with phone camera | ☐ | Physical test |
| QR format correct: SV-YYYY-XXXXXX | ☐ | Format validation |

---

## Go / No-Go (all must be green)

| Verification | PASS ☐ / FAIL ☐ | Notes |
|--------------|------------------|-------|
| Magic links arrive ≤120s across 5 providers | ☑ | Already verified Phase 0.6 |
| `/account` → Hosted Customer Portal opens via **server-generated session URL** | ☑ | Already verified Phase 0.6 |
| Checkout → webhook → profile upsert is **idempotent** (no duplicates) | ☑ | Already verified Phase 0.6 |
| Dashboard renders item photos via **signed URLs**; **RLS** isolation verified | ☐ | Multi-photo verification needed |
| Vercel SPA deep-link routing works (no 404 on refresh) | ☐ | Test with /items/:id routes |
| 50 items render in <5s on commodity devices | ☐ | Performance benchmark |
| All Phase-1 CRUD operations work under RLS | ☐ | Security audit |
| Batch operations persist correctly | ☐ | Data integrity check |
| Physical lock enforcement prevents edits | ☐ | Trigger verification |
| Search/filter performance acceptable with 100+ items | ☐ | Load test |

---

## Decision

**Phase 0.6**: ☑ **GO** (verified Oct 13, 2025)
**Phase 0.6.1**: ☐ **GO** / ☐ **NO-GO** (pending Vercel deployment fix)
**Phase 1.0**: ☐ **GO** / ☐ **NO-GO** (in progress)

---

## Notes

- If any "Hard Gate" fails → NO-GO
- Resolve discrepancies in favor of `SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md`
- Phase-1 addenda take precedence for new features not in v3.1
- All v3.1 constraints remain: Stripe Hosted only, RLS enforced, signed URLs, 4 routes
