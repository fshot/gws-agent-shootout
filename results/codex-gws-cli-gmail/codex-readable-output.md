I’m reading the repo instructions and fixture files first, then I’ll run the `gws` operations in the required order and capture timings, retries, and verbatim errors.
I have the protocol. Next I’m inspecting the fixture contents and the `gws` CLI surface so I can execute the operations without deviating from the required tool path.
I’ve got the fixtures and seeded IDs. Now I’m checking the exact `gws` method shapes for Drive, Docs, Sheets, Gmail, and Calendar so the test run stays within the CLI’s supported surface.
I have enough context to start the run. I’m now building the artifact IDs in sequence: isolation folder first, then the component tests in order, while capturing exact stderr/stdout for each operation and only retrying on the specified transient classes.
I’m about to execute the actual write operations. The run will create the isolation folder, then drive/doc/sheet/gmail/calendar artifacts in order, and I’ll preserve any verbatim API errors instead of normalizing them.
The run is in progress. I’ve started the sequential API calls and I’m waiting on the write-heavy middle section where Docs, Sheets, Gmail, and Calendar mutations happen.
I’m still in the active run. There’s no final report yet, which suggests one of the live API calls or the script’s later steps is still executing rather than failing fast.
I finished one pass and found CLI-invocation errors on my side, not API-side failures: `gws` expects nested subcommands for Sheets, and uploads must stay under the working tree. I’m correcting the command forms and rerunning the protocol cleanly so the final report reflects an actual tool run rather than my bad invocation.
I’m validating the remaining edge cases before the rerun: Sheets subcommand shape, Gmail search target, and a repo-local upload path so the CLI accepts the media file.
I’ve validated the correct `gws` forms. I’m rerunning the full protocol now with the corrected Sheets commands, a repo-local upload file, and the Gmail read path wired to the thread search result.
The corrected run is still active. At this point it’s likely in the later Docs/Gmail/Calendar calls rather than failing immediately, which is what I wanted before collecting the final report.
## Component Test Results
| # | Operation | Result | Time | Retries | Error |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search | PASS | 1s | 0 |  |
| 2 | Drive: upload | PASS | 1s | 0 |  |
| 3 | Drive: share | PASS | 3s | 0 |  |
| 4 | Docs: read | PASS | 0s | 0 |  |
| 5 | Docs: create | PASS | 3s | 0 |  |
| 6 | Docs: edit | PASS | 1s | 0 |  |
| 7 | Sheets: read | PASS | 1s | 0 |  |
| 8 | Sheets: write | PASS | 0s | 0 |  |
| 9 | Sheets: create | PASS | 3s | 0 |  |
| 10 | Gmail: search | PASS | 1s | 0 |  |
| 11 | Gmail: read | PASS | 1s | 0 |  |
| 12 | Gmail: send | PASS | 1s | 0 |  |
| 13 | Calendar: list | PASS | 1s | 0 |  |
| 14 | Calendar: create | PASS | 0s | 0 |  |
| 15 | Calendar: update | PASS | 1s | 0 |  |

## Integration Test Results
| Step | Operation | Result | Time | Retries | Error |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive for `GWS Shootout — Seed Document`, read its content | PASS | 2s | 0 |  |
| 2 | Create `[GWS-D] April 2026 Committee Agenda` using `fixtures/create-doc-content.md` | PASS | 2s | 0 |  |
| 3 | Add agenda Doc URL to description of `[GWS-D] Test Event` | PASS | 1s | 0 |  |
| 4 | Send `[GWS-D] Committee Meeting Reminder` to other account with agenda link | PASS | 1s | 0 |  |
| 5 | Create `[GWS-D] April 2026 Committee Summary` with decisions + action items | PASS | 2s | 0 |  |
| 6 | Append row `"Meeting", "2026-04-15", "3 attendees"` to `[GWS-D] Created Test Sheet` | PASS | 1s | 0 |  |

## Summary
Pass: 15/15
Fail: 0/15
Blocked: 0/15
Integration: 6/6
Total time: 1m
