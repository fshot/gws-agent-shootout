# Setup: D / gmail

**Date**: 2026-04-15
**Config**: D — Codex CLI + GWS CLI
**Account**: fshotwell@gmail.com
**Starting from**: Reusing GWS CLI setup from config B

## Prerequisites

- **OS**: macOS 15.x (Darwin 25.3.0)
- **Runtime versions**: Node (for Codex CLI)
- **GCP project**: Existing project reused from config B (`hdca-workspace-tools`)
- **Billing**: Not required

## Agent setup

**Agent**: Codex CLI (OpenAI)
**Version**: 0.120.0
**Non-default config**: `--full-auto` mode, `--json` output format

## Connector installation

GWS CLI installation and GCP configuration were completed during config B setup. See `results/claude-code-gws-cli-gmail/setup.md` for full details.

### Config files created/modified

| File | Location | What changed |
|------|----------|-------------|
| AGENTS.md | Project root | Codex CLI project instructions (test protocol) |
| scripts/run-codex.sh | Project root | Wrapper script for dispatching Codex in full-auto mode |

## GCP project configuration

Reused from config B. No additional APIs or OAuth changes required.

### APIs enabled

All APIs enabled during config B setup. Key APIs for this test:
- `drive.googleapis.com`
- `docs.googleapis.com`
- `sheets.googleapis.com`
- `gmail.googleapis.com`
- `calendar-json.googleapis.com`

### OAuth consent screen

Same as config B. See `results/claude-code-gws-cli-gmail/setup.md`.

### OAuth client

Same as config B — same GCP project, same OAuth client, same credentials.

## First-run auth flow

No additional auth required. Codex CLI uses the `gws` command, which was already authenticated during config B setup. The `gmail.env` file sets `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to the gmail profile, and the wrapper script sources this env file before invoking Codex.

## Resulting artifacts

| Artifact | Location | Notes |
|----------|----------|-------|
| GWS CLI profile | `~/.config/gws/profiles/gmail/` | Reused from config B |
| Env file | `envs/gmail.env` | Reused from config B |
| Codex raw output | `results/codex-gws-cli-gmail/codex-raw-output.jsonl` | Captured by wrapper script |
| Codex readable output | `results/codex-gws-cli-gmail/codex-readable-output.md` | Extracted by wrapper script |

## Account-type differences

N/A — this is the gmail account. See config D / workspace for workspace-specific differences.

## Gotchas

1. **`--full-auto` sandbox blocks network and keyring access.** `codex exec --full-auto` is an alias for `--sandbox workspace-write`, which restricts the sandbox to file writes within the workspace. DNS resolution fails (`dns error: failed to lookup address information: nodename nor servname provided, or not known`) and macOS keyring access is denied (`Platform secure storage failure: Unable to obtain authorization for this operation`). Both are required by `gws` CLI. Fix: use `--dangerously-bypass-approvals-and-sandbox` instead of `--full-auto`.

2. **`gws` rejects `--upload` paths outside the working directory.** Codex initially wrote the upload file to `/tmp/`, but `gws drive files create --upload` validates that the file path is within the current working directory. Fix: use a repo-local temporary directory (e.g., `.tmp/`).

3. **Codex required schema exploration before execution.** Codex spent ~3 minutes reading `gws --help`, `gws schema <method>`, and subcommand help before writing test commands. This is expected behavior — Codex does not have prior knowledge of the `gws` CLI's command surface.

4. **First script had incorrect Sheets subcommand syntax.** Codex initially used incorrect Sheets command paths. After the first script failure, it corrected to the proper `gws sheets spreadsheets values get/update/append` form.
