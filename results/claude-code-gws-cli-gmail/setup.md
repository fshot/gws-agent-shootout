# Setup: B / gmail

**Date**: 2026-04-15
**Config**: B — Claude Code + GWS CLI
**Account**: fshotwell@gmail.com
**Starting from**: Existing GWS CLI installation (set up prior to this shootout)

## Prerequisites

- **OS**: macOS 15.x (Apple Silicon)
- **Runtime versions**: Rust toolchain (GWS CLI is a compiled binary)
- **GCP project**: `hdca-workspace-tools` (owned by fshotwell@gmail.com)
- **Billing**: Not required for Gmail API, Drive API, etc. in testing mode

## Agent setup

**Agent**: Claude Code
**Version**: Claude Opus 4.6 (1M context)
**Non-default config**: None. GWS CLI is invoked via Bash tool — no MCP server or special integration needed.

## Connector installation

### GWS CLI

**Version**: 0.22.5
**Source**: Installed via cargo (Rust package manager)

```bash
cargo install gws
```

The binary is placed in `~/.cargo/bin/gws` (must be on PATH).

### Config files created/modified

| File | Location | What changed |
|------|----------|-------------|
| OAuth client secret | `~/.config/gws/profiles/gmail/client_secret.json` | Downloaded from GCP Console |
| Encrypted credentials | `~/.config/gws/profiles/gmail/credentials.enc` | Created by `gws auth login` |
| Token cache | `~/.config/gws/profiles/gmail/token_cache.json` | Auto-managed, refreshed on each use |

## GCP project configuration

### APIs enabled

| API | How enabled |
|-----|------------|
| Google Drive API | GCP Console → APIs & Services → Enable |
| Google Docs API | GCP Console |
| Google Sheets API | GCP Console |
| Gmail API | GCP Console |
| Google Calendar API | GCP Console |
| People API | GCP Console (used for contact resolution) |

### OAuth consent screen

- **User type**: External
- **App name**: GWS CLI
- **Scopes requested**: `drive`, `docs`, `sheets`, `gmail.modify`, `calendar`, `cloud-platform`, `openid`, `userinfo.email`, `userinfo.profile`
- **Publishing status**: Testing (tokens expire every 7 days)
- **Test users added**: `fshotwell@gmail.com`

### OAuth client

- **Type**: Desktop application
- **Client ID**: `498491056696-*.apps.googleusercontent.com` (from project `hdca-workspace-tools`)
- **Credential file location**: `~/.config/gws/profiles/gmail/client_secret.json`

## First-run auth flow

1. Ran `gws auth login -s drive,docs,sheets,gmail,calendar`
2. CLI printed an OAuth URL and started a local HTTP server on a random port
3. Browser opened to Google account chooser → selected `fshotwell@gmail.com`
4. Consent screen appeared showing "GWS CLI wants to access your Google Account" with requested scopes
5. Clicked "Allow"
6. Browser redirected to `http://localhost:{port}` — CLI captured the auth code
7. CLI printed "Authentication successful. Encrypted credentials saved."
8. Credentials stored at `~/.config/gws/profiles/gmail/credentials.enc` (AES-256-GCM, key in OS keyring)

## Resulting artifacts

| Artifact | Location | Notes |
|----------|----------|-------|
| GWS CLI profile | `~/.config/gws/profiles/gmail/` | Contains client_secret.json, credentials.enc, token_cache.json |
| Env file | `envs/gmail.env` | Sets `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to the profile |
| Env vars set by direnv | `GOOGLE_WORKSPACE_CLI_CONFIG_DIR`, `GWS_ACCOUNT`, `GCP_PROJECT` | Auto-loaded on `cd` into results directory |

## Account-type differences

This is the gmail (personal) account. Key differences from workspace:
- Uses GCP project `hdca-workspace-tools` (owned by this account)
- No domain-wide delegation or admin consent required
- OAuth consent screen must be "External" (not "Internal")
- User must be added to "Test users" list in GCP Console

## Profile-based account switching

GWS CLI supports seamless multi-account switching via the `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` environment variable. Each account gets its own profile directory:

```
~/.config/gws/profiles/
  gmail/              # fshotwell@gmail.com (GCP: hdca-workspace-tools)
  crux/               # fshotwell@cruxcapacity.com (GCP: crux-workspace)
```

direnv automatically sets this variable when you `cd` into a results directory, so `gws` commands use the right account with no manual switching.

```bash
cd results/claude-code-gws-cli-gmail
gws auth status 2>&1 | grep user    # → fshotwell@gmail.com

cd ../claude-code-gws-cli-workspace
gws auth status 2>&1 | grep user    # → fshotwell@cruxcapacity.com
```

## Gotchas

1. **Token expiry in Testing mode**: Refresh tokens expire every 7 days. If you see `invalid_rapt` errors, re-run `gws auth login -s drive,docs,sheets,gmail,calendar` with the profile's config dir set.

2. **File upload path restriction**: `gws drive files create --upload` requires the file to be within the current working directory. Absolute paths outside cwd are rejected with a validation error.

3. **`gws gmail +append` flag**: The `+append` helper uses `--spreadsheet` not `--id` for the spreadsheet ID. The error message is clear, but the inconsistency with other helpers is worth noting.

4. **Subcommand hierarchy**: Sheets values operations use `gws sheets spreadsheets values {get|update|append}` (three levels deep), not `gws sheets spreadsheets.values` (dot notation doesn't work).

5. **stderr noise**: GWS CLI prints `Using keyring backend: keyring` to stderr on every command. When piping stdout to `python3 -c` for JSON parsing, redirect stderr to `/dev/null` or the keyring message gets mixed in.
