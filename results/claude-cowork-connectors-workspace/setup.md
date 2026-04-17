# Setup: A / workspace

**Date**: 2026-04-16
**Config**: A — Claude Desktop (Cowork) + google_workspace_mcp
**Account**: fshotwell@cruxcapacity.com
**Starting from**: reusing Claude Desktop MCP config from A / gmail

## Prerequisites

See [A / gmail setup](../claude-cowork-connectors-gmail/setup.md) and [C / gmail setup](../claude-code-mcp-gmail/setup.md) for full details.

## Agent setup

**Agent**: Claude Desktop (Cowork mode)
**Version**: Claude Desktop with Opus 4.6 (tested for consistency with other configs run 2026-04-15/16; Opus 4.7 was available but not used)
**Non-default config**: workspace-mcp MCP server in `claude_desktop_config.json` (configured during gmail run)

## Connector installation

No changes from gmail run. Same MCP server config, same google_workspace_mcp installation.

## Account-type differences

The google_workspace_mcp uses `--single-user` mode, which binds to one Google account at a time. The gmail run authenticated as fshotwell@gmail.com. Switching to fshotwell@cruxcapacity.com may require re-authentication via the MCP server's OAuth flow (localhost:8000 callback).

The workspace prompt includes an account verification step: search Drive first and confirm the returned file ID matches the workspace seed data, not the gmail seed data. If the wrong account is active, the MCP server should prompt for re-auth when it encounters a scope/account mismatch.

## Gotchas

To be recorded during test execution.
