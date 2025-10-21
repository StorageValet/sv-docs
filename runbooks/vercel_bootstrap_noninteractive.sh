#!/usr/bin/env bash
# Storage Valet v3.1 — Vercel Project Bootstrap (Non-Interactive)
# Scope: Create/link sv-portal, set 4 staging env vars, deploy to staging
# Uses confirmed values from credentials CSV + placeholder for Stripe TEST key

set -euo pipefail

PROJECT_DIR="$HOME/code/sv-portal"
PROJECT_NAME="sv-portal"

# Confirmed values from CREDENTIALS_AND_CONFIG_CHECKLIST.csv
VITE_SUPABASE_URL="${VITE_SUPABASE_URL:-https://gmjucacmbrumncfnnhua.supabase.co}"
VITE_SUPABASE_ANON_KEY="${VITE_SUPABASE_ANON_KEY:-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNTkzMDgsImV4cCI6MjA3MzYzNTMwOH0.sR4S7DNrwxhi1C4HFnDzr0YL6IBqxzVwCGYtBDhSAFI}"
# Placeholder for Stripe TEST key - update after creating TEST mode keys in Stripe Dashboard
VITE_STRIPE_PUBLISHABLE_KEY="${VITE_STRIPE_PUBLISHABLE_KEY:-pk_test_PLACEHOLDER_UPDATE_AFTER_STRIPE_SETUP}"
# Will be set after deploy
VITE_APP_URL="${VITE_APP_URL:-}"

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

### 2) Login (requires browser interaction)
echo "Step 1: Vercel Login"
echo "-------------------"
echo "⚠ This step requires browser interaction for authentication"
vercel login

echo ""
echo "✓ Vercel login complete"
echo ""

### 3) Link project
echo "Step 2: Link Project ($PROJECT_NAME)"
echo "-----------------------------------"
# Check if already linked
if [ -f .vercel/project.json ]; then
  echo "✓ Project already linked (found .vercel/project.json)"
else
  echo "Linking to project: $PROJECT_NAME"
  # Try linking to existing project
  if ! vercel link --project "$PROJECT_NAME" --yes 2>/dev/null; then
    echo "Project not found. Creating new project..."
    # Will require interactive confirmation for new project creation
    vercel link --yes || {
      echo "⚠ Link failed. May require manual project creation in Vercel dashboard."
      echo "Visit: https://vercel.com/new"
      exit 1
    }
  fi
  echo "✓ Project linked"
fi
echo ""

### 4) Ensure SPA rewrites (vercel.json)
echo "Step 3: Ensure SPA Rewrites (vercel.json)"
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

### 5) Display environment values
echo "Step 4: Environment Variables (Staging)"
echo "---------------------------------------"
echo "Using these values:"
echo "  VITE_SUPABASE_URL: ${VITE_SUPABASE_URL:0:40}..."
echo "  VITE_SUPABASE_ANON_KEY: ${VITE_SUPABASE_ANON_KEY:0:40}..."
echo "  VITE_STRIPE_PUBLISHABLE_KEY: $VITE_STRIPE_PUBLISHABLE_KEY"
echo "  VITE_APP_URL: ${VITE_APP_URL:-<will set after deploy>}"
echo ""

### 6) Set environment variables in Vercel (staging/preview only)
echo "Step 5: Adding Environment Variables to Vercel"
echo "----------------------------------------------"

# Helper function to add env var
add_env() {
  local NAME="$1"
  local VALUE="$2"

  if [ -z "${VALUE:-}" ]; then
    echo "⊘ Skipped $NAME (no value provided)"
    return 0
  fi

  # Try to add; if it fails (already exists), that's okay
  if printf "%s" "$VALUE" | vercel env add "$NAME" preview 2>/dev/null; then
    echo "✓ $NAME added to preview"
  else
    echo "⊘ $NAME already exists in preview (skipping)"
  fi
}

add_env "VITE_SUPABASE_URL" "$VITE_SUPABASE_URL"
add_env "VITE_SUPABASE_ANON_KEY" "$VITE_SUPABASE_ANON_KEY"
add_env "VITE_STRIPE_PUBLISHABLE_KEY" "$VITE_STRIPE_PUBLISHABLE_KEY"
add_env "VITE_APP_URL" "$VITE_APP_URL"

echo ""

### 7) First deploy to staging
echo "Step 6: Deploying to Staging (Preview)"
echo "--------------------------------------"
echo "Running: vercel deploy"
echo ""

# Deploy to preview/staging (not production)
DEPLOY_OUTPUT=$(vercel deploy --yes 2>&1)
echo "$DEPLOY_OUTPUT"

# Extract staging URL
STAGING_URL=$(echo "$DEPLOY_OUTPUT" | grep -Eo 'https://[a-zA-Z0-9.-]+\.vercel\.app' | head -1)

if [ -z "$STAGING_URL" ]; then
  echo "⚠ Could not extract staging URL from deploy output"
  echo "Check output above for deployment URL"
  STAGING_URL="<check-vercel-dashboard>"
else
  echo ""
  echo "✓ Deploy complete"
  echo "Staging URL: $STAGING_URL"
fi
echo ""

### 8) Handle VITE_APP_URL chicken-egg problem
if [ -z "$VITE_APP_URL" ] && [ "$STAGING_URL" != "<check-vercel-dashboard>" ]; then
  echo "Step 7: Setting VITE_APP_URL with Staging URL"
  echo "---------------------------------------------"
  echo "VITE_APP_URL was blank. Setting it to: $STAGING_URL"

  if printf "%s" "$STAGING_URL" | vercel env add VITE_APP_URL preview 2>/dev/null; then
    echo "✓ VITE_APP_URL added"
  else
    echo "⊘ VITE_APP_URL already exists (skipping)"
  fi

  echo ""
  echo "Step 8: Redeploying with VITE_APP_URL"
  echo "-------------------------------------"
  REDEPLOY_OUTPUT=$(vercel deploy --yes 2>&1)
  echo "$REDEPLOY_OUTPUT"

  # Update staging URL from redeploy
  NEW_STAGING_URL=$(echo "$REDEPLOY_OUTPUT" | grep -Eo 'https://[a-zA-Z0-9.-]+\.vercel\.app' | head -1)
  if [ -n "$NEW_STAGING_URL" ]; then
    STAGING_URL="$NEW_STAGING_URL"
  fi

  echo "✓ Redeployment complete"
  VITE_APP_URL="$STAGING_URL"
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
echo "⚠ ACTION REQUIRED:"
echo "  - Update VITE_STRIPE_PUBLISHABLE_KEY with real TEST key from Stripe Dashboard"
echo "  - Run: vercel env add VITE_STRIPE_PUBLISHABLE_KEY preview"
echo ""
echo "Next: Verify $STAGING_URL/login opens without 404"
echo ""
