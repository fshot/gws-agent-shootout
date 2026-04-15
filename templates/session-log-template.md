# Session Log: {CONFIG} / {ACCOUNT}

**Date**: YYYY-MM-DD
**Config**: {A|B|C|D|D2|E|F} — {agent} + {connector}
**Account**: {fshotwell@gmail.com | fshotwell@cruxcapacity.com}
**Operator**: Frank Shotwell
**Session duration**: {start} — {end} ({total minutes})

## Setup

**Time to first operation**: {minutes}
**Setup doc**: [setup.md](setup.md) (detailed install/config steps)
**Setup summary**: {one-line: was setup from scratch, or reused prior config?}
**Auth notes**: {any auth issues, consent screens, scope prompts during test run}

## Pre-test: Isolation Folder

**Folder created**: {yes/no}
**Folder name**: `[GWS-{CONFIG}] Shootout Results`
**Folder ID**: {Drive folder ID}

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | | | 0 | |
| 2 | Drive: upload `fixtures/upload-test.txt` | | | 0 | |
| 3 | Drive: share uploaded file with {other account} | | | 0 | |
| 4 | Docs: read `GWS Shootout — Seed Document` | | | 0 | |
| 5 | Docs: create `[GWS-{CONFIG}] Created Test Doc` | | | 0 | |
| 6 | Docs: edit (append to Doc from #5) | | | 0 | |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | | | 0 | |
| 8 | Sheets: write D1:F1 to seed Sheet | | | 0 | |
| 9 | Sheets: create `[GWS-{CONFIG}] Created Test Sheet` | | | 0 | |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | | | 0 | |
| 11 | Gmail: read message from #10 | | | 0 | |
| 12 | Gmail: send `[GWS-{CONFIG}] Test Email` to {other account} | | | 0 | |
| 13 | Calendar: list events on `GWS Shootout` calendar | | | 0 | |
| 14 | Calendar: create `[GWS-{CONFIG}] Test Event` | | | 0 | |
| 15 | Calendar: update event from #14 (move +1 hour) | | | 0 | |

**Pass**: {X}/15
**Fail**: {Y}/15
**Blocked**: {Z}/15
**Intervention count**: {number of times human stepped in}

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | | | 0 | |
| 2 | Create `[GWS-{CONFIG}] April 2026 Committee Agenda` | | | 0 | |
| 3 | Update `[GWS-{CONFIG}] Test Event` description with agenda link | | | 0 | |
| 4 | Send `[GWS-{CONFIG}] Committee Meeting Reminder` to {other account} | | | 0 | |
| 5 | Create `[GWS-{CONFIG}] April 2026 Committee Summary` | | | 0 | |
| 6 | Append row to `[GWS-{CONFIG}] Created Test Sheet` | | | 0 | |

**Total time**: {minutes}
**Intervention count**: {number}

## Raw Output

{Paste terminal output, error messages, API responses here. If over 100 lines, save as a separate file and link.}

## Screenshots

{List screenshots taken during this session with filenames and what they show.}
