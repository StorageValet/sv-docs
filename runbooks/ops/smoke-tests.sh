#!/bin/bash
# Storage Valet v3.1 — Smoke Test Script
# Run after deployment to validate Phase 0.6 gates and Go/No-Go criteria

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"
APP_URL="${APP_URL:-}"
TEST_EMAIL="${TEST_EMAIL:-test@example.com}"

# Check prerequisites
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ] || [ -z "$APP_URL" ]; then
  echo -e "${RED}❌ Missing environment variables${NC}"
  echo "Please set:"
  echo "  export SUPABASE_URL=https://your-project.supabase.co"
  echo "  export SUPABASE_ANON_KEY=your-anon-key"
  echo "  export APP_URL=https://portal.mystoragevalet.com"
  exit 1
fi

echo "========================================="
echo "Storage Valet v3.1 — Smoke Tests"
echo "========================================="
echo "Supabase URL: $SUPABASE_URL"
echo "App URL: $APP_URL"
echo ""

# Test counters
PASSED=0
FAILED=0

# Helper functions
pass() {
  echo -e "${GREEN}✅ PASS${NC}: $1"
  ((PASSED++))
}

fail() {
  echo -e "${RED}❌ FAIL${NC}: $1"
  ((FAILED++))
}

warn() {
  echo -e "${YELLOW}⚠️  WARN${NC}: $1"
}

# Test 1: create-checkout function
echo ""
echo "Test 1: Create Checkout Function (Gate 3)"
echo "-----------------------------------------"
CHECKOUT_RESPONSE=$(curl -s -X POST "$SUPABASE_URL/functions/v1/create-checkout" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$TEST_EMAIL\"}")

if echo "$CHECKOUT_RESPONSE" | grep -q "url"; then
  CHECKOUT_URL=$(echo "$CHECKOUT_RESPONSE" | grep -o '"url":"[^"]*' | cut -d'"' -f4)
  pass "Checkout function returned URL: ${CHECKOUT_URL:0:50}..."
else
  fail "Checkout function did not return URL"
  echo "Response: $CHECKOUT_RESPONSE"
fi

# Test 2: Portal accessibility
echo ""
echo "Test 2: Portal Accessibility"
echo "----------------------------"
PORTAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL")

if [ "$PORTAL_STATUS" = "200" ]; then
  pass "Portal accessible at $APP_URL"
else
  fail "Portal returned HTTP $PORTAL_STATUS"
fi

# Test 3: Portal /login route
echo ""
echo "Test 3: Portal /login Route (SPA Rewrite)"
echo "-----------------------------------------"
LOGIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL/login")

if [ "$LOGIN_STATUS" = "200" ]; then
  pass "Portal /login route accessible (SPA rewrite working)"
else
  fail "Portal /login returned HTTP $LOGIN_STATUS (SPA rewrite issue)"
fi

# Test 4: Portal /dashboard route (should redirect to /login if not authed)
echo ""
echo "Test 4: Portal /dashboard Route"
echo "-------------------------------"
DASHBOARD_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL/dashboard")

if [ "$DASHBOARD_STATUS" = "200" ]; then
  pass "Portal /dashboard accessible"
else
  warn "Portal /dashboard returned HTTP $DASHBOARD_STATUS (expected if not authenticated)"
fi

# Test 5: Edge function accessibility
echo ""
echo "Test 5: Edge Function Endpoints"
echo "--------------------------------"

# create-portal-session (requires auth, expect 401)
PORTAL_SESSION_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$SUPABASE_URL/functions/v1/create-portal-session")

if [ "$PORTAL_SESSION_STATUS" = "401" ]; then
  pass "create-portal-session rejects unauthenticated requests"
else
  warn "create-portal-session returned HTTP $PORTAL_SESSION_STATUS (expected 401)"
fi

# stripe-webhook (requires Stripe signature, expect 400)
WEBHOOK_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$SUPABASE_URL/functions/v1/stripe-webhook")

if [ "$WEBHOOK_STATUS" = "400" ]; then
  pass "stripe-webhook rejects requests without signature"
else
  warn "stripe-webhook returned HTTP $WEBHOOK_STATUS (expected 400)"
fi

# Test 6: Check for CORS headers
echo ""
echo "Test 6: CORS Configuration"
echo "--------------------------"
CORS_HEADERS=$(curl -s -I -X OPTIONS "$SUPABASE_URL/functions/v1/create-checkout")

if echo "$CORS_HEADERS" | grep -iq "access-control-allow-origin"; then
  pass "CORS headers present on Edge Functions"
else
  warn "CORS headers not detected (may cause Webflow integration issues)"
fi

# Summary
echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All automated tests passed!${NC}"
  echo ""
  echo "Next steps:"
  echo "1. Test magic link deliverability across 5 email providers (Gate 5)"
  echo "2. Test photo upload with validation (Gate 6)"
  echo "3. Complete full checkout flow and verify webhook idempotency (Gate 4)"
  echo "4. Test Customer Portal session from /account (Gate 1)"
  echo "5. Test Storage RLS with cross-tenant access attempt (Gate 2)"
  exit 0
else
  echo -e "${RED}❌ Some tests failed. Review logs above.${NC}"
  exit 1
fi
