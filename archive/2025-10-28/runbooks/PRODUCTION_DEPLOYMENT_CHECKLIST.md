# Production Deployment Checklist — Storage Valet Phase 1

**Version:** 1.0
**Date Created:** 2025-10-20
**Target Deployment Date:** __________
**Deployment Lead:** __________

---

## Purpose

This checklist ensures a safe, complete, and verified deployment of the Storage Valet Customer Portal Phase 1 to production. Every item must be checked off before considering the deployment complete.

**DO NOT SKIP STEPS.** If a step is not applicable, mark it N/A with a reason.

---

## Pre-Deployment Checklist

### 1. Code Readiness

- [ ] All Phase 1 code committed to `main` branch
- [ ] Git tags created for release:
  ```bash
  cd ~/code/sv-portal && git tag phase-1.0-production && git push --tags
  cd ~/code/sv-db && git tag phase-1.0-production && git push --tags
  cd ~/code/sv-edge && git tag phase-1.0-production && git push --tags
  cd ~/code/sv-docs && git tag phase-1.0-production && git push --tags
  ```
- [ ] No outstanding critical bugs (check BUG_TRACKING_TEMPLATE.md)
- [ ] TypeScript compiles with 0 errors: `cd ~/code/sv-portal && npm run lint`
- [ ] All dependencies installed and up-to-date

---

### 2. Testing Verification

- [ ] Manual test script completed: PHASE_1_MANUAL_TEST_SCRIPT.md
  - [ ] Pass rate ≥95% (acceptable to have minor cosmetic issues)
  - [ ] All critical and high-severity bugs fixed
- [ ] Validation checklist completed: FINAL_VALIDATION_CHECKLIST_v3.1_PHASE1.md
  - [ ] All "Hard Gates" passing
  - [ ] All Phase 1 requirements passing
- [ ] Security audit completed:
  - [ ] RLS verified (cross-user isolation tested)
  - [ ] Photo signed URLs verified (1-hour expiry)
  - [ ] No sensitive data in console logs
  - [ ] No secrets in frontend code
- [ ] Performance verified:
  - [ ] 50+ items load in <5 seconds
  - [ ] Search/filter responsive with 100+ items
- [ ] Cross-browser tested:
  - [ ] Chrome (desktop)
  - [ ] Safari (desktop)
  - [ ] Firefox (desktop)
  - [ ] Mobile Safari (iOS)
  - [ ] Mobile Chrome (Android)
- [ ] Mobile responsiveness verified

---

### 3. Database Preparation

- [ ] **CRITICAL:** Backup production database before any changes
  - [ ] Backup method: Supabase Dashboard → Database → Backups → Create Manual Backup
  - [ ] Backup confirmed and downloadable
  - [ ] Backup location documented: __________

- [ ] Migration 0004 applied to production:
  ```bash
  cd ~/code/sv-db
  supabase db push --db-url [PRODUCTION_DB_URL]
  ```
  - [ ] Migration executed successfully (no errors)
  - [ ] Validation script run: `scripts/validate_migration_0004.sh`
  - [ ] All 8 performance indexes verified
  - [ ] RLS policies verified on all tables:
    - [ ] items (SELECT, INSERT, UPDATE, DELETE)
    - [ ] customer_profile (SELECT, UPDATE)
    - [ ] actions (SELECT, INSERT)
    - [ ] inventory_events (SELECT)

- [ ] Data integrity checks:
  - [ ] Existing items have photo_paths populated (or NULL)
  - [ ] No orphaned photos in storage bucket
  - [ ] All QR codes unique

- [ ] Database configuration verified:
  - [ ] Connection pooling settings appropriate
  - [ ] Rate limits configured (if needed)
  - [ ] Backup schedule enabled (daily recommended)

---

### 4. Stripe Configuration (LIVE MODE)

**⚠️ WARNING:** This section switches from TEST to LIVE mode. Real money will be charged.

- [ ] **Stripe Dashboard:** Switch to LIVE mode (toggle in top-right corner)

- [ ] Product created in LIVE mode:
  - [ ] Name: "Storage Valet Premium"
  - [ ] Description: "Full-service storage with pickup and delivery"
  - [ ] Price: $299.00 USD / month (recurring)
  - [ ] Price ID copied: __________________ (starts with `price_live_...`)

- [ ] Webhook endpoint configured in LIVE mode:
  - [ ] URL: `https://[SUPABASE_PROJECT_ID].supabase.co/functions/v1/stripe-webhook`
  - [ ] Events selected:
    - [ ] checkout.session.completed
    - [ ] customer.subscription.created
    - [ ] customer.subscription.updated
    - [ ] customer.subscription.deleted
    - [ ] invoice.payment_succeeded
    - [ ] invoice.payment_failed
  - [ ] Webhook signing secret copied: __________________ (starts with `whsec_...`)
  - [ ] Webhook endpoint status: Active

