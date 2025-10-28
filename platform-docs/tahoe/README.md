# macOS Tahoe Documentation

**Status**: ⏳ On-Demand - MCP Server Available (apple-docs-mcp)

## Quick Access

- **Apple Dev Docs**: https://developer.apple.com/documentation
- **macOS Release Notes**: https://developer.apple.com/documentation/macos-release-notes
- **System Preferences**: System Settings
- **WWDC Videos**: https://developer.apple.com/videos

## Key Topics for Storage Valet Mac Integration

- System Preferences and Settings API
- File system and sandboxing
- Notifications and user alerts
- App extensions
- URL schemes and deep linking
- macOS App development best practices
- Menu bar applications
- Document-based apps
- Accessibility features
- macOS-specific UI patterns
- Performance optimization for macOS

## How to Use

### Option 1: Ask Claude Code (Recommended)
```
Me: "How do I disable iPhone app mirroring on macOS Tahoe?"
Claude: [Fetches latest Tahoe docs via MCP and provides answer]
```

### Option 2: MCP Server Setup (Optional)
To access comprehensive Apple documentation via MCP, use `apple-docs-mcp`:
```bash
# Optional: Set up apple-docs-mcp for deeper integration
npm install -g @anthropic-ai/apple-docs-mcp
```

### Option 3: Direct Apple Developer Site
- Apple's official documentation: https://developer.apple.com/documentation
- Always has the most current information

## Storage Valet on macOS

If building native macOS features for Storage Valet:

1. **File Handling**: Working with documents and files
2. **Notifications**: Alert users of important events
3. **App Extensions**: Integration with Finder, etc.
4. **Accessibility**: Making the app accessible to all users
5. **Performance**: Optimizing for different Mac models
6. **Security**: Code signing, entitlements, sandboxing
7. **Distribution**: App signing and distribution

## Current System Info

- **macOS Version**: Tahoe 26.0.1 (M4 Max)
- **Release Date**: October 2025
- **Architecture**: ARM64 (Apple Silicon)
- **Supported Features**: All latest macOS Tahoe features

## macOS Tahoe Highlights

- New Apps window (replaces Launchpad)
- Improved Spotlight integration
- Enhanced performance on Apple Silicon
- New accessibility features
- Improved system settings organization
- Better Continuity features
- Genmoji and Image Playground
- Screen capture enhancements

## Documentation Categories

### System APIs
- File system frameworks
- Notification frameworks
- Window management
- Menu systems
- Preferences and Settings

### User Interface
- AppKit (native macOS UI)
- SwiftUI (modern UI framework)
- Interface Builder
- macOS design patterns

### App Deployment
- Code signing
- Notarization
- Distribution
- Updates and auto-updates
- App Sandbox

### Performance
- Activity Monitor analysis
- Profiling tools
- Memory management
- CPU optimization

## Useful Links

- [Apple Developer Documentation](https://developer.apple.com/documentation)
- [macOS 26 Release Notes](https://developer.apple.com/documentation/macos-release-notes)
- [App Sandbox Documentation](https://developer.apple.com/documentation/security/app_sandbox)
- [Notification Framework](https://developer.apple.com/documentation/usernotifications)
- [System Settings Changes](https://developer.apple.com/documentation/PreferencePanes)

## Important Settings Found

- **iPhone Apps Display**: System Settings → Spotlight → Results from System → iPhone Apps
- **iCloud Continuity**: System Settings → General → AirDrop & Handoff
- **Screen Mirroring**: System Settings → General → AirDrop & Handoff

## MCP Configuration

To enable full apple-docs-mcp integration:
1. Install apple-docs-mcp MCP server
2. Add to Claude Code configuration
3. Query Apple docs directly from Claude

Status: Ready for setup when needed

---

Last updated: 2025-10-28
macOS Version: Tahoe 26.0.1
