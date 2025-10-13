# Storage Valet v3.1 — Phase 0.6 Gates Documentation

**Status:** Implementation Complete (Pending Live Testing)
**Date:** 2025-10-11

---

## Gate 1: Stripe Customer Portal Session Function ✅

### Implementation

**File:** `sv-edge/functions/create-portal-session/index.ts`

**Flow:**
1. Extract authenticated user from Supabase JWT
2. Query `customer_profile.stripe_customer_id`
3. Call `stripe.billingPortal.sessions.create()`
4. Return short-lived session URL (~5 min expiry)

**Portal Integration:**
- **File:** `sv-portal/src/pages/Account.tsx`
- **Trigger:** "Manage Billing" button
- **Auth:** Passes `session.access_token` in Authorization header
- **Redirect:** `window.location.href = data.url`

### Validation Test

```bash
# 1. Log in to portal as test user
# 2. Navigate to /account
# 3. Click "Manage Billing"
# 4. Verify redirect to https://billing.stripe.com/p/session/xxxxx
# 5. Verify Customer Portal displays subscription details
```

**Success Criteria:**
- [ ] Button click triggers Edge Function
- [ ] Function returns valid session URL
- [ ] User redirected to Stripe Customer Portal
- [ ] Portal shows subscription status, payment methods, invoices

---

## Gate 2: Signed-URL Photo Policy + Storage RLS ✅

### Implementation

**Migration:** `sv-db/migrations/0002_storage_rls.sql`
- Private `item-photos` bucket
- RLS policies: owner-only SELECT/INSERT/UPDATE/DELETE
- Path format: `{user_id}/{item_id}.{ext}`

**Portal Helpers:** `sv-portal/src/lib/supabase.ts`
```typescript
// Signed URL generation (1h expiry)
export async function getItemPhotoUrl(photoPath: string): Promise<string | null> {
  const { data } = await supabase.storage
    .from('item-photos')
    .createSignedUrl(photoPath, 3600)
  return data.signedUrl
}
```

**Usage:** `sv-portal/src/components/ItemCard.tsx`
- Fetches signed URL on component mount
- Displays photo via `<img src={photoUrl} />`
- URL auto-expires after 1 hour

### Validation Test

```bash
# Test 1: Owner access
curl -H "Authorization: Bearer USER_A_TOKEN" \
  https://YOUR_PROJECT.supabase.co/storage/v1/object/item-photos/USER_A_ID/photo.jpg
# Expected: 200 OK (RLS allows)

# Test 2: Cross-tenant access (direct URL)
curl -H "Authorization: Bearer USER_B_TOKEN" \
  https://YOUR_PROJECT.supabase.co/storage/v1/object/item-photos/USER_A_ID/photo.jpg
# Expected: 403 Forbidden (RLS blocks)

# Test 3: Signed URL access (as owner)
curl "https://...signedUrl...with-token"
# Expected: 200 OK, image returned

# Test 4: Signed URL expiry (after 1h)
# Expected: 403 or 404 (token expired)
```

**Success Criteria:**
- [ ] Direct URL access blocked by RLS for non-owners
- [ ] Signed URLs work for authorized users
- [ ] Signed URLs expire after 1 hour
- [ ] Portal renders photos via signed URLs only

---

## Gate 3: Checkout Function (Webflow CTA) ✅

### Implementation

**File:** `sv-edge/functions/create-checkout/index.ts`

**Flow:**
1. Accept optional `email`, `referral_code`, `promo_code` from request body
2. Retrieve `STRIPE_PRICE_PREMIUM299` from environment
3. Create Stripe Checkout Session:
   - Mode: `subscription`
   - Line item: `{ price: STRIPE_PRICE_PREMIUM299, quantity: 1 }`
   - Success URL: `{APP_URL}/dashboard?session_id={CHECKOUT_SESSION_ID}`
   - Cancel URL: `{APP_URL}` or `https://mystoragevalet.com`
   - Metadata: `{ referral_code, promo_code }`
4. Return `{ url: session.url }`

**No Secrets in Webflow:**
- Webflow only calls public Edge Function URL
- Stripe Price ID stored in Supabase secrets
- No API keys exposed client-side

### Validation Test

```bash
# Test from Webflow or direct API call
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/create-checkout \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","referral_code":"FRIEND10"}'

# Expected response:
{
  "url": "https://checkout.stripe.com/c/pay/cs_test_xxxxx"
}

# Navigate to URL, complete checkout
# Verify webhook fires and customer profile created
```

**Success Criteria:**
- [ ] Function returns valid Stripe Checkout URL
- [ ] Metadata (referral_code) appears in Stripe Dashboard → Event logs
- [ ] Success redirect goes to `{APP_URL}/dashboard`
- [ ] Cancel redirect goes to `{APP_URL}` or marketing site

---

## Gate 4: Webhook Idempotency ✅

### Implementation

**File:** `sv-edge/functions/stripe-webhook/index.ts`

**Idempotency Pattern (Log-First):**
1. Verify webhook signature
2. **Insert `event_id` into `billing.webhook_events`** (UNIQUE constraint)
3. If insert fails with code `23505` (duplicate key):
   - Log: `Duplicate event {id}, skipping`
   - Return: `{ ok: true, duplicate: true }`
4. If insert succeeds:
   - Process event (create user, upsert profile, send magic link)
   - Return: `{ ok: true }`