- [ ] API keys copied (LIVE mode):
  - [ ] Publishable key: __________________ (starts with `pk_live_...`)
  - [ ] Secret key: __________________ (starts with `sk_live_...`) **DO NOT COMMIT TO GIT**

- [ ] Stripe account settings verified:
  - [ ] Business name correct
  - [ ] Support email set
  - [ ] Business URL set
  - [ ] Tax settings configured (if applicable)
  - [ ] Payment methods enabled (card, Apple Pay, Google Pay, etc.)

- [ ] Stripe Customer Portal configured:
  - [ ] Features enabled: Update payment method, View invoices, Cancel subscription
  - [ ] Branding matches Storage Valet brand
  - [ ] Return URL set to: `https://portal.mystoragevalet.com/account`

---

### 5. Supabase Configuration (Production)

- [ ] Project identified:
  - [ ] Project ID: __________________
  - [ ] Project URL: __________________
  - [ ] Region: __________________

- [ ] Auth settings verified:
  - [ ] Site URL set to: `https://portal.mystoragevalet.com`
  - [ ] Redirect URLs added:
    - [ ] `https://portal.mystoragevalet.com/**` (wildcard)
  - [ ] Email auth enabled
  - [ ] Email templates customized (optional but recommended):
    - [ ] Magic Link email
    - [ ] Confirmation email
  - [ ] SMTP configured (optional - using Supabase default is acceptable)

- [ ] Storage bucket verified:
  - [ ] Bucket name: `item-photos`
  - [ ] Public: NO (private bucket)
  - [ ] File size limit: 5MB (enforced in app, not bucket)
  - [ ] Allowed MIME types: image/jpeg, image/png, image/webp

- [ ] Edge Functions secrets set (PRODUCTION values):
  ```bash
  cd ~/code/sv-edge
  supabase secrets set --project-ref [PROJECT_ID] STRIPE_SECRET_KEY="sk_live_..."
  supabase secrets set --project-ref [PROJECT_ID] STRIPE_WEBHOOK_SECRET="whsec_..."
  supabase secrets set --project-ref [PROJECT_ID] STRIPE_PRICE_PREMIUM299="price_live_..."
  supabase secrets set --project-ref [PROJECT_ID] SUPABASE_URL="https://[PROJECT_ID].supabase.co"
  supabase secrets set --project-ref [PROJECT_ID] SUPABASE_SERVICE_ROLE_KEY="[SERVICE_ROLE_KEY]"
  supabase secrets set --project-ref [PROJECT_ID] APP_URL="https://portal.mystoragevalet.com"
  ```
  - [ ] All 6 secrets set successfully
  - [ ] Verify secrets: `supabase secrets list --project-ref [PROJECT_ID]`

- [ ] Edge Functions deployed:
  ```bash
  cd ~/code/sv-edge
  supabase functions deploy stripe-webhook --project-ref [PROJECT_ID]
  supabase functions deploy create-checkout --project-ref [PROJECT_ID]
  supabase functions deploy create-portal-session --project-ref [PROJECT_ID]
  ```
  - [ ] stripe-webhook deployed
  - [ ] create-checkout deployed
  - [ ] create-portal-session deployed
  - [ ] All functions show "Status: Active" in Supabase Dashboard

- [ ] Database backups enabled:
  - [ ] Automatic daily backups enabled
  - [ ] Backup retention period: 7 days (or longer)

---

### 6. Vercel Configuration (Production)

- [ ] Project configured:
  - [ ] Project name: `sv-portal` (or similar)
  - [ ] Git repository connected: [GitHub repo URL]
  - [ ] Production branch: `main`
  - [ ] Framework preset: Vite

- [ ] Environment variables set (Production environment):
  - [ ] `VITE_SUPABASE_URL`: `https://[PROJECT_ID].supabase.co`
  - [ ] `VITE_SUPABASE_ANON_KEY`: `[ANON_KEY from Supabase Dashboard]`
  - [ ] `VITE_APP_URL`: `https://portal.mystoragevalet.com`
  - [ ] `VITE_STRIPE_PUBLISHABLE_KEY`: `pk_live_...`
  - [ ] All variables marked for "Production" environment

- [ ] Build settings verified:
  - [ ] Build command: `npm run build`
  - [ ] Output directory: `dist`
  - [ ] Install command: `npm install`
  - [ ] Node version: 18.x or 20.x

