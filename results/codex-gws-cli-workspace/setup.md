# Setup: D / workspace

**Date**: 2026-04-15
**Config**: D — Codex CLI + GWS CLI
**Account**: fshotwell@cruxcapacity.com
**Starting from**: Reusing Codex CLI + GWS CLI setup from config D/gmail and config B

## Prerequisites

- **OS**: macOS 15.x (Darwin 25.3.0, arm64)
- **Runtime versions**: Node v22.x (Codex CLI requirement)
- **GCP project**: `crux-workspace` (existing, reused from config B/workspace)
- **Billing**: Not required (OAuth "Testing" mode)

## Agent setup

**Agent**: Codex CLI (OpenAI)
**Version**: 0.120.0
**Non-default config**: Run with `--dangerously-bypass-approvals-and-sandbox` (required for network + keyring access; `--full-auto` sandbox blocks DNS and macOS keyring). Discovered during config D/gmail run.

## Connector installation

Reused GWS CLI setup from [config B/workspace setup](../claude-code-gws-cli-workspace/setup.md). No new installation steps.

### Config files created/modified

No changes. Reusing existing GWS CLI profile at `~/.config/gws/profiles/crux/`.

## GCP project configuration

Reused from config B/workspace. See [config B/workspace setup](../claude-code-gws-cli-workspace/setup.md) for full GCP configuration details.

## First-run auth flow

No new auth required. Reusing existing OAuth tokens from config B/workspace run.

## Resulting artifacts

| Artifact | Location | Notes |
|----------|----------|-------|
| GWS CLI profile | `~/.config/gws/profiles/crux/` | Reused from config B |
| Env file | `envs/workspace.env` | Sets `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to crux profile |
| Env vars set by direnv | `GOOGLE_WORKSPACE_CLI_CONFIG_DIR`, `GWS_ACCOUNT`, `GCP_PROJECT` | Auto-loaded on `cd` into results directory |

## Account-type differences

Workspace account uses GCP project `crux-workspace` (vs `hdca-workspace-tools` for gmail). Profile directory is `~/.config/gws/profiles/crux/` (vs `~/.config/gws/profiles/gmail/`). No behavioral differences expected from GWS CLI perspective.

## Gotchas

Sandbox issue already resolved in D/gmail run: `--full-auto` mode is incompatible with GWS CLI due to DNS and keyring restrictions. Using `--dangerously-bypass-approvals-and-sandbox` from the start.
