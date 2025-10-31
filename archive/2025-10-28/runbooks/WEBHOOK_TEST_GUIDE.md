# Stripe Webhook Idempotency Test Guide

## Current Status ✅
- Webhook endpoint is LIVE and PUBLIC: `https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook`
- JWT verification: DISABLED (Stripe signatures only)
- Async signature verification: FIXED (using `constructEventAsync`)
- Idempotency index: VERIFIED in database

## Test Steps

### Option A: Send Test Webhook from Stripe Dashboard (RECOMMENDED)

1. **Go to Stripe Dashboard** → Test mode → Developers → Webhooks
2. **Click your webhook endpoint** (should show the URL above)
3. **Click "Send test webhook" button** (top right)
4. **Select event type**: `checkout.session.completed`
5. **Click "Send test webhook"**
6. **IMMEDIATELY repeat**: Click "Send test webhook" button AGAIN with same event
7. **Check the result**:
   - First delivery: Should show HTTP 200
   - Second delivery: Should show HTTP 200 (but marked as duplicate in logs)

### Option B: Use Real Checkout Flow

1. **Get a checkout URL**:
   ```bash
   curl -sS -X POST 'https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/create-checkout' \
     -H 'Content-Type: application/json' \
     -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNTkzMDgsImV4cCI6MjA3MzYzNTMwOH0.sR4S7DNrwxhi1C4HFnDzr0YL6IBqxzVwCGYtBDhSAFI' \
     -d '{}' | python3 -c 'import sys,json; print(json.load(sys.stdin).get("url",""))'
   ```

2. **Complete the checkout** with test card: `4242 4242 4242 4242`

3. **Find the event in Stripe** → Events tab → Look for `checkout.session.completed`

4. **Test idempotency**: Click "Resend" on that event TWICE

## Verification

### Check Database for Events
```bash
# Connect to Supabase and run:
SELECT event_id, event_type, created_at,
       COUNT(*) OVER (PARTITION BY event_id) as duplicate_check
FROM billing.webhook_events
ORDER BY created_at DESC
LIMIT 10;
```

### Expected Result
- Each unique `event_id` should appear ONCE in the database
- If Stripe sends the same event twice, the second attempt should be rejected
- The webhook function should return `{"ok": true, "duplicate": true}` for the second delivery

## What's Fixed

1. ✅ **Async Signature Verification**: Changed from `constructEvent` to `constructEventAsync`
2. ✅ **Public Endpoint**: JWT verification disabled via `verify_jwt = false` in `supabase.toml`
3. ✅ **Idempotency Constraint**: Unique index on `event_id` exists in database
4. ✅ **Duplicate Detection**: Function properly handles `23505` error code

## Troubleshooting

If webhooks still fail:

1. **Check Stripe webhook logs** in Dashboard → Developers → Webhooks → [Your endpoint] → Events tab
2. **Verify signing secret matches**: `whsec_tRASzHJUjhArEhilLPJ30DCuneArQ0Ak`
3. **Check Supabase function logs**:
   ```bash
   supabase functions logs stripe-webhook --project-ref gmjucacmbrumncfnnhua
   ```
4. **Verify environment variables are set**:
   ```bash
   supabase secrets list --project-ref gmjucacmbrumncfnnhua | grep STRIPE
   ```
