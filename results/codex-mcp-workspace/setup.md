# Setup: D2 / @workspace

**Date**: 2026-04-15
**Config**: D2 — Codex CLI + google_workspace_mcp
**Account**: fshotwell@cruxcapacity.com
**Starting from**: reusing MCP server from config C; reusing GCP project from config B

## Prerequisites

- **OS**: macOS 26.3.1
- **Runtime versions**: Python 3.11.9 (Homebrew), Node v22.x
- **GCP project**: Existing project `hdca-workspace-tools` reused from configs B and C
- **Billing**: Not required

## Agent setup

**Agent**: Codex CLI
**Version**: 0.120.0
**Non-default config**: workspace-mcp MCP server added via `codex mcp add`

## Connector installation

### google_workspace_mcp (workspace-mcp)

Reuses the same MCP server installation from config C. See `results/claude-code-mcp-gmail/setup.md` for full installation steps.

#### Codex-specific MCP registration

Already configured during the D2 gmail run. See `results/codex-mcp-gmail/setup.md`.

### Config files created/modified

No new config files — reusing D2 gmail setup.

## GCP project configuration

Reuses config B's GCP project and OAuth configuration. See `results/claude-code-gws-cli-gmail/setup.md`.

### OAuth credentials

Reuses `client_secret.json` from config C at `/Users/fshot/code/google_workspace_mcp/client_secret.json`.

## First-run auth flow

Workspace account credentials were established during the config C workspace run. Cached credentials at `~/.google_workspace_mcp/credentials/fshotwell@cruxcapacity.com.json`.

Note: The initial D2 workspace attempt (before this run) failed because workspace account credentials did not exist. After completing config C's workspace run, the cached credentials were available and this run succeeded without auth prompts.

## Account-type differences

- No differences in connector setup between gmail and workspace accounts.
- The initial run attempt failed due to missing workspace OAuth credentials — the gmail run (D2 gmail) had credentials cached from config C gmail, but workspace credentials required running config C workspace first.

## Gotchas

- Codex MCP auth shows "Unsupported" — this is expected since the MCP server manages its own OAuth, not Codex.
- Must complete the corresponding config C run for each account type before D2 can succeed, since D2 relies on cached OAuth tokens from the MCP server's credential store.
