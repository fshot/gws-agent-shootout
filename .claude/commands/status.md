# Show test run status

Scan all results directories and report progress against the protocol.

## Instructions

1. **Read `CLAUDE.md`** to get the full config list and done criteria.

2. **Scan `results/` directories** for completed session logs. For each expected config/account combination, report:

   | Config | Account | Session Log | Setup Doc | Pass | Fail | Blocked | Integration |
   |--------|---------|-------------|-----------|------|------|---------|-------------|

   Fill in from the session-log.md files. If a directory or file doesn't exist, mark it as `--`.

3. **Check fixtures** — are `fixtures/seed-ids-gmail.json` and `fixtures/seed-ids-workspace.json` populated (non-null IDs)?

4. **Check synthesis** — do `synthesis/comparison.md` and `synthesis/blog-draft.md` exist?

5. **Print the done criteria checklist** from CLAUDE.md with current status:
   - Mark each criterion as done or not done based on what you found.

6. **Suggest next action** based on the execution plan phases:
   - If seed data is missing → `/project:seed {account}`
   - If the next test run in phase order is pending → `/project:run-test {config} {account}`
   - If all runs are done but synthesis is missing → `/project:synthesize`
   - If everything is done but cleanup hasn't happened → `/project:cleanup`

Keep the output concise. This is a dashboard, not a report.
