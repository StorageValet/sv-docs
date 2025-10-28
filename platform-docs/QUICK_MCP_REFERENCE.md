# Quick MCP Reference Card

**Print this or keep in your terminal notes**

## Check MCP Status
```bash
claude mcp list
```

**Expected output:**
```
supabase: https://mcp.supabase.com/mcp (HTTP) - ✓ Connected
stripe: [pending]
vercel: [pending]
```

---

## Ask Questions (All Platforms)

```bash
you: "Your question about Supabase/Stripe/React/Vercel/Tahoe"
Claude: [Automatically fetches latest docs and answers]
```

### Popular Questions by Platform

**Supabase**
- "How do I set up realtime subscriptions?"
- "Show me RLS policy examples"
- "What's the best way to handle authentication?"

**Stripe**
- "What webhook events do I need?"
- "How do I implement subscription billing?"
- "Show me payment retry logic"

**Vercel**
- "How do I deploy my app?"
- "Can I use Edge Functions?"
- "How do I set environment variables?"

**React**
- "Show me a custom hook example"
- "How do I handle forms?"
- "What's useMemo vs useCallback?"

---

## Repository Location

```bash
cd ~/code/sv-docs
cat platform-docs/README.md              # Overview
cat MCP_AND_DOCUMENTATION_SETUP_GUIDE.md # Full guide
ls platform-docs/                        # See all platforms
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| MCP not responding | Run `claude mcp list` to check connection |
| Doc seems outdated | MCP always fetches latest; trust the source |
| Need offline docs | Check `~/code/sv-docs/platform-docs/[platform]/` |
| New platform needed | Open issue in sv-docs repository |

---

## Status as of 2025-10-28

| Platform | Status | What to Expect |
|----------|--------|----------------|
| **Supabase** | ✅ Active | Real-time docs |
| **Stripe** | ⏳ Soon | Real-time docs (awaiting API key) |
| **Vercel** | ⏳ Soon | Real-time docs (awaiting OAuth) |
| **React** | ✅ Active | Direct access at https://react.dev |

---

**Next Steps**: Provide Stripe API key → Stripe MCP becomes active → All systems green ✅
