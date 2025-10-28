# Stripe Documentation

**Status**: ⏳ Pending - Awaiting API Key Configuration

## Quick Access

- **Official Docs**: https://docs.stripe.com
- **API Reference**: https://stripe.com/docs/api
- **Dashboard**: https://dashboard.stripe.com
- **Status Page**: https://status.stripe.com

## Key Topics for Storage Valet

- Payment Processing (Cards, Apple Pay, Google Pay)
- Billing and Subscriptions
- Invoicing and Payment Collection
- Customer Management
- Webhook Events
- API Keys and Security
- Testing Mode vs Live Mode
- Price tiers and plans
- Tax Calculation
- Revenue Recognition

## How to Use Once Configured

### Option 1: Ask Claude Code (Recommended)
```
Me: "How do I handle failed payment retries in Stripe?"
Claude: [Fetches latest Stripe docs via MCP and provides detailed answer]
```

### Option 2: Direct MCP Tools
Once configured, Claude Code will have access to Stripe-specific MCP tools:
- Search Stripe documentation
- Query API endpoints
- Review payment flows
- Validate Stripe configurations

### Option 3: Local Docs (if MCP is unavailable)
Automatically synced copies stored in this directory for reference.

## Storage Valet Integration Points

1. **Payment Processing**: Accept payments for storage subscriptions
2. **Subscription Management**: Recurring billing for different storage tiers
3. **Invoice Generation**: Automated invoicing for customers
4. **Webhook Handling**: Process payment events (succeeded, failed, refunded)
5. **Customer Portal**: Allow customers to manage subscriptions
6. **Tax Compliance**: Calculate and collect appropriate taxes
7. **Revenue Reporting**: Track MRR and financial metrics

## Configuration Status

- CLI Tool: ✅ Installed (`stripe --version`)
- API Key: ⏳ Pending setup
- MCP Server: ⏳ Pending API key
- Test Mode: Ready when configured

## Useful Links

- [Stripe API Docs](https://stripe.com/docs/api)
- [Payment Intents Guide](https://stripe.com/docs/payments/payment-intents)
- [Subscriptions Guide](https://stripe.com/docs/billing/subscriptions/overview)
- [Webhooks Guide](https://stripe.com/docs/webhooks)
- [Testing Guide](https://stripe.com/docs/testing)

## Setup Instructions

1. Generate restricted API key from Stripe Dashboard
2. Store key securely in your environment
3. Provide key to AI for MCP configuration
4. Verify connection with `claude mcp list`

---

Last updated: 2025-10-28
Status: Awaiting API Key
