# Webflow → Supabase → Stripe Integration Guide for Perplexity Assistant

**Date:** October 23, 2025
**Status:** Ready for Implementation
**Context:** Storage Valet Phase 1 Launch
**Target:** Connect Webflow landing page to live Stripe checkout flow

---

## Overview: The Complete Flow

Your landing page visitors follow this journey:

```
1. User visits Webflow landing page (mystoragevalet.com)
2. User clicks "Sign up" button
3. Button triggers JavaScript that calls Supabase Edge Function
4. Edge Function creates Stripe Checkout Session (price: $299/month)
5. User redirected to Stripe-hosted checkout page
6. User completes payment (test card: 4242 4242 4242 4242)
7. Stripe fires webhook to Supabase
8. Webhook handler creates auth user + sends magic link
9. User receives email with magic link
10. User clicks link → logs into portal (portal.mystoragevalet.com)
```

**Key Point:** Webflow does NOT directly connect to Supabase or Stripe. Webflow calls a single Edge Function URL, and that function handles all the Stripe logic server-side.

---

## Part 1: Verify Prerequisites

Before adding code to Webflow, confirm these are ready:

### ✅ 1. Supabase Edge Function is Deployed

The function `create-checkout` must already be deployed and accessible:

**Check if it's working:**
```bash
curl -sS -X POST 'https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/create-checkout' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNTkzMDgsImV4cCI6MjA3MzYzNTMwOH0.sR4S7DNrwxhi1C4HFnDzr0YL6IBqxzVwCGYtBDhSAFI' \
  -d '{}'
```

**Expected response:**
```json
{
  "url": "https://checkout.stripe.com/c/pay/cs_test_..."
}
```

If you see HTTP 200 with a `checkout.stripe.com` URL → ✅ Ready to proceed
If you see HTTP 401 → Function may have JWT enforcement (needs to be public)
If you see HTTP 500 → Stripe keys may not be configured

**Contact Claude if the Edge Function is not responding.**

### ✅ 2. Stripe Test Mode is Active

Go to Stripe Dashboard:
- Confirm "Test mode" toggle is ON (top right)
- Confirm you have a test price ID for $299/month (price_test_...)
- Confirm webhook endpoint exists pointing to: `https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/stripe-webhook`

### ✅ 3. Portal URL is Configured

The Edge Function redirects to this URL after checkout:
- **Staging:** `https://sv-portal-staging.vercel.app` (if testing)
- **Production:** `https://portal.mystoragevalet.com` (for live)

Confirm the domain works and shows the login page.

---

## Part 2: Critical Technical Details

### Edge Function URL
```
https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/create-checkout
```

### How to Call It (From Webflow)
```javascript
// Request
const response = await fetch(CHECKOUT_URL, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + ANON_KEY
  },
  body: JSON.stringify({})
});

// Response
const data = await response.json();
// data.url = "https://checkout.stripe.com/..."
// data.error = error message (if request fails)
```

### Key Implementation Details

1. **Method:** POST (not GET)
2. **Body:** Empty object `{}` or null
3. **Authorization Header:** REQUIRED - Include the anon key
4. **CORS:** Already enabled on the Edge Function
5. **Response Time:** ~1-2 seconds
6. **Success Indicator:** HTTP 200 + `data.url` contains `checkout.stripe.com`

