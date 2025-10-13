#!/bin/bash
# Storage Valet v3.1 — Set Supabase Edge Function Secrets (Staging)
# Run this script from ~/code/sv-edge after replacing all placeholders

set -e

echo "========================================="
echo "Setting Supabase Edge Function Secrets"
echo "========================================="
echo ""

# IMPORTANT: Replace all REPLACE_ME_* values before running this script
# Obtain values from secrets_needed.md documentation

# Supabase Project URL
supabase secrets set SUPABASE_URL="https://gmjucacmbrumncfnnhua.supabase.co"
echo "✓ SUPABASE_URL set"

# Supabase Service Role Key (NEVER expose client-side)
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1ODA1OTMwOCwiZXhwIjoyMDczNjM1MzA4fQ.Xp4DGJ6PqThMK1WznYof38OScwivhEDqTEP0H7gLneA"
echo "✓ SUPABASE_SERVICE_ROLE_KEY set"

# Stripe Secret Key (TEST mode for staging)
supabase secrets set STRIPE_SECRET_KEY="sk_test_51RK44KCLlNQ5U3EW93B27HYO5QzqAghObRkoMooZmA6ILyjgUH04i2pQzHqk0bbIChwEQWwwMyMVeA51ev6AI7Bd00r6vnWiw3"
echo "✓ STRIPE_SECRET_KEY set"

# Stripe Webhook Secret (TEST mode)
supabase secrets set STRIPE_WEBHOOK_SECRET="whsec_rqkbxrxFGrUWiVkNiQigNGrdxc2dXErJ"
echo "✓ STRIPE_WEBHOOK_SECRET set"

# Stripe Price ID for $299/month (TEST mode)
supabase secrets set STRIPE_PRICE_PREMIUM299="price_1SH04RCLlNQ5U3EWwQX82kLI"
echo "✓ STRIPE_PRICE_PREMIUM299 set"

# Portal Base URL (Vercel staging URL)
supabase secrets set APP_URL="https://staging.portal.mystoragevalet.com"
echo "✓ APP_URL set"

echo ""
echo "========================================="
echo "All Edge Function secrets set!"
echo "========================================="
echo ""
echo "Verify secrets (values will be redacted):"
supabase secrets list

echo ""
echo "Next steps:"
echo "1. Deploy Edge Functions: supabase functions deploy create-checkout create-portal-session stripe-webhook"
echo "2. Test Edge Functions: curl -X POST \$SUPABASE_URL/functions/v1/create-checkout"
echo "3. Configure Stripe webhook to point to stripe-webhook Edge Function"
