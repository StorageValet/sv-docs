# Platform Documentation Repository

This directory contains organized official documentation for all platforms used in Storage Valet development and deployment. Most docs are fetched real-time via MCP servers.

## Structure

Each platform has its own subdirectory:

- **supabase/** - Supabase database, auth, and realtime docs (MCP enabled)
- **stripe/** - Stripe payments, billing, and API docs (MCP enabled)
- **vercel/** - Vercel deployment, Edge Functions, and infrastructure docs (MCP enabled)
- **react/** - React library, hooks, and best practices docs

## How These Docs Are Kept Current

### MCP-Enabled Platforms (Real-time via AI)
- **Supabase**: Configured as MCP server - always fetches latest docs on-demand
- **Stripe**: Configured as MCP server - always fetches latest docs on-demand
- **Vercel**: Configured as MCP server - always fetches latest docs on-demand

### Always-Available Platforms (Direct Access)
- **React**: Access directly at https://react.dev (no sync needed)

## Using These Docs with Claude Code

### Option 1: Via MCP Servers (Recommended - Real-time)
Simply ask Claude Code questions about any platform. It will automatically fetch the latest official documentation from the MCP servers.

Example:
```
Me: "How do I set up realtime subscriptions in Supabase?"
Claude: [Fetches latest Supabase docs via MCP and provides answer]
```

### Option 2: Via Local Repo (Fallback)
If MCP servers are unavailable, you can reference the local copies in this directory. These are less current but always available.

### Option 3: Mixed Approach (Best for Offline Work)
- Use MCP servers when available (online)
- Fall back to local copies when needed (offline)

## AI Team Access

All team members using Claude Code should have access to:
1. MCP servers (automatic once configured)
2. This repository via Git clone
3. Read access to local documentation files

## Configuration

MCP servers are configured in `~/.claude/settings.local.json` or `~/.claude/claude_desktop_config.json` (for Claude Desktop).

Current MCP servers active:
- ✅ Supabase (mcp.supabase.com) - Real-time docs
- ⚠️ Stripe (via @stripe/mcp) - Configured, minor CLI compatibility issue
- ✅ Vercel (mcp.vercel.com) - OAuth on first use
- 📋 React - Direct access at https://react.dev (no automation needed)

## Maintenance

- **Real-time**: MCP servers fetch latest docs on every query
- **No automated syncing**: No GitHub Actions or cron jobs - zero risk to production
- **Manual updates**: Review platform docs for major version changes as needed

Last updated: 2025-10-28 (Tahoe docs removed - not business-related)
