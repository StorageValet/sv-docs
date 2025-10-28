# Storage Valet AI Team: MCP & Documentation Setup Guide

**Last Updated**: 2025-10-28
**Created By**: Claude Code
**Audience**: All AI assistants working on Storage Valet (Claude, Claude Desktop, Claude Code)

---

## Overview

Storage Valet now has a comprehensive documentation system powered by **Model Context Protocol (MCP)** servers. This ensures all AI team members have access to the latest official documentation for our core platforms.

## What is MCP?

**MCP (Model Context Protocol)** is like giving AI assistants direct access to live documentation databases. Instead of relying on training data or manual doc uploads, MCPs fetch real-time official docs when you ask questions.

**Benefit**: When you ask about Stripe payments, Claude automatically fetches the latest Stripe API docs—no manual copy-pasting needed.

---

## Currently Configured Platforms

### ✅ **Supabase** - Active MCP Server
- **Status**: Real-time docs available
- **How to Use**: Ask any question about Supabase; Claude fetches current docs automatically
- **Example**: "How do I set up row-level security in Supabase?"
- **MCP Endpoint**: mcp.supabase.com/mcp

### ⏳ **Stripe** - Awaiting Configuration
- **Status**: Pending Stripe API key
- **Next Steps**: User will provide secret key → Claude configures MCP
- **What You'll Get**: Real-time Stripe API and billing docs
- **Example Once Active**: "What's the current Stripe webhook event format?"

### ⏳ **Vercel** - Awaiting Configuration
- **Status**: Pending OAuth setup
- **Next Steps**: User authenticates with Vercel → OAuth configured
- **What You'll Get**: Real-time Vercel deployment and Edge Function docs
- **Example Once Active**: "How do I set environment variables in Vercel?"

### ⚙️ **React** - Direct Access (No Sync Needed)
- **Status**: Always current at https://react.dev
- **How to Use**: Ask any React question; Claude accesses latest docs
- **Example**: "Show me an example of using useReducer with localStorage"
- **Update Frequency**: No automation - always fetch directly from official source


---

## How Your AI Team Uses This

### For Claude Desktop Users

1. **Automatic**: MCPs are configured in `~/.claude/claude_desktop_config.json`
2. **No action needed**: Just ask questions normally
3. **Real-time docs**: Claude automatically queries MCP servers

### For Claude Code CLI Users (Terminal)

1. **Automatic**: MCPs are in `~/.claude/settings.local.json`
2. **Usage**: Type questions, Claude fetches docs via MCP
3. **Example**:
   ```
   you: "What are the best practices for Supabase RLS policies?"
   Claude: [Fetches latest Supabase docs and provides answer]
   ```

### For Any AI Using These Docs

1. **Primary Method**: Ask Claude questions → MCP fetches current docs
2. **Fallback Method**: Check `/platform-docs/` directory in sv-docs repo
3. **Best Practice**: Always reference MCP servers first (most current)

---

## MCP Server Reference

### Quick Access Commands

```bash
# List all active MCP servers
claude mcp list

# Check if Stripe MCP is connected (once configured)
claude mcp list | grep stripe

# Verify Supabase MCP (should show connected)
claude mcp list | grep supabase
```

### MCP Configuration Files

- **Claude Code**: `~/.claude/settings.local.json`
- **Claude Desktop**: `~/.claude/claude_desktop_config.json`

Both files contain an `mcpServers` object with server definitions.

---

## When MCP Servers Become Available

### Supabase ✅ Now Available
- **Activation**: Already configured
- **What It Provides**: Search all Supabase docs, access API references, check code examples
- **Useful Queries**: "Show me the Supabase realtime API", "How do I handle auth tokens?"

### Stripe (Coming Soon) ⏳
- **Activation**: When user provides API key
- **What It Will Provide**: Payment API docs, webhook event formats, billing best practices
- **Useful Queries**: "What webhook events should I handle?", "How do I process refunds?"

### Vercel (Coming Soon) ⏳
- **Activation**: When user authenticates with OAuth
- **What It Will Provide**: Deployment guide, Edge Functions docs, environment config
- **Useful Queries**: "How do I deploy to Vercel?", "Can I run Python in Edge Functions?"

### React ✅ Always Available
- **Activation**: No setup needed - access directly at https://react.dev
- **What It Provides**: Latest React documentation, API references, patterns
- **Useful Queries**: "Show me how to use useContext", "What's the difference between useMemo and useCallback?"

---

## Documentation Repository Structure

```
~/code/sv-docs/
├── platform-docs/                    # New: Platform documentation
│   ├── README.md                     # Guide to this system
│   ├── supabase/README.md           # Supabase docs index (MCP active)
│   ├── stripe/README.md             # Stripe docs index (MCP pending)
│   ├── vercel/README.md             # Vercel docs index (MCP pending)
│   └── react/README.md              # React docs index (direct access)
├── runbooks/                         # Existing: Operational guides
├── scripts/                          # Existing: Utility scripts
└── [other Storage Valet docs]
```

### How to Access These Docs

**Method 1 (Recommended): Ask Claude**
```
you: "Where do I find the Supabase authentication docs?"
Claude: [Provides links and explanations from MCP]
```

**Method 2: Browse Locally**
```bash
# View what's in each platform directory
cat ~/code/sv-docs/platform-docs/supabase/README.md
cat ~/code/sv-docs/platform-docs/stripe/README.md
```

