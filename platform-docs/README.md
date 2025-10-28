# Platform Documentation Repository

This directory contains organized, automatically-updated official documentation for all platforms used in Storage Valet development and deployment.

## Structure

Each platform has its own subdirectory:

- **supabase/** - Supabase database, auth, and realtime docs (MCP enabled)
- **stripe/** - Stripe payments, billing, and API docs (MCP enabled)
- **vercel/** - Vercel deployment, Edge Functions, and infrastructure docs (MCP enabled)
- **react/** - React library, hooks, and best practices docs
- **tahoe/** - macOS Tahoe system documentation and API references (MCP enabled)

## How These Docs Are Kept Current

### MCP-Enabled Platforms (Real-time via AI)
- **Supabase**: Configured as MCP server - always fetches latest docs on-demand
- **Stripe**: Configured as MCP server - always fetches latest docs on-demand
- **Vercel**: Configured as MCP server - always fetches latest docs on-demand
- **Tahoe**: MCP server configured when needed - fetches latest Apple docs

### Manual Sync Platforms (Periodic Updates)
- **React**: Updated via GitHub Actions workflow (weekly)

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
- ✅ React - Weekly GitHub Actions sync
- 📋 Tahoe (on-demand, apple-docs-mcp) - Available when needed

## Maintenance

- **Weekly**: GitHub Actions syncs React docs
- **On-demand**: MCP servers always provide latest info
- **Monthly**: Manual review of all platform docs for major changes

Last updated: 2025-10-28
