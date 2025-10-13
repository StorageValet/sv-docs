#!/bin/bash
# === Stripe → Supabase webhook test (signed) ===
# Requires: python3, curl, supabase CLI linked to project
set -euo pipefail

# --- CONFIG ---
PROJ="gmjucacmbrumncfnnhua"
ENDPOINT="https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook"
WHSEC="whsec_tRASzHJUjhArEhilLPJ30DCuneArQ0Ak"  # Test secret you confirmed
EVT_ID="evt_sim_manual_001"                      # Keep constant to test idempotency
SESSION_ID="cs_test_sim_manual_001"

# --- build minimal, realistic Stripe event payload ---
cat > /tmp/payload.json <<'JSON'
{
  "id": "EVT_PLACEHOLDER",
  "type": "checkout.session.completed",
  "api_version": "2023-10-16",
  "created": 1739400000,
  "data": {
    "object": {
      "id": "CS_PLACEHOLDER",
      "object": "checkout.session",
      "mode": "subscription",
      "payment_status": "paid",
      "status": "complete"
    }
  }
}
JSON

# inject stable ids
python3 - <<PY
import json
p = json.load(open("/tmp/payload.json"))
p["id"] = "$EVT_ID"
p["data"]["object"]["id"] = "$SESSION_ID"
json.dump(p, open("/tmp/payload.json", "w"))
PY

sign_and_send () {
  TS="$(date +%s)"
  SIG="$(python3 - <<'PY'
import os, hmac, hashlib
# Remove whsec_ prefix from secret
sec_raw = os.environ["WHSEC"]
if sec_raw.startswith("whsec_"):
    sec_raw = sec_raw[7:]
sec = sec_raw.encode()
ts = os.environ["TS"]
body = open("/tmp/payload.json", "rb").read()
to_sign = (ts + ".").encode() + body
print(hmac.new(sec, to_sign, hashlib.sha256).hexdigest())
PY
)"
  echo ">> POST t=$TS v1=$SIG"
  curl -sS -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -H "Stripe-Signature: t=$TS,v1=$SIG" \
    --data-binary @/tmp/payload.json -i | sed -n '1,20p'
}

export WHSEC TS

echo "=== First delivery (should INSERT) ==="
sign_and_send || true

sleep 2
echo
echo "=== Second delivery (same event_id; should SHORT-CIRCUIT as duplicate) ==="
sign_and_send || true

echo
echo "=== Quick DB check ==="
echo "Run this SQL to verify: SELECT event_id, COUNT(*) AS rows FROM billing.webhook_events WHERE event_id = '$EVT_ID' GROUP BY 1;"
