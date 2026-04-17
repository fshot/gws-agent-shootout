# Setup: C / @gmail.com

**Date**: 2026-04-15
**Config**: C — Claude Code + google_workspace_mcp
**Account**: fshotwell@gmail.com
**Starting from**: reusing GCP project from config B; local install of google_workspace_mcp

## Prerequisites

- **OS**: macOS 26.3.1
- **Runtime versions**: Python 3.11.9 (Homebrew), Node v22.x
- **GCP project**: Existing project `hdca-workspace-tools` reused from config B
- **Billing**: Not required

## Agent setup

**Agent**: Claude Code
**Version**: 2.1.109
**Non-default config**: workspace-mcp MCP server added via Claude Code `/mcp add` command

## Connector installation

### google_workspace_mcp (workspace-mcp) v1.19.0

The connector is [taylorwilsdon/google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp), installed locally as a Python project with its own virtual environment.

#### Installation steps

```bash
# Clone the repo
cd /Users/fshot/code
git clone https://github.com/taylorwilsdon/google_workspace_mcp.git
cd google_workspace_mcp

# Create venv and install dependencies
python3.11 -m venv .venv
.venv/bin/pip install -e .

# Copy OAuth client credentials from GCP project (reused from config B)
cp ~/Downloads/client_secret_*.json ./client_secret.json
```

#### How the MCP server runs

Claude Code launches the server as a child process via stdio transport:

```bash
.venv/bin/python main.py --transport stdio --tools gmail drive calendar docs sheets --single-user
```

Key flags:
- `--transport stdio`: Communicates with Claude Code over stdin/stdout (JSON-RPC)
- `--tools gmail drive calendar docs sheets`: Enables specific GWS service modules
- `--single-user`: Simplifies auth for single-account use (no multi-tenant OAuth)

#### MCP server registration in Claude Code

Registering the server with Claude Code required multiple attempts and restarts due to config file confusion:

**Attempt 1 (failed):** Added the server config to `~/.claude/.mcp.json` with a `cwd` field and relative paths. Claude Code never loaded the tools. `claude mcp list` did not show the server.

**Attempt 2 (failed):** Discovered that Claude Code reads user-scoped MCP servers from `~/.claude.json`, NOT from `~/.claude/.mcp.json`. Moved the config there, but still used relative paths with a `cwd` field. Server still didn't load — **the `cwd` field is silently ignored by Claude Code**.

**Attempt 3 (worked):** Used the CLI command with absolute paths:

```bash
claude mcp add -s user workspace-mcp -- \
  /Users/fshot/code/google_workspace_mcp/.venv/bin/python \
  /Users/fshot/code/google_workspace_mcp/main.py \
  --transport stdio \
  --tools gmail drive calendar docs sheets \
  --single-user
```

Each config change required a full Claude Code session restart, since MCP servers are only loaded at session initialization. This debugging loop (edit config → restart → check `claude mcp list` → repeat) consumed significant time during initial setup.

### Config files created/modified

| File | Location | What changed |
|------|----------|-------------|
| `client_secret.json` | `/Users/fshot/code/google_workspace_mcp/` | OAuth client credentials from GCP Console (same client as config B) |
| MCP server config | Claude Code session/project state | workspace-mcp server entry with stdio transport |

## GCP project configuration

Reuses the GCP project and OAuth configuration from config B (see `results/claude-code-gws-cli-gmail/setup.md`).

### APIs enabled

| API | How enabled |
|-----|------------|
| Google Drive API | Reused from config B |
| Google Docs API | Reused from config B |
| Google Sheets API | Reused from config B |
| Gmail API | Reused from config B |
| Google Calendar API | Reused from config B |

### OAuth consent screen

Reuses config B's consent screen settings. See config B setup doc for details.

- **Publishing status**: Testing (refresh tokens expire every 7 days)
- **Test users**: fshotwell@gmail.com, fshotwell@cruxcapacity.com

## First-run auth flow

The workspace-mcp server manages its own OAuth token lifecycle, separate from the GWS CLI credentials used in config B. On first use of any tool category, the server:

1. Detects missing/expired token for the requested API scope
2. Generates an OAuth authorization URL pointing to `localhost:8000/oauth2callback`
3. Returns the URL in the tool error response, prompting the user to click it
4. User completes Google consent screen in browser
5. OAuth callback captures the authorization code and exchanges it for tokens
6. Tokens are stored locally by the MCP server

**Critical finding: incremental scope authorization.** The server does NOT request all scopes upfront. It requests scopes per-service as each API is first accessed. During testing:
- Drive, Docs tools worked on first use (authorized during initial setup)
- Sheets tools triggered a re-authorization prompt mid-test (test #7), requiring the user to click a new auth URL and re-consent with Sheets scopes added
- This is a user intervention that counts toward the intervention total

The full scope set requested (all at once during the Sheets re-auth):
- `gmail.modify`, `gmail.settings.basic`, `gmail.labels`, `gmail.readonly`, `gmail.send`, `gmail.compose`
- `spreadsheets.readonly`, `spreadsheets`
- `documents`, `documents.readonly`
- `drive.file`, `drive.readonly`, `drive`
- `calendar`, `calendar.readonly`, `calendar.events`
- `userinfo.email`, `userinfo.profile`, `openid`

## Resulting artifacts

| Artifact | Location | Notes |
|----------|----------|-------|
| Python venv | `/Users/fshot/code/google_workspace_mcp/.venv/` | Contains all dependencies |
| OAuth client secret | `/Users/fshot/code/google_workspace_mcp/client_secret.json` | Same GCP OAuth client as config B |
| OAuth tokens | Managed internally by workspace-mcp server | Stored in server's credential store |

## Account-type differences

Testing with @gmail.com personal account. No admin consent or domain-wide delegation required. The GCP project is in "Testing" mode, so refresh tokens expire every 7 days.

## Gotchas

1. **Config file location trap (cost: ~30 min).** Claude Code does NOT read MCP servers from `~/.claude/.mcp.json` — it reads them from `~/.claude.json`. The `.mcp.json` file appears legacy/unused for stdio servers. This is poorly documented and caused multiple failed restart cycles before the correct file was found.

2. **`cwd` field silently ignored (cost: ~15 min).** Even after finding the right config file, using relative paths with a `cwd` field didn't work. Claude Code ignores `cwd` for stdio MCP servers. All paths in `command` and `args` must be absolute. No error message — the server simply doesn't appear in `claude mcp list`.

3. **Session restart required for config changes.** MCP servers are loaded once at session init. Every config tweak requires a full Claude Code restart. Combined with gotchas #1 and #2, this turned a 2-minute config task into a 45-minute debugging session.

4. **Incremental scope auth interrupts testing.** Unlike GWS CLI (config B) which requests all scopes during `gws auth login`, the workspace-mcp server triggers re-authorization when you first hit a new API surface. This caused a mid-test interruption at component test #7 (Sheets: read). The user had to click an auth URL and complete consent before continuing. This is a significant UX difference from config B.

5. **localhost:8000 callback.** The OAuth redirect goes to `localhost:8000`, which means the MCP server's HTTP endpoint must be accessible even in stdio mode. The `fastmcp.json` config confirms the server runs an HTTP listener on port 8000 for OAuth callbacks.

6. **`--single-user` mode.** This flag simplifies the auth flow for personal use but means the server can only manage credentials for one Google account at a time. Switching between @gmail.com and @workspace requires re-authentication or separate server instances.
