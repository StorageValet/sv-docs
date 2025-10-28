# Supabase Documentation

**Status**: ✅ MCP Server Active - Real-time docs available

## Quick Access

- **MCP Server**: mcp.supabase.com/mcp
- **Official Docs**: https://supabase.com/docs
- **GitHub**: https://github.com/supabase/supabase
- **Status Page**: https://status.supabase.com

## Key Topics for Storage Valet

- PostgreSQL Database Setup
- Authentication (JWT, OAuth, Magic Links)
- Realtime Subscriptions
- Storage (File uploads and management)
- Edge Functions (Server-side logic)
- Database Migrations
- Row Level Security (RLS)
- Vector embeddings and pgvector
- Multi-tenancy patterns

## How to Use

### Option 1: Ask Claude Code (Recommended)
```
Me: "How do I set up row level security in Supabase for multi-tenant apps?"
Claude: [Fetches latest Supabase docs via MCP and provides detailed answer]
```

### Option 2: Direct MCP Query
Claude Code has direct access to `mcp__supabase__*` tools including:
- `mcp__supabase__search_docs` - Search all Supabase documentation
- `mcp__supabase__list_tables` - List tables in your project
- `mcp__supabase__list_migrations` - Check migration history
- `mcp__supabase__execute_sql` - Run SQL queries
- And many more...

### Option 3: Local Docs (if MCP is unavailable)
Automatically synced copies are stored in this directory for offline reference.

## Storage Valet Integration Points

1. **User Authentication**: Supabase Auth for user login/signup
2. **Document Storage**: Supabase Storage for file uploads
3. **Metadata Tracking**: PostgreSQL tables for document metadata
4. **Real-time Updates**: WebSocket subscriptions for live updates
5. **Access Control**: RLS policies for document permissions

## Current Project Configuration

- Project URL: Check `~/.supabase/config.json`
- Default schema: `public`
- Extensions enabled: uuid, vector (pgvector)

## Useful Links

- [Supabase Docs](https://supabase.com/docs)
- [JavaScript Client](https://supabase.com/docs/reference/javascript)
- [SQL API Reference](https://supabase.com/docs/reference/sql)
- [Auth Providers](https://supabase.com/docs/guides/auth)

---

Last updated: 2025-10-28
