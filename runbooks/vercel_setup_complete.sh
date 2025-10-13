#!/usr/bin/env bash
# Storage Valet v3.1 — Complete Vercel Setup
# Run this in YOUR terminal (not Claude Code) for interactive authentication

set -euo pipefail

PROJECT_DIR="$HOME/code/sv-portal"
PROJECT_NAME="sv-portal"

# Environment values from credentials CSV
VITE_SUPABASE_URL="https://gmjucacmbrumncfnnhua.supabase.co"
VITE_SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNTkzMDgsImV4cCI6MjA3MzYzNTMwOH0.sR4S7DNrwxhi1C4HFnDzr0YL6IBqxzVwCGYtBDhSAFI"
# Placeholder - you need to create TEST mode keys in Stripe Dashboard
VITE_STRIPE_PUBLISHABLE_KEY="pk_test_PLACEHOLDER_UPDATE_AFTER_STRIPE_SETUP"

echo "========================================"
echo "Storage Valet v3.1 — Vercel Setup"
echo "========================================"
echo ""

cd "$PROJECT_DIR"
echo "✓ Working directory: $PROJECT_DIR"
echo ""

# Step 1: Login
echo "Step 1: Vercel Login"
echo "-------------------"
vercel login
echo ""
echo "✓ Login complete"
echo ""

# Step 2: Link project
echo "Step 2: Link/Create Project"
echo "---------------------------"
echo "When prompted:"
echo "  - Set up and deploy? → Y"
echo "  - Which scope? → Select your account"
echo "  - Link to existing project? → N"
echo "  - Project name? → sv-portal"
echo "  - Directory? → ./ (just press Enter)"
echo ""
read -p "Press Enter to continue..."

vercel link --yes

echo ""
echo "✓ Project linked"
echo ""

# Step 3: Check vercel.json exists
if [ -f vercel.json ]; then
  echo "✓ vercel.json exists with SPA rewrites"
else
  echo "⚠ vercel.json missing - this shouldn't happen"
fi
echo ""

# Step 4: Set environment variables
echo "Step 3: Setting Environment Variables"
echo "-------------------------------------"

set_env() {
  local NAME="$1"
  local VALUE="$2"

  echo "Setting $NAME..."
  if printf "%s" "$VALUE" | vercel env add "$NAME" preview 2>/dev/null; then
    echo "  ✓ Added to preview"
  else
    echo "  ⊘ Already exists (skipping)"
  fi
}

set_env "VITE_SUPABASE_URL" "$VITE_SUPABASE_URL"
set_env "VITE_SUPABASE_ANON_KEY" "$VITE_SUPABASE_ANON_KEY"
set_env "VITE_STRIPE_PUBLISHABLE_KEY" "$VITE_STRIPE_PUBLISHABLE_KEY"

echo ""
echo "✓ Environment variables set"
echo ""

# Step 5: First deploy
echo "Step 4: Deploying to Staging"
echo "----------------------------"
echo "This will deploy to preview/staging (not production)"
echo ""

vercel deploy --yes

echo ""
echo "✓ Deployment complete!"
echo ""

# Step 6: Get staging URL
echo "Step 5: Getting Staging URL"
echo "--------------------------"
STAGING_URL=$(vercel ls 2>/dev/null | grep "$PROJECT_NAME" | grep -Eo 'https://[a-zA-Z0-9.-]+\.vercel\.app' | head -1)

if [ -z "$STAGING_URL" ]; then
  echo "Could not auto-detect staging URL. Check output above or run:"
  echo "  vercel ls"
  STAGING_URL="<check-vercel-dashboard>"
else
  echo "Staging URL: $STAGING_URL"
fi
echo ""

# Step 7: Set VITE_APP_URL
if [ "$STAGING_URL" != "<check-vercel-dashboard>" ]; then
  echo "Step 6: Setting VITE_APP_URL"
  echo "----------------------------"

  if printf "%s" "$STAGING_URL" | vercel env add VITE_APP_URL preview 2>/dev/null; then
    echo "✓ VITE_APP_URL set to: $STAGING_URL"
  else
    echo "⊘ VITE_APP_URL already exists"
  fi

  echo ""
  echo "Step 7: Redeploying with Complete Env Vars"
  echo "------------------------------------------"
  vercel deploy --yes
  echo ""
  echo "✓ Redeployment complete"
fi

echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Project: $PROJECT_NAME"
echo "Staging URL: $STAGING_URL"
echo ""
echo "Verification:"
echo "  vercel env ls     # List all environment variables"
echo "  vercel ls         # List deployments"
echo ""
echo "⚠ Remember to update VITE_STRIPE_PUBLISHABLE_KEY with real TEST key!"
echo ""
echo "Next: Test $STAGING_URL/login in your browser"
echo ""
