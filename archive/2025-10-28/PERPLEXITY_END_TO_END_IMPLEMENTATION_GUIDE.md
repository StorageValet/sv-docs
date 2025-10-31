# Storage Valet: End-to-End Production Setup & Webflow Integration Guide

**For:** Perplexity Agent
**Purpose:** Complete production infrastructure setup + Webflow integration
**Status:** Ready for Execution
**Approach:** Production-first with Stripe TEST MODE for safety
**Philosophy:** Accuracy and completeness over speed. Verify each step.

---

## Overview of What We're Building

This guide walks you through setting up a complete, integrated system:

```
Customer Journey:
1. User visits Webflow landing page (www.mystoragevalet.com)
2. User clicks "Sign up" CTA
3. JavaScript calls Supabase Edge Function (create-checkout)
4. Edge Function calls Stripe API to create Checkout Session
5. User redirected to Stripe-hosted checkout page
6. User enters payment info (test card: 4242 4242 4242 4242)
7. User clicks "Pay"
8. Stripe fires webhook to Supabase (checkout.session.completed)
9. Webhook handler creates Supabase Auth user + sends magic link
10. Customer receives magic link via email
11. Customer clicks link → authenticated on portal.mystoragevalet.com
12. Customer sees empty dashboard → ready to add items
```

**Infrastructure:**
- **Frontend:** Webflow (public landing page) + Vite/React portal
- **Hosting:** Vercel (portal)
- **Backend:** Supabase (Auth, Database, Storage, Edge Functions)
- **Payments:** Stripe (TEST MODE)
- **Email:** Supabase built-in

---

## Prerequisites: What Must Be True Before Starting

Before proceeding, confirm these conditions are met:

### ✅ Prerequisite 1: Supabase Edge Functions Deployed

**Status:** Already confirmed deployed and tested

**What this means:**
- `create-checkout` function exists and is callable
- `stripe-webhook` function exists and is callable
- `create-portal-session` function exists and is callable

**If NOT true:** Contact Claude before proceeding

### ✅ Prerequisite 2: Stripe Account in TEST Mode

**To verify:**
1. Go to https://dashboard.stripe.com
2. Check top-right corner → should see **Test mode** toggle (enabled)
3. If toggle says "Viewing test data" → ✅ Correct
4. If toggle says "Viewing live data" → ❌ Stop, contact Claude

**What we're verifying:**
- All payments in this phase are simulated
- No real money will be charged
- Test API keys end with `_test_` (not `_live_`)

### ✅ Prerequisite 3: Vercel Project Exists for Portal

**To verify:**
1. Go to https://vercel.com/dashboard
2. Look for a project called `sv-portal` (or similar)
3. Confirm it has a deployment URL (e.g., `sv-portal.vercel.app`)

**If NOT found:** Contact Claude before proceeding

### ✅ Prerequisite 4: GitHub Access

You'll need to verify Git commits from sv-portal, sv-db, sv-edge repos.

**To verify:**
1. Go to https://github.com/StorageValet
2. Confirm you see repos: sv-portal, sv-db, sv-edge, sv-docs
3. You can access them

**If NOT accessible:** Contact Claude before proceeding

### ✅ Prerequisite 5: Webflow Account & Landing Page

You need access to the Webflow editor for mystoragevalet.com landing page.

**To verify:**
1. Go to https://webflow.com
2. Log in to your account
3. Open the Storage Valet landing page project
4. Confirm you can edit it (you should see the "Settings" gear icon)

**If NOT editable:** Contact Claude before proceeding

---

## Critical Information Reference

Before starting, save these values somewhere accessible. You'll reference them throughout:

### Supabase Details
```
Project ID: gmjucacmbrumncfnnhua
Project URL: https://gmjucacmbrumncfnnhua.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNTkzMDgsImV4cCI6MjA3MzYzNTMwOH0.sR4S7DNrwxhi1C4HFnDzr0YL6IBqxzVwCGYtBDhSAFI
```

### Portal Details
```
Production Domain: portal.mystoragevalet.com
Vercel Project: sv-portal (find actual URL in Vercel dashboard)
```

### Webflow Details
```
Landing Page Domain: mystoragevalet.com (or www.mystoragevalet.com)
Project: Storage Valet (or similar name in your Webflow account)
```

### Stripe Details
```
Mode: TEST (not LIVE)
Test Publishable Key: pk_test_... (find in Stripe Dashboard → Developers → API Keys)
Test Secret Key: sk_test_... (find in Stripe Dashboard → Developers → API Keys)
Price ID ($299/month): price_test_... (find or create in Stripe Dashboard → Products)
Webhook Signing Secret: whsec_... (find or create in Stripe Dashboard → Webhooks)
```

---

## Phase 1: Vercel Configuration

### Step 1.1: Verify Vercel Project Exists

**Goal:** Confirm the sv-portal project is set up in Vercel and get its current URL

**Instructions:**

1. Go to https://vercel.com/dashboard
2. Look for a project called `sv-portal`
3. Click on it to open the project details
4. Note the **Production URL** (e.g., `sv-portal-something.vercel.app`)
5. Click the URL or go to "Domains" section

**What you're looking for:**
- Current production URL (could be preview or main deployment)
- List of domains already configured
- Recent deployment logs

**Verification checklist:**
- [ ] Found sv-portal project
- [ ] Noted current production URL
- [ ] Can see domains section
- [ ] Can see deployment history

**If stuck:** Go to https://vercel.com/StorageValet and look for sv-portal project there (if in an organization)

---

### Step 1.2: Add Production Domain to Vercel

**Goal:** Configure `portal.mystoragevalet.com` as the primary production domain

**Prerequisites for this step:**
- DNS for mystoragevalet.com is already managed
- You have access to domain DNS settings (or have confirmed domain is ready for CNAME)
- Vercel project from Step 1.1 is open

**Instructions:**

1. In Vercel project (sv-portal), go to **Settings** (left sidebar)
2. Click **Domains**
3. You should see an input field to "Add Domain"
4. Enter: `portal.mystoragevalet.com`
5. Click "Add" or "Next"
6. Vercel will show you DNS configuration options:
   - **Option A:** Add CNAME record (if you manage DNS)
   - **Option B:** Change nameservers (if you own the domain registrar)

**DNS Configuration (CNAME Method - Most Common):**

Vercel will show you a target like `cname.vercel-dns.com.`

You need to:
1. Go to your domain registrar DNS settings (GoDaddy, Namecheap, Route53, etc.)
2. Create a CNAME record:
   - **Name:** `portal`
   - **Value:** `cname.vercel-dns.com.` (exactly as Vercel shows)
   - **TTL:** 3600 (default)
3. Save the DNS record
4. Return to Vercel
5. Click "Verify" in the domain section

**DNS Configuration (Nameserver Method - Alternative):**

If Vercel prompts you to change nameservers:
1. Copy the nameservers Vercel provides
2. Go to your domain registrar
3. Update nameservers to point to Vercel's
4. Wait for propagation (can take 24-48 hours, but usually <1 hour)

**Verification:**

After adding the domain, Vercel will show one of:
- ✅ **Verified** - Domain is configured and working
- ⏳ **Pending** - DNS is still propagating (may take minutes to hours)
- ❌ **Error** - DNS configuration is wrong

