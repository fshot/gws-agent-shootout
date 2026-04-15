# GWS Agent Shootout — Codex CLI Instructions

You are running a structured test of Google Workspace access via Codex CLI. Follow these instructions exactly.

## Your role

You are executing one test run of the GWS Agent Shootout protocol. You will be given a config ID (D or D2) and an account (gmail or workspace). Your job is to run all 15 component tests and 6 integration test steps, recording results in the exact format specified below.

## Test accounts

- **gmail**: `fshotwell@gmail.com` (free personal account)
- **workspace**: `fshotwell@cruxcapacity.com` (paid Google Workspace account)
- When sharing or emailing, target the *other* account.

## Connector

- **Config D**: Use the `gws` CLI command for all operations. It should already be installed and authenticated.
- **Config D2**: Use the google_workspace_mcp MCP server tools for all operations. They should already be configured.

## Naming convention

Prefix all created artifacts with `[GWS-{CONFIG}]`:
- Drive/Docs/Sheets: `[GWS-D] Description` or `[GWS-D2] Description`
- Calendar events: `[GWS-D] Description` or `[GWS-D2] Description`
- Email subjects: `[GWS-D] Description` or `[GWS-D2] Description`

## Pre-test step

Create a Drive isolation folder: `[GWS-{CONFIG}] Shootout Results`. Put all created files in this folder.

## Component tests

Execute these in order. For each, record: result (PASS/FAIL/BLOCKED), wall-clock time, retry count, and any error output.

| # | Operation | Test data |
|---|-----------|-----------|
| 1 | Drive: search | Search for `gws-shootout-seed.txt` |
| 2 | Drive: upload | Upload `fixtures/upload-test.txt` as `[GWS-{CONFIG}] Uploaded Test File` into isolation folder |
| 3 | Drive: share | Share uploaded file with the other test account as Viewer |
| 4 | Docs: read | Read `GWS Shootout — Seed Document` |
| 5 | Docs: create | Create `[GWS-{CONFIG}] Created Test Doc` in isolation folder using content from `fixtures/create-doc-content.md` |
| 6 | Docs: edit | Append H2 "Added by {CONFIG}" with paragraph + 3 bullets to Doc from #5 |
| 7 | Sheets: read | Read A1:C5 from `GWS Shootout — Seed Sheet` |
| 8 | Sheets: write | Write `"Updated", "by", "{CONFIG}"` to D1:F1 of seed Sheet |
| 9 | Sheets: create | Create `[GWS-{CONFIG}] Created Test Sheet` in isolation folder using `fixtures/create-sheet-data.csv` |
| 10 | Gmail: search | Search for subject `GWS Shootout — Seed Email` |
| 11 | Gmail: read | Read first message from thread found in #10 |
| 12 | Gmail: send | Send to other account, subject `[GWS-{CONFIG}] Test Email from Shootout` |
| 13 | Calendar: list | List events on `GWS Shootout` calendar for next 14 days |
| 14 | Calendar: create | Create `[GWS-{CONFIG}] Test Event` on `GWS Shootout` calendar, 60 min, 3 days from now |
| 15 | Calendar: update | Move event from #14 forward by 1 hour |

## Integration test

After component tests, run these steps:

| Step | Operation |
|------|-----------|
| 1 | Search Drive for `GWS Shootout — Seed Document`, read its content |
| 2 | Create `[GWS-{CONFIG}] April 2026 Committee Agenda` using `fixtures/create-doc-content.md` |
| 3 | Add agenda Doc URL to description of `[GWS-{CONFIG}] Test Event` |
| 4 | Send `[GWS-{CONFIG}] Committee Meeting Reminder` to other account with agenda link |
| 5 | Create `[GWS-{CONFIG}] April 2026 Committee Summary` with decisions + action items |
| 6 | Append row `"Meeting", "2026-04-15", "3 attendees"` to `[GWS-{CONFIG}] Created Test Sheet` |

## Failure handling

- **Retry**: On transient errors (network, 429/500/503, auth expiry), retry up to 2 times with 30s wait.
- **Skip**: After retries exhausted, mark as FAIL and proceed to next operation.
- **Blocked**: If a prerequisite failed, mark dependent as `BLOCKED (by #N)`.
- **No workarounds**: Do not try alternative approaches. Test the tool as-is.

## Output format

Print your results as a structured report. Use this exact format:

```
## Component Test Results
| # | Operation | Result | Time | Retries | Error |
|---|-----------|--------|------|---------|-------|
| 1 | ... | PASS/FAIL/BLOCKED | Xs | 0 | |
...

## Integration Test Results
| Step | Operation | Result | Time | Retries | Error |
|------|-----------|--------|------|---------|-------|
| 1 | ... | PASS/FAIL/BLOCKED | Xs | 0 | |
...

## Summary
Pass: X/15
Fail: Y/15
Blocked: Z/15
Integration: X/6
Total time: Xm
```

## Rules

- Record observations only. No interpretation ("this was easy"), no suggestions.
- Copy error messages verbatim.
- Do not clean up test artifacts after the run.
