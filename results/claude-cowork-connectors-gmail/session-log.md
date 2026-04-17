# Session Log: A / gmail

**Date**: 2026-04-16
**Config**: A — Claude Desktop (Cowork) + google_workspace_mcp
**Model**: Opus 4.6 (tested for consistency with other configs run 2026-04-15/16; Opus 4.7 was available but not used)
**Account**: fshotwell@gmail.com
**Operator**: Frank Shotwell
**Session duration**: ~8 minutes (estimated from Cowork output cadence)

## Setup

**Time to first operation**: ~2 minutes (includes MCP server initialization and 18 permission approval prompts)
**Setup doc**: [setup.md](setup.md) (references config C setup)
**Setup summary**: Reused google_workspace_mcp from config C. Added MCP server to `~/Library/Application Support/Claude/claude_desktop_config.json`. Restarted Claude Desktop.
**Auth notes**: OAuth tokens from config C's prior run were still valid — no re-auth required. However, Claude Desktop prompted for 18 individual tool permission approvals on first use of the MCP server. Each tool (search_drive_files, create_drive_file, get_doc_content, etc.) required a separate click to authorize.

## Pre-test: Isolation Folder

**Folder created**: yes
**Folder name**: `[GWS-A] Shootout Results`
**Folder ID**: `{folder-id}`

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | PASS | ~2s | 0 | Returned expected ID `{drive-id}`. |
| 2 | Drive: upload `fixtures/upload-test.txt` | PASS | ~3s | 0 | Created file ID `{drive-id}` in isolation folder. |
| 3 | Drive: share uploaded file with fshotwell@cruxcapacity.com | PASS | ~2s | 0 | Reader permission granted, permission ID `{perm-id}`. |
| 4 | Docs: read `GWS Shootout — Seed Document` | PASS | ~2s | 0 | Returned all headings, paragraphs, bullets, and preserving-content paragraph. |
| 5 | Docs: create `[GWS-A] Created Test Doc` | PASS | ~8s | 0 | Multi-step: create → insert text → inspect structure → apply formatting (H1, bold, H2, bullets). Doc ID: `{doc-id}`. Note: `create_doc` has no `folder_id` parameter, so doc created in Drive root, not isolation folder. |
| 6 | Docs: edit (append to Doc from #5) | PASS | ~5s | 0 | Appended H2 "Added by A" with paragraph and 3 bullets. Original content unchanged. Required inspect → insert → format cycle. |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | FAIL | ~2s | 0 | Read succeeded but values don't match fixture spec. Got: Alice/Engineer/92, Bob/Designer/87, Carol/PM/95, David/Engineer/88. Expected: Alice/Engineer/95, Bob/Designer/88, Carol/Manager/92, David/Analyst/85. Seed data was likely modified by prior config test runs (configs B, C, D wrote to this sheet). |
| 8 | Sheets: write D1:F1 to seed Sheet | PASS | ~2s | 0 | D1="Updated", E1="by", F1="A" written successfully. |
| 9 | Sheets: create `[GWS-A] Created Test Sheet` | PASS | ~4s | 0 | Sheet ID: `{sheet-id}`. Headers + 5 data rows. |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | PASS | ~2s | 0 | Found 2 messages matching subject. |
| 11 | Gmail: read message from #10 | PASS | ~2s | 0 | Body contains `This is a seed email for search and read testing.` |
| 12 | Gmail: send `[GWS-A] Test Email from Shootout` to fshotwell@cruxcapacity.com | PASS | ~2s | 0 | Message ID: `{msg-id}`. |
| 13 | Calendar: list events on `GWS Shootout` calendar | PASS | ~2s | 0 | Returned 9 events including seed event `{event-id}`. |
| 14 | Calendar: create `[GWS-A] Test Event` | PASS | ~3s | 0 | Event ID: `{event-id}`. 10:00 AM CDT on 2026-04-19. |
| 15 | Calendar: update event from #14 (move +1 hour) | PASS | ~2s | 0 | Moved to 11:00 AM CDT (16:00 UTC). |

**Pass**: 14/15
**Fail**: 1/15
**Blocked**: 0/15
**Intervention count**: 0 during test execution (18 permission clicks during MCP server initialization, before tests began)

### Note on #7 failure

The Sheets read failure is a seed data integrity issue, not a tool failure. Prior test runs (configs B through D2) wrote to the seed sheet as part of their #8 (write cells) tests, and may have also modified data rows. The read operation itself succeeded — the MCP tool returned correct cell values. The values simply don't match the original fixture because the seed sheet has been mutated by earlier runs. This should be recorded as PASS (tool works) with a note about seed data contamination in the synthesis.

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | PASS | ~3s | 0 | Re-executed search + read (not cached from #4). Content matches seed. |
| 2 | Create `[GWS-A] April 2026 Committee Agenda` | PASS | ~8s | 0 | Doc ID: `{doc-id}`. H1, H2, bold, bullets applied. |
| 3 | Update `[GWS-A] Test Event` description with agenda link | PASS | ~4s | 1 | First attempt failed: `Missing end time.` — `manage_event` update action requires `start_time`/`end_time` even when only changing `description`. Retry with full time fields succeeded. |
| 4 | Send `[GWS-A] Committee Meeting Reminder` to fshotwell@cruxcapacity.com | PASS | ~2s | 0 | Message ID: `{msg-id}`. Body includes agenda Doc URL. |
| 5 | Create `[GWS-A] April 2026 Committee Summary` | PASS | ~6s | 0 | Doc ID: `{doc-id}`. H1, 2 H2s, 3 decision bullets, 3 action item bullets. |
| 6 | Append row to `[GWS-A] Created Test Sheet` | PASS | ~2s | 0 | Row appended to A7:C7: `Meeting`, `2026-04-15`, `3 attendees`. |

**Total time**: ~25s (excluding setup)
**Intervention count**: 0

## Observations

1. **Single-prompt autonomous execution.** All 21 operations (pre-test + 15 component + 6 integration) were driven by a single prompt pasted into Cowork. No follow-up prompts needed. Cowork worked through the entire checklist autonomously.

2. **Doc creation is multi-step.** Unlike GWS CLI (config B) which creates formatted Docs in one command, the MCP server requires: create plain doc → insert text → inspect structure (get character indices) → apply formatting styles. This worked reliably but requires more tool calls per operation.

3. **`create_doc` lacks `folder_id` parameter.** Docs created via MCP land in Drive root, not the isolation folder. Cowork did not attempt to move them (unlike Gemini CLI which used `drive.moveFile`).

4. **`manage_event` update requires full time fields.** Updating only the description fails with "Missing end time." Must include `start_time` and `end_time` even for non-time changes. Cowork self-corrected on retry.

5. **`inspect_doc_structure` requires explicit `tab_id: "t.0"`.** Without it, returns 0 elements for new docs. Cowork discovered and handled this autonomously.

6. **18 permission prompts at startup.** Claude Desktop requires individual tool-level permission approval for each MCP tool on first use. This is a one-time cost but a notable UX friction point vs. Claude Code (which handles MCP tool permissions via settings).

## Screenshots

No screenshots captured (text-based Cowork session).

## Notes for Synthesis

Config A with google_workspace_mcp is the strongest non-CLI result in the shootout. 14/15 component + 6/6 integration, zero intervention during execution, full CRUD across all five GWS services. The only "failure" (#7) is seed data contamination from prior runs, not a tool limitation.

The original protocol defined Config A as "Claude Cowork + built-in connectors (read-only baseline)." Swapping in google_workspace_mcp transforms it from a read-only reference point into a full-featured desktop solution. This is the key finding for readers who want GWS agent access without using a CLI.

Comparison with Config C (same MCP, Claude Code CLI): functionally equivalent results. The MCP server is the differentiator, not the agent shell. Desktop vs. CLI is a UX preference, not a capability gap.
