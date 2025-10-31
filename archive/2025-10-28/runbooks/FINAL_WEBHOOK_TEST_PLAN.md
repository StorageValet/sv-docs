# Final Webhook Testing Plan

## ✅ What Was Fixed

1. **Switched to `Deno.serve` API** - Modern built-in API instead of old `serve` from std lib
2. **Confirmed raw body handling** - Using `await req.text()` before `constructEventAsync`
3. **Added METHOD check** - Only accepts POST requests (returns 405 for others)
4. **Improved error handling** - Proper type checking for error messages

## 🔴 SECURITY WARNING

**CRITICAL**: Your webhook secret `whsec_tRASzHJUjhArEhilLPJ30DCuneArQ0Ak` was exposed in the conversation.

**After testing, immediately rotate it:**
1. Go to Stripe Dashboard → Developers → Webhooks → Your endpoint
2. Click "Reveal" on signing secret → Click "Roll secret"
3. Update Supabase secret:
   ```bash
   supabase secrets set STRIPE_WEBHOOK_SECRET='whsec_NEW_SECRET_HERE' --project-ref gmjucacmbrumncfnnhua
   ```
4. Redeploy webhook function

## ✅ Current Status

- **Endpoint**: `https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook`
- **Status**: ✅ PUBLIC, accessible, returns "Missing signature" when tested without Stripe headers
- **JWT verification**: ✅ DISABLED
- **Signature verification**: ✅ Using `constructEventAsync` with raw body
- **Idempotency**: ✅ Unique constraint on `event_id` in database

## 📋 Testing Steps (Stripe Dashboard Method - RECOMMENDED)

### Step 1: Send Test Webhook
1. Open **Stripe Dashboard** → **Test mode** → **Developers** → **Webhooks**
2. Click on your webhook endpoint (should show the URL above)
3. Click **"Send test webhook"** button (top right corner)
4. Select event type: **`checkout.session.completed`**
5. Click **"Send test webhook"**
6. **Note the event ID** from the response (e.g., `evt_xxx...`)

### Step 2: Test Idempotency (Send Same Event Twice)
1. **Immediately** click **"Send test webhook"** again
2. Select the **same event type**: `checkout.session.completed`
3. This sends a second event with a new ID (different from true idempotency)

**Note**: Stripe Dashboard creates NEW event IDs each time. For true idempotency testing:
- Go to **Events** tab
- Find the event you just created
- Click **"Resend"** or **"Send test webhook"** on that specific event
- This will resend the SAME event ID twice

### Step 3: Verify Results

#### Check Supabase Function Logs:
```bash
supabase functions logs stripe-webhook --project-ref gmjucacmbrumncfnnhua | tail -50
```

Expected logs:
- First delivery: Should show successful insert
- Second delivery (same event_id): Should log "Duplicate event evt_xxx, skipping"

#### Check Database:
Use Supabase SQL Editor or MCP tool:
```sql
SELECT
  event_id,
  event_type,
  created_at,
  COUNT(*) OVER (PARTITION BY event_id) as duplicate_check
FROM billing.webhook_events
ORDER BY created_at DESC
LIMIT 10;
```

**Expected result**: Each `event_id` should appear EXACTLY ONCE (duplicate_check = 1)

## 🧪 Alternative: Real Checkout Test

If you want to test the full flow:

1. **Generate checkout URL**:
   ```bash
   ANON='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNTkzMDgsImV4cCI6MjA3MzYzNTMwOH0.sR4S7DNrwxhi1C4HFnDzr0YL6IBqxzVwCGYtBDhSAFI'
   curl -sS -X POST 'https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/create-checkout' \
     -H "Authorization: Bearer $ANON" \
     -H 'Content-Type: application/json' \
     -d '{}' | python3 -c 'import sys,json; print(json.load(sys.stdin)["url"])'
   ```

2. **Complete checkout** with test card `4242 4242 4242 4242`

3. **Stripe automatically sends** `checkout.session.completed` webhook

4. **Find the event** in Stripe Dashboard → Events

5. **Resend it twice** to test idempotency

## 🎯 Success Criteria

✅ **First webhook delivery**:
- HTTP 200 response
- Event inserted in `billing.webhook_events` table
- User created in `auth.users` (if new email)
- `customer_profile` record created/updated
- Magic link email sent

✅ **Second webhook delivery (same event_id)**:
- HTTP 200 response
- Response body: `{"ok": true, "duplicate": true}`
- Log shows: "Duplicate event evt_xxx, skipping"
- NO new database record (constraint prevents it)
- NO duplicate processing

## 🔧 Troubleshooting

### If webhook returns 400 with signature error:
1. Verify secret in Stripe Dashboard matches Supabase secret
2. Check that webhook is configured for the correct endpoint URL
3. Ensure API version in Stripe webhook settings is recent (2023+)

### If webhook returns 500:
1. Check Supabase function logs for detailed error
2. Verify all environment variables are set:
   ```bash
   supabase secrets list --project-ref gmjucacmbrumncfnnhua
   ```
3. Check database schema matches migration files

### If idempotency fails (duplicates in DB):
1. Verify unique constraint exists:
   ```sql
   SELECT indexname, indexdef
   FROM pg_indexes
   WHERE tablename = 'webhook_events' AND schemaname = 'billing';
   ```
2. Should see: `ux_billing_webhook_events_event_id` or `webhook_events_event_id_key`

## 📝 Post-Testing Checklist

- [ ] Webhook receives events successfully
- [ ] Signature verification passes
- [ ] Idempotency prevents duplicate processing
- [ ] Database records are created correctly
- [ ] **Rotate webhook secret (CRITICAL)**
- [ ] Document webhook endpoint in project README
- [ ] Set up monitoring/alerts for webhook failures (optional)

## 🚀 Next Steps After Success

Once webhook testing passes:
1. Update Stripe webhook to use **LIVE mode** secret (when ready for production)
2. Add webhook endpoint monitoring
3. Test other event types (subscription updates, cancellations, payment failures)
4. Verify magic link email delivery (<120s per your Gate 5 requirement)
