# Clean up test artifacts from GWS accounts

Remove all test artifacts created during the shootout from both accounts.

**Account**: $ARGUMENTS (must be `gmail`, `workspace`, or `both`)

## Instructions

This command implements Phase 6 of the execution plan. Run AFTER all test runs are complete and session logs are verified.

### Pre-flight

1. Run `/project:status` equivalent — confirm all intended test runs have session logs. If any are missing, warn the operator that cleanup will remove the seed data those runs depend on.

2. Confirm with the operator before proceeding. List what will be deleted.

### Cleanup steps

For each account specified:

1. **Drive**: Search for and delete all folders matching `gws-shootout-*` and any files prefixed `[GWS-`. Also delete `gws-shootout-seed.txt`.

2. **Docs**: Delete any Docs with names starting with `[GWS-` or `GWS Shootout —`.

3. **Sheets**: Delete any Sheets with names starting with `[GWS-` or `GWS Shootout —`. (Note: the seed Sheet may have had columns D+ written to — deleting the whole sheet handles this.)

4. **Calendar**: Delete all events on the `GWS Shootout` calendar, then delete the calendar itself.

5. **Gmail**: Optionally delete emails with subjects containing `[GWS-` or `GWS Shootout`. Ask the operator — these serve as evidence and may be worth keeping.

### Record

Write `results/cleanup-log.md` documenting:
- Date and time
- Account(s) cleaned
- Number of artifacts deleted per category
- Any artifacts that could not be deleted (with error messages)
- Whether emails were kept or deleted

### Update fixtures

Set all IDs in `fixtures/seed-ids-{account}.json` back to `null` and clear `seeded_at`.