### The Anon Key (SAFE TO EXPOSE)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNTkzMDgsImV4cCI6MjA3MzYzNTMwOH0.sR4S7DNrwxhi1C4HFnDzr0YL6IBqxzVwCGYtBDhSAFI
```

**Why it's safe:** The anon key can only call specific Supabase functions and read public data. It cannot delete data or access admin functions.

---

## Part 3: Add Custom Code to Webflow

### Step 1: Access Webflow Settings

In Webflow Designer:
1. Click the **gear icon** (Settings) in the top left
2. Click **Custom Code** (left sidebar)
3. Find the **Footer Code** section (at the bottom of the page)

### Step 2: Paste This JavaScript

Copy the entire code block below and paste it into Webflow's **Footer Code** section:

```html
<script>
(function() {
  // ========== Configuration ==========
  const CHECKOUT_URL = 'https://gmjucacmbrumncfnnhua.supabase.co/functions/v1/create-checkout';
  const ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtanVjYWNtYnJ1bW5jZm5uaHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNTkzMDgsImV4cCI6MjA3MzYzNTMwOH0.sR4S7DNrwxhi1C4HFnDzr0YL6IBqxzVwCGYtBDhSAFI';

  // Wait for DOM to load
  document.addEventListener('DOMContentLoaded', function() {
    // Find all buttons that trigger checkout
    // Update selectors below to match your actual Webflow button classes/IDs
    const signupButtons = document.querySelectorAll(
      'a[href*="signup"], ' +  // Links with "signup" in href
      'a[href*="sign-up"], ' +  // Links with "sign-up" in href
      '.signup-btn, ' +        // Any element with class "signup-btn"
      '[data-checkout="true"]'  // Any element with data-checkout="true" attribute
    );

    console.log('✓ Found ' + signupButtons.length + ' signup button(s)');

    signupButtons.forEach(function(button) {
      button.addEventListener('click', async function(e) {
        // Prevent default link behavior
        e.preventDefault();

        // Get original text to restore later
        const originalText = button.innerText || button.textContent;
        const originalStyle = button.style.opacity;

        try {
          // Show loading state
          button.innerText = 'Loading checkout...';
          button.style.opacity = '0.6';
          button.style.pointerEvents = 'none';

          console.log('→ Calling checkout function...');

          // Call the Edge Function
          const response = await fetch(CHECKOUT_URL, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + ANON_KEY
            },
            body: JSON.stringify({})
          });

          // Parse response
          const data = await response.json();

          if (!response.ok) {
            throw new Error(data.error || 'Failed to create checkout session');
          }

          if (!data.url) {
            throw new Error('No checkout URL returned from server');
          }

          console.log('✓ Checkout URL received:', data.url);

          // Redirect to Stripe Checkout
          window.location.href = data.url;

        } catch (error) {
          console.error('✗ Checkout error:', error.message);

          // Restore button state
          button.innerText = originalText;
          button.style.opacity = originalStyle;
          button.style.pointerEvents = 'auto';

          // Show error to user
          alert('Sorry, we encountered an issue starting checkout. Please try again or contact support. Error: ' + error.message);
        }
      });
    });
  });
})();
</script>
```

### Step 3: Update Button Selectors (IMPORTANT)

The code above tries to find buttons using common selectors. **You must verify these match your actual Webflow buttons:**

1. **Inspect one of your "Sign up" buttons in the Webflow Designer**
2. **Check its class names and/or ID attributes**
3. **Update the `querySelectorAll()` selector to match**

**Examples:**

If your button has class `w-button` and specifically `signup-cta`:
```javascript
const signupButtons = document.querySelectorAll('.signup-cta');
```

If your button has multiple classes, target the specific one:
```javascript
const signupButtons = document.querySelectorAll('a.primary-cta, button.signup-btn');
```

If your button is a Webflow link block without special class:
```javascript
const signupButtons = document.querySelectorAll('a[href="#signup"]'); // assuming the link points to #signup
```

**Easiest approach:** Add a custom class to all your signup buttons:
- Select the button in Webflow Designer
- Go to **Settings** → **Advanced**
- Add a custom class like `checkout-button`
- Then use: `document.querySelectorAll('.checkout-button')`

### Step 4: Save and Publish

1. Click **Save** in the Custom Code section
2. Click **Publish** in Webflow (top right)
3. Go to your live Webflow site
4. Click a "Sign up" button and observe the behavior

---

## Part 4: Testing the Integration

### ✅ Test 1: Open Browser Console (Most Important)

When you click a signup button:

1. **Open DevTools:** Press `F12` or `Cmd+Option+I`
2. **Go to Console tab**
3. **Look for log messages:**
   - `"✓ Found 3 signup button(s)"` → Buttons were found
   - `"→ Calling checkout function..."` → Function was called
   - `"✓ Checkout URL received: https://checkout.stripe.com/..."` → Success!
   - `"✗ Checkout error: ..."` → Something went wrong

**If you see error messages, note them and provide to Claude for debugging.**

### ✅ Test 2: Successful Checkout Flow

If everything works:

1. You'll be redirected to `checkout.stripe.com`
2. You should see a form to enter test payment info
3. **Use this test card:**
   - Number: `4242 4242 4242 4242`
   - Expiry: Any future date (e.g., 12/25)
   - CVC: Any 3 digits (e.g., 123)
   - ZIP: Any 5 digits

4. Click **"Pay"**
5. If successful, you should be redirected to your portal (or see a success message)

### ✅ Test 3: Check Stripe Dashboard

1. Go to Stripe Dashboard → **Developers** → **Events** (Test mode)
2. You should see a new `checkout.session.completed` event
3. Click it and verify the payment details

### ❌ Test 4: Error Scenarios

**If you see "401 Unauthorized":**
- The Edge Function is enforcing JWT verification
- Contact Claude - the function needs `verify_jwt = false` setting

**If you see "Missing signature" error:**
- This is actually GOOD - it means the function is working (it's expecting a Stripe webhook signature, not a browser call)
- Ignore this for testing; it won't appear in normal checkout flow

**If button text never changes:**
- Button selectors don't match your actual buttons
- Check the console for "Found 0 signup button(s)" message
- Adjust selectors in the JavaScript code

**If redirect to checkout doesn't happen:**
- Check response.json() value in console
- Verify CHECKOUT_URL is correct
- Verify the Edge Function URL is actually deployed and responding

---

## Part 5: Testing Checklist Before Going Live

- [ ] Button selector correctly identifies all signup buttons (`console.log` shows correct count)
- [ ] Clicking button shows "Loading checkout..." state
- [ ] Redirect to `checkout.stripe.com` works
- [ ] Test payment (4242 4242 4242 4242) completes
- [ ] Stripe Dashboard shows `checkout.session.completed` event
- [ ] No console errors (or only benign ones)
- [ ] Mobile browser also works (test on phone if possible)
- [ ] Different buttons all work the same way

---

## Part 6: What Happens After Checkout (Backend Flow)

**Note:** You don't need to do anything for this - it happens automatically once the Edge Function is deployed.

1. **Stripe webhook** fires → Supabase receives `checkout.session.completed`
2. **Edge Function** (`stripe-webhook`) processes webhook:
   - Creates a Supabase Auth user with the customer's email
   - Marks the user as confirmed (skips email verification)
   - Sends a **magic link** to their email
3. **Customer receives email** with magic link
4. **Customer clicks link** → Logs into portal
5. **Portal shows** their empty dashboard (no items yet)

If a customer doesn't receive the magic link:
- Check spam folder
- Confirm email address was entered correctly in checkout form
- Check Supabase logs for errors

---

## Part 7: Environment Variables Reference

These are already configured in Supabase (you don't need to change them):

| Variable | Where Set | Value |
|----------|-----------|-------|
| `STRIPE_SECRET_KEY` | Supabase Edge Secrets | `sk_test_...` (test mode) |
| `STRIPE_PRICE_PREMIUM299` | Supabase Edge Secrets | `price_test_...` (test price) |
| `STRIPE_WEBHOOK_SECRET` | Supabase Edge Secrets | `whsec_...` |
| `APP_URL` | Supabase Edge Secrets | Portal redirect URL |
| `SUPABASE_URL` | Supabase Edge Secrets | `https://gmjucacmbrumncfnnhua.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Edge Secrets | Admin key for Auth operations |

