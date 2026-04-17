# Setup: E / gmail

**Date**: 2026-04-15
**Config**: E — Gemini CLI + Workspace extension
**Account**: fshotwell@gmail.com
**Starting from**: existing Gemini CLI installation with Workspace extension

## Prerequisites

- **OS**: macOS 15.x (Darwin 25.3.0)
- **Runtime versions**: Node (bundled with Gemini CLI)
- **GCP project**: Managed by Gemini CLI / Google Cloud — no manual GCP project required
- **Billing**: Not required

## Agent setup

**Agent**: Gemini CLI
**Version**: 0.37.0
**Non-default config**: `--yolo` mode for auto-approval, `--output-format json` for structured output

## Connector installation

### Workspace extension

The google-workspace extension was installed via the Gemini CLI built-in extension system.

```bash
gemini extensions install google-workspace
```

### Extension structure

The extension provides skills for: gmail, google-calendar, google-chat, google-docs, google-sheets, google-slides.
Commands available for: calendar, drive, gmail.

Location: `~/.gemini/extensions/google-workspace/`

### Config files created/modified

| File | Location | What changed |
|------|----------|-------------|
| Extension install record | `~/.gemini/extensions/google-workspace/.gemini-extension-install.json` | Extension registration |
| Extension enablement | `~/.gemini/extensions/extension-enablement.json` | Lists enabled extensions |
| OAuth credentials | `~/.gemini/oauth_creds.json` | OAuth tokens for Google account |
| Gemini credentials | `~/.gemini/gemini-credentials.json` | Gemini API credentials |

## GCP project configuration

### APIs enabled

The Workspace extension handles API access through Gemini's own OAuth infrastructure. No manual GCP project or API enablement is required — the extension uses Google's pre-configured OAuth client.

### OAuth consent screen

- **User type**: Managed by Google/Gemini
- **App name**: Gemini CLI
- **Scopes requested**: Drive, Docs, Sheets, Gmail, Calendar (managed by extension)
- **Publishing status**: N/A (Google-managed)

### OAuth client

- **Type**: Desktop app (Gemini CLI built-in)
- **Client ID**: Managed by Gemini CLI
- **Credential file location**: `~/.gemini/oauth_creds.json`

## First-run auth flow

The Workspace extension authenticated during `gemini extensions install`:

1. Ran `gemini extensions install google-workspace`
2. Browser opened to Google OAuth consent screen
3. Selected `fshotwell@gmail.com` account
4. Approved requested scopes (Drive, Docs, Sheets, Gmail, Calendar)
5. Redirect back to localhost, tokens stored in `~/.gemini/oauth_creds.json`

## Resulting artifacts

| Artifact | Location | Notes |
|----------|----------|-------|
| Extension files | `~/.gemini/extensions/google-workspace/` | Commands, skills, dist, node_modules |
| OAuth credentials | `~/.gemini/oauth_creds.json` | Access/refresh tokens |
| Google account ID | `~/.gemini/google_account_id` | Links to authenticated account |

## Account-type differences

This is the first run (gmail). Workspace account differences will be noted in the workspace run.

## Gotchas

- `gemini extensions list` produces ImportProcessor errors when run from this project directory — it tries to parse email addresses in GEMINI.md as file imports. This appears cosmetic and does not affect extension functionality.