**What to do:**
- If **Verified:** Continue to Step 1.3
- If **Pending:** Wait a few minutes and refresh
- If **Error:** Check the DNS record is exactly as Vercel specified

**Verification checklist:**
- [ ] Entered `portal.mystoragevalet.com` in Vercel
- [ ] DNS configuration added (CNAME or nameservers)
- [ ] Domain shows as "Verified" or "Pending"
- [ ] If Pending, will check again in 10 minutes

---

### Step 1.3: Make Production Domain Primary

**Goal:** Set `portal.mystoragevalet.com` as the primary/default domain

**Instructions:**

1. In Vercel → Settings → Domains
2. Find `portal.mystoragevalet.com` in the list
3. Look for a "Make Primary" button or similar
4. Click it (or drag to reorder if needed)
5. Verify it now shows as the primary domain (may show a star or "PRIMARY" label)

**Why this matters:**
- All redirects and defaults will use this domain
- Magic links in emails will point here
- Analytics will report under this domain

**Verification checklist:**
- [ ] `portal.mystoragevalet.com` shows as PRIMARY
- [ ] Other domains (if any) are secondary

---

### Step 1.4: Verify Current Environment Variables

**Goal:** Check which environment variables are already set in Vercel

**Instructions:**

1. In Vercel project (sv-portal) → **Settings** (left sidebar)
2. Click **Environment Variables**
3. You'll see a list of existing variables
4. Make note of what's already configured

**Environment variables you should see:**
```
VITE_SUPABASE_URL
VITE_SUPABASE_ANON_KEY
VITE_APP_URL (might be missing or incorrect)
VITE_STRIPE_PUBLISHABLE_KEY (might be missing or incorrect)
```

**Current state likely:**
- ✅ `VITE_SUPABASE_URL` - Should be set to `https://gmjucacmbrumncfnnhua.supabase.co`
- ✅ `VITE_SUPABASE_ANON_KEY` - Should be the anon key from Prerequisites
- ⚠️ `VITE_APP_URL` - Might point to old URL or missing
- ⚠️ `VITE_STRIPE_PUBLISHABLE_KEY` - Might be missing

**Screenshot what you see** for reference

**Verification checklist:**
- [ ] Can access Environment Variables section
- [ ] Noted which variables exist
- [ ] Noted which variables need updating

---

### Step 1.5: Update/Add VITE_APP_URL

**Goal:** Set the portal URL for redirects and auth

**Current value:** Likely something like `https://sv-portal-staging.vercel.app` or similar
**New value:** `https://portal.mystoragevalet.com`

**Instructions:**

1. In Vercel → Settings → Environment Variables
2. Look for `VITE_APP_URL` variable
3. **If it exists:**
   - Click it to edit
   - Change the value to: `https://portal.mystoragevalet.com`
   - Make sure it applies to: **Production** (checkmark the Production environment)
   - Click "Save"
4. **If it doesn't exist:**
   - Click "Add New" or similar
   - **Name:** `VITE_APP_URL`
   - **Value:** `https://portal.mystoragevalet.com`
   - **Environment:** Check "Production" (uncheck Preview and Development if present)
   - Click "Save"

**Verification checklist:**
- [ ] `VITE_APP_URL` is set to `https://portal.mystoragevalet.com`
- [ ] Applied to Production environment only (or Production + Preview if testing)
- [ ] Successfully saved

---

### Step 1.6: Update/Add VITE_STRIPE_PUBLISHABLE_KEY

**Goal:** Configure Stripe test publishable key for checkout

**Prerequisites:**
- Have Stripe TEST MODE publishable key (starts with `pk_test_`)
- If you don't have it, go to: https://dashboard.stripe.com → Developers → API Keys → find "Publishable key" under "Standard keys"

**Instructions:**

1. In Vercel → Settings → Environment Variables
2. Look for `VITE_STRIPE_PUBLISHABLE_KEY` variable
3. **If it exists:**
   - Click it to edit
   - Change the value to your Stripe TEST publishable key (`pk_test_...`)
   - Make sure it applies to: **Production** (and Preview if testing)
   - Click "Save"
4. **If it doesn't exist:**
   - Click "Add New"
   - **Name:** `VITE_STRIPE_PUBLISHABLE_KEY`
   - **Value:** `pk_test_...` (your Stripe test publishable key)
   - **Environment:** Check "Production" and "Preview"
   - Click "Save"

**Important:** Make sure you're copying the **Publishable** key, not the Secret key. Publishable keys:
- Are safe to expose in client-side code
- Start with `pk_test_` (test mode) or `pk_live_` (production)
- Can be used in Webflow and frontend code

**Do NOT use Secret key** (starts with `sk_test_` or `sk_live_`) - that goes in Supabase Edge Functions only.

**Verification checklist:**
- [ ] `VITE_STRIPE_PUBLISHABLE_KEY` is set
- [ ] Value starts with `pk_test_` (not `sk_test_`)
- [ ] Applied to Production environment
- [ ] Successfully saved

---

### Step 1.7: Verify VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY

**Goal:** Confirm these are correct (should be from Prerequisites)

**Instructions:**

1. In Vercel → Settings → Environment Variables
2. Find `VITE_SUPABASE_URL`
   - Should be: `https://gmjucacmbrumncfnnhua.supabase.co`
   - If different or missing, update it
3. Find `VITE_SUPABASE_ANON_KEY`
   - Should be: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (from Prerequisites)
   - If different or missing, update it

**Verification checklist:**
- [ ] `VITE_SUPABASE_URL` = `https://gmjucacmbrumncfnnhua.supabase.co`
- [ ] `VITE_SUPABASE_ANON_KEY` = correct anon key from Prerequisites
- [ ] Both applied to Production environment

---

### Step 1.8: Trigger Vercel Redeployment

**Goal:** Force Vercel to rebuild and deploy with the new environment variables

**Why needed:** Environment variables are baked into the build. Without rebuilding, the old values are still deployed.

**Instructions:**

