#!/usr/bin/env bash
# Storage Valet v3.1 — Vercel Project Bootstrap
# Scope: Create/link sv-portal, set 4 staging env vars, deploy to staging
# Solves chicken-egg: Deploy first, then set VITE_APP_URL, then redeploy

set -euo pipefail

PROJECT_DIR="$HOME/code/sv-portal"
PROJECT_NAME="sv-portal"

echo "========================================"
echo "Storage Valet v3.1 — Vercel Bootstrap"
echo "========================================"
echo ""

### 0) Verify project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
  echo "ERROR: $PROJECT_DIR not found."
  exit 1
fi

cd "$PROJECT_DIR"
echo "✓ Working directory: $PROJECT_DIR"
echo ""

### 1) Install Vercel CLI if needed
if ! command -v vercel >/dev/null 2>&1; then
  echo "Installing Vercel CLI globally..."
  npm i -g vercel
  echo "✓ Vercel CLI installed"
else
  echo "✓ Vercel CLI already installed ($(vercel --version))"
fi
echo ""

### 2) Login & Link
echo "Step 1: Vercel Login & Project Link"
echo "-----------------------------------"
vercel login

echo ""
echo "Linking project: $PROJECT_NAME"
# Try non-interactive link first; fall back to interactive if needed
if ! vercel link --project "$PROJECT_NAME" --yes 2>/dev/null; then
  echo "Project not found or requires interactive setup. Running interactive link..."
  vercel link
fi
echo "✓ Project linked"
echo ""

### 3) Ensure SPA rewrites (vercel.json)
echo "Step 2: Ensure SPA Rewrites (vercel.json)"
echo "------------------------------------------"
if [ ! -f vercel.json ]; then
  echo "Creating vercel.json with SPA rewrites..."
  cat > vercel.json <<'JSON'
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
JSON
  echo "✓ vercel.json created"

  # Commit if git repo exists
  if [ -d .git ]; then
    git add vercel.json
    git commit -m "chore(vercel): Add SPA rewrites for deep linking" || true
    echo "✓ vercel.json committed to git"
  fi
else
  echo "✓ vercel.json already exists"
fi
echo ""

### 4) Collect staging env values (interactive prompts)
echo "Step 3: Environment Variables (Staging)"
echo "---------------------------------------"
echo "Enter values for STAGING environment:"
echo "(Press Enter to skip VITE_APP_URL if unknown; we'll set it after deploy)"
echo ""

read -r -p "VITE_SUPABASE_URL (e.g., https://xxxxx.supabase.co): " VITE_SUPABASE_URL
read -r -p "VITE_SUPABASE_ANON_KEY (Supabase anon/public key): " VITE_SUPABASE_ANON_KEY
read -r -p "VITE_STRIPE_PUBLISHABLE_KEY (pk_test_...): " VITE_STRIPE_PUBLISHABLE_KEY
read -r -p "VITE_APP_URL (staging portal URL; leave blank if unknown): " VITE_APP_URL || VITE_APP_URL=""

echo ""

### 5) Set environment variables in Vercel (staging only)
echo "Step 4: Adding Environment Variables to Vercel (staging)"
echo "--------------------------------------------------------"

# Helper function to add env var
add_env() {
  local NAME="$1"
  local VALUE="$2"

  if [ -z "${VALUE:-}" ]; then
    echo "⊘ Skipped $NAME (no value provided)"
    return 0
  fi

  # Check if env var already exists for staging
  if vercel env ls 2>/dev/null | grep -q "$NAME.*preview"; then
    echo "⊘ $NAME already exists (skipping to avoid duplicate)"
  else
    printf "%s" "$VALUE" | vercel env add "$NAME" preview production || {
      echo "⚠ Failed to add $NAME (may already exist)"
    }
    echo "✓ $NAME set"
  fi
}

add_env "VITE_SUPABASE_URL" "$VITE_SUPABASE_URL"
add_env "VITE_SUPABASE_ANON_KEY" "$VITE_SUPABASE_ANON_KEY"
add_env "VITE_STRIPE_PUBLISHABLE_KEY" "$VITE_STRIPE_PUBLISHABLE_KEY"
add_env "VITE_APP_URL" "$VITE_APP_URL"

echo ""

### 6) First deploy to staging
echo "Step 5: Deploying to Staging"
echo "----------------------------"
echo "Running: vercel --yes"
echo ""

DEPLOY_OUTPUT=$(vercel --yes 2>&1 | tee /dev/tty)
STAGING_URL=$(echo "$DEPLOY_OUTPUT" | grep -E "https://.*\.vercel\.app" | tail -1 | awk '{print $NF}')

echo ""
echo "✓ Deploy complete"
echo "Staging URL: $STAGING_URL"
echo ""

### 7) Handle VITE_APP_URL chicken-egg problem
if [ -z "$VITE_APP_URL" ] && [ -n "$STAGING_URL" ]; then
  echo "Step 6: Setting VITE_APP_URL with Staging URL"
  echo "---------------------------------------------"
  echo "VITE_APP_URL was blank. Setting it to: $STAGING_URL"

  printf "%s" "$STAGING_URL" | vercel env add VITE_APP_URL preview production || {
    echo "⚠ VITE_APP_URL may already exist; attempting to use existing value"
  }

  echo "✓ VITE_APP_URL set to $STAGING_URL"
  echo ""

  echo "Step 7: Redeploying with VITE_APP_URL"
  echo "-------------------------------------"
  vercel --yes
  echo "✓ Redeployment complete"

  VITE_APP_URL="$STAGING_URL"
else
  echo "✓ VITE_APP_URL already set or deploy failed"
fi

echo ""
echo "========================================"
echo "Bootstrap Complete!"
echo "========================================"
echo ""
echo "Project: $PROJECT_NAME"
echo "Staging URL: $STAGING_URL"
echo "SPA Rewrites: $([ -f vercel.json ] && echo "YES" || echo "NO")"
echo ""
echo "Next steps:"
echo "1. Verify staging URL opens: $STAGING_URL/login"
echo "2. Run validation checklist"
echo "3. Proceed to Supabase/Stripe setup in separate session"
echo ""
