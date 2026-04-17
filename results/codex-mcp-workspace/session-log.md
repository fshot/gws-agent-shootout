# Session Log: D2 / @workspace

**Date**: 2026-04-15
**Config**: D2 — Codex CLI + google_workspace_mcp
**Account**: fshotwell@cruxcapacity.com
**Operator**: Frank Shotwell
**Session duration**: 19:57:30 — 20:02:28 PDT (4m 58s)

## Setup

**Time to first operation**: ~1m (Codex read AGENTS.md, fixtures, then started operations)
**Setup doc**: [setup.md](setup.md) (detailed install/config steps)
**Setup summary**: Reused MCP server and Codex MCP registration from D2 gmail run. OAuth tokens cached from config C workspace run.
**Auth notes**: No auth prompts during test run. Previous attempt (before config C workspace run) failed due to missing workspace credentials. This run used cached credentials successfully.

## Pre-test: Isolation Folder

**Folder created**: yes
**Folder name**: `[GWS-D2] Shootout Results`
**Folder ID**: `{folder-id}`

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | PASS | 1s | 0 | Found file ID `{drive-id}`, matches seed-ids-workspace.json |
| 2 | Drive: upload `fixtures/upload-test.txt` | PASS | 1s | 0 | File ID: `{drive-id}`, uploaded to isolation folder |
| 3 | Drive: share uploaded file with fshotwell@gmail.com | PASS | 1s | 0 | Shared as reader |
| 4 | Docs: read `GWS Shootout — Seed Document` | PASS | 2s | 0 | Content matches seed-doc-content.md |
| 5 | Docs: create `[GWS-D2] Created Test Doc` | PASS | 2s | 0 | Doc ID: `{doc-id}`. Used `import_to_google_doc` with fixture markdown |
| 6 | Docs: edit (append to Doc from #5) | PASS | 4s | 0 | Appended H2 "Added by D2" with paragraph and 3 bullets via `insert_doc_elements` + `inspect_doc_structure` + `get_doc_as_markdown` |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | PASS | 31s | 1 | First attempt returned HTTP 503 "The service is currently unavailable." Waited 30s, retry succeeded. Values match seed-sheet-data.csv |
| 8 | Sheets: write D1:F1 to seed Sheet | PASS | 1s | 0 | Wrote `Updated, by, D2` |
| 9 | Sheets: create `[GWS-D2] Created Test Sheet` | PASS | 3s | 0 | Sheet ID: `{sheet-id}`. Created, moved to isolation folder, populated with fixture CSV data |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | PASS | 1s | 0 | Found 2 messages matching subject |
| 11 | Gmail: read message from #10 | PASS | 1s | 0 | Body contains `This is a seed email for search and read testing.` |
| 12 | Gmail: send `[GWS-D2] Test Email from Shootout` to fshotwell@gmail.com | PASS | 1s | 0 | Message ID: `{msg-id}` |
| 13 | Calendar: list events on `GWS Shootout` calendar | PASS | 1s | 0 | Found 3 events including seed event and events from prior configs |
| 14 | Calendar: create `[GWS-D2] Test Event` | PASS | 1s | 0 | Event ID: `{event-id}`, 2026-04-18T10:00-11:00 PDT |
| 15 | Calendar: update event from #14 (move +1 hour) | PASS | 1s | 0 | Moved to 11:00-12:00 PDT |

**Pass**: 15/15
**Fail**: 0/15
**Blocked**: 0/15
**Intervention count**: 0

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | PASS | 2s | 0 | Found and read seed doc content |
| 2 | Create `[GWS-D2] April 2026 Committee Agenda` | PASS | 2s | 0 | Doc ID: `{doc-id}` |
| 3 | Update `[GWS-D2] Test Event` description with agenda link | PASS | 2s | 1 | First attempt failed: `manage_event` update with only `description` field returned `HttpError 400: Missing end time.` Retry with `start_time` and `end_time` fields included succeeded. Same bug as D2 gmail run. |
| 4 | Send `[GWS-D2] Committee Meeting Reminder` to fshotwell@gmail.com | PASS | 1s | 0 | Message ID: `{msg-id}` |
| 5 | Create `[GWS-D2] April 2026 Committee Summary` | PASS | 2s | 0 | Doc ID: `{doc-id}` |
| 6 | Append row to `[GWS-D2] Created Test Sheet` | PASS | 1s | 0 | Row `Meeting, 2026-04-15, 3 attendees` written to A7:C7 |

**Total time**: 4m 58s wall clock
**Intervention count**: 0

## Token Usage

| Metric | Value |
|--------|-------|
| Input tokens | 1,356,936 |
| Cached input tokens | 1,292,288 |
| Output tokens | 7,883 |
| Cache hit rate | 95.2% |

## Raw Output

Full JSONL output: [codex-raw-output.jsonl](codex-raw-output.jsonl)
Readable extraction: [codex-readable-output.md](codex-readable-output.md) (empty — jq extraction missed the structured output format; use JSONL directly)

## Screenshots

No screenshots captured (automated Codex run, no browser interaction).
