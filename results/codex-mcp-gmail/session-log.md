# Session Log: D2 / @gmail.com

**Date**: 2026-04-15
**Config**: D2 — Codex CLI + google_workspace_mcp
**Account**: fshotwell@gmail.com
**Operator**: Frank Shotwell
**Session duration**: 17:24:04 — 17:27:38 PDT (3m 34s)

## Setup

**Time to first operation**: ~1m (Codex read AGENTS.md, fixtures, then started operations)
**Setup doc**: [setup.md](setup.md) (detailed install/config steps)
**Setup summary**: Reused MCP server installation from config C. Added MCP to Codex via `codex mcp add`. OAuth tokens cached from config C's gmail run.
**Auth notes**: No auth prompts during test run. Cached credentials from config C were still valid.

## Pre-test: Isolation Folder

**Folder created**: yes
**Folder name**: `[GWS-D2] Shootout Results`
**Folder ID**: `{folder-id}`

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | PASS | 2s | 0 | Found file ID `{drive-id}`, matches seed-ids-gmail.json |
| 2 | Drive: upload `fixtures/upload-test.txt` | PASS | 2s | 0 | Uploaded to isolation folder |
| 3 | Drive: share uploaded file with fshotwell@cruxcapacity.com | PASS | 2s | 0 | Shared as reader |
| 4 | Docs: read `GWS Shootout — Seed Document` | PASS | 2s | 0 | Content matches seed-doc-content.md |
| 5 | Docs: create `[GWS-D2] Created Test Doc` | PASS | 3s | 0 | Used `import_to_google_doc` with fixture markdown |
| 6 | Docs: edit (append to Doc from #5) | PASS | 9s | 0 | Appended H2 "Added by D2" with paragraph and 3 bullets via `insert_doc_elements` |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | PASS | 2s | 0 | Values match seed-sheet-data.csv |
| 8 | Sheets: write D1:F1 to seed Sheet | PASS | 1s | 0 | Wrote `Updated, by, D2` |
| 9 | Sheets: create `[GWS-D2] Created Test Sheet` | PASS | 6s | 0 | Created with fixture CSV data in isolation folder |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | PASS | 2s | 0 | Found seed email thread |
| 11 | Gmail: read message from #10 | PASS | 2s | 0 | Body contains expected seed email text |
| 12 | Gmail: send `[GWS-D2] Test Email` to fshotwell@cruxcapacity.com | PASS | 3s | 0 | Message ID: `{msg-id}` |
| 13 | Calendar: list events on `GWS Shootout` calendar | PASS | 3s | 0 | Found seed event and events from prior configs |
| 14 | Calendar: create `[GWS-D2] Test Event` | PASS | 2s | 0 | Event ID: `{event-id}`, 2026-04-18 09:00-10:00 PDT |
| 15 | Calendar: update event from #14 (move +1 hour) | PASS | 2s | 0 | Moved to 10:00-11:00 PDT |

**Pass**: 15/15
**Fail**: 0/15
**Blocked**: 0/15
**Intervention count**: 0

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | PASS | 4s | 0 | Found and read seed doc content |
| 2 | Create `[GWS-D2] April 2026 Committee Agenda` | PASS | 3s | 0 | Doc ID: `{doc-id}` |
| 3 | Update `[GWS-D2] Test Event` description with agenda link | PASS | 5s | 1 | First attempt failed: `manage_event` update with only `description` field returned `HttpError 400: Missing end time.` Retry with `start_time` and `end_time` fields included succeeded. |
| 4 | Send `[GWS-D2] Committee Meeting Reminder` to fshotwell@cruxcapacity.com | PASS | 3s | 0 | Message ID: `{msg-id}` |
| 5 | Create `[GWS-D2] April 2026 Committee Summary` | PASS | 3s | 0 | Doc ID: `{doc-id}` |
| 6 | Append row to `[GWS-D2] Created Test Sheet` | PASS | 2s | 0 | Row `Meeting, 2026-04-15, 3 attendees` written to A7:C7 |

**Total time**: 3m 34s wall clock
**Intervention count**: 0

## Token Usage

| Metric | Value |
|--------|-------|
| Input tokens | 1,244,133 |
| Cached input tokens | 1,196,928 |
| Output tokens | 6,998 |
| Cache hit rate | 96.2% |

## Raw Output

Full JSONL output: [codex-raw-output.jsonl](codex-raw-output.jsonl)
Readable extraction: [codex-readable-output.md](codex-readable-output.md)

## Screenshots

No screenshots captured (automated Codex run, no browser interaction).
