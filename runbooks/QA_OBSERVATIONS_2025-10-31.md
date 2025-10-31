# Storage Valet QA Observations — October 31, 2025
**Tester:** Zach Brown  
**Environment:** Production portal (https://portal.mystoragevalet.com)  
**Context:** Post-RLS remediation sanity pass. Findings captured for follow-up triage.

---

## How to Log Additional Findings
When you discover a new issue, add a subsection under **Observed Issues** using this structure:

```
### <Short Issue Name>
- **Environment:** (e.g., Production portal – Chrome 129 / macOS 14.7)
- **Feature/Area:** (e.g., Account page – navigation)
- **Steps:** 
  1. ...
  2. ...
- **Expected:** Describe the desired behaviour.
- **Actual:** Describe what happened instead (include screenshots/console snippet if available).
- **Notes:** Optional diagnostic clues, related tickets, or hypotheses.
```

This format mirrors the 90-case validation checklist and keeps the history audit-ready.

---

## Observed Issues (2025-10-31)

### Account Page Missing Navigation Controls
- **Environment:** Production portal – Comet 1.2 (Chromium), macOS 14.7
- **Feature/Area:** Account page layout / navigation
- **Steps:**
  1. Authenticate via magic link.
  2. Browse directly to `https://portal.mystoragevalet.com/account` (e.g., from email or manual URL entry).
- **Expected:** Primary navigation (Dashboard, Schedule, Account, Logout) visible so users can return to other areas of the app.
- **Actual:** Page renders profile and billing sections only; no nav bar or back link. If the page is opened directly, the user must rely on the browser back button or manually edit the URL.
- **Notes:** Dashboard implements a top navigation bar; Account page likely needs an `AppLayout` or shared header component.
- **Status:** ✅ Resolved Oct 31, 2025 — Introduced shared `AppLayout` navigation wrapper and applied to Dashboard, Schedule, Account pages.

### Item Photo Upload Accepted but Not Displayed
- **Environment:** Production portal – Comet 1.2 (Chromium), macOS 14.7
- **Feature/Area:** Dashboard item gallery / photo rendering
- **Steps:**
  1. Add a new inventory item via Dashboard (`Add Item` modal) and attach a JPG photo (<5 MB).
  2. Submit the item and return to the dashboard card view.
- **Expected:** Item card displays the uploaded photo (or at minimum a thumbnail placeholder referencing the uploaded path).
- **Actual:** Item card shows “No Photo.” Upload succeeds (no error toast) but the dashboard never loads the asset.
- **Notes:** Potential regression from multi-photo migration (photo paths stored in `photo_paths[]` vs. `photo_path`); confirm Supabase storage insert/logs for the uploaded file.

### Item Dimensions Not Converting to Cubic Feet
- **Environment:** Production portal – Comet 1.2 (Chromium), macOS 14.7
- **Feature/Area:** Dashboard item card calculated metrics
- **Steps:**
  1. Add an item with dimensions (Length = 12", Width = 15", Height = 24").
  2. Observe the metric summary on the resulting card.
- **Expected:** Volume displayed as a positive cubic-foot value (e.g., 2.5 cu ft).
- **Actual:** Card reports “0.0 cu ft” despite non-zero dimensions; only weight renders correctly.
- **Notes:** Investigate client-side volume calculation (likely `length_inches * width_inches * height_inches / 1728`). Check for missing data mapping from `photo_paths` update or type conversion (numbers stored as text?).

---

## Next Steps
1. Assign each issue to the appropriate sprint or bug-fix ticket.
2. Add regression tests to the Phase‑1 validation checklist once fixes ship.
3. Retest after fixes and append results (e.g., `✅ Resolved in commit …`).
