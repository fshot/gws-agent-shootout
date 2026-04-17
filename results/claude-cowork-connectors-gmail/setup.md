# Setup: A / gmail

**Date**: 2026-04-16
**Config**: A — Claude Desktop (Cowork) + google_workspace_mcp
**Account**: fshotwell@gmail.com
**Starting from**: reusing google_workspace_mcp install and OAuth credentials from config C

## Prerequisites

- **OS**: macOS 15.x (Darwin 25.3.0)
- **Runtime versions**: Python 3.11.9 (Homebrew)
- **GCP project**: Existing project `hdca-workspace-tools` reused from config B
- **Billing**: Not required

## Agent setup

**Agent**: Claude Desktop (Cowork mode)
**Version**: Claude Desktop with Opus 4.6 (tested for consistency with other configs run 2026-04-15/16; Opus 4.7 was available but not used)
**Non-default config**: workspace-mcp MCP server added to `claude_desktop_config.json`

## Connector installation

### google_workspace_mcp via Claude Desktop MCP config

Reuses the existing google_workspace_mcp installation from config C (see `results/claude-code-mcp-gmail/setup.md` for full install steps).

The MCP server was added to Claude Desktop's config file:

**File**: `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "workspace-mcp": {
      "command": "/Users/fshot/code/google_workspace_mcp/.venv/bin/python",
      "args": [
        "/Users/fshot/code/google_workspace_mcp/main.py",
        "--transport", "stdio",
        "--tools", "gmail", "drive", "calendar", "docs", "sheets",
        "--single-user"
      ]
    }
  }
}
```

No `cwd` field — Claude Desktop (like Claude Code) requires absolute paths for the command and all args.

### Config files created/modified

| File | Location | What changed |
|------|----------|-------------|
| Claude Desktop config | `~/Library/Application Support/Claude/claude_desktop_config.json` | Added `mcpServers.workspace-mcp` entry |

## GCP project configuration

Reuses config B/C's GCP project, OAuth client, and API enablement. See `results/claude-code-gws-cli-gmail/setup.md`.

## First-run auth flow

OAuth tokens from config C's test run should still be valid (same MCP server installation, same credential store). If tokens have expired (GCP "Testing" mode = 7-day refresh token lifetime), the MCP server will prompt for re-authorization via `localhost:8000` on first tool call.

## Account-type differences

This is the gmail run. Workspace differences will be noted in the workspace run.

## Gotchas

To be recorded during test execution.