1. In Vercel project (sv-portal) → **Deployments** (left sidebar)
2. Find the most recent production deployment
3. Look for a **"Redeploy"** button or three-dot menu
4. Click "Redeploy" (or if that's not available, click the menu and look for "Redeploy with build cache")
5. Vercel will start rebuilding with the new environment variables
6. Wait for deployment to complete (usually 2-5 minutes)

**How to know it's done:**
- Status changes from "Building" to "Ready" (green checkmark)
- Deployment shows a timestamp and status

**Alternative method (if Redeploy not visible):**
1. Go to **Settings** → **Git**
2. Find the connected Git repository
3. Manually trigger a redeploy by clicking a "Deploy" button, or:
4. Push a small change to the main branch on GitHub (this auto-triggers deploy)

**Verification checklist:**
- [ ] Clicked Redeploy (or triggered via Git)
- [ ] Deployment status shows "Building"
- [ ] Waited for status to become "Ready" (green)
- [ ] Note the deployment timestamp

**Note:** Don't close the tab. Vercel deployments can take 3-5 minutes.

---

### Step 1.9: Verify Portal Loads with New Domain

**Goal:** Confirm the portal is accessible at `https://portal.mystoragevalet.com`

**Prerequisites:**
- Vercel deployment from Step 1.8 is complete (status = "Ready")
- Domain is verified in Vercel (from Step 1.2)

**Instructions:**

1. Open a new browser tab
2. Go to `https://portal.mystoragevalet.com`
3. Wait for the page to load (may take 5-10 seconds on first load)
4. You should see the Storage Valet login page with:
   - Logo/branding
   - Email input field
   - "Send Magic Link" button (or similar)

**What you're verifying:**
- ✅ Domain is resolving to Vercel
- ✅ Portal application is loading
- ✅ Environment variables are correct (no errors about missing Supabase URL/key)
- ✅ No SSL/TLS certificate errors

**If you see errors:**
- **"Cannot find server" or "Connection timeout":** Domain DNS not fully propagated yet. Wait 5-10 minutes and try again.
- **HTTPS certificate error:** Vercel's automatic SSL may not be ready. Wait a few minutes and retry.
- **Blank page or console errors:** Environment variables may be wrong. Check Step 1.4-1.7.

**Verification checklist:**
- [ ] `https://portal.mystoragevalet.com` loads successfully
- [ ] Page shows login/magic link interface
- [ ] No console errors (press F12 to check)
- [ ] Note the current time and come back in 2-3 minutes if DNS seems slow

---

## Phase 2: Supabase Edge Function Secrets Configuration

### Step 2.1: Access Supabase Edge Function Secrets

**Goal:** Verify and configure secrets that the Edge Functions need to work

**Instructions:**

1. Go to https://supabase.com/dashboard
2. Click on your project: `gmjucacmbrumncfnnhua`
3. Left sidebar → **Edge Functions**
4. You should see three functions:
   - `create-checkout`
   - `stripe-webhook`
   - `create-portal-session`
5. In the same sidebar, find **Secrets** or look for a "Settings" option for Edge Functions
6. Click it

**Alternative path if Secrets aren't obvious:**
1. In Supabase Dashboard, left sidebar → **Settings**
2. Scroll down to **Secrets**
3. Or click **Functions** then click gear icon for settings

**What you should see:**
A list of existing secrets with names and masked values

**Verification checklist:**
- [ ] Found the Secrets section for Edge Functions
- [ ] Can see list of existing secrets (or empty list)
- [ ] Can add new secrets (there should be an "Add new secret" button)

---

### Step 2.2: Verify/Set APP_URL Secret

**Goal:** Configure the portal URL for redirects

**Current value should be:** Something like `https://sv-portal-staging.vercel.app`
**New value should be:** `https://portal.mystoragevalet.com`

**Instructions:**

1. In Supabase Secrets section, look for `APP_URL` secret
2. **If it exists:**
   - Click it to view/edit
   - Verify the value is correct: `https://portal.mystoragevalet.com`
   - If not, update it to the correct value
   - Click "Save" or "Update"
3. **If it doesn't exist:**
   - Click "Add new secret" or similar
   - **Name:** `APP_URL`
   - **Value:** `https://portal.mystoragevalet.com`
   - Click "Create" or "Save"

**Why this matters:**
- Edge Functions use `APP_URL` to redirect users after checkout
- Stripe checkout success/cancel URLs are configured to redirect here
- Magic links in emails will point to this URL

**Verification checklist:**
- [ ] `APP_URL` secret exists
- [ ] Value is `https://portal.mystoragevalet.com`
- [ ] Successfully saved

---

### Step 2.3: Verify SUPABASE_URL Secret

**Goal:** Confirm the Supabase URL is configured for Edge Functions

**Expected value:** `https://gmjucacmbrumncfnnhua.supabase.co`

**Instructions:**

1. In Supabase Secrets section, look for `SUPABASE_URL`
2. **If it exists:**
   - Verify the value matches: `https://gmjucacmbrumncfnnhua.supabase.co`
   - If not, update it
3. **If it doesn't exist:**
   - Add it with value: `https://gmjucacmbrumncfnnhua.supabase.co`

**Verification checklist:**
- [ ] `SUPABASE_URL` secret exists
- [ ] Value is correct

---

### Step 2.4: Verify/Set STRIPE_SECRET_KEY (TEST MODE)

**Goal:** Configure Stripe API secret key for Edge Functions to create checkout sessions

**Prerequisites:**
- Must be the TEST MODE secret key (starts with `sk_test_`)
- Do NOT use LIVE MODE key yet

**How to find it:**
1. Go to https://dashboard.stripe.com
2. Confirm TEST MODE is active (toggle in top right)
3. Left sidebar → **Developers** (or look for "Developers")
4. Click **API Keys**
5. Under "Standard keys" section, find "Secret key"
6. Copy the entire secret key (starts with `sk_test_...`)

**Instructions:**

1. In Supabase Secrets section, look for `STRIPE_SECRET_KEY`
2. **If it exists:**
   - Verify it starts with `sk_test_` (not `sk_live_`)
   - If it's `sk_live_` or outdated, update it with current test key
3. **If it doesn't exist:**
   - Click "Add new secret"
   - **Name:** `STRIPE_SECRET_KEY`
   - **Value:** `sk_test_...` (paste entire test secret key)
   - Click "Create"

**Important:** If you ever see `sk_live_` here and we haven't launched yet, that's a problem. Contact Claude.

**Verification checklist:**
- [ ] `STRIPE_SECRET_KEY` secret exists
- [ ] Value starts with `sk_test_` (not `sk_live_`)
- [ ] Successfully saved/verified

---

### Step 2.5: Verify/Set STRIPE_PRICE_PREMIUM299

**Goal:** Configure the Stripe price ID for the $299/month subscription

**Prerequisites:**
- Price must exist in Stripe Dashboard
- Price must be in TEST MODE
- Price should be $299/month, recurring

**How to find it:**
1. Go to https://dashboard.stripe.com
2. Confirm TEST MODE is active
3. Left sidebar → **Products**
4. Look for a product called "Storage Valet Premium" (or similar)
5. Click on it
6. Find the price of $299/month
7. Click the price to expand details
8. Copy the **Price ID** (starts with `price_test_...`)

**If price doesn't exist:**
1. Click "Create product"
2. **Name:** "Storage Valet Premium"
3. **Type:** Service (not physical goods)
4. **Pricing:** Add recurring price:
   - Amount: 29900 (cents) = $299.00
   - Recurring: Monthly
   - Click "Create product"
5. Copy the resulting price ID

**Instructions:**

1. In Supabase Secrets section, look for `STRIPE_PRICE_PREMIUM299`
2. **If it exists:**
   - Verify the value starts with `price_test_` (not `price_live_`)
   - If outdated or different, update with correct price ID
3. **If it doesn't exist:**
   - Click "Add new secret"
   - **Name:** `STRIPE_PRICE_PREMIUM299`
   - **Value:** `price_test_...` (paste the price ID)
   - Click "Create"

**Verification checklist:**
- [ ] `STRIPE_PRICE_PREMIUM299` secret exists
- [ ] Value starts with `price_test_`
- [ ] Successfully saved/verified

---

### Step 2.6: Verify SUPABASE_SERVICE_ROLE_KEY

**Goal:** Confirm the service role key exists for webhook auth

**Expected:**
- Should start with `eyJ...` (it's a JWT token)
- Used by Edge Functions to create auth users

**How to find it:**
1. Go to https://supabase.com/dashboard
2. Your project: `gmjucacmbrumncfnnhua`
3. **Settings** (bottom left, gear icon)
4. **API** (left sidebar)
5. Find "Service Role Key" (labeled as "service_role secret")
6. Copy it

**Instructions:**

1. In Supabase Secrets section, look for `SUPABASE_SERVICE_ROLE_KEY`
2. **If it exists:**
   - Verify it's set (value will be masked)
   - Don't need to change it
3. **If it doesn't exist:**
   - Click "Add new secret"
   - **Name:** `SUPABASE_SERVICE_ROLE_KEY`
   - **Value:** (paste the entire service role key from API settings)
   - Click "Create"

**Verification checklist:**
- [ ] `SUPABASE_SERVICE_ROLE_KEY` secret exists
- [ ] Does not need updating (it's stable)

---

### Step 2.7: Verify/Set STRIPE_WEBHOOK_SECRET (TEST MODE)

**Goal:** Configure the webhook signing secret for Stripe to authenticate incoming webhooks

**Prerequisites:**
- Webhook endpoint must be created in Stripe first
- Must be the TEST MODE webhook secret (starts with `whsec_test_`)

**How to create/find it:**
1. Go to https://dashboard.stripe.com
2. Confirm TEST MODE
3. Left sidebar → **Developers** → **Webhooks**
4. Look for an endpoint with URL: `https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook`

**If endpoint doesn't exist:**
1. Click "Add endpoint"
2. **Endpoint URL:** `https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook`
3. **Events to send:** Select these events:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
4. Click "Add events"
5. Click "Create endpoint"
6. You'll see the signing secret (starts with `whsec_test_`)

**If endpoint exists:**
1. Click on the endpoint
2. Copy the "Signing secret" (will be shown after you click "Reveal")

**Instructions:**

1. In Supabase Secrets section, look for `STRIPE_WEBHOOK_SECRET`
2. **If it exists:**
   - Verify it starts with `whsec_test_` (not `whsec_live_`)
   - If outdated, update with current signing secret
3. **If it doesn't exist:**
   - Click "Add new secret"
   - **Name:** `STRIPE_WEBHOOK_SECRET`
   - **Value:** `whsec_test_...` (paste entire signing secret)
   - Click "Create"

**Verification checklist:**
- [ ] `STRIPE_WEBHOOK_SECRET` secret exists
- [ ] Value starts with `whsec_test_`
- [ ] Webhook endpoint exists in Stripe pointing to correct URL
- [ ] Webhook is set to send the required events

---

### Step 2.8: Redeploy Edge Functions to Apply Secrets

**Goal:** Restart the Edge Functions so they can access the updated secrets

**Instructions:**

1. In Supabase Dashboard → **Edge Functions**
2. For each function, click on it:
   - `create-checkout`
   - `stripe-webhook`
   - `create-portal-session`
3. For each function:
   - Look for a "Deploy" button or menu option
   - Click "Deploy" or "Redeploy"
   - Wait for it to show "Ready" status (green)

**Alternative method:**
1. Go to your local `/code/sv-edge` folder (on Mac Studio, not needed now)
2. For now, just verify in Supabase UI that each function shows "Ready" status

**Why this matters:**
- Secrets are loaded when functions start up
- Redeploying ensures they have access to the updated secrets
- Without redeploy, functions will fail when trying to use old/missing secrets

**Verification checklist:**
- [ ] All three Edge Functions show "Ready" status
- [ ] No error messages

---

## Phase 3: Stripe Configuration

### Step 3.1: Verify/Create Stripe Product (if not done in Step 2.5)

**Goal:** Ensure "Storage Valet Premium" product exists with $299/month price

**Status likely:** Already created in Step 2.5 (you're just verifying)

**Instructions:**

1. Go to https://dashboard.stripe.com
2. Confirm TEST MODE
3. Left sidebar → **Products**
4. Look for "Storage Valet Premium" (or similar)
5. Click it to view details
6. Verify there's a price of $299/month, recurring
7. Copy the **Price ID** (starts with `price_test_...`)

**If product doesn't exist:**
- Follow the creation steps from Step 2.5

**Verification checklist:**
- [ ] Product "Storage Valet Premium" exists
- [ ] Has price of $299/month, recurring
- [ ] Price ID starts with `price_test_`

---

### Step 3.2: Verify Webhook Endpoint (if not done in Step 2.7)

**Goal:** Ensure webhook endpoint is created and listening for events

**Status likely:** Already created in Step 2.7 (you're just verifying)

**Instructions:**

1. Go to https://dashboard.stripe.com
2. Confirm TEST MODE
3. Left sidebar → **Developers** → **Webhooks**
4. Look for endpoint with URL: `https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook`
5. Click it to view details
6. Verify these events are selected:
   - `checkout.session.completed` (required)
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
7. Copy the **Signing secret** (if not already copied)

**If endpoint doesn't exist:**
- Follow creation steps from Step 2.7

**Verification checklist:**
- [ ] Webhook endpoint exists
- [ ] Correct URL: `https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook`
- [ ] Events selected match list above
- [ ] Signing secret is in Supabase secrets

---

### Step 3.3: Configure Stripe Checkout URLs

**Goal:** Set the success and cancel URLs that Stripe redirects to after checkout

**Note:** The `create-checkout` Edge Function sets these server-side, but we're verifying they're correct.

**What they should be:**
- **Success URL:** `https://portal.mystoragevalet.com/dashboard` (portal.mystoragevalet.com domain)
- **Cancel URL:** `https://portal.mystoragevalet.com` or `https://www.mystoragevalet.com` (your choice)

**Instructions:**

1. This is configured in the Edge Function code (`create-checkout/index.ts`)
2. You don't need to change Stripe settings
3. The function automatically sets:
   ```
   success_url: ${appUrl}/dashboard
   cancel_url: ${appUrl}/account
   ```
4. `appUrl` is the `APP_URL` secret we set in Step 2.2

**Verification checklist:**
- [ ] Confirmed `APP_URL` secret is `https://portal.mystoragevalet.com` (done in Step 2.2)
- [ ] Understood that Stripe redirects are handled by Edge Function
- [ ] No changes needed in Stripe Dashboard

---

## Phase 4: Webflow Integration

### Step 4.1: Open Webflow Project

**Goal:** Access the Storage Valet landing page project in Webflow Editor

**Instructions:**

1. Go to https://webflow.com
2. Log in with your account
3. Look for the Storage Valet project (or similar name)
4. Click to open it
5. You should now be in the **Webflow Designer** (visual editor)

**What you should see:**
- Left sidebar with pages, elements, layers
- Center: visual preview of the landing page
- Right sidebar with design/settings
- Top: toolbar with design, preview, publish buttons

**Verification checklist:**
- [ ] Webflow Designer is open
- [ ] Landing page is visible
- [ ] Can see elements/sections on the page

---

### Step 4.2: Inspect "Sign Up" Buttons

**Goal:** Find all signup CTAs and identify their exact element structure

**Why needed:** To create accurate selectors in the JavaScript code

**Instructions:**

1. In the Webflow Designer, look at the landing page for "Sign Up" or "Get Started" buttons
2. For each button/CTA:
   - **Method A (Easiest):** Click the button in the designer → Look at left sidebar for its **class name** or **ID**
   - **Method B:** Right-click the button → Inspect element → Look at the HTML
3. Note down:
   - Button text (e.g., "Sign Up", "Get Started")
   - Element type (usually `<a>` or `<button>`)
   - Classes (e.g., `w-button`, `primary-button`, `cta-btn`)
   - ID (if any)

**Document your findings:**
```
Button 1:
- Text: "Sign Up"
- Element: <a>
- Classes: w-button, btn-primary
- ID: none

Button 2:
- Text: "Get Started"
- Element: <button>
- Classes: w-button, cta-button
- ID: signup-main

etc.
```

**Verification checklist:**
- [ ] Found all signup CTAs on the page
- [ ] Noted their class names and IDs
- [ ] Documented the structure

---

### Step 4.3: Decide on Button Selector Strategy

**Goal:** Choose how to target the signup buttons in JavaScript

**Option A: Use Existing Classes (Automatic)**
- Pro: Works with current button structure
- Con: Less precise if buttons aren't clearly marked
- Selector: `.primary-button` or `a.w-button` or similar

**Option B: Add Custom Class (Recommended)**
- Pro: Precise, future-proof, clear intent
- Con: Need to add class to each button (one-time setup)
- Selector: `.checkout-button`

**Option C: Use Element Attributes**
- Pro: Works without changing HTML
- Con: May be fragile if layout changes
- Selector: `a[href="#signup"]` or `button[data-action="checkout"]`

**My Recommendation:** Use **Option B** (Add Custom Class)

**Instructions for Option B:**

1. In Webflow Designer, select the first "Sign Up" button
2. Right panel → Look for "Class" section
3. Click to add a class
4. Enter: `checkout-button`
5. Press Enter
6. Repeat for all signup buttons on the page

**After adding custom class:**
- All signup buttons will have class `checkout-button`
- JavaScript selector will be: `.checkout-button`
- Much easier to target and debug

**Verification checklist:**
- [ ] Decided on selector strategy
- [ ] If Option B: Added `checkout-button` class to all signup buttons
- [ ] Can identify all buttons with the chosen selector

---

### Step 4.4: Access Webflow Custom Code Settings

**Goal:** Navigate to where you'll paste the JavaScript

**Instructions:**

1. In Webflow Designer, click the **Settings** gear icon (top left area)
2. A settings panel should open
3. Look for **Custom Code** option
4. Click it
5. You should see sections for:
   - **Head Code** (for `<head>` tags, CSS, etc.)
   - **Footer Code** (for JavaScript, analytics, etc.)

**Alternative path if Settings menu isn't clear:**
1. Top menu → Look for "Settings" option
2. Or click the gear icon next to "Publish" button
3. Find "Custom Code"

**Verification checklist:**
- [ ] Found Settings → Custom Code
- [ ] Can see Head Code and Footer Code sections
- [ ] Can see input areas to paste code

---

### Step 4.5: Prepare JavaScript Code for Webflow

**Goal:** Have the correct JavaScript ready to paste

**The code below is ready to use. You'll paste it into Footer Code section.**

```html
<script>
(function() {
  // ========== CONFIGURATION ==========
  // These values are used by the checkout function
  const CHECKOUT_URL = 'https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/create-checkout';
  const ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNTkzMDgsImV4cCI6MjA3MzYzNTMwOH0.sR4S7DNrwxhi1C4HFnDzr0YL6IBqxzVwCGYtBDhSAFI';

  // UPDATE THIS SELECTOR based on your button structure from Step 4.2/4.3
  // If you added class "checkout-button": use '.checkout-button'
  // If buttons have class "primary-button": use '.primary-button'
  // If buttons are links with href="#": use 'a[href="#"]'
  const BUTTON_SELECTOR = '.checkout-button'; // MODIFY THIS if needed

  // ========== HELPER FUNCTIONS ==========
  function logWithPrefix(message, level = 'log') {
    const timestamp = new Date().toLocaleTimeString();
    const prefix = '[SV Checkout]';
    console[level](`${prefix} ${timestamp} - ${message}`);
  }

  function showLoadingState(button) {
    button._originalText = button.innerText || button.textContent;
    button._originalStyle = {
      opacity: button.style.opacity,
      pointerEvents: button.style.pointerEvents,
      cursor: button.style.cursor
    };
    button.innerText = 'Loading checkout...';
    button.style.opacity = '0.6';
    button.style.pointerEvents = 'none';
    button.style.cursor = 'not-allowed';
  }

  function restoreButtonState(button) {
    if (button._originalText) {
      button.innerText = button._originalText;
    }
    if (button._originalStyle) {
      button.style.opacity = button._originalStyle.opacity;
      button.style.pointerEvents = button._originalStyle.pointerEvents;
      button.style.cursor = button._originalStyle.cursor;
    }
  }

  // ========== MAIN FUNCTION ==========
  document.addEventListener('DOMContentLoaded', function() {
    logWithPrefix('Initializing checkout handler...');

    // Find all signup buttons
    const signupButtons = document.querySelectorAll(BUTTON_SELECTOR);
    logWithPrefix(`Found ${signupButtons.length} signup button(s) using selector: "${BUTTON_SELECTOR}"`);

    if (signupButtons.length === 0) {
      logWithPrefix('WARNING: No buttons found. Check BUTTON_SELECTOR is correct.', 'warn');
    }

    signupButtons.forEach(function(button, index) {
      logWithPrefix(`Attaching click handler to button ${index + 1}: "${button.innerText.trim()}"`);

      button.addEventListener('click', async function(e) {
        // Prevent default link behavior
        e.preventDefault();

        logWithPrefix('Checkout button clicked');

        try {
          // Show loading state
          showLoadingState(button);
          logWithPrefix('Showing loading state...');

          // Call Edge Function
          logWithPrefix('Calling Edge Function: create-checkout');

          const response = await fetch(CHECKOUT_URL, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + ANON_KEY
            },
            body: JSON.stringify({})
          });

          logWithPrefix(`Edge Function response status: ${response.status}`);

          // Parse response
          const data = await response.json();

          // Check for HTTP errors
          if (!response.ok) {
            const errorMessage = data.error || `HTTP ${response.status}`;
            throw new Error(`Edge Function error: ${errorMessage}`);
          }

          // Check for missing checkout URL
          if (!data.url) {
            throw new Error('No checkout URL returned from Edge Function');
          }

          logWithPrefix(`✓ Checkout URL received from Edge Function`);
          logWithPrefix(`Redirecting to Stripe Checkout...`);

          // Redirect to Stripe Checkout (give it a moment to log)
          setTimeout(() => {
            window.location.href = data.url;
          }, 100);

        } catch (error) {
          logWithPrefix(`✗ Checkout failed: ${error.message}`, 'error');

          // Restore button state
          restoreButtonState(button);

          // Show error to user
          const errorMsg = `Sorry, we encountered an issue starting checkout.\n\nError: ${error.message}\n\nPlease try again or contact support.`;
          alert(errorMsg);
        }
      });
    });

    logWithPrefix('Checkout handler initialization complete');
  });
})();
</script>
```

**Before pasting, verify:**
- [ ] `CHECKOUT_URL` is correct: `https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/create-checkout`
- [ ] `ANON_KEY` is correct (from Prerequisites)
- [ ] `BUTTON_SELECTOR` matches your button structure (from Step 4.3)

**If using Option B (custom class):**
- `BUTTON_SELECTOR` should be: `.checkout-button`

**If using different selector:**
- Update `BUTTON_SELECTOR` to match your choice

**Verification checklist:**
- [ ] Have the JavaScript code ready to paste
- [ ] Verified all configuration values are correct
- [ ] Know which BUTTON_SELECTOR to use

---

### Step 4.6: Paste JavaScript into Webflow Footer Code

**Goal:** Add the JavaScript to Webflow so it runs on the landing page

**Instructions:**

1. In Webflow Designer, open **Settings** → **Custom Code**
2. Click in the **Footer Code** section (large text area)
3. Paste the entire JavaScript code from Step 4.5
4. The code should now appear in the Footer Code box
5. Click **Save** (usually a button at bottom of settings panel)

**What you're pasting:**
- A self-contained JavaScript function
- It finds checkout buttons
- Adds click handlers to them
- Calls the Supabase Edge Function
- Redirects to Stripe Checkout

**Verification checklist:**
- [ ] Code pasted into Footer Code section
- [ ] Code is visible in the text area
- [ ] Clicked Save
- [ ] No error messages appear

---

### Step 4.7: Publish Webflow Site

**Goal:** Deploy the updated landing page with checkout JavaScript

**Instructions:**

1. In Webflow Designer, top right → Click **Publish** button
2. You'll see a dialog asking where to publish:
   - **Webflow domain** (e.g., storage-valet-something.webflow.com)
   - **Custom domain** (www.mystoragevalet.com or your actual domain)
3. Select which one(s) to publish
4. Click **Publish** button in the dialog
5. Wait for publishing to complete (usually 10-30 seconds)
6. You'll see a confirmation message

**Verification checklist:**
- [ ] Clicked Publish
- [ ] Waited for publishing to complete
- [ ] Saw confirmation message

---

### Step 4.8: Test Webflow on Live Domain

**Goal:** Verify the signup flow works on the live website

**Prerequisites:**
- Webflow is published (Step 4.7 complete)
- Vercel portal is deployed (Step 1.8 complete)
- All environment variables are set correctly

**Instructions:**

1. Open a new browser tab
2. Go to your live Webflow site:
   - If you have custom domain: `https://www.mystoragevalet.com`
   - If using Webflow domain: `https://storage-valet-something.webflow.com`
3. Find a signup/CTA button
4. **Before clicking, open Developer Tools:**
   - Press `F12` (Windows) or `Cmd+Option+I` (Mac)
   - Click **Console** tab
   - Keep console open while you test

**Testing the flow:**

1. Look at console - you should see:
   ```
   [SV Checkout] ... Initializing checkout handler...
   [SV Checkout] ... Found X signup button(s) using selector: ".checkout-button"
   [SV Checkout] ... Attaching click handler to button 1: "Sign Up"
   etc.
   ```

2. Click a signup button
3. You should immediately see in console:
   ```
   [SV Checkout] ... Checkout button clicked
   [SV Checkout] ... Showing loading state...
   [SV Checkout] ... Calling Edge Function: create-checkout
   [SV Checkout] ... Edge Function response status: 200
   [SV Checkout] ✓ Checkout URL received from Edge Function
   [SV Checkout] ... Redirecting to Stripe Checkout...
   ```

4. You should be redirected to Stripe Checkout page

**What to look for:**
- ✅ Console shows button found and handler attached
- ✅ Clicking button triggers "Checkout button clicked" log
- ✅ Redirects to checkout.stripe.com
- ✅ No red errors in console

**If something goes wrong:**

**Issue: "Found 0 signup button(s)"**
- BUTTON_SELECTOR doesn't match your buttons
- Go back to Step 4.2 and verify button classes
- Update BUTTON_SELECTOR in the code
- Re-paste code to Webflow
- Republish

**Issue: Error "Cannot read properties of undefined"**
- Check ANON_KEY is correct and complete
- Check CHECKOUT_URL is exactly as shown

**Issue: "Edge Function error" or 500 status**
- Edge Function may not have secrets configured
- Verify Step 2.1-2.8 are complete

**Verification checklist:**
- [ ] Opened console (F12 or Cmd+Option+I)
- [ ] See "Initializing checkout handler" message
- [ ] See "Found X button(s)" message
- [ ] Clicked button
- [ ] See "Checkout button clicked" message
- [ ] Redirected to Stripe Checkout page
- [ ] No red errors in console

---

## Phase 5: End-to-End Testing

### Step 5.1: Understand the Test Card Information

**Goal:** Know how to complete test checkout without real payment

**Stripe provides test cards for different scenarios:**

```
Test Card (Always Succeeds):
- Number: 4242 4242 4242 4242
- Expiry: Any future date (e.g., 12/25)
- CVC: Any 3 digits (e.g., 123)
- ZIP: Any 5 digits (e.g., 12345)

Result: Payment succeeds, webhook fires normally
```

**Other test cards (for testing failures):**
```
Card that declines:
- Number: 4000 0000 0000 0002
- Same expiry/CVC/ZIP as above
- Result: Payment declines, webhook does NOT fire
```

For now, use **4242 4242 4242 4242** (succeeds).

**Verification checklist:**
- [ ] Have test card number memorized or written down
- [ ] Understand this won't charge real money

---

### Step 5.2: Complete a Full Checkout

**Goal:** Go through entire checkout process to verify integration works end-to-end

**Prerequisites:**
- Landing page is published (Step 4.7)
- Portal is deployed (Step 1.8)
- Environment variables are set (Phases 1-2)

**Instructions:**

1. Open browser to your Webflow landing page
2. Open Developer Console (F12 or Cmd+Option+I)
3. Click a signup button
4. Browser should redirect to Stripe checkout page
5. You should see a form asking for:
   - Email address
   - Card information
   - Billing details

6. Fill in the form:
   - **Email:** Use a test email that you can access (e.g., your test@example.com or similar)
   - **Card Number:** `4242 4242 4242 4242`
   - **Expiry:** `12/25` (or any future date)
   - **CVC:** `123` (or any 3 digits)
   - **Billing ZIP:** `12345` (or any 5 digits)

7. Click **"Pay"** button
8. Wait for Stripe to process (2-5 seconds)
9. You should see one of:
   - ✅ **Success page** with message about payment completion
   - ❌ **Error page** with message about payment failure

**If you see success page:**
- Take note of the confirmation/session ID shown
- Note the email address used
- This means Stripe received the payment
- The webhook should now be processing

**If you see error page:**
- Note the error message
- Check console for any errors
- Contact Claude with the error details

**Verification checklist:**
- [ ] Redirected to Stripe checkout
- [ ] Entered test card info
- [ ] Clicked Pay
- [ ] Waited for processing
- [ ] Saw success or error page
- [ ] Noted the email address used

---

### Step 5.3: Verify Stripe Received the Payment

**Goal:** Check that Stripe recorded the checkout attempt

**Instructions:**

1. Go to https://dashboard.stripe.com
2. Confirm **TEST MODE** is active (top right)
3. Left sidebar → **Payments**
4. Look for a recent payment with amount $299.00 or 0 (depends on how Stripe shows it)
5. Click on it to view details
6. Verify it shows:
   - Status: Succeeded or Completed
   - Amount: $299.00 USD
   - Email: The test email you used
   - Payment Method: Visa ending in 4242
   - Timestamp: Just now

**What this tells you:**
- ✅ Stripe received payment information
- ✅ Edge Function correctly created a checkout session
- ✅ Customer was redirected to checkout page
- ✅ Payment was processed (or attempted)

**Verification checklist:**
- [ ] Found the payment in Stripe Dashboard
- [ ] Status shows "Succeeded"
- [ ] Amount is $299.00
- [ ] Email matches what you entered

---

### Step 5.4: Verify Webhook Fired

**Goal:** Check that Stripe sent the webhook to Supabase

**Instructions:**

1. In Stripe Dashboard (TEST MODE), left sidebar → **Developers** → **Webhooks**
2. Click on the endpoint: `https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook`
3. Click **"Events"** or look for event history
4. Look for the most recent `checkout.session.completed` event
5. Click on it to view details
6. You should see:
   - Event: `checkout.session.completed`
   - Status: Delivered (green checkmark) or Pending
   - Timestamp: Just now
   - Request body showing the payment details

**If status is "Failed":**
- Click on it to see error message
- Common issues:
  - Webhook signing secret doesn't match
  - Supabase Edge Function is down
  - `STRIPE_WEBHOOK_SECRET` secret not set correctly

**What this tells you:**
- ✅ Stripe detected the payment completion
- ✅ Webhook was sent to Supabase
- ✅ Supabase received the request

**Verification checklist:**
- [ ] Found the webhook endpoint
- [ ] Clicked Events
- [ ] Found `checkout.session.completed` event
- [ ] Status shows "Delivered" or "Succeeded"

---

### Step 5.5: Verify Magic Link Email

**Goal:** Check that Supabase sent the magic link to the test email

**Instructions:**

1. Check the email address you used during checkout
2. Look for an email from Supabase (sender might be noreply@supabase.io or similar)
3. Subject might be: "Your login link for Storage Valet" or similar
4. The email should contain:
   - A button or link that says "Login" or "Confirm your email"
   - Link format: `https://portal.mystoragevalet.com/auth/callback?...`
5. Click the link

**Expected behavior after clicking link:**
- Browser redirects to `https://portal.mystoragevalet.com`
- You should be logged in automatically
- You should see the dashboard (likely empty, since you haven't added items)

**If you don't receive email:**
- Check spam/junk folder
- Wait up to 2 minutes (Supabase email can be slow)
- Check that webhook succeeded in Step 5.4
- If webhook failed, magic link won't be sent

**If email arrives but link doesn't work:**
- Check the link URL is correct (should contain portal.mystoragevalet.com)
- Try copying the link and pasting in browser
- Check that portal is deployed and accessible

**What this tells you:**
- ✅ Webhook was processed by Supabase
- ✅ Auth user was created with the email
- ✅ Magic link generation works
- ✅ Email delivery works
- ✅ Portal is accessible

**Verification checklist:**
- [ ] Received magic link email within 2 minutes
- [ ] Email from Supabase/SV
- [ ] Contains login link
- [ ] Clicked link
- [ ] Redirected to portal.mystoragevalet.com
- [ ] Logged in automatically
- [ ] Saw dashboard

---

### Step 5.6: Verify You're Authenticated in Portal

**Goal:** Confirm you're logged in and can access customer features

**Instructions:**

1. You should be on the dashboard page after clicking magic link
2. You should see:
   - Storage Valet logo/branding
   - Navigation menu with: Dashboard, Schedule, Account, Logout
   - An empty items list or "Add your first item" message
   - A floating "+" button to add items (or similar)

3. Try clicking **Account** in navigation
4. You should see:
   - Your email address displayed
   - Profile fields (name, phone, address)
   - Stripe Customer Portal button

5. Try clicking the **Stripe Customer Portal** button
6. You should be redirected to Stripe's billing page showing:
   - Your subscription ($299/month)
   - Ability to update payment method
   - Ability to cancel subscription
   - Invoice history

**If step redirects fail:**
- Check browser console for errors
- Verify `APP_URL` is correct in Supabase secrets (Step 2.2)
- Verify Stripe test keys are in place

**What this tells you:**
- ✅ Authentication works end-to-end
- ✅ Portal loads correctly
- ✅ Customer account is created
- ✅ Stripe Customer Portal integration works

**Verification checklist:**
- [ ] Logged in to portal
- [ ] Can see dashboard
- [ ] Can navigate to Account page
- [ ] Account page shows email
- [ ] Stripe Customer Portal link works
- [ ] Can see subscription in Stripe

---

### Step 5.7: Document Results

**Goal:** Record what worked and any issues found

**Create a summary with:**

```
End-to-End Test Results
Date: [Today's date]
Tester: [Your name]

SIGNUP & CHECKOUT
✅ or ❌ Webflow signup button is clickable
✅ or ❌ Clicking button shows loading state
✅ or ❌ Redirects to Stripe checkout.stripe.com
✅ or ❌ Can enter test card (4242 4242 4242 4242)
✅ or ❌ Payment processes successfully

STRIPE WEBHOOK
✅ or ❌ Payment appears in Stripe Dashboard
✅ or ❌ Webhook event shows as "Delivered"
✅ or ❌ No errors in webhook logs

EMAIL & AUTHENTICATION
✅ or ❌ Received magic link email within 2 minutes
✅ or ❌ Magic link redirects to portal
✅ or ❌ Automatically logged in after clicking link

PORTAL ACCESS
✅ or ❌ Portal loads at https://portal.mystoragevalet.com
✅ or ❌ Can see dashboard with empty items
✅ or ❌ Can navigate to Account page
✅ or ❌ Can access Stripe Customer Portal
✅ or ❌ Subscription shows in Stripe

OVERALL
Status: PASS or FAIL (or PASS WITH ISSUES)

Issues Found:
- [List any problems encountered]

Next Steps:
- [Any fixes or improvements needed]
```

**If any items failed:**
- Note the exact error message
- Try to reproduce it
- Screenshot the error
- Document for debugging

**Verification checklist:**
- [ ] Completed all test items
- [ ] Documented results
- [ ] Noted any issues found
- [ ] Ready for next steps

---

## Phase 6: Verification Checkpoints

### Checkpoint 6.1: Vercel Configuration Complete

**Verify all of Phase 1 is complete:**
- [ ] Production domain added to Vercel (`portal.mystoragevalet.com`)
- [ ] Domain is verified/active
- [ ] Environment variables set:
  - [ ] `VITE_APP_URL` = `https://portal.mystoragevalet.com`
  - [ ] `VITE_SUPABASE_URL` = `https://gmjucacmbrumncfnnhua.supabase.co`
  - [ ] `VITE_SUPABASE_ANON_KEY` = correct anon key
  - [ ] `VITE_STRIPE_PUBLISHABLE_KEY` = `pk_test_...`
- [ ] Vercel redeployed with new environment variables
- [ ] Portal loads at `https://portal.mystoragevalet.com`
- [ ] No console errors on login page

---

### Checkpoint 6.2: Supabase Secrets Complete

**Verify all of Phase 2 is complete:**
- [ ] Edge Function secrets verified:
  - [ ] `APP_URL` = `https://portal.mystoragevalet.com`
  - [ ] `SUPABASE_URL` = `https://gmjucacmbrumncfnnhua.supabase.co`
  - [ ] `SUPABASE_SERVICE_ROLE_KEY` = set
  - [ ] `STRIPE_SECRET_KEY` = `sk_test_...`
  - [ ] `STRIPE_PRICE_PREMIUM299` = `price_test_...`
  - [ ] `STRIPE_WEBHOOK_SECRET` = `whsec_test_...`
- [ ] All three Edge Functions show "Ready" status
- [ ] No error messages in Supabase logs

---

### Checkpoint 6.3: Stripe Configuration Complete

**Verify all of Phase 3 is complete:**
- [ ] Stripe in TEST MODE
- [ ] Product "Storage Valet Premium" exists with $299/month price
- [ ] Webhook endpoint created and listening
- [ ] Webhook configured to receive events:
  - [ ] `checkout.session.completed`
  - [ ] `customer.subscription.created`
  - [ ] `customer.subscription.updated`
  - [ ] `customer.subscription.deleted`
  - [ ] `invoice.payment_succeeded`
  - [ ] `invoice.payment_failed`

---

### Checkpoint 6.4: Webflow Integration Complete

**Verify all of Phase 4 is complete:**
- [ ] Custom code pasted into Webflow Footer Code
- [ ] Button selector matches actual buttons (e.g., `.checkout-button`)
- [ ] Webflow published
- [ ] Console shows "Initializing checkout handler" and "Found X button(s)"
- [ ] No console errors on landing page

---

### Checkpoint 6.5: End-to-End Testing Complete

**Verify all of Phase 5 is complete:**
- [ ] Completed full checkout with test card
- [ ] Payment appears in Stripe Dashboard
- [ ] Webhook delivered successfully in Stripe
- [ ] Received magic link email
- [ ] Logged into portal via magic link
- [ ] Can access Account page and Stripe Customer Portal
- [ ] No critical errors encountered

---

## Phase 7: Troubleshooting Reference

### Issue: "Found 0 signup button(s)" in console

**Cause:** Button selector doesn't match actual buttons

**Fix:**
1. Go back to Step 4.2 and inspect buttons again
2. Verify the actual class names or IDs
3. Update `BUTTON_SELECTOR` in the JavaScript code
4. Re-paste code to Webflow
5. Republish

**Test:** Open browser console and check for updated message

---

### Issue: Clicking button does nothing

**Cause:** JavaScript didn't load or attach

**Fix:**
1. Open browser console (F12)
2. Should see initialization messages
3. If no messages: JavaScript didn't load
   - Verify custom code was saved in Webflow
   - Verify Webflow was published
   - Clear browser cache and reload (Ctrl+Shift+Delete or Cmd+Shift+Delete)
4. If messages but no response: Click handler not attached
   - Verify button selector is correct
   - Manually test clicking button and watch console

---

### Issue: "Edge Function error" or 500 status

**Cause:** Edge Function isn't running correctly or secrets are missing

**Fix:**
1. Go to Supabase Dashboard → Edge Functions
2. Click on `create-checkout` function
3. Check if it shows "Ready" status (green)
4. If not "Ready": Click Deploy/Redeploy
5. Check function logs for errors:
   - Bottom of Edge Function page should show recent logs
   - Look for error messages
6. Verify all secrets are set (Phase 2)
7. Try curl test from Step 2.1 prerequisites

---

### Issue: Redirects to Stripe but see error on checkout page

**Cause:** Stripe configuration issue

**Fix:**
1. Check Stripe TEST MODE is active
2. Verify price ID is correct and exists
3. Verify product exists in Stripe
4. Check Stripe API keys are in Edge secrets
5. Look at Stripe Dashboard → Events for any errors

---

### Issue: Don't receive magic link email

**Cause:** Webhook didn't fire or email service is slow

**Fix:**
1. Check Stripe Dashboard → Webhooks → Events for `checkout.session.completed`
2. If not there: Webhook didn't fire
   - Check `STRIPE_WEBHOOK_SECRET` is correct
   - Check webhook endpoint URL is exactly: `https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook`
3. If event is there but status is "Failed": Webhook signature verification failed
   - Update `STRIPE_WEBHOOK_SECRET` in Supabase
   - Verify it matches Stripe Dashboard signing secret exactly
4. If event is "Delivered": Webhook went through
   - Check spam folder
   - Wait up to 2-3 minutes
   - Check Supabase logs for email sending errors

---

### Issue: Magic link doesn't work

**Cause:** Email link is incorrect or portal isn't accessible

**Fix:**
1. Check the link URL in the email
2. Should contain: `portal.mystoragevalet.com`
3. If it contains old URL (e.g., vercel staging URL): `APP_URL` secret is wrong
   - Update `APP_URL` in Supabase Edge secrets to `https://portal.mystoragevalet.com`
   - Redeploy Edge Functions
4. If URL is correct: Portal may not be accessible
   - Try manually visiting `https://portal.mystoragevalet.com`
   - Verify Vercel deployment is ready

---

### Issue: Logged in but portal shows error about "missing data"

**Cause:** Migration 0004 not applied to database or environment variables wrong

**Fix:**
1. Contact Claude - this may require database migration (Step Sprint 0)
2. Provide screenshot of the error

---

## Summary Checklist

Before declaring success, verify:

### All Phases Complete
- [ ] Phase 1: Vercel configuration (domain, env vars, deployment)
- [ ] Phase 2: Supabase secrets (all 6 secrets set and verified)
- [ ] Phase 3: Stripe configuration (product, webhook, test mode)
- [ ] Phase 4: Webflow integration (code pasted, buttons identified, published)
- [ ] Phase 5: End-to-end testing (all steps completed successfully)

### Critical Functionality Working
- [ ] Landing page loads
- [ ] Signup buttons found and clickable
- [ ] Clicking button shows loading state
- [ ] Redirects to Stripe checkout
- [ ] Test card payment succeeds
- [ ] Webhook fires and delivers
- [ ] Magic link email arrives
- [ ] Can log into portal via magic link
- [ ] Account page works and shows Stripe integration
- [ ] No console errors

### No Critical Blockers
- [ ] No 404 errors on URLs
- [ ] No 500 errors from Edge Functions
- [ ] No CORS errors
- [ ] No missing environment variables
- [ ] No broken links or redirects

### Ready for Next Phase
- [ ] All tests passed
- [ ] Documentation updated
- [ ] No outstanding issues

---

## When Done: Communicate Results

**Message to Claude:**
> "Completed end-to-end implementation:
>
> ✅ Vercel domain: portal.mystoragevalet.com is primary
> ✅ Environment variables: All 4 Vercel vars set correctly
> ✅ Supabase secrets: All 6 secrets configured
> ✅ Stripe: TEST MODE active, product and webhook configured
> ✅ Webflow: Custom code added, buttons identified, published
> ✅ Testing: Completed full checkout with test card
> ✅ Webhook: Delivered successfully to Supabase
> ✅ Magic link: Received and portal login works
> ✅ Stripe Portal: Integration working, can manage billing
>
> [List any issues found and fixed]
>
> System is ready for Phase 1 testing with real portal features."

---

## Notes for Ongoing Work

- **TEST MODE:** Currently using Stripe test keys. Before launch, will switch to `_live_` keys.
- **ANON KEY EXPIRY:** The anon key shown has an expiry date in JWT. If errors occur about token expiry, contact Claude for refresh.
- **DNS PROPAGATION:** If domain issues occur, may take up to 24 hours to fully propagate globally. Testing from local network usually works faster.
- **VERCEL CACHE:** If changes don't appear, Vercel may have cached old version. Use "Redeploy" to force fresh build.

