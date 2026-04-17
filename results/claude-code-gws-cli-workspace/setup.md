# Setup: B / workspace

**Date**: 2026-04-15
**Config**: B — Claude Code + GWS CLI
**Account**: fshotwell@cruxcapacity.com
**Starting from**: Reusing GWS CLI installation from config B / gmail

## Prerequisites

- **OS**: macOS 15.x (Apple Silicon)
- **Runtime versions**: Rust toolchain (GWS CLI is a compiled binary)
- **GCP project**: `crux-workspace` (owned by fshotwell@cruxcapacity.com)
- **Billing**: Not required for Gmail API, Drive API, etc. in testing mode

## Agent setup

**Agent**: Claude Code
**Version**: Claude Opus 4.6 (1M context)
**Non-default config**: None. GWS CLI is invoked via Bash tool — no MCP server or special integration needed.

## Connector installation

GWS CLI was already installed for config B / gmail. See [../claude-code-gws-cli-gmail/setup.md](../claude-code-gws-cli-gmail/setup.md) for full installation steps.

**Version**: 0.22.5

No additional installation needed — the `gws` binary is shared across all accounts.

### Config files created/modified

| File | Location | What changed |
|------|----------|-------------|
| OAuth client secret | `~/.config/gws/profiles/crux/client_secret.json` | Downloaded from GCP Console for project `crux-workspace` |
| Encrypted credentials | `~/.config/gws/profiles/crux/credentials.enc` | Created by `gws auth login` |
| Token cache | `~/.config/gws/profiles/crux/token_cache.json` | Auto-managed, refreshed on each use |

## GCP project configuration

### APIs enabled

| API | How enabled |
|-----|------------|
| Google Drive API | GCP Console → APIs & Services → Enable |
| Google Docs API | GCP Console |
| Google Sheets API | GCP Console |
| Gmail API | GCP Console |
| Google Calendar API | GCP Console |
| People API | GCP Console |

### OAuth consent screen

- **User type**: Internal (Workspace accounts support Internal apps)
- **App name**: GWS CLI
- **Scopes requested**: `drive`, `docs`, `sheets`, `gmail.modify`, `calendar`, `cloud-platform`, `openid`, `userinfo.email`, `userinfo.profile`
- **Publishing status**: Testing
- **Test users added**: N/A (Internal apps are available to all domain users)

### OAuth client

- **Type**: Desktop application
- **Client ID**: `498491056696-*.apps.googleusercontent.com` (from project `crux-workspace`)
- **Credential file location**: `~/.config/gws/profiles/crux/client_secret.json`

## First-run auth flow

Same flow as gmail account — see [../claude-code-gws-cli-gmail/setup.md](../claude-code-gws-cli-gmail/setup.md#first-run-auth-flow) for the step-by-step.

```bash
GOOGLE_WORKSPACE_CLI_CONFIG_DIR=~/.config/gws/profiles/crux \
  gws auth login -s drive,docs,sheets,gmail,calendar
```

## Resulting artifacts

| Artifact | Location | Notes |
|----------|----------|-------|
| GWS CLI profile | `~/.config/gws/profiles/crux/` | Contains client_secret.json, credentials.enc, token_cache.json |
| Env file | `envs/workspace.env` | Sets `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to the crux profile |
| Env vars set by direnv | `GOOGLE_WORKSPACE_CLI_CONFIG_DIR`, `GWS_ACCOUNT`, `GCP_PROJECT` | Auto-loaded on `cd` into results directory |

## Account-type differences

Key differences from the gmail (personal) account:

- Uses GCP project `crux-workspace` (separate from the gmail account's `hdca-workspace-tools`)
- OAuth consent screen can be set to **Internal** (only available for Workspace accounts), removing the need to add test users
- No 100-user cap on test users (Internal apps are available to all domain users)
- Admin consent may be required depending on Workspace admin policies
- Same 7-day token expiry in Testing mode applies

## Gotchas

Same gotchas as gmail run — see [../claude-code-gws-cli-gmail/setup.md](../claude-code-gws-cli-gmail/setup.md#gotchas) for full list. No additional workspace-specific issues encountered during setup.