- [ ] SPA rewrites configured (for deep linking):
  - [ ] File: `vercel.json` (or Vercel dashboard)
  - [ ] Rewrite rule:
    ```json
    {
      "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
    }
    ```
  - [ ] Verified: Direct navigation to `/dashboard` doesn't 404

- [ ] Custom domain configured:
  - [ ] Domain: `portal.mystoragevalet.com`
  - [ ] DNS records added (in domain registrar):
    - [ ] A record or CNAME record pointing to Vercel
    - [ ] Values provided by Vercel dashboard
  - [ ] SSL certificate: Auto-provisioned by Vercel
  - [ ] HTTPS redirect enabled

---

### 7. DNS & Domain Configuration

- [ ] Domain registrar: __________________
- [ ] DNS records configured:
  - [ ] `portal.mystoragevalet.com` → Vercel
    - Type: CNAME
    - Value: `cname.vercel-dns.com` (or A record with Vercel IP)
  - [ ] DNS propagation verified: https://dnschecker.org
    - [ ] Check shows correct Vercel IP/CNAME globally

- [ ] SSL certificate verified:
  - [ ] Certificate issued (check in browser)
  - [ ] Certificate valid for: `portal.mystoragevalet.com`
  - [ ] No mixed content warnings
  - [ ] HTTPS redirect working (http:// → https://)

---

### 8. Webflow Integration

- [ ] Landing page URL: __________________
- [ ] CTA button configured:
  - [ ] Button text: "Get Started" (or similar)
  - [ ] Button action: Custom code embed
  - [ ] Embed code calls: `https://[SUPABASE_PROJECT_ID].supabase.co/functions/v1/create-checkout`
  - [ ] Success redirect: `https://portal.mystoragevalet.com/dashboard`
  - [ ] Cancel redirect: `https://mystoragevalet.com` (back to landing page)
  - [ ] **NO SECRETS** in Webflow embed code (verified)

- [ ] Test button functionality:
  - [ ] Click CTA → redirects to Stripe Checkout
  - [ ] Complete test checkout (use test card: 4242 4242 4242 4242)
  - [ ] After checkout → webhook fires → magic link sent
  - [ ] Magic link works → redirects to dashboard

---

## Deployment Execution

### 9. Production Deployment

**Deployment Window:** __________ (Date/Time)
**Rollback Plan:** If deployment fails, revert Vercel to previous production deployment and restore database backup

**Steps:**

1. **Deploy sv-edge functions:**
   ```bash
   cd ~/code/sv-edge
   supabase functions deploy stripe-webhook --project-ref [PROJECT_ID]
   supabase functions deploy create-checkout --project-ref [PROJECT_ID]
   supabase functions deploy create-portal-session --project-ref [PROJECT_ID]
   ```
   - [ ] Deployment successful (no errors)
   - [ ] Functions show "Status: Active" in dashboard

2. **Deploy sv-portal to Vercel:**
   - [ ] Option A: Trigger from Vercel dashboard (recommended for control)
     - [ ] Vercel Dashboard → sv-portal project → Deployments
     - [ ] Click "Deploy" → Select branch: `main`
     - [ ] **CRITICAL:** Uncheck "Use existing build cache"
     - [ ] Environment: Production
     - [ ] Click "Deploy"
   - [ ] Option B: Push to main branch (auto-deploys)
     ```bash
     cd ~/code/sv-portal
     git push origin main
     ```

3. **Monitor deployment:**
   - [ ] Watch Vercel build logs for errors
   - [ ] Build status: Success ✅
   - [ ] Deployment URL: __________________
   - [ ] Production URL assigned: `https://portal.mystoragevalet.com`

4. **Verify deployment:**
   - [ ] Visit `https://portal.mystoragevalet.com`
   - [ ] Page loads (no 404 or 500 errors)
   - [ ] Open browser dev tools (F12) → Console
   - [ ] No console errors on page load
   - [ ] Check "View Source" → confirm latest code deployed (search for unique Phase 1 identifier)

---

## Post-Deployment Verification

### 10. Smoke Tests (Production)

**Execute these tests immediately after deployment:**

- [ ] **Authentication:**
  - [ ] Navigate to portal URL
  - [ ] Enter email address
  - [ ] Click "Send Magic Link"
  - [ ] Receive magic link within 120 seconds
  - [ ] Click link → redirects to dashboard
  - [ ] User logged in successfully

- [ ] **Dashboard loads:**
  - [ ] Insurance coverage bar displays
  - [ ] Empty state shows (if no items)
  - [ ] Floating "+" button visible
  - [ ] No console errors

- [ ] **Create item:**
  - [ ] Click "+" button
  - [ ] Upload photo (JPG, <5MB)
  - [ ] Fill all required fields
  - [ ] Click "Add Item"
  - [ ] Item appears in dashboard
  - [ ] QR code generated (SV-YYYY-XXXXXX format)
  - [ ] Photo loads via signed URL

- [ ] **Edit item:**
  - [ ] Click item card → Edit
  - [ ] Change label
  - [ ] Click "Save Changes"
  - [ ] Changes reflected on dashboard

- [ ] **Delete item:**
  - [ ] Click item → Delete
  - [ ] Confirm deletion
  - [ ] Item removed from dashboard

- [ ] **Search:**
  - [ ] Enter search term
  - [ ] Results filter correctly

- [ ] **Profile:**
  - [ ] Navigate to Account page
  - [ ] Edit profile fields
  - [ ] Click "Save Profile"
  - [ ] Refresh page → changes persist

- [ ] **Stripe Customer Portal:**
  - [ ] Click "Manage Billing"
  - [ ] Stripe Customer Portal opens
  - [ ] Correct subscription displays
  - [ ] Return to portal works

- [ ] **Schedule service:**
  - [ ] Select item(s)
  - [ ] Click "Schedule Pickup"
  - [ ] Fill form (date >48 hours from now)
  - [ ] Submit request
  - [ ] Success message displays

- [ ] **QR Code:**
  - [ ] Open item details
  - [ ] QR code displays
  - [ ] Click "Download PNG" → downloads successfully
  - [ ] Scan QR with phone → readable

- [ ] **Timeline:**
  - [ ] Open item details
  - [ ] Timeline shows "item_created" event
  - [ ] Timestamp displays correctly

---

### 11. Integration Verification

- [ ] **Stripe Webhook:**
  - [ ] Stripe Dashboard → Webhooks → [Your endpoint]
  - [ ] Check "Events" tab
  - [ ] Recent events show successful delivery (200 OK status)
  - [ ] If no events yet, trigger test checkout

- [ ] **Webflow CTA:**
  - [ ] Visit landing page: __________________
  - [ ] Click CTA button
  - [ ] Redirects to Stripe Checkout (LIVE mode)
  - [ ] **DO NOT** complete real checkout (unless you want to)
  - [ ] Cancel and verify no errors

- [ ] **Email Deliverability (5 Providers):**
  - [ ] Gmail: Magic link received within 120 seconds
  - [ ] Outlook: Magic link received within 120 seconds
  - [ ] iCloud: Magic link received within 120 seconds
  - [ ] Yahoo: Magic link received within 120 seconds
  - [ ] ProtonMail: Magic link received within 120 seconds
  - [ ] Check spam folders if not in inbox

---

### 12. Security Verification (Production)

- [ ] **RLS Isolation:**
  - [ ] Create 2 test accounts
  - [ ] User A creates items
  - [ ] User B attempts to access User A's items → BLOCKED
  - [ ] No cross-user data visible

- [ ] **Photo Access:**
  - [ ] Photo URLs contain signed token (?token=...)
  - [ ] User B cannot access User A's photos directly

- [ ] **Secrets Not Exposed:**
  - [ ] View page source → search for "secret", "sk_live", "service_role"
  - [ ] No sensitive keys visible in HTML/JS
  - [ ] Environment variables not exposed in build

- [ ] **HTTPS Enforcement:**
  - [ ] Navigate to `http://portal.mystoragevalet.com` (no S)
  - [ ] Automatically redirects to `https://`
  - [ ] Browser shows padlock icon (secure)

---

### 13. Monitoring Setup

- [ ] **Error Tracking (Optional but Recommended):**
  - [ ] Sentry/LogRocket/Rollbar configured
  - [ ] Test error: Trigger intentional error and verify it's logged
  - [ ] Alert notifications configured

- [ ] **Uptime Monitoring (Optional but Recommended):**
  - [ ] Uptime Robot / Pingdom / UptimeRobot configured
  - [ ] Monitor URL: `https://portal.mystoragevalet.com`
  - [ ] Check frequency: Every 5 minutes
  - [ ] Alert email: __________________

- [ ] **Analytics (Optional):**
  - [ ] Google Analytics / Plausible configured
  - [ ] Tracking ID added to portal
  - [ ] Test: Visit page and verify hit registers

---

### 14. Documentation Updates

- [ ] Update DEPLOYMENT_STATUS document:
  - [ ] Mark production as DEPLOYED
  - [ ] Document production URLs
  - [ ] Document deployment date/time

- [ ] Update README files:
  - [ ] sv-portal README with production URL
  - [ ] sv-edge README with production endpoints
  - [ ] sv-docs README with latest status

- [ ] Create customer-facing documentation (if needed):
  - [ ] User guide: How to add items
  - [ ] User guide: How to schedule pickup
  - [ ] FAQ: Common questions
  - [ ] Support email: support@mystoragevalet.com

---

## Beta Testing (Optional but Recommended)

### 15. Beta User Testing

**Beta Users:** (Name 2-3 friendly customers)
1. __________________
2. __________________
3. __________________

**Steps:**
- [ ] Invite beta users via email
- [ ] Provide test accounts or guide through signup
- [ ] Ask them to use portal for 24-48 hours
- [ ] Gather feedback via survey or call:
  - [ ] What was confusing?
  - [ ] What didn't work?
  - [ ] What features are missing?
  - [ ] Overall experience rating (1-10)

- [ ] Address critical feedback:
  - [ ] Bug: __________________ → Fixed? ☐
  - [ ] Bug: __________________ → Fixed? ☐
  - [ ] Feature request: __________________ → Defer to Phase 2

---

## Full Launch

### 16. Public Launch Preparation

- [ ] **Marketing site updated:**
  - [ ] Landing page CTA tested
  - [ ] Pricing page shows $299/month
  - [ ] Features page reflects Phase 1 capabilities

- [ ] **Customer communication:**
  - [ ] Email drafted to existing customers
  - [ ] Email sent announcing portal launch
  - [ ] Social media posts scheduled (if applicable)

- [ ] **Support readiness:**
  - [ ] Support team trained on portal features
  - [ ] Support documentation created
  - [ ] Support email monitored: support@mystoragevalet.com

- [ ] **Terms & Privacy:**
  - [ ] Terms of Service link added to portal footer
  - [ ] Privacy Policy link added to portal footer
  - [ ] Documents reviewed by legal (if required)

---

### 17. Post-Launch Monitoring (First 48 Hours)

- [ ] **Day 1 (Launch Day):**
  - [ ] Monitor error logs every 2 hours
  - [ ] Check Stripe Dashboard for failed payments
  - [ ] Check Supabase logs for database errors
  - [ ] Respond to customer support inquiries within 2 hours

- [ ] **Day 2:**
  - [ ] Monitor error logs every 4 hours
  - [ ] Review user analytics:
    - [ ] How many signups?
    - [ ] How many items created?
    - [ ] How many service requests?
  - [ ] Check email deliverability (any issues reported?)

- [ ] **Day 3-7:**
  - [ ] Daily check of error logs
  - [ ] Daily review of support tickets
  - [ ] Weekly meeting to review launch metrics

---

## Rollback Plan

### 18. Rollback Procedure (If Critical Issue Arises)

**Trigger Conditions:** Any of the following require immediate rollback:
- Site is completely down (500 errors)
- Users cannot log in (auth broken)
- Data loss or corruption detected
- Security breach discovered

**Rollback Steps:**
1. **Rollback Vercel Deployment:**
   - [ ] Vercel Dashboard → Deployments
   - [ ] Find previous working deployment
   - [ ] Click three dots → "Promote to Production"
   - [ ] Verify old version is live

2. **Rollback Database (If Needed):**
   - [ ] Supabase Dashboard → Database → Backups
   - [ ] Restore from backup created before deployment
   - [ ] **WARNING:** This will lose any data created since backup

3. **Rollback Supabase Secrets (If Needed):**
   - [ ] Re-set old secret values (if changed)
   - [ ] Redeploy Edge Functions with old secrets

4. **Notify Users:**
   - [ ] Display maintenance banner on site
   - [ ] Send email if downtime exceeds 30 minutes

5. **Post-Mortem:**
   - [ ] Document what went wrong
   - [ ] Identify root cause
   - [ ] Create fix plan
   - [ ] Schedule re-deployment

---

## Sign-Off

**Deployment Checklist Completed By:**
- Name: __________________
- Role: __________________
- Date: __________________
- Signature: __________________

**Deployment Approved By:**
- Name: __________________
- Role: __________________
- Date: __________________
- Signature: __________________

**Production Launch Status:** ☐ SUCCESS ✅  ☐ ROLLBACK REQUIRED ❌

**Notes:**
________________________________________________________________
________________________________________________________________
________________________________________________________________

---

**Congratulations!** If all items are checked, the Storage Valet Customer Portal Phase 1 is now live and ready for customers. 🎉

**Next Steps:**
- Monitor closely for first week
- Gather user feedback
- Plan Phase 2 features based on feedback
- Celebrate your hard work! 🚀

