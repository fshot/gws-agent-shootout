# Session Log: F / @gmail.com

**Date**: 2026-04-16
**Config**: F — ChatGPT (Thinking 5.4) + Google Drive/Calendar/Gmail connectors
**Account**: fshotwell@gmail.com
**Operator**: Frank Shotwell
**Session duration**: ~12 minutes wall clock (0.4m tool execution time reported by ChatGPT)

## Setup

**Time to first operation**: ~5 minutes (includes failed desktop app attempt, switching to web UI, connecting apps, first "Instant" attempt that returned all FAILs, switching to "Thinking" model)
**Setup doc**: [setup.md](setup.md)
**Setup summary**: Desktop app OAuth broken (NSURLErrorDomain -1100). Connected via web UI. "Instant 5.3" model returned 0/15 without trying. Switched to "Thinking 5.4" which actually used tools.
**Auth notes**: OAuth worked in browser but failed in macOS desktop app. Every tool call during testing required manual approval via modal dialog (~8 approvals total).

## Pre-test: Isolation Folder

**Folder created**: No
**Folder name**: `[GWS-F] Shootout Results`
**Folder ID**: N/A — No Drive folder-create action available in connected tools

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | PASS | 0.3s | 0 | Found file with ID `{drive-id}` — matches seed fixture |
| 2 | Drive: upload `fixtures/upload-test.txt` | FAIL | — | 0 | No plain-text file upload action available; Drive create supports only native Doc/Sheet/Slide files |
| 3 | Drive: share uploaded file with fshotwell@cruxcapacity.com | BLOCKED (by #2) | — | 0 | Source file from #2 was not created |
| 4 | Docs: read `GWS Shootout — Seed Document` | PASS | 1.2s | 0 | Content included `Seed Document`, `Section One`, `Section Two`, 3 bullets, preserve-content paragraph |
| 5 | Docs: create `[GWS-F] Created Test Doc` | PASS | 3.2s | 0 | Created Doc `{doc-id}`; verified H1, H2, bullets, bold labels |
| 6 | Docs: edit (append to Doc from #5) | PASS | 1.6s | 0 | Appended `Added by F` section; original content remained intact |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | FAIL | 1.8s | 0 | Read succeeded but returned `Alice Chen/Engineer/92`, `Bob Martinez/Designer/87`, `Carol Johnson/PM/95`, `David Kim/Engineer/88` — does not match expected fixture data (likely modified by prior test runs) |
| 8 | Sheets: write D1:F1 to seed Sheet | PASS | 1.6s | 0 | Wrote `Updated`, `by`, `F` to D1:F1; verified on readback |
| 9 | Sheets: create `[GWS-F] Created Test Sheet` | PASS | 3.3s | 0 | Created spreadsheet `{sheet-id}` with header + 5 data rows |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | PASS | 0.5s | 0 | Found seed email thread |
| 11 | Gmail: read message from #10 | PASS | 0.3s | 0 | Body contained `This is a seed email for search and read testing.` |
| 12 | Gmail: send `[GWS-F] Test Email` to fshotwell@cruxcapacity.com | PASS | 0.8s | 0 | Sent with correct subject and body |
| 13 | Calendar: list events on `GWS Shootout` calendar | PASS | 0.3s | 0 | Listed events; included `GWS Shootout — Seed Event` |
| 14 | Calendar: create `[GWS-F] Test Event` | FAIL | — | 0 | Create-event action does not expose `calendar_id`; cannot target non-primary `GWS Shootout` calendar |
| 15 | Calendar: update event from #14 | BLOCKED (by #14) | — | 0 | Test event not created |

**Pass**: 10/15
**Fail**: 3/15
**Blocked**: 2/15
**Intervention count**: ~8 (all tool-approval modal dialogs; no error recovery interventions)

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | PASS | 2.0s | 0 | Found and read matching seed content |
| 2 | Create `[GWS-F] April 2026 Committee Agenda` | PASS | 2.4s | 0 | Created agenda Doc `{doc-id}` with requested formatting |
| 3 | Update `[GWS-F] Test Event` description with agenda link | BLOCKED (by #14) | — | 0 | No `[GWS-F] Test Event` existed on target calendar |
| 4 | Send `[GWS-F] Committee Meeting Reminder` to fshotwell@cruxcapacity.com | PASS | 0.7s | 0 | Sent with agenda Doc URL in body |
| 5 | Create `[GWS-F] April 2026 Committee Summary` | PASS | 2.0s | 0 | Created summary Doc `{doc-id}` with H1, decisions bullets, action items |
| 6 | Append row to `[GWS-F] Created Test Sheet` | PASS | 1.5s | 0 | Appended `Meeting`, `2026-04-15`, `3 attendees`; verified on readback |

**Total time**: ~12 minutes wall clock
**Intervention count**: included in component test count above

## Raw Output

ChatGPT web UI does not provide raw API output. Results above are from ChatGPT's self-reported results table.

## Screenshots

- `screenshots/` — OAuth consent screens, NSURLErrorDomain error, model selector, tool approval dialogs (captured via CleanShot)

## Notable Observations

1. No isolation folder created — all Docs/Sheets created in Drive root (no folder-create capability).
2. Created artifacts not prefixed with isolation folder path since folder creation failed.
3. Test #7 (Sheets read) returned data that doesn't match the seed fixture — likely modified by prior test runs writing to D1:F1, or ChatGPT read stale/cached data. The read itself succeeded; the mismatch is in the A1:C5 values.
4. Gmail access worked despite not being explicitly listed as a connected app in Settings > Apps.
5. Tool execution times reported by ChatGPT are fast (0.3s–3.3s per operation) but total wall-clock time was ~12 min due to mandatory per-action approval prompts.
