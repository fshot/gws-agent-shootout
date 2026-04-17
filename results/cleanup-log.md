# Cleanup Log

**Date**: 2026-04-17
**Operator**: Frank Shotwell
**Script**: `.tmp/cleanup.py` (see git history or reconstruct from this log)
**Accounts cleaned**: fshotwell@gmail.com, fshotwell@cruxcapacity.com

## Method

Python wrapper around `gws` CLI using the profile for each account. For each account:

1. **Drive**: Listed files matching `name contains '[GWS-'`, `name = 'gws-shootout-seed.txt'`, or `name contains 'GWS Shootout'`. Deleted each permanently via `gws drive files delete`.
2. **Calendar**: Located the `GWS Shootout` calendar via `calendarList.list`, then deleted it via `calendars.delete` (this also deleted all events on it). Also swept primary calendar for stray `[GWS-*]` events.
3. **Gmail**: Searched for messages with `subject:[GWS-` OR `subject:"GWS Shootout"`. Moved each to trash via `users.messages.trash`. (Trash auto-purges after 30 days.)

## Preserved (NOT deleted)

Three pre-shootout GWS CLI smoke-test artifacts in the gmail account were identified and explicitly preserved:

- `GWS CLI Test Folder` (folder)
- `GWS CLI Test Sheet — April 2026` (spreadsheet)
- `GWS CLI Smoke Test — April 2026` (document)

These predate the shootout and were created during earlier `/gws` skill development.

## Results

### fshotwell@gmail.com

| Category | Count |
|----------|------:|
| Drive files deleted | 61 |
| — of which documents | 31 |
| — of which text files | 11 |
| — of which spreadsheets | 10 |
| — of which folders | 9 |
| Calendars deleted | 1 (`GWS Shootout`) |
| Gmail messages trashed | 35 |
| Stray primary-calendar events | 0 |
| Errors | 0 |

### fshotwell@cruxcapacity.com

| Category | Count |
|----------|------:|
| Drive files deleted | 28 |
| — of which documents | 14 |
| — of which spreadsheets | 5 |
| — of which text files | 5 |
| — of which folders | 4 |
| Calendars deleted | 1 (`GWS Shootout`) |
| Gmail messages trashed | 28 |
| Stray primary-calendar events | 0 |
| Errors | 0 |

## Totals

- **89** Drive files permanently deleted
- **2** dedicated calendars deleted (with all their events)
- **63** Gmail messages moved to trash (auto-purge in 30 days)

## Seed fixture files

`fixtures/seed-ids-gmail.json` and `fixtures/seed-ids-workspace.json` were previously reset: all IDs set to `null`, `seeded_at` set to `null`.

## Follow-ups

- The `GWS Shootout` calendar was deleted entirely rather than just its events; this also removes the calendar from Google Calendar's sidebar.
- Gmail messages are in trash, not permanently deleted. Google's default policy empties trash after 30 days. If you want them gone sooner, manually "Empty Trash now" in the Gmail UI for each account.
- No screenshots were deleted — those live in `results/*/screenshots/` and are not test artifacts in the Google Workspace sense.
