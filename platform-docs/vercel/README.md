# Vercel Documentation

**Status**: ✅ MCP Configured - OAuth on First Use

## Quick Access

- **Official Docs**: https://vercel.com/docs
- **MCP Server**: https://mcp.vercel.com
- **Dashboard**: https://vercel.com/dashboard
- **Status Page**: https://status.vercel.com

## Key Topics for Storage Valet

- Deployment and Git integration
- Edge Functions and serverless computing
- Environment variables and secrets
- Preview deployments
- Custom domains and SSL
- Monitoring and analytics
- Performance optimization
- Image optimization
- API routes
- Database connections
- Log streaming

## How to Use Once Configured

### Option 1: Ask Claude Code (Recommended)
```
Me: "How do I set up environment variables for my Supabase connection in Vercel?"
Claude: [Fetches latest Vercel docs via MCP and provides detailed answer]
```

### Option 2: Direct MCP Integration
Once configured with OAuth, Claude Code will have access to:
- Search Vercel documentation
- Query your project configuration
- Check deployment logs
- Review environment settings
- Monitor project analytics

### Option 3: Local Docs (if MCP is unavailable)
Automatically synced copies stored in this directory for reference.

## Storage Valet Integration Points

1. **Frontend Deployment**: Deploy Next.js/React frontend
2. **API Routes**: Server-side endpoints for backend logic
3. **Edge Functions**: Low-latency serverless functions
4. **Environment Config**: Secure storage of API keys and secrets
5. **Preview Deployments**: Test changes before production
6. **Custom Domain**: Domain setup and DNS configuration
7. **Analytics**: Performance monitoring and insights
8. **Database Integration**: Connecting to Supabase database
9. **Authentication**: Integrating with Supabase Auth

## Configuration Status

- CLI Tool: ✅ Installed (`vercel --version`)
- MCP Server: ✅ Configured (https://mcp.vercel.com)
- OAuth Connection: ⏳ Will prompt on first use
- Project Access: Ready - OAuth happens automatically

## Your Vercel Projects

### sv-portal (Production)
- **URL**: https://portal.mystoragevalet.com
- **Status**: ✅ Deployed and active
- **Last Updated**: 4 days ago
- **Node Version**: 22.x

### zacharybrown (Staging/Personal)
- **Status**: 📋 Created, not in production
- **Last Updated**: 6 days ago
- **Node Version**: 22.x

## Useful Links

- [Vercel Docs](https://vercel.com/docs)
- [Deployment Guide](https://vercel.com/docs/deployments/overview)
- [Edge Functions Guide](https://vercel.com/docs/functions/edge-functions)
- [Environment Variables](https://vercel.com/docs/projects/environment-variables)
- [Database Guide](https://vercel.com/docs/storage)
- [CLI Reference](https://vercel.com/docs/cli)

## How to Authenticate

OAuth authentication happens **automatically** on first use:

1. Ask Claude Code a Vercel question, like:
   - "What's the status of my sv-portal project?"
   - "Show me recent deployments"
2. Claude will prompt with an OAuth link
3. Authenticate with your Vercel account
4. Grant Claude Code access
5. Done! MCP is now fully authenticated

Verify with: `claude mcp list`

---

Last updated: 2025-10-28
Status: ✅ Ready - MCP Configured & Projects Listed
