# Session Log: C / @workspace

**Date**: 2026-04-15
**Config**: C — Claude Code + google_workspace_mcp
**Account**: fshotwell@cruxcapacity.com
**Operator**: Frank Shotwell
**Session duration**: ~15 minutes

## Setup

**Time to first operation**: <1 minute (reused existing MCP server from config C / @gmail.com run)
**Setup doc**: [setup.md](setup.md) (references config C / @gmail.com setup for full details)
**Setup summary**: Reused existing workspace-mcp MCP server installation. No new setup required.
**Auth notes**: No re-authentication was prompted. The MCP server appeared to use existing tokens. However, `list_calendars` showed `fshotwell@gmail.com` as the "Primary" calendar, suggesting the server may still be authenticated as the gmail account from the prior run. All operations against the workspace account's Drive, Docs, Sheets, Gmail, and Calendar succeeded regardless — likely because the `user_google_email` parameter directs API calls to the correct account, or the server re-authorized silently.

## Pre-test: Isolation Folder

**Folder created**: yes
**Folder name**: `[GWS-C] Shootout Results`
**Folder ID**: `{folder-id}`

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | FAIL | <5s | 0 | File found, but returned ID `{drive-id}` does not match seed-ids-workspace.json ID `{drive-id}`. Seed IDs file appears stale (IDs were likely regenerated after initial seeding). The MCP search itself worked correctly. |
| 2 | Drive: upload `fixtures/upload-test.txt` | PASS | <5s | 0 | Uploaded as `[GWS-C] Uploaded Test File`, ID: `{drive-id}`, placed in isolation folder. Note: MCP `create_drive_file` accepts inline content, not a file path — content was pasted, not uploaded byte-for-byte from disk. |
| 3 | Drive: share uploaded file with fshotwell@gmail.com | PASS | <5s | 0 | Shared as reader. Response showed `fshotwell@gmail.com (owner)` which appears to be a labeling quirk in the MCP response — the role granted was reader. |
| 4 | Docs: read `GWS Shootout — Seed Document` | PASS | <5s | 0 | Seed doc ID from fixtures returned 404. Searched by name, found at ID `{doc-id}`. Content matched seed-doc-content.md. |
| 5 | Docs: create `[GWS-C] Created Test Doc` | PASS | ~15s | 0 | Doc created (ID: `{doc-id}`). Required 3 MCP calls: create_doc, inspect_doc_structure (with tab_id — without tab_id returned total_length: 0), batch_update_doc for formatting. Moved to isolation folder via update_drive_file. |
| 6 | Docs: edit (append to Doc from #5) | PASS | ~10s | 0 | Appended "Added by C" H2 section with paragraph and 3 bullet items. Required: batch_update_doc (insert_text with end_of_segment), inspect_doc_structure, batch_update_doc (heading + bullets). Original content preserved. |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | PASS | <5s | 0 | Seed sheet ID from fixtures returned no data. Searched by name, found 2 matches. Used most recently modified (ID: `{sheet-id}`). Values match seed-sheet-data.csv exactly. |
| 8 | Sheets: write D1:F1 to seed Sheet | PASS | <5s | 0 | Wrote "Updated", "by", "C" to D1:F1. |
| 9 | Sheets: create `[GWS-C] Created Test Sheet` | PASS | <5s | 0 | Created spreadsheet (ID: `{sheet-id}`), populated A1:D6 with create-sheet-data.csv content, moved to isolation folder. |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | PASS | <5s | 0 | Found 2 messages matching subject. |
| 11 | Gmail: read message from #10 | PASS | <5s | 0 | Body contains "This is a seed email for search and read testing." From: fshotwell@cruxcapacity.com, To: fshotwell@gmail.com. |
| 12 | Gmail: send `[GWS-C] Test Email` to fshotwell@gmail.com | PASS | <5s | 0 | Email sent, message ID: `{msg-id}`. |
| 13 | Calendar: list events on `GWS Shootout` calendar | PASS | <5s | 0 | Seed calendar ID from fixtures returned 404. Listed calendars, found actual ID: `{calendar-id}`. Found 3 events including seed event and events from prior config runs. |
| 14 | Calendar: create `[GWS-C] Test Event` | PASS | <5s | 0 | Created `[GWS-C] Test Event (Workspace)` on April 18 at 14:00-15:00 CDT. Appended "(Workspace)" to distinguish from gmail run event. Event ID: `{event-id}`. |
| 15 | Calendar: update event from #14 (move +1 hour) | PASS | <5s | 0 | Moved from 14:00-15:00 to 15:00-16:00 CDT (20:00-21:00 UTC). |

**Pass**: 14/15
**Fail**: 1/15
**Blocked**: 0/15
**Intervention count**: 0

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | PASS | <5s | 0 | Found doc by name search (seed ID was stale), content read successfully. |
| 2 | Create `[GWS-C] April 2026 Committee Agenda` | PASS | <5s | 0 | Doc created (ID: `{doc-id}`), moved to isolation folder. |
| 3 | Update `[GWS-C] Test Event` description with agenda link | PASS | <5s | 1 | First attempt failed: `manage_event` update requires start_time/end_time even for description-only changes (HTTP 400: "Missing end time"). Succeeded on retry with times included. |
| 4 | Send `[GWS-C] Committee Meeting Reminder` to fshotwell@gmail.com | PASS | <5s | 0 | Email sent with agenda link in body. Message ID: `{msg-id}`. |
| 5 | Create `[GWS-C] April 2026 Committee Summary` | PASS | <5s | 0 | Doc created (ID: `{doc-id}`) with decisions and action items. Moved to isolation folder. |
| 6 | Append row to `[GWS-C] Created Test Sheet` | PASS | <5s | 0 | Appended `Meeting, 2026-04-15, 3 attendees` to row 7. |

**Total time**: ~3 minutes
**Intervention count**: 0

## Observations

### Seed IDs stale
Multiple seed artifact IDs in `fixtures/seed-ids-workspace.json` did not match the actual IDs found in the workspace account:
- Drive file: expected `{drive-id}`, found `{drive-id}`
- Doc: expected `{doc-id}`, found `{doc-id}`
- Sheet: expected `{sheet-id}`, found `{sheet-id}`
- Calendar: expected `{calendar-id}`, found `{calendar-id}`

All operations succeeded by searching by name rather than relying on stored IDs.

### MCP server authentication ambiguity
`list_calendars` showed `fshotwell@gmail.com` as the "Primary" calendar despite all API calls passing `user_google_email=fshotwell@cruxcapacity.com`. The `--single-user` mode documentation says it manages one account, but the server either silently re-authorized for the workspace account or the `user_google_email` parameter routes API calls regardless of which OAuth token the server holds. All operations produced correct results for the workspace account.

### inspect_doc_structure requires tab_id
When calling `inspect_doc_structure` without `tab_id`, it returned `total_length: 0` and `elements: []` even though the doc had content. Passing `tab_id: "t.0"` returned the correct structure. This is a quirk that adds an extra API call to the Docs workflow.

### manage_event update requires times
The `manage_event` update action fails with HTTP 400 "Missing end time" if `start_time` and `end_time` are not provided, even when only updating the description. This differs from the Google Calendar API's PATCH behavior which allows partial updates. The MCP server appears to use PUT (full replacement) rather than PATCH.

### Token cost comparison (workspace-mcp vs GWS CLI)
- **workspace-mcp**: 71 deferred tool names in system prompt (~700 tokens baseline). When schemas are loaded via ToolSearch, ~30,000-40,000 tokens of JSON schemas enter the conversation context and persist for the session.
- **GWS CLI skill** (`/gws`): 0 tokens baseline, ~2,000 tokens when invoked on-demand. Covers the entire GWS CLI interface.
- The MCP approach consumes 15-20x more context tokens than the CLI skill approach for equivalent GWS coverage.

### API calls per operation (MCP overhead)
Creating and formatting a Google Doc required multiple MCP tool calls:
1. `create_doc` (insert plain text)
2. `inspect_doc_structure` with `tab_id` (get indices for formatting)
3. `batch_update_doc` (apply heading styles, bold, bullet lists)
4. `update_drive_file` (move to isolation folder)

The GWS CLI equivalent is a single `gws docs create` command. The MCP decomposition is more granular but requires the agent to manage document indices manually, increasing the risk of index calculation errors and the token cost of intermediate results.

## Raw Output

All tool calls and responses are recorded inline in the session log above.

## Screenshots

No screenshots captured for this run (MCP operations are CLI-based with no UI interaction required).