---

## Part 8: Troubleshooting Guide

### Issue: "Found 0 signup button(s)" in console

**Problem:** Button selectors don't match your buttons
**Fix:**
1. Right-click signup button → Inspect
2. Look at the HTML element
3. Find its class or ID
4. Update the `querySelectorAll` selector
5. Example: if element is `<a class="w-button w-button--large">`, use `.w-button--large`

### Issue: Button doesn't respond to clicks

**Problem:** Event listener didn't attach
**Fix:**
1. Verify button selector is correct (see above)
2. Check browser console for JavaScript errors
3. Make sure custom code is saved and page is published

### Issue: "No checkout URL returned" error

**Problem:** Edge Function isn't returning the checkout URL
**Fix:**
1. Verify Edge Function is deployed: Test the curl command from Part 1
2. Check Supabase logs for errors
3. Verify Stripe API keys are configured in Edge secrets
4. Verify Stripe price ID exists and is in test mode

### Issue: Redirects to checkout but payment fails

**Problem:** Stripe configuration issue
**Fix:**
1. Confirm you're in Stripe **Test Mode** (not Live Mode)
2. Verify the price ID matches between Stripe Dashboard and Edge secrets
3. Check Stripe webhook is configured correctly
4. Look at Stripe logs for payment processing errors

