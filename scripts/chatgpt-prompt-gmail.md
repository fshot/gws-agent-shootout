# GWS Agent Shootout — Config F Test Run

You are running a structured test of Google Workspace access. Execute all operations below autonomously, in order. Do not stop to ask questions — if something fails, record the failure and move to the next operation.

## Context

- **Config**: F (ChatGPT + Google Drive connector)
- **Account**: fshotwell@gmail.com
- **Other account** (for sharing/emailing): fshotwell@cruxcapacity.com
- **Today's date**: 2026-04-16
- **Artifact prefix**: `[GWS-F]`

## Seed data (already exists — do not create these)

- **Drive file**: `gws-shootout-seed.txt` — expected ID: `{drive-id}`
- **Google Doc**: `GWS Shootout — Seed Document` — ID: `{doc-id}`
- **Google Sheet**: `GWS Shootout — Seed Sheet` — ID: `{sheet-id}`
- **Calendar**: `GWS Shootout` — ID: `{calendar-id}`
- **Calendar event**: `GWS Shootout — Seed Event` — ID: `{event-id}`

## Failure handling

- On transient errors (network, 429/500/503, auth expiry), retry up to 2 times with 30s wait.
- After retries exhausted, mark as FAIL and proceed to the next operation.
- If a prerequisite failed, mark the dependent as BLOCKED (by #N).
- **No workarounds.** Do not try alternative approaches. Test only your built-in capabilities. If you cannot perform an operation with your connected tools, mark it FAIL and explain what capability is missing.

## Pre-test step

Create a Drive folder named `[GWS-F] Shootout Results`. Record its ID. All created files go in this folder.

---

## Component Tests (15 operations)

### #1 — Drive: search
Search for a file named `gws-shootout-seed.txt`.
**Pass if**: returns file ID `{drive-id}`.

### #2 — Drive: upload
Create a new file in the isolation folder named `[GWS-F] Uploaded Test File` with this exact content:

```
GWS Agent Shootout — Upload Test File

This file is uploaded by every agent configuration during operation #2 (Drive: upload).
Its content must match byte-for-byte after upload to pass the test.

Config: F
Account: fshotwell@gmail.com
Timestamp: 2026-04-16

Line count: 10
Checksum anchor: gws-shootout-upload-v1
```

**Pass if**: file appears in Drive with correct content.

### #3 — Drive: share (depends on #2)
Share the file from #2 with `fshotwell@cruxcapacity.com` as Viewer.
**Pass if**: permission granted, sharee listed in file permissions.

### #4 — Docs: read
Read the content of `GWS Shootout — Seed Document` (ID: `{doc-id}`).
**Pass if**: returned text contains headings "Seed Document", "Section One", "Section Two", three bullet points, and the paragraph about preserving content.

### #5 — Docs: create
Create a new Google Doc named `[GWS-F] Created Test Doc` in the isolation folder with this content (preserve formatting — H1, H2, bold, bullets):

```
# Committee Agenda

**Date**: April 2026
**Prepared by**: GWS Agent Shootout

## Old Business

Review of action items from the previous meeting. Confirm completion status of each item.

- Review Q1 budget reconciliation
- Status update on vendor migration
- Follow up on accessibility audit findings

## New Business

Items proposed for discussion at this month's meeting.

- Proposal: Adopt new project management tooling
- Discussion: Summer intern program scope
- Vote: Updated meeting cadence (monthly vs. biweekly)

## Action Items

To be filled in after the meeting.

## Next Meeting

Date and time to be confirmed.
```

**Pass if**: Doc created with H1, H2, bold text, and bullet lists.

### #6 — Docs: edit (depends on #5)
Append a new section to the Doc from #5:

```
## Added by F

This section was appended by ChatGPT using the Google Drive connector during the GWS Agent Shootout.

- First appended bullet
- Second appended bullet
- Third appended bullet
```

**Pass if**: new section appears, original content unchanged.

### #7 — Sheets: read
Read cells A1:C5 from `GWS Shootout — Seed Sheet` (ID: `{sheet-id}`).
**Pass if**: values match this data:
```
Name, Role, Score
Alice Chen, Engineer, 95
Bob Martinez, Designer, 88
Carol Johnson, Manager, 92
David Kim, Analyst, 85
```

### #8 — Sheets: write
Write the values `Updated`, `by`, `F` to cells D1, E1, F1 of `GWS Shootout — Seed Sheet`.
**Pass if**: values appear in correct cells.

### #9 — Sheets: create
Create a new spreadsheet named `[GWS-F] Created Test Sheet` in the isolation folder with this data:

```
Task,Owner,Status,Due Date
Update project charter,Alice Chen,Complete,2026-04-01
Review vendor proposals,Bob Martinez,In Progress,2026-04-15
Draft Q2 roadmap,Carol Johnson,Not Started,2026-04-30
Security audit follow-up,David Kim,In Progress,2026-04-20
Budget reconciliation,Alice Chen,Complete,2026-04-05
```

**Pass if**: spreadsheet created with headers and 5 data rows.

### #10 — Gmail: search
Search for emails with subject `GWS Shootout — Seed Email`.
**Pass if**: returns the seed email thread.

### #11 — Gmail: read (depends on #10)
Read the body of the first message from the thread found in #10.
**Pass if**: body contains `This is a seed email for search and read testing.`

### #12 — Gmail: send
Send an email to `fshotwell@cruxcapacity.com` with:
- Subject: `[GWS-F] Test Email from Shootout`
- Body: `This email was sent by ChatGPT using Google Drive connector at 2026-04-16.`

**Pass if**: email sent with correct subject and body.

### #13 — Calendar: list
List events on the `GWS Shootout` calendar (ID: `{calendar-id}`) for the next 14 days.
**Pass if**: returns at least the seed event with title `GWS Shootout — Seed Event`.

### #14 — Calendar: create
Create an event on the `GWS Shootout` calendar:
- Title: `[GWS-F] Test Event`
- Duration: 60 minutes
- Date: 2026-04-19 at 10:00 AM (3 days from now)
- Description: `Created by ChatGPT + Google Drive connector`

**Pass if**: event appears on calendar with correct details.

### #15 — Calendar: update (depends on #14)
Move the event from #14 forward by 1 hour (to 11:00 AM).
**Pass if**: updated time reflected.

---

## Integration Test: Meeting Lifecycle (6 steps)

### Step 1 — Find last month's meeting notes
Search Drive for `GWS Shootout — Seed Document`, then read its content.
**Pass if**: content matches the seed document.

### Step 2 — Create this month's agenda
Create a Google Doc named `[GWS-F] April 2026 Committee Agenda` in the isolation folder. Use the same content as test #5 above.
**Pass if**: Doc created with formatting.

### Step 3 — Update calendar event with agenda link
Add the URL of the Doc from Step 2 to the description of the `[GWS-F] Test Event` (created in component test #14).
**Pass if**: event description contains the Doc URL.

### Step 4 — Send reminder email
Send to `fshotwell@cruxcapacity.com`:
- Subject: `[GWS-F] Committee Meeting Reminder`
- Body: Include a reference to the agenda Doc URL from Step 2.

**Pass if**: email sent with Doc link in body.

### Step 5 — Create summary Doc
Create `[GWS-F] April 2026 Committee Summary` in the isolation folder with:
- H1: April 2026 Committee Summary
- 3 bullet-point decisions (make up plausible content)
- Action items section with 2-3 items

**Pass if**: Doc created with formatting.

### Step 6 — Log attendance in Sheet (depends on component #9)
Append a row to `[GWS-F] Created Test Sheet` with values: `Meeting`, `2026-04-15`, `3 attendees`.
**Pass if**: row appended.

---

## Output format

When all operations are complete, print a single results table. Use this exact format:

```
## Component Test Results
| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 0 | Pre-test: create folder | ... | ... | 0 | ... |
| 1 | Drive: search | ... | ... | 0 | ... |
...through #15...

## Integration Test Results
| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Find & read notes | ... | ... | 0 | ... |
...through #6...

## Summary
Component: X/15 pass, Y/15 fail, Z/15 blocked
Integration: X/6 pass, Y/6 fail, Z/6 blocked
Total wall-clock time: Xm
```

Record observations only. No interpretation ("this was easy"), no suggestions, no cleanup.
