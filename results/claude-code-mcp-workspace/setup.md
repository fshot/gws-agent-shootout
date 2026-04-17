# Setup: C / @workspace

**Date**: 2026-04-15
**Config**: C — Claude Code + google_workspace_mcp
**Account**: fshotwell@cruxcapacity.com
**Starting from**: reusing connector install and GCP project from config C / @gmail.com

## Prerequisites

Same as config C / @gmail.com. See [`results/claude-code-mcp-gmail/setup.md`](../claude-code-mcp-gmail/setup.md).

- **OS**: macOS 26.3.1
- **Runtime versions**: Python 3.11.9 (Homebrew), Node v22.x
- **GCP project**: Existing project `hdca-workspace-tools` reused from config B
- **Billing**: Not required

## Agent setup

**Agent**: Claude Code
**Version**: 2.1.109
**Non-default config**: workspace-mcp MCP server (same as gmail run)

## Connector installation

Reuses the google_workspace_mcp installation from the config C / @gmail.com run. No additional install steps.

See [`results/claude-code-mcp-gmail/setup.md`](../claude-code-mcp-gmail/setup.md) for full installation details.

## GCP project configuration

Reuses config B's GCP project (`hdca-workspace-tools`). All APIs already enabled.

### OAuth consent screen

- **Test users**: fshotwell@gmail.com, fshotwell@cruxcapacity.com (both added during config B setup)
- **Publishing status**: Testing (refresh tokens expire every 7 days)

## First-run auth flow

The workspace-mcp server uses `--single-user` mode, which manages credentials for one Google account at a time. Switching from @gmail.com to @workspace requires re-authentication.

Expected: on first tool call targeting the workspace account, the server will prompt for a new OAuth consent flow via localhost:8000 callback URL.

## Account-type differences

This is the @workspace (Google Workspace paid account) run. Differences from @gmail.com:
- Google Workspace accounts may have admin-imposed restrictions on third-party app access
- Domain-wide delegation is NOT used — we authenticate as the individual user
- The GCP project's OAuth consent screen has the workspace account added as a test user

## Gotchas

See config C / @gmail.com setup doc for the full list of gotchas (MCP config file location, cwd ignored, session restart requirements, incremental scope auth). All apply equally to the workspace run.

Additional workspace-specific notes:
- The `--single-user` flag means re-auth is required when switching from the gmail run. This is expected, not a bug.
