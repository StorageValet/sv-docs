#!/bin/bash
# Quick webhook status checker

echo "=== WEBHOOK ENDPOINT STATUS ==="
echo "Endpoint: https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook"
echo ""

echo "=== Testing endpoint accessibility (should return 400 'Missing signature') ==="
curl -sS -X POST 'https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook' \
  -H 'Content-Type: application/json' \
  -d '{"test":"data"}' -i | head -20
echo ""

echo "=== Recent webhook events in database ==="
echo "Please manually check Supabase dashboard or run:"
echo "SELECT event_id, event_type, created_at FROM billing.webhook_events ORDER BY created_at DESC LIMIT 10;"
