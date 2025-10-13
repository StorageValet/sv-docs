#!/bin/bash
# Storage Valet v3.1 — Set Vercel Environment Variables (Staging)
# Run this script from ~/code/sv-portal after replacing all placeholders

set -e

echo "========================================="
echo "Setting Vercel Environment Variables"
echo "========================================="
echo ""

# IMPORTANT: Replace all REPLACE_ME_* values before running
# Obtain values from secrets_needed.md documentation

# Note: This script uses Vercel CLI. Install with: npm i -g vercel
# Link project first: cd ~/code/sv-portal && vercel link

PROJECT_NAME="sv-portal-staging"

echo "Setting environment variables for project: $PROJECT_NAME"
echo ""

# Supabase URL (public)
vercel env add VITE_SUPABASE_URL preview production <<EOF
https://gmjucacmbrumncfnnhua.supabase.co
EOF
echo "✓ VITE_SUPABASE_URL set"

# Supabase Anon Key (public)
vercel env add VITE_SUPABASE_ANON_KEY preview production <<EOF
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNTkzMDgsImV4cCI6MjA3MzYzNTMwOH0.sR4S7DNrwxhi1C4HFnDzr0YL6IBqxzVwCGYtBDhSAFI
EOF
echo "✓ VITE_SUPABASE_ANON_KEY set"

# App URL (Vercel staging/production URL)
vercel env add VITE_APP_URL preview production <<EOF
https://staging.portal.mystoragevalet.com
EOF
echo "✓ VITE_APP_URL set"

# Stripe Publishable Key (TEST mode - public)
vercel env add VITE_STRIPE_PUBLISHABLE_KEY preview production <<EOF
pk_test_51RK44KCLlNQ5U3EWvf4X8fCUYHpkIK6ptjQpZ02OkaLQuyH2UUpJz1dWIJk5teuhyM4FwW19DMflTTfkFKDw9Hqp00mXqa5Zn9
EOF
echo "✓ VITE_STRIPE_PUBLISHABLE_KEY set"

echo ""
echo "========================================="
echo "All Vercel environment variables set!"
echo "========================================="
echo ""

echo "Verify environment variables:"
vercel env ls

echo ""
echo "For local development:"
echo "1. Create .env file: cp .env.example .env"
echo "2. Fill in values in .env (do NOT commit .env)"
echo "3. Or pull from Vercel: vercel env pull .env.local"

echo ""
echo "Next steps:"
echo "1. Deploy to Vercel: vercel --prod"
echo "2. Copy deployment URL → use as APP_URL in Supabase secrets"
echo "3. Test portal: open \$VITE_APP_URL/login"