### Issue: Magic link never arrives

**Problem:** Webhook isn't firing or is failing silently
**Fix:**
1. Go to Stripe Dashboard → Developers → Webhooks
2. Find your endpoint
3. Check "Event deliveries" tab
4. Look for the checkout event
5. If it shows "failed", click it to see the error
6. Common causes: Webhook URL is wrong, signing secret is wrong

---

## Part 9: Security Notes (Why This is Safe)

**Why can Webflow expose the anon key?**
- The anon key can only call the `create-checkout` function
- It cannot delete, modify, or read sensitive customer data
- Stripe API calls happen server-side (in the Edge Function)
- Stripe secret key is NEVER exposed to Webflow

**Why is the API call public (no authentication)?**
- Anyone can call the function, but they still need a valid Stripe price ID
- The Edge Function checks the price ID is correct before creating the session
- Failed checkouts cost nothing (Stripe doesn't charge for incomplete sessions)

**If someone tries to exploit this:**
- They can create checkout sessions, but must pay to complete them
- They can't access customer data or modify items
- All database operations are restricted by Row-Level Security (RLS)

---

## Part 10: Next Steps After Testing

### If Everything Works ✅

1. Change `STRIPE_SECRET_KEY` to LIVE mode key in Supabase Edge secrets
2. Change `STRIPE_PRICE_PREMIUM299` to LIVE mode price ID
3. Change `STRIPE_WEBHOOK_SECRET` to LIVE mode webhook secret
4. Update `APP_URL` to production portal URL
5. Deploy to production

### If Something Doesn't Work ❌

1. Note all error messages from browser console
2. Copy the curl test command from Part 1 and run it locally (show output)
3. Contact Claude with:
   - Screenshots of error messages
   - Console logs
   - Curl response output
   - Which step failed (button selector, function call, redirect, etc.)

---

## Summary: What Perplexity Should Do

1. ✅ Verify Edge Function is deployed and responding
2. ✅ Add custom code to Webflow Footer Code section
3. ✅ Update button selectors to match your actual buttons
4. ✅ Save and publish the Webflow site
5. ✅ Test the flow in browser (check console for errors)
6. ✅ Complete a test payment
7. ✅ Verify webhook fires in Stripe Dashboard
8. ✅ Report success or error messages to Claude

---

## Contact

If you hit any blockers:
- Note the exact error message
- Screenshot the browser console
- Provide the curl test response
- Contact Claude with this information

**Target:** Have Webflow signup flow working by Oct 25, 2025.

