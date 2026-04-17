# Session Log: D / workspace

**Date**: 2026-04-15
**Config**: D — Codex CLI + GWS CLI
**Account**: fshotwell@cruxcapacity.com
**Operator**: Frank Shotwell
**Session duration**: 17:11 — 17:18 (~7 minutes wall clock; ~1 minute API execution time)

## Setup

**Time to first operation**: ~4 minutes (Codex read AGENTS.md, fixtures, `gws --help`, and 8 schema endpoints before executing)
**Setup doc**: [setup.md](setup.md) (detailed install/config steps)
**Setup summary**: Reused GWS CLI setup from config B/workspace. No new installation required.
**Auth notes**: Initial attempt blocked by Codex free-tier rate limit (consumed by D/gmail run earlier same day). Operator upgraded to ChatGPT Plus and re-authenticated via `codex login`. Second attempt succeeded. No GWS CLI auth issues.

## Pre-test: Isolation Folder

**Folder created**: yes
**Folder name**: `[GWS-D] Shootout Results`
**Folder ID**: `{folder-id}`

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | PASS | 1s | 0 | |
| 2 | Drive: upload `fixtures/upload-test.txt` | PASS | 2s | 0 | |
| 3 | Drive: share uploaded file with fshotwell@gmail.com | PASS | 2s | 0 | |
| 4 | Docs: read `GWS Shootout — Seed Document` | PASS | 1s | 0 | |
| 5 | Docs: create `[GWS-D] Created Test Doc` | PASS | 3s | 0 | |
| 6 | Docs: edit (append to Doc from #5) | PASS | 2s | 0 | |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | PASS | 1s | 0 | |
| 8 | Sheets: write D1:F1 to seed Sheet | PASS | 1s | 0 | |
| 9 | Sheets: create `[GWS-D] Created Test Sheet` | PASS | 4s | 0 | |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | PASS | 1s | 0 | |
| 11 | Gmail: read message from #10 | PASS | 0s | 0 | |
| 12 | Gmail: send `[GWS-D] Test Email` to fshotwell@gmail.com | PASS | 1s | 0 | |
| 13 | Calendar: list events on `GWS Shootout` calendar | PASS | 1s | 0 | |
| 14 | Calendar: create `[GWS-D] Test Event` | PASS | 1s | 0 | |
| 15 | Calendar: update event from #14 (move +1 hour) | PASS | 1s | 0 | |

**Pass**: 15/15
**Fail**: 0/15
**Blocked**: 0/15
**Intervention count**: 1 (ChatGPT Plus upgrade + re-login required after free-tier rate limit exhausted by D/gmail run)

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | PASS | 1s | 0 | |
| 2 | Create `[GWS-D] April 2026 Committee Agenda` | PASS | 3s | 0 | |
| 3 | Update `[GWS-D] Test Event` description with agenda link | PASS | 1s | 0 | |
| 4 | Send `[GWS-D] Committee Meeting Reminder` to fshotwell@gmail.com | PASS | 1s | 0 | |
| 5 | Create `[GWS-D] April 2026 Committee Summary` | PASS | 3s | 0 | |
| 6 | Append row to `[GWS-D] Created Test Sheet` | PASS | 1s | 0 | |

**Total time**: 1 minute (API execution only)
**Intervention count**: 0

## Token Usage

| Metric | D/workspace | D/gmail (for comparison) |
|--------|-------------|------------------------|
| Input tokens | 416,092 | 933,172 |
| Cached input tokens | 379,904 (91%) | 890,624 (95%) |
| Output tokens | 10,430 | 18,982 |
| Commands executed | 16 | 30 |
| Schema endpoints read | 8 | 10 |

Notable: workspace run consumed **55% fewer input tokens** than gmail run. Codex read 8 schema endpoints (vs 10 for gmail) and used `sed -n '1,220p'` to truncate schema output instead of reading full JSON. Codex also switched from bash to a Python runner earlier, avoiding the failed-then-retry pattern seen in D/gmail. This suggests Codex learned a more efficient strategy on the second run — though since Codex has no cross-session memory, this is coincidental (different model sampling, not learned behavior).

## Execution Notes

Codex CLI v0.120.0 ran with `--dangerously-bypass-approvals-and-sandbox` (required for network + keyring access, as discovered in D/gmail).

### Rate limit incident

The D/gmail run consumed the entire free-tier Codex weekly quota. The first workspace attempt (16:16) and second attempt (16:31 after re-login) both returned:
```
{"type":"error","message":"You've hit your usage limit. Upgrade to Plus to continue using Codex (https://chatgpt.com/explore/plus), or try again at Apr 22nd, 2026 12:09 PM."}
```

Operator upgraded to ChatGPT Plus ($20/mo) and re-authenticated via `codex login`. Third attempt (17:11) succeeded. This confirms:
- Free-tier Codex has a very low weekly quota (exhausted by a single ~933K-token session)
- The rate limit error persists through re-login unless the underlying plan is upgraded
- Plan upgrade takes effect immediately once re-authenticated

### Execution strategy

Codex's approach for workspace differed from gmail:
1. Read AGENTS.md, fixtures, `gws --help`, and 8 schema endpoints (gmail: 10 schemas, no truncation)
2. Verified auth: `gws drive about get` confirmed `fshotwell@cruxcapacity.com`
3. First bash script (item_16) failed with jq parse error — `gws` CLI prints "Using keyring backend: keyring" to stdout, which corrupts JSON piped to jq
4. Codex pivoted to a **Python runner** (item_20) using `subprocess` instead of bash+jq, which handled the mixed stdout cleanly
5. Python runner executed all 21 operations (15 component + 6 integration) sequentially with timing

### Keyring stdout pollution

The `gws` CLI prints `Using keyring backend: keyring` to stdout on first invocation in a session. This corrupted the bash script's JSON parsing (jq got `Using keyring backend...` before the JSON). The Python runner worked around this by parsing output differently. This is a `gws` CLI bug — diagnostic messages should go to stderr, not stdout.

## Raw Output

Full JSONL: [codex-raw-output.jsonl](codex-raw-output.jsonl) (44 lines)
Readable output: [codex-readable-output.md](codex-readable-output.md) (empty — jq extraction pattern didn't match Codex's output format for this run; results extracted from item_22 in JSONL)

## Screenshots

None captured (Codex CLI is terminal-only; no screenshots of GWS UI results taken during this run).
