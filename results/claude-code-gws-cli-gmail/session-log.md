# Session Log: B / gmail

**Date**: 2026-04-15
**Config**: B — Claude Code + GWS CLI
**Account**: fshotwell@gmail.com
**Operator**: Frank Shotwell
**Session duration**: 14:06 — 14:11 (5 minutes)

## Setup

**Time to first operation**: <1 min (GWS CLI already installed and authenticated)
**Setup doc**: [setup.md](setup.md) (detailed install/config steps)
**Setup summary**: Reused existing GWS CLI installation (v0.22.5). Profile-based auth via `GOOGLE_WORKSPACE_CLI_CONFIG_DIR=~/.config/gws/profiles/gmail`.
**Auth notes**: No auth prompts during test run. Token was valid from prior session.

## Pre-test: Isolation Folder

**Folder created**: yes
**Folder name**: `[GWS-B] Shootout Results`
**Folder ID**: `{folder-id}`

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | PASS | 1s | 0 | Found file, ID matches seed-ids-gmail.json (`{drive-id}`) |
| 2 | Drive: upload `fixtures/upload-test.txt` | PASS | 1s | 0 | Uploaded as `[GWS-B] Uploaded Test File`, 313 bytes, ID `{drive-id}` |
| 3 | Drive: share uploaded file with fshotwell@cruxcapacity.com | PASS | 2s | 0 | Shared as reader, permission ID `{perm-id}` |
| 4 | Docs: read `GWS Shootout — Seed Document` | PASS | 1s | 0 | Exported as text/plain (639 bytes). Content matches fixtures/seed-doc-content.md: headings, paragraphs, bullet items all present. |
| 5 | Docs: create `[GWS-B] Created Test Doc` | PASS | 4s | 0 | Created with H1, H2, bold text, bullet lists. ID `{drive-id}`. Moved to isolation folder. |
| 6 | Docs: edit (append to Doc from #5) | PASS | 2s | 0 | Appended H2 "Added by B" with paragraph + 3 bullet items. Original content preserved. Verified via text export (789 bytes). |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | PASS | 1s | 0 | Values match fixtures/seed-sheet-data.csv exactly. 5 rows, 3 columns. |
| 8 | Sheets: write D1:F1 to seed Sheet | PASS | 1s | 0 | Wrote `"Updated", "by", "B"` to D1:F1. 3 cells updated. |
| 9 | Sheets: create `[GWS-B] Created Test Sheet` | PASS | 3s | 0 | Created with 24 cells (6 rows x 4 columns) from fixtures/create-sheet-data.csv. ID `{sheet-id}`. Moved to isolation folder. |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | PASS | 1s | 0 | Found 2 messages (sent + received). Thread ID `{msg-id}`. |
| 11 | Gmail: read message from #10 | PASS | 1s | 0 | Body: `This is a seed email for search and read testing.` Matches expected content. Used `gws gmail +read` helper. |
| 12 | Gmail: send `[GWS-B] Test Email` to fshotwell@cruxcapacity.com | PASS | 2s | 0 | Sent, message ID `{msg-id}`. Body includes agent name, connector, and UTC timestamp. Used `gws gmail +send` helper. |
| 13 | Calendar: list events on `GWS Shootout` calendar | PASS | 2s | 0 | Found 1 event: `GWS Shootout — Seed Event` at 2026-04-22T17:00:00Z. |
| 14 | Calendar: create `[GWS-B] Test Event` | PASS | <1s | 0 | Created on GWS Shootout calendar, 60 min, 2026-04-18 10:00 PT. ID `{event-id}`. |
| 15 | Calendar: update event from #14 (move +1 hour) | PASS | 1s | 0 | Moved from 10:00 to 11:00 PT (17:00Z → 18:00Z). |

**Pass**: 15/15
**Fail**: 0/15
**Blocked**: 0/15
**Intervention count**: 0

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | PASS | 2s | 0 | Found by name search, read via text export. |
| 2 | Create `[GWS-B] April 2026 Committee Agenda` | PASS | 4s | 0 | Created with H1, H2, bullets. Content from fixtures/create-doc-content.md. ID `{doc-id}`. Moved to isolation folder. |
| 3 | Update `[GWS-B] Test Event` description with agenda link | PASS | 1s | 0 | Patched event description to include Google Docs URL. |
| 4 | Send `[GWS-B] Committee Meeting Reminder` to fshotwell@cruxcapacity.com | PASS | 2s | 0 | Sent with agenda link in body. Message ID `{msg-id}`. |
| 5 | Create `[GWS-B] April 2026 Committee Summary` | PASS | 13s | 0 | Created with H1, H2 (Decisions + Action Items), 6 bullet items. ID `{drive-id}`. Moved to isolation folder. |
| 6 | Append row to `[GWS-B] Created Test Sheet` | PASS | 1s | 0 | Appended `"Meeting", "2026-04-15", "3 attendees"` at A7:C7. Used `spreadsheets values append` API (the `+append` helper's `--id` flag was wrong, `--spreadsheet` is correct). |

**Total time**: ~23s
**Intervention count**: 0

## Artifact IDs

| Artifact | ID |
|----------|----|
| Isolation folder | `{folder-id}` |
| Uploaded test file | `{drive-id}` |
| Created test Doc | `{doc-id}` |
| Created test Sheet | `{sheet-id}` |
| Test event | `{event-id}` |
| Agenda Doc | `{doc-id}` |
| Summary Doc | `{doc-id}` |
| Test email | `{msg-id}` |
| Reminder email | `{msg-id}` |

## Screenshots

No screenshots captured for this run (CLI-only, no browser UI involved).