**Database Constraint:** `sv-db/migrations/0001_init.sql`
```sql
CREATE TABLE billing.webhook_events (
  event_id text UNIQUE NOT NULL,  -- ← Prevents duplicates
  ...
);
```

### Validation Test

```bash
# Use Stripe CLI to send same event twice
stripe trigger checkout.session.completed

# Capture event ID from logs
# Replay same event ID (Stripe retries webhook)

# Check Supabase function logs
supabase functions logs stripe-webhook

# Expected output:
# First event: "Checkout completed for user@example.com (user_id: xxxxx)"
# Second event: "Duplicate event evt_xxxxx, skipping"
```

**Success Criteria:**
- [ ] First event processes successfully (user created, profile upserted)
- [ ] Second event short-circuits with "duplicate" log
- [ ] No duplicate user records or double magic links sent
- [ ] Database query: `SELECT COUNT(*) FROM billing.webhook_events WHERE event_id = 'evt_xxxxx'` returns 1

---

## Gate 5: Magic Link Deliverability ≤120s ⏳

### Implementation

**Provider:** Supabase Auth built-in email (default)
**Future:** SendGrid integration for production

**Template:** Supabase Dashboard → Authentication → Email Templates → Magic Link

**Test Providers:**
1. Gmail
2. Outlook/Hotmail
3. iCloud
4. Yahoo
5. Proton Mail

### Validation Test

```bash
# For each provider:
# 1. Sign up with email from provider
# 2. Navigate to portal /login
# 3. Enter email and click "Send magic link"
# 4. Start timer
# 5. Check inbox for email from Supabase
# 6. Stop timer when email received
# 7. Record delivery time
```

**Test Matrix:**

| Provider | Test Email | Send Time | Receive Time | Duration (s) | Pass/Fail |
|----------|-----------|-----------|--------------|--------------|-----------|
| Gmail | test+gmail@example.com | | | | ☐ |
| Outlook | test@outlook.com | | | | ☐ |
| iCloud | test@icloud.com | | | | ☐ |
| Yahoo | test@yahoo.com | | | | ☐ |
| Proton | test@proton.me | | | | ☐ |

**Success Criteria:**
- [ ] All 5 providers receive email within ≤120 seconds
- [ ] Email not in spam folder
- [ ] Magic link works on click (redirects to `/dashboard`)
- [ ] Email template uses "as needed" language (not "on-demand")

---

## Gate 6: Photo Validation (≤5MB, JPG/PNG/WebP) ✅

### Implementation

**Client-Side Validation:** `sv-portal/src/lib/supabase.ts`
```typescript
export function validatePhotoFile(file: File): { valid: boolean; error?: string } {
  const maxSizeMB = 5
  const allowedFormats = ['image/jpeg', 'image/png', 'image/webp']

  if (file.size > maxSizeMB * 1024 * 1024) {
    return { valid: false, error: 'File size must be ≤5MB' }
  }

  if (!allowedFormats.includes(file.type)) {
    return { valid: false, error: 'Only JPG, PNG, and WebP formats are allowed' }
  }

  return { valid: true }
}
```

**Server-Side:** Storage bucket size limit (configured in Supabase Dashboard)

### Validation Test

```bash
# Test 1: Oversized file
# Create 6MB test image
convert -size 2000x2000 xc:white test_6mb.jpg

# Upload via portal Dashboard
# Expected: Client-side error "File size must be ≤5MB"

# Test 2: HEIC file (rejected format)
# Upload HEIC photo from iPhone
# Expected: Client-side error "Only JPG, PNG, and WebP formats are allowed"

# Test 3: Valid JPG (3MB)
convert -size 1500x1500 xc:blue test_3mb.jpg

# Upload via portal Dashboard
# Expected: Success, photo uploaded to Storage, rendered via signed URL

# Test 4: Valid PNG
# Upload 2MB PNG
# Expected: Success

# Test 5: Valid WebP
# Upload 4MB WebP
# Expected: Success
```

**Success Criteria:**
- [ ] Files >5MB rejected before upload
- [ ] HEIC files rejected before upload
- [ ] JPG/PNG/WebP files ≤5MB upload successfully
- [ ] Uploaded photos render in Dashboard via signed URLs

---

## Overall Gate Status

| Gate | Status | Ready for Live Test |
|------|--------|---------------------|
| 1. Customer Portal Session | ✅ Implemented | ✅ Yes |
| 2. Storage RLS + Signed URLs | ✅ Implemented | ✅ Yes (needs bucket creation) |
| 3. Checkout Function | ✅ Implemented | ✅ Yes |
| 4. Webhook Idempotency | ✅ Implemented | ✅ Yes |
| 5. Magic Link ≤120s | ⏳ Pending Test | ⚠️ Needs live provider testing |
| 6. Photo Validation | ✅ Implemented | ✅ Yes |

---

## Next Steps

1. **Deploy to Supabase + Vercel** (follow `DEPLOYMENT_GUIDE_v3.1.md`)
2. **Run Gate 5 deliverability tests** across 5 email providers
3. **Execute Go/No-Go checklist** (see deployment guide)
4. **Document results** in validation report
5. **Decision:** GO or NO-GO based on all gates passing

---

**Phase 0.6 implementation complete. Proceed to deployment and live testing.**