**Method 3: Use as Fallback**
If MCPs are unavailable (rare), read from local copies in `platform-docs/`.

---

## Key Integration Points with Storage Valet

### Supabase ← → Storage Valet
- User authentication and session management
- Document metadata storage in PostgreSQL
- File storage and access control
- Real-time subscriptions for collaborative features
- Row-level security for multi-tenancy

### Stripe ← → Storage Valet
- Payment processing for storage subscriptions
- Recurring billing and invoicing
- Customer subscription management
- Webhook handling for payment events
- Revenue reporting

### Vercel ← → Storage Valet
- Frontend deployment (React app)
- Edge Functions for server-side logic
- Environment variable management
- Custom domain setup
- Analytics and performance monitoring

### React ← → Storage Valet
- UI components and pages
- State management and hooks
- Form handling and validation
- File upload interfaces
- Real-time UI updates

---

## Common Questions & Troubleshooting

### Q: What if an MCP server is down?
**A**: Claude will let you know and suggest alternatives. The local docs in `platform-docs/` serve as a fallback.

### Q: Can I access MCP docs offline?
**A**: Yes, local copies in `platform-docs/` are always available. They're less current but sufficient for most questions.

### Q: How often are React docs updated?
**A**: React docs are always current at https://react.dev - no sync needed. Access directly for latest information.

### Q: How do I request documentation for a new platform?
**A**: Create an issue in sv-docs repo describing:
1. Platform name
2. Why it's needed for Storage Valet
3. If it has an official MCP server

### Q: What if I have a question the MCP docs don't answer?
**A**: Claude can combine MCP docs with:
- General knowledge about the topic
- Context about your Storage Valet codebase
- Best practices and patterns
- Workarounds and alternatives

---

## For System Administrators

### Monitoring MCP Health

```bash
# Check all MCP servers
claude mcp list

# Expected output:
# supabase: https://mcp.supabase.com/mcp (HTTP) - ✓ Connected
# stripe: [url] - ✓ Connected (once configured)
# vercel: https://mcp.vercel.com (HTTP) - ✓ Connected (once configured)
```

### Adding New MCP Servers

To add a new platform's MCP server:

1. **Find the MCP server**: Search `[Platform] MCP server official`
2. **Document it**: Add README in `platform-docs/[platform]/`
3. **Configure it**: Use `claude mcp add [name] --scope user`
4. **Verify**: Run `claude mcp list` and confirm connection
5. **Commit**: Add to sv-docs repository

### Updating Configuration

All team members get updated configuration via git pull:

```bash
cd ~/code/sv-docs
git pull
# MCP settings automatically apply to Claude Code
```

---

## Best Practices for Your AI Team

1. **Always Ask First**: Use `you: "Question about [platform]?"` format
   - Claude will fetch latest docs automatically
   - More reliable than searching manually

2. **Reference Documentation**: When Claude provides solutions, it will cite official docs
   - Trust these citations for accuracy
   - Use them for team training

3. **Share Knowledge**: If you find a useful doc section, share it with the team
   - Add it to relevant `platform-docs/[platform]/README.md`
   - Commit to sv-docs for persistence

4. **Keep It Current**: Monthly spot-check that MCP servers are working
   - Run `claude mcp list` to verify connections
   - Report any disconnections immediately

5. **Fallback to Locals**: If MCP is slow, reference local docs
   - They're updated automatically
   - Sufficient for most common questions

---

## What's Next

### Immediate (Next 1-2 Days)
- [ ] User provides Stripe API key
- [ ] Configure Stripe MCP
- [ ] Verify with `claude mcp list`

### Short Term (Next Week)
- [ ] User authenticates Vercel OAuth
- [ ] Configure Vercel MCP
- [ ] Test Vercel documentation access

### Medium Term (Next Month)
- [ ] Evaluate React MCP servers (if needed)
- [ ] Consider macOS Tahoe MCP for native features
- [ ] Monitor MCP server health

### Long Term
- [ ] Add more platforms as Storage Valet grows
- [ ] Build integration guides between platforms
- [ ] Create runbooks using MCP-powered documentation

---

## Quick Reference: Asking Questions

### Format
```
you: "[Platform question in natural language]"
```

### Examples

**Supabase (MCP Active)**
```
you: "How do I implement row-level security for a multi-tenant app in Supabase?"
Claude: [Fetches latest Supabase docs and provides detailed answer]
```

**Stripe (MCP Coming)**
```
you: "What are the required webhook events for payment processing?"
Claude: [Once configured, fetches Stripe webhook documentation]
```

**Vercel (MCP Coming)**
```
you: "How do I set up a custom domain in Vercel?"
Claude: [Once configured, fetches Vercel deployment docs]
```

**React (MCP Active)**
```
you: "Show me how to implement a custom hook for API calls"
Claude: [Fetches React documentation and provides example code]
```

---

## Support & Questions

If anything is unclear:
1. Check this document first
2. Ask Claude about the specific platform
3. Review the platform-specific README in `platform-docs/[platform]/`
4. Create an issue in sv-docs repo

---

## Version History

- **2025-10-28**: Initial setup guide created
  - Supabase MCP: ✅ Active
  - Stripe MCP: ⏳ Awaiting API key
  - Vercel MCP: ⏳ Awaiting OAuth
  - React: ✅ Direct access (no sync needed)
  - Tahoe: 📋 On-demand

---

**Made with ❤️ for the Storage Valet AI Team**
