# Session Log: D / gmail

**Date**: 2026-04-15
**Config**: D — Codex CLI + GWS CLI
**Account**: fshotwell@gmail.com
**Operator**: Frank Shotwell
**Session duration**: 16:01 — 16:08 (~7 minutes wall clock; ~1 minute API execution time)

## Setup

**Time to first operation**: ~4 minutes (Codex spent time reading AGENTS.md, fixtures, and `gws` CLI help/schema before executing)
**Setup doc**: [setup.md](setup.md) (detailed install/config steps)
**Setup summary**: Reused GWS CLI setup from config B. No new installation required.
**Auth notes**: First run attempt used `codex exec --full-auto` which runs in a `workspace-write` sandbox. This sandbox blocks network access (DNS resolution fails) and macOS keyring access (cannot decrypt `credentials.enc`). All 15 tests failed with `dns error: failed to lookup address information`. Script was updated to use `--dangerously-bypass-approvals-and-sandbox` for the second run, which gave Codex full shell access including network and keyring. Second run succeeded.

## Pre-test: Isolation Folder

**Folder created**: yes
**Folder name**: `[GWS-D] Shootout Results`
**Folder ID**: (created by Codex run script, not captured separately)

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | PASS | 1s | 0 | |
| 2 | Drive: upload `fixtures/upload-test.txt` | PASS | 1s | 0 | |
| 3 | Drive: share uploaded file with fshotwell@cruxcapacity.com | PASS | 3s | 0 | |
| 4 | Docs: read `GWS Shootout — Seed Document` | PASS | 0s | 0 | |
| 5 | Docs: create `[GWS-D] Created Test Doc` | PASS | 3s | 0 | |
| 6 | Docs: edit (append to Doc from #5) | PASS | 1s | 0 | |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | PASS | 1s | 0 | |
| 8 | Sheets: write D1:F1 to seed Sheet | PASS | 0s | 0 | |
| 9 | Sheets: create `[GWS-D] Created Test Sheet` | PASS | 3s | 0 | |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | PASS | 1s | 0 | |
| 11 | Gmail: read message from #10 | PASS | 1s | 0 | |
| 12 | Gmail: send `[GWS-D] Test Email` to fshotwell@cruxcapacity.com | PASS | 1s | 0 | |
| 13 | Calendar: list events on `GWS Shootout` calendar | PASS | 1s | 0 | |
| 14 | Calendar: create `[GWS-D] Test Event` | PASS | 0s | 0 | |
| 15 | Calendar: update event from #14 (move +1 hour) | PASS | 1s | 0 | |

**Pass**: 15/15
**Fail**: 0/15
**Blocked**: 0/15
**Intervention count**: 1 (script change from `--full-auto` to `--dangerously-bypass-approvals-and-sandbox` after first run failed due to sandbox restrictions)

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | PASS | 2s | 0 | |
| 2 | Create `[GWS-D] April 2026 Committee Agenda` | PASS | 2s | 0 | |
| 3 | Update `[GWS-D] Test Event` description with agenda link | PASS | 1s | 0 | |
| 4 | Send `[GWS-D] Committee Meeting Reminder` to fshotwell@cruxcapacity.com | PASS | 1s | 0 | |
| 5 | Create `[GWS-D] April 2026 Committee Summary` | PASS | 2s | 0 | |
| 6 | Append row to `[GWS-D] Created Test Sheet` | PASS | 1s | 0 | |

**Total time**: 1 minute (API execution only)
**Intervention count**: 0

## Execution Notes

Codex CLI v0.120.0 generated a single bash script (`/tmp/gws_shootout_run2.sh`) that executed all 15 component tests and 6 integration steps sequentially. The script included:
- Retry logic matching the protocol (up to 2 retries on transient errors with 30s wait)
- Dependency tracking (BLOCKED marking for dependent operations)
- Per-operation timing
- TSV-based result collection with formatted markdown output

Codex's first attempt generated a script (`gws_shootout_run1.sh`) that failed on operation #2 due to `--upload` path validation: `gws` rejected a `/tmp/` path outside the working directory. Codex diagnosed this, corrected the path to use a repo-local `.tmp/` directory, and also fixed Sheets subcommand syntax (`sheets spreadsheets values` vs incorrect forms). The second script ran cleanly.

Codex also spent initial time probing `gws` CLI help and schema endpoints to learn the exact command surface before writing the test script. This added ~3 minutes to the session but resulted in correct commands on the (corrected) second attempt.

### Sandbox discovery

`codex exec --full-auto` uses `--sandbox workspace-write`, which restricts the sandbox to workspace file writes only. Network access is blocked (DNS resolution fails) and macOS keyring access is denied (cannot decrypt `gws` credentials). This makes `--full-auto` incompatible with any tool requiring network or system keyring access. `--dangerously-bypass-approvals-and-sandbox` or equivalent is required for `gws` CLI operations.

## Raw Output

Full JSONL: [codex-raw-output.jsonl](codex-raw-output.jsonl) (76 lines)
Readable messages: [codex-readable-output.md](codex-readable-output.md)

## Screenshots

None captured (Codex CLI is terminal-only; no screenshots of GWS UI results taken during this run).
