# Setup: E / workspace

**Date**: 2026-04-16
**Config**: E — Gemini CLI + Workspace extension
**Account**: fshotwell@cruxcapacity.com
**Starting from**: reusing Gemini CLI + Workspace extension from config E / gmail

## Prerequisites

See [E / gmail setup](../gemini-cli-workspace-gmail/setup.md) for full details.

- **OS**: macOS 15.x (Darwin 25.3.0)
- **Runtime versions**: Node (bundled with Gemini CLI)
- **GCP project**: Managed by Gemini CLI / Google Cloud — no manual GCP project required
- **Billing**: Not required

## Agent setup

**Agent**: Gemini CLI
**Version**: 0.37.0
**Non-default config**: `--yolo` mode for auto-approval, `--output-format json` for structured output

## Connector installation

Reused existing installation from E / gmail. No additional steps required.

Extension location: `~/.gemini/extensions/google-workspace/`

## Account-type differences

**The Workspace extension cannot switch accounts.** It stores a single set of OAuth credentials in `~/.gemini/oauth_creds.json`, bound to whichever account authenticated during `gemini extensions install`. The tracking file `~/.gemini/google_accounts.json` confirms the single-account model:

```json
{ "active": "fshotwell@gmail.com", "old": [] }
```

Switching to a different account requires destructive re-authentication:

```bash
cd ~/.gemini/extensions/google-workspace/
npm run auth-utils -- clear    # wipe tokens from system keychain
npm run auth-utils -- login    # re-authenticate as different account
```

No env vars, CLI flags, or profile directories exist for concurrent multi-account support.

This run proceeded with the gmail account's credentials still active. All operations targeted fshotwell@gmail.com, not fshotwell@cruxcapacity.com. Results are documented for completeness but are invalid for the workspace account comparison.

## Gotchas

1. See [E / gmail setup](../gemini-cli-workspace-gmail/setup.md) for known issues (ImportProcessor errors).
2. **Single-account lock-in**: The extension's credential model is a showstopper for multi-account workflows. Anyone consulting, freelancing, or working across personal + work Google accounts cannot use this extension without manual re-auth each time they switch contexts. The GWS CLI's profile-directory approach (`GOOGLE_WORKSPACE_CLI_CONFIG_DIR`) solves this cleanly; the Workspace extension has no equivalent.
