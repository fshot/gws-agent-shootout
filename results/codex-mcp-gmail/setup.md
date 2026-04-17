# Setup: D2 / @gmail.com

**Date**: 2026-04-15
**Config**: D2 — Codex CLI + google_workspace_mcp
**Account**: fshotwell@gmail.com
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

```bash
codex mcp add workspace-mcp -- \
  /Users/fshot/code/google_workspace_mcp/.venv/bin/python \
  /Users/fshot/code/google_workspace_mcp/main.py \
  --transport stdio \
  --tools gmail drive calendar docs sheets \
  --single-user
```

Verified with:
```bash
codex mcp list
# Output: workspace-mcp enabled, Auth: Unsupported
```

### Config files created/modified

| File | Location | What changed |
|------|----------|-------------|
| Codex config | `~/.codex/config.toml` | workspace-mcp server entry added |

## GCP project configuration

Reuses config B's GCP project and OAuth configuration. See `results/claude-code-gws-cli-gmail/setup.md`.

### OAuth credentials

Reuses `client_secret.json` from config C at `/Users/fshot/code/google_workspace_mcp/client_secret.json`.

## First-run auth flow

Cached credentials from config C exist at `~/.google_workspace_mcp/credentials/fshotwell@gmail.com.json`. No new auth flow expected unless tokens have expired (7-day expiry in Testing mode).

## Account-type differences

N/A — this is the first D2 run (gmail). Workspace run will note any differences.

## Gotchas

- Codex MCP auth shows "Unsupported" — this is expected since the MCP server manages its own OAuth, not Codex.
- If tokens have expired since config C's run, Codex may need user intervention to re-authorize via browser redirect.
