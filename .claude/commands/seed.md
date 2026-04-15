# Seed test data for a GWS account

Create all seed artifacts required by the protocol in the specified account.

**Account**: $ARGUMENTS (must be `gmail` or `workspace`)

## Instructions

Read `CLAUDE.md` section "Test data and fixtures" for the full list of seed artifacts.

Resolve the account:
- `gmail` → `fshotwell@gmail.com`
- `workspace` → `fshotwell@cruxcapacity.com`

### Steps

1. **Create the `GWS Shootout` calendar** in the target account.

2. **Create seed artifacts** in order. Use the GWS CLI (`/gws` skill) or the Claude AI built-in connectors (Google Drive, Gmail, Calendar) — whichever is available in this session.

   | Artifact | Name | Content source |
   |----------|------|---------------|
   | Drive file | `gws-shootout-seed.txt` | Plain text: `This is the GWS Agent Shootout seed file. Created 2026-04-15.` |
   | Google Doc | `GWS Shootout — Seed Document` | `fixtures/seed-doc-content.md` |
   | Google Sheet | `GWS Shootout — Seed Sheet` | `fixtures/seed-sheet-data.csv` (A1:C5) |
   | Calendar event | `GWS Shootout — Seed Event` | 60 min, 7 days from today, on `GWS Shootout` calendar |
   | Seed email | Subject: `GWS Shootout — Seed Email` | Send FROM the *other* account TO this account. Body: `This is a seed email for search and read testing.` |

3. **Record artifact IDs** — after creating each artifact, capture its Google ID and update `fixtures/seed-ids-{gmail|workspace}.json` with the real IDs and set `seeded_at` to today's date.

4. **Verify** — read back each artifact to confirm it exists and has the expected content.

5. **Report** — print a summary table: artifact name, ID, status (created/verified/failed).

### Important

- If an artifact already exists (from a prior seeding attempt), skip creation but still verify and record its ID.
- The seed email requires sending from the OTHER account. If you only have access to one account in this session, note which email still needs to be sent and instruct the operator to send it manually or in the next seed session.
- Do NOT create isolation folders or test artifacts — those are created during test runs.
