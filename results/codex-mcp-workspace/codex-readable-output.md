I’m loading the repo instructions and fixture contents first, then I’ll execute the D2 run strictly with the Google Workspace MCP tools and capture timings, retries, and verbatim errors.

I’ve got the fixture data and seed IDs. Next I’m creating the isolation folder, then I’ll run the 15 component tests in order and keep the integration steps dependent on those outcomes.

I’m starting the Workspace operations now. I’ll keep artifact IDs as I go so dependent tests and the final report stay consistent.

I’m editing the created doc now. I’ll append the new content first, then apply heading and list formatting so the operation stays within the Docs MCP flow rather than treating markdown as a workaround.

The Sheets read hit a transient 503. I’m following the protocol now: 30-second wait, then a retry, up to two retries total if needed.

The component run is complete apart from final bookkeeping. I’m moving into the six integration steps now, reusing the event and sheet created earlier and marking dependencies if any later step is blocked.

The event description update exposed a required-field constraint in `manage_event`. I’m reissuing that integration step with the existing start and end times included so the operation is still tested through the same MCP path.

The run is finished. I’m compiling the structured report now with the retry/error details preserved, including the transient Sheets 503 and the Calendar update validation error encountered during integration step 3.

## Component Test Results
| # | Operation | Result | Time | Retries | Error |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search | PASS | 1s | 0 | |
| 2 | Drive: upload | PASS | 1s | 0 | |
| 3 | Drive: share | PASS | 1s | 0 | |
| 4 | Docs: read | PASS | 2s | 0 | |
| 5 | Docs: create | PASS | 2s | 0 | |
| 6 | Docs: edit | PASS | 4s | 0 | |
| 7 | Sheets: read | PASS | 31s | 1 | `Error calling tool 'read_sheet_values': API error in read_sheet_values: <HttpError 503 when requesting https://sheets.googleapis.com/v4/spreadsheets/{sheet-id}/values/A1%3AC5?alt=json returned "The service is currently unavailable.". Details: "The service is currently unavailable.">` |
| 8 | Sheets: write | PASS | 1s | 0 | |
| 9 | Sheets: create | PASS | 3s | 0 | |
| 10 | Gmail: search | PASS | 1s | 0 | |
| 11 | Gmail: read | PASS | 1s | 0 | |
| 12 | Gmail: send | PASS | 1s | 0 | |
| 13 | Calendar: list | PASS | 1s | 0 | |
| 14 | Calendar: create | PASS | 1s | 0 | |
| 15 | Calendar: update | PASS | 1s | 0 | |

## Integration Test Results
| Step | Operation | Result | Time | Retries | Error |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive for `GWS Shootout — Seed Document`, read its content | PASS | 2s | 0 | |
| 2 | Create `[GWS-D2] April 2026 Committee Agenda` using `fixtures/create-doc-content.md` | PASS | 2s | 0 | |
| 3 | Add agenda Doc URL to description of `[GWS-D2] Test Event` | PASS | 2s | 0 | `Error calling tool 'manage_event': API error in manage_event: <HttpError 400 when requesting https://www.googleapis.com/calendar/v3/calendars/c_a8f7b5d52e5817ebed8cdc56c81bde235e4e4e1d7b79866ed090cbbaa8fa6c28%40group.calendar.google.com/events/{event-id}?conferenceDataVersion=1&alt=json returned "Missing end time.". Details: "[{'domain': 'global', 'reason': 'required', 'message': 'Missing end time.'}]">` |
| 4 | Send `[GWS-D2] Committee Meeting Reminder` to other account with agenda link | PASS | 1s | 0 | |
| 5 | Create `[GWS-D2] April 2026 Committee Summary` with decisions + action items | PASS | 2s | 0 | |
| 6 | Append row `"Meeting", "2026-04-15", "3 attendees"` to `[GWS-D2] Created Test Sheet` | PASS | 1s | 0 | |

## Summary
Pass: 15/15
Fail: 0/15
Blocked: 0/15
Integration: 6/6
Total time: 1m

