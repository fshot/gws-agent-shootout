# Session Log: C / @gmail.com

**Date**: 2026-04-15
**Config**: C — Claude Code + google_workspace_mcp
**Account**: fshotwell@gmail.com
**Operator**: Frank Shotwell
**Session duration**: 15:02 — 15:13 (11 minutes)

## Setup

**Time to first operation**: ~1 min (MCP server already running from prior session setup)
**Setup doc**: [setup.md](setup.md) (detailed install/config steps including prior-session debugging)
**Setup summary**: Reused existing local installation of google_workspace_mcp at `/Users/fshot/code/google_workspace_mcp/`. MCP server already registered in Claude Code from prior session. GCP project and OAuth client reused from config B.
**Auth notes**: Sheets API triggered a re-authorization mid-test at component test #7. User had to click an OAuth URL and re-consent to add Sheets scopes. This is due to workspace-mcp's incremental scope authorization — it doesn't request all scopes upfront. All subsequent API calls (Gmail, Calendar) worked without further auth prompts, suggesting the re-auth at test #7 added all remaining scopes in one batch.

## Pre-test: Isolation Folder

**Folder created**: yes
**Folder name**: `[GWS-C] Shootout Results`
**Folder ID**: `{folder-id}`

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | PASS | 15:03:22 | 0 | Found file ID `{drive-id}`, matches seed-ids-gmail.json |
| 2 | Drive: upload `fixtures/upload-test.txt` | PASS | 15:03:27 | 0 | Used `create_drive_file` with `fileUrl` param (file:// protocol). Content verified byte-for-byte via `get_drive_file_content`. File ID: `{drive-id}` |
| 3 | Drive: share uploaded file with fshotwell@cruxcapacity.com | PASS | 15:03:38 | 0 | Used `manage_drive_access` grant action. Permission ID: `{perm-id}` |
| 4 | Docs: read `GWS Shootout — Seed Document` | PASS | 15:03:48 | 0 | Used `get_doc_as_markdown`. All headings, paragraphs, and bullet items match `fixtures/seed-doc-content.md` |
| 5 | Docs: create `[GWS-C] Created Test Doc` | PASS | 15:03:56 | 0 | Created via `create_doc` + `batch_update_doc` (12 insert_text ops) + second `batch_update_doc` (9 formatting ops: H1, H2, bold, bullet lists). Moved to isolation folder via `update_drive_file`. Doc ID: `{doc-id}` |
| 6 | Docs: edit (append to Doc from #5) | PASS | 15:04:33 | 0 | Appended H2 "Added by C" + paragraph + 3 bullet items via `batch_update_doc`. Verified original content preserved via `get_doc_as_markdown` |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | PASS | 15:09:54 | 1 | **First attempt failed: auth required for Sheets scopes.** Server returned OAuth URL. User clicked link, completed consent (~6 min intervention). Retry succeeded. Values match seed-sheet-data.csv: Headers `Name, Role, Score` + 4 data rows |
| 8 | Sheets: write D1:F1 to seed Sheet | PASS | 15:10:02 | 0 | Wrote `["Updated", "by", "C"]` to D1:F1 via `modify_sheet_values` |
| 9 | Sheets: create `[GWS-C] Created Test Sheet` | PASS | 15:10:14 | 0 | Created via `create_spreadsheet` + `modify_sheet_values` (6 rows x 4 cols from create-sheet-data.csv). Moved to isolation folder. Sheet ID: `{folder-id}` |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | PASS | 15:10:32 | 0 | Found 2 messages. Message ID: `{msg-id}` |
| 11 | Gmail: read message from #10 | PASS | 15:10:37 | 0 | Body contains `This is a seed email for search and read testing.` From: fshotwell@cruxcapacity.com |
| 12 | Gmail: send `[GWS-C] Test Email` to fshotwell@cruxcapacity.com | PASS | 15:10:42 | 0 | Message ID: `{msg-id}` |
| 13 | Calendar: list events on `GWS Shootout` calendar | PASS | 15:10:48 | 0 | Found 2 events: seed event (`{event-id}`, matches seed-ids) and config B's test event (cross-config visibility confirmed) |
| 14 | Calendar: create `[GWS-C] Test Event` | PASS | 15:10:57 | 0 | Event created. ID: `{event-id}` |
| 15 | Calendar: update event from #14 (move +1 hour) | PASS | 15:11:09 | 0 | Moved from 15:00-16:00 to 16:00-17:00 CDT |

**Pass**: 15/15
**Fail**: 0/15
**Blocked**: 0/15
**Intervention count**: 1 (Sheets OAuth re-auth at test #7)

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | PASS | 15:11:20 | 0 | Found via `search_drive_files`, read via `get_doc_as_markdown`. Content matches seed |
| 2 | Create `[GWS-C] April 2026 Committee Agenda` | PASS | 15:11:33 | 0 | Created with `create_doc` + `batch_update_doc` (12 inserts + 9 format ops). Full formatting: H1, H2, bold, bullet lists. Moved to isolation folder. Doc ID: `{folder-id}` |
| 3 | Update `[GWS-C] Test Event` description with agenda link | PASS | 15:12:09 | 1 | First attempt failed: `manage_event` update requires start/end time even for description-only changes (API error: "Missing end time"). Retry with times included succeeded |
| 4 | Send `[GWS-C] Committee Meeting Reminder` to fshotwell@cruxcapacity.com | PASS | 15:12:27 | 0 | Message ID: `{msg-id}`. Body includes agenda Doc link |
| 5 | Create `[GWS-C] April 2026 Committee Summary` | PASS | 15:12:34 | 0 | Created with H1 title, H2 "Decisions" (3 bullet items), H2 "Action Items" (3 bullet items). Moved to isolation folder. Doc ID: `{folder-id}` |
| 6 | Append row to `[GWS-C] Created Test Sheet` | PASS | 15:13:13 | 0 | Wrote `Meeting, 2026-04-15, 3 attendees` to row 7 via `modify_sheet_values` |

**Total time**: ~2 minutes (15:11:20 — 15:13:20)
**Intervention count**: 0

## Raw Output

### Artifacts created during this run

| Artifact | Type | ID | Location |
|----------|------|----|----------|
| Isolation folder | Drive folder | `{folder-id}` | My Drive root |
| Uploaded test file | Drive file | `{drive-id}` | Isolation folder |
| Created Test Doc | Google Doc | `{doc-id}` | Isolation folder |
| Created Test Sheet | Google Sheet | `{sheet-id}` | Isolation folder |
| Test Event | Calendar event | `{event-id}` | GWS Shootout calendar |
| Test Email | Gmail message | `{msg-id}` | Sent |
| Committee Agenda | Google Doc | `{doc-id}` | Isolation folder |
| Committee Summary | Google Doc | `{doc-id}` | Isolation folder |
| Reminder Email | Gmail message | `{msg-id}` | Sent |

### Notable API behaviors

1. **`create_drive_file` supports `fileUrl` with `file://` protocol** — enables local file upload without reading content into the prompt. This is more efficient than passing content as a string parameter.

2. **Doc creation is a multi-step process**: `create_doc` creates an empty doc, then `batch_update_doc` with `end_of_segment: true` inserts text sequentially, then `inspect_doc_structure` gets exact indices, then a second `batch_update_doc` applies formatting. This is 4 API round-trips per formatted doc vs. a single `gws docs create --from-markdown` in config B.

3. **`manage_event` update requires start/end time** even when only changing the description. The Calendar API returns "Missing end time" error without them. This is a quirk of the MCP tool's implementation — it sends a full event body rather than a partial update.

4. **Incremental OAuth scoping**: Drive, Docs, Gmail, and Calendar all worked without additional auth prompts. Only Sheets triggered a re-auth. After the Sheets re-auth, the token included all scopes (the consent screen showed the full scope list), so subsequent services worked without interruption.

## Screenshots

(No screenshots captured during this automated session.)
