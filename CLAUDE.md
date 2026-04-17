# GWS Agent Shootout: v2 Research Protocol

## Purpose

Structured comparison of AI agent tools for programmatic Google Workspace access.
This is the v2 follow-up to a [sloppy v1 experiment](https://cruxcapacity.com/blog/2026-04-14/)
where Claude drove the research with no protocol and produced disorganized results.

The v1/v2 process comparison is part of the story: same tools, same person, same Claude, better structure.

## What we're testing

Can an AI agent create, read, edit, and share Google Workspace content (Docs, Sheets, Drive, Gmail, Calendar) on your behalf, triggered by a command, voice prompt, or scheduled job?

Not: "does Gemini work inside Google Docs?" We're testing external, agent-driven access.

## Tool matrix

Seven configurations, each tested against two account types:

| Config | Agent | GWS connector | Notes |
|--------|-------|---------------|-------|
| **A** | Claude Cowork (desktop) | Built-in connectors | Baseline. Read-only reference point. |
| **B** | Claude Code | GWS CLI | v1 winner for coverage. Full CRUD. |
| **C** | Claude Code | google_workspace_mcp | Community MCP: [taylorwilsdon/google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp). 12 services, OAuth 2.1. |
| **D** | Codex CLI | GWS CLI | OpenAI's agent + same GWS CLI. Head-to-head with config B. |
| **D2** | Codex CLI | google_workspace_mcp | Same MCP as config C, different agent. Head-to-head with config C. |
| **E** | Gemini CLI | Workspace extension | [gemini-cli-extensions/workspace](https://github.com/gemini-cli-extensions/workspace). Pre-configured OAuth. |
| **F** | ChatGPT | Google Drive connector | Paid plan. Included for completeness. |

Account types per config:
- **@gmail.com**: `fshotwell@gmail.com` (free personal account)
- **@workspace**: `fshotwell@cruxcapacity.com` (paid Google Workspace account)

Total: 14 test runs (7 configs x 2 accounts). Config F may be @gmail.com only.

### Sharing targets

Operations that require a second user (e.g., Drive sharing, email sending) use the *other* test account as the target. When testing with @gmail.com, share/send to @workspace and vice versa.

## Setup documentation requirements

A key output of this project is a reproducible setup guide. Each connector and utility that requires installation or configuration must be documented in enough detail that a reader can follow along from scratch.

### What needs full setup documentation

These components require detailed install/config writeups:

- **GWS CLI** (configs B, D): installation, GCP project creation, OAuth client setup, API enablement, credential download, first-run auth flow, scope grants
- **google_workspace_mcp** (configs C, D2): repo clone/install, GCP project + OAuth setup (or reuse from GWS CLI), MCP server config in Claude Code / Codex, first-run auth, token storage
- **Gemini CLI Workspace extension** (config E): extension install, OAuth/credential setup, scope grants, any GCP project requirements
- **Any other MCP servers or connectors** tested along the way

### What does NOT need full setup docs

The agent tools themselves (Claude Code, Codex CLI, Gemini CLI, ChatGPT) are well-documented elsewhere. Note the version used and any non-default configuration, but skip basic install narration.

### What to record for each connector

1. **Prerequisites**: OS, runtime versions (Node, Python, etc.), GCP project requirements, billing requirements
2. **Installation steps**: exact commands run, in order
3. **GCP configuration**: APIs enabled, OAuth consent screen settings, OAuth client type and scopes requested, credential file locations
4. **First-run auth flow**: what happens on first use --- browser redirects, consent screens, scope approval prompts. Screenshot each screen.
5. **Resulting artifacts**: where tokens/credentials are stored, what config files were created/modified, environment variables set
6. **Account-type differences**: anything that differs between @gmail.com and @workspace setup (admin consent, domain-wide delegation, etc.)
7. **Gotchas**: anything that failed on first attempt, unclear error messages, missing documentation in the upstream project

### Where setup docs live

Each results directory gets a `setup.md` alongside `session-log.md`. For connectors shared across configs (e.g., GWS CLI used by both B and D), the first config to use it writes the full setup doc; later configs reference it and note only what differed.

```
results/
  {config}-{account}/
    setup.md                          # Install + config steps for this connector
    session-log.md
    screenshots/
```

## Test data and fixtures

Every test run uses identical, pre-defined test data so results are comparable across configs. Seed data must exist in both accounts before any test run begins.

### Seed data (created once per account during Phase 0)

Create these artifacts manually or via GWS CLI before testing:

| Artifact | Name | Content/Details |
|----------|------|-----------------|
| Drive file | `gws-shootout-seed.txt` | Plain text file containing: `This is the GWS Agent Shootout seed file. Created {date}.` |
| Google Doc | `GWS Shootout — Seed Document` | H1: "Seed Document", H2: "Section One", body paragraph, bullet list (3 items), H2: "Section Two", body paragraph. Use content from `fixtures/seed-doc-content.md`. |
| Google Sheet | `GWS Shootout — Seed Sheet` | Sheet1, A1:C5 populated. Headers: `Name, Role, Score`. 4 data rows. Use data from `fixtures/seed-sheet-data.csv`. |
| Calendar event | `GWS Shootout — Seed Event` | 60-minute event, set to 7 days from seed date, description: `Seed event for GWS Agent Shootout testing.` |
| Email thread | Send an email to the test account from the *other* test account | Subject: `GWS Shootout — Seed Email`. Body: `This is a seed email for search and read testing.` |

Record the Google Drive file IDs for each seed artifact in `fixtures/seed-ids-{account}.json` so test runs can verify they found the right files.

### Test fixture files (in repo)

```
fixtures/
  seed-doc-content.md                 # Exact content for the seed Google Doc
  seed-sheet-data.csv                 # Exact data for the seed Google Sheet
  upload-test.txt                     # File every config uploads in operation #2
  create-doc-content.md               # Content for operation #5 (create Doc)
  create-sheet-data.csv               # Data for operation #9 (create Sheet)
  seed-ids-gmail.json                 # File IDs for fshotwell@gmail.com seed data
  seed-ids-workspace.json             # File IDs for fshotwell@cruxcapacity.com seed data
```

### Naming convention for test artifacts

Every artifact created during a test run includes the config ID for identification and cleanup:

- **Drive/Docs/Sheets**: `[GWS-{CONFIG}] {Description}` — e.g., `[GWS-B] Uploaded Test File`
- **Calendar events**: `[GWS-{CONFIG}] {Description}` — e.g., `[GWS-C] Test Event`
- **Emails**: Subject prefix `[GWS-{CONFIG}]` — e.g., `[GWS-D] Test Email from Shootout`

### Isolation folder

Each test run creates a Drive folder named `gws-shootout-{config}` (e.g., `gws-shootout-B`) as its first action. All created files go inside this folder. This prevents cross-run contamination in search results.

### Test calendar

Create a dedicated calendar named `GWS Shootout` in each account during Phase 0. All calendar operations target this calendar, not the primary calendar.

## Operation checklist

Each test run executes these operations in order. Record pass/fail, timing, and exact output.

### Pre-test step

Before operation #1, create the isolation folder: `[GWS-{CONFIG}] Shootout Results` in Drive.

### Component tests

| # | Category | Operation | Exact test data | Success criteria |
|---|----------|-----------|-----------------|-----------------|
| 1 | Drive | Search for a file by name | Search for `gws-shootout-seed.txt` | Returns the seed file with correct file ID (verify against `fixtures/seed-ids-{account}.json`) |
| 2 | Drive | Upload a local file | Upload `fixtures/upload-test.txt` as `[GWS-{CONFIG}] Uploaded Test File` into isolation folder | File appears in Drive, content matches local file byte-for-byte |
| 3 | Drive | Share a file with another user | Share the uploaded file with the other test account (`fshotwell@cruxcapacity.com` or `fshotwell@gmail.com`) as Viewer | Permission granted, sharee listed in file permissions |
| 4 | Docs | Read a Doc's content | Read `GWS Shootout — Seed Document` | Returned text contains all headings, paragraphs, and bullet items from `fixtures/seed-doc-content.md` |
| 5 | Docs | Create a new Doc with formatted content | Create `[GWS-{CONFIG}] Created Test Doc` in isolation folder using content from `fixtures/create-doc-content.md` | Doc created with H1, H2, bold text, and bullet list |
| 6 | Docs | Edit an existing Doc (append + format) | Append a new H2 section titled "Added by {CONFIG}" with a paragraph and 3 bullet items to the Doc created in #5 | New section appears, original content unchanged |
| 7 | Sheets | Read cell range | Read A1:C5 from `GWS Shootout — Seed Sheet` | Values match `fixtures/seed-sheet-data.csv` exactly |
| 8 | Sheets | Write to cell range | Write `"Updated", "by", "{CONFIG}"` to D1:F1 of `GWS Shootout — Seed Sheet` | Values appear in Sheets UI in correct cells |
| 9 | Sheets | Create a new Sheet with headers + data | Create `[GWS-{CONFIG}] Created Test Sheet` in isolation folder using `fixtures/create-sheet-data.csv` | Sheet created, data matches CSV |
| 10 | Gmail | Search messages | Search for subject `GWS Shootout — Seed Email` | Returns the seed email thread |
| 11 | Gmail | Read a message body | Read the first message from the thread found in #10 | Body contains `This is a seed email for search and read testing.` |
| 12 | Gmail | Send an email | Send to the other test account, subject `[GWS-{CONFIG}] Test Email from Shootout`, body: `This email was sent by {AGENT} using {CONNECTOR} at {timestamp}.` | Email received by target with correct subject and body |
| 13 | Calendar | List upcoming events | List events on the `GWS Shootout` calendar for the next 14 days | Returns at least the seed event with correct title and time |
| 14 | Calendar | Create an event | Create `[GWS-{CONFIG}] Test Event` on `GWS Shootout` calendar, 60 min, 3 days from now, description: `Created by {AGENT} + {CONNECTOR}` | Event appears on calendar with correct details |
| 15 | Calendar | Update an event (change time) | Move the event created in #14 forward by 1 hour | Updated time reflected in calendar |

### Integration test: meeting lifecycle

After component tests pass, run this end-to-end scenario. All artifacts use the `[GWS-{CONFIG}]` prefix and go in the isolation folder.

| Step | Operation | Details |
|------|-----------|---------|
| 1 | Find last month's meeting notes | Search Drive for `GWS Shootout — Seed Document`, read its content |
| 2 | Create this month's agenda Doc | Create `[GWS-{CONFIG}] April 2026 Committee Agenda` with H1 title, date, 5 agenda items (use content from `fixtures/create-doc-content.md` as the template) |
| 3 | Update the calendar event | Add the agenda Doc's URL to the description of `[GWS-{CONFIG}] Test Event` (created in component test #14) |
| 4 | Send reminder email | Send to the other test account, subject `[GWS-{CONFIG}] Committee Meeting Reminder`, body referencing the agenda Doc link |
| 5 | Create summary Doc | Create `[GWS-{CONFIG}] April 2026 Committee Summary` with H1 title, 3 bullet-point decisions, action items |
| 6 | Log attendance in Sheet | Append a row to `[GWS-{CONFIG}] Created Test Sheet` (from component test #9) with: `"Meeting", "2026-04-15", "3 attendees"` |

Record total time and intervention count.

## Failure handling

### Retry policy

On transient errors (network timeout, HTTP 429/500/503, auth token expiry), retry up to **2 times** with a 30-second wait between attempts. Record each attempt and the error in the session log.

### Skip policy

If an operation fails after retries, record the failure with full error output, mark it as `FAIL`, and **proceed to the next operation**. Do not abandon the entire run.

### Dependency handling

Some operations depend on earlier ones. If a prerequisite fails, mark the dependent operation as `BLOCKED (by #{N})` rather than attempting it.

| Operation | Depends on |
|-----------|-----------|
| #3 (share) | #2 (upload) |
| #6 (edit Doc) | #5 (create Doc) |
| #8 (write cells) | seed Sheet exists |
| #11 (read email) | #10 (search email) |
| #15 (update event) | #14 (create event) |
| Integration #3 | Integration #2 |
| Integration #4 | Integration #2 |
| Integration #6 | Component #9 |

### Workaround prohibition

Do not attempt alternative approaches to make a failing operation pass. The point is to test the tool as-is. If `gws docs create` fails, do not fall back to raw API calls or a different tool. Record the failure. This preserves the "no smoothing" principle from the synthesis rules.

## Cleanup

### During testing

No cleanup between test runs. Artifacts from earlier runs should remain so we can verify isolation is working (search tests should not return artifacts from other configs).

### After all testing

After all 14 runs are complete and session logs are verified:

1. Delete all Drive folders matching `gws-shootout-*` and their contents
2. Delete all events on the `GWS Shootout` calendar
3. Remove the `GWS Shootout` calendar from both accounts
4. Revert any writes to the seed Sheet (columns D+)
5. Delete sent test emails (optional — they serve as additional evidence)

Record cleanup steps in `results/cleanup-log.md` as a guide appendix.

## Execution plan

Run configs in this order to maximize setup reuse and minimize intervention.

### Phase 0 — Seed data (manual, both accounts)

Create all seed artifacts listed in "Test data and fixtures" above. Record file IDs in `fixtures/seed-ids-{account}.json`. Create the `GWS Shootout` calendar in both accounts.

**Estimated time**: 30 minutes per account.

### Phase 1 — GWS CLI baseline (config B)

Run **B / @gmail.com** first. This creates:
- The GCP project, OAuth client, and API enablement for GWS CLI
- The canonical setup doc that configs D, and any other GWS CLI users, will reference

Then run **B / @workspace**. Note account-type differences in setup doc.

### Phase 2 — MCP setup (config C)

Run **C / @gmail.com**. This creates:
- The google_workspace_mcp installation and OAuth config
- The canonical MCP setup doc that config D2 will reference

Then run **C / @workspace**.

### Phase 3 — Codex configs (D, D2)

Run **D / @gmail.com**, then **D / @workspace**. Reuses GWS CLI from Phase 1; setup doc references B's and notes only Codex-specific differences.

Run **D2 / @gmail.com**, then **D2 / @workspace**. Reuses MCP from Phase 2; setup doc references C's.

### Phase 4 — Remaining configs (E, A, F)

These are independent of each other and of Phases 1-3. Run in any order.

- **E** (Gemini CLI + Workspace extension): fresh setup, own GCP config
- **A** (Claude Cowork): minimal setup, read-only baseline
- **F** (ChatGPT): web UI, minimal setup

### Phase 5 — Synthesis

Fresh Claude session reads all raw logs and writes `synthesis/comparison.md` and `synthesis/blog-draft.md`. See "Publication spec" and "Synthesis rules" sections.

### Phase 6 — Cleanup

Run cleanup checklist. Write `results/cleanup-log.md`.

## Environment management (direnv)

Account credentials and context are managed via `direnv` + `.env` files so that `cd`-ing into a results directory automatically loads the right Google account.

### Setup

```bash
./scripts/setup-direnv.sh
```

This creates `.envrc` files in the project root and all 14 results directories. Each results directory's `.envrc` detects the account from the directory name (e.g., `codex-gws-cli-gmail` → loads `envs/gmail.env`) and exports the relevant variables.

### Key environment variables

| Variable | Example | Used by |
|----------|---------|---------|
| `GWS_ACCOUNT` | `fshotwell@gmail.com` | All scripts and connectors |
| `GWS_TARGET_ACCOUNT` | `fshotwell@cruxcapacity.com` | Share/send operations |
| `GWS_ACCOUNT_LABEL` | `gmail` | Profile directory naming |
| `GWS_CONFIG` | `B` | Artifact naming prefix |
| `GWS_ARTIFACT_PREFIX` | `[GWS-B]` | Drive/Docs/Sheets/Calendar names |
| `GCP_PROJECT` | `hdca-workspace-tools` | GCP API access |
| `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` | `~/.config/gws/profiles/gmail` | GWS CLI profile directory |

### How account switching works

GWS CLI reads `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to find its config files (`client_secret.json`, `credentials.enc`, `token_cache.json`). Each account gets its own profile directory under `~/.config/gws/profiles/`. direnv sets this variable automatically when you `cd` into a results directory, so `gws` commands use the right account with zero manual credential swapping.

```bash
# Verify it works — cd between directories and check:
cd results/claude-code-gws-cli-gmail
gws auth status 2>&1 | grep user    # → fshotwell@gmail.com

cd ../claude-code-gws-cli-workspace
gws auth status 2>&1 | grep user    # → fshotwell@cruxcapacity.com
```

### Credential storage (profile directories)

All OAuth credentials live in `~/.config/gws/profiles/`, one directory per account:

```
~/.config/gws/
  profiles/
    gmail/                           # Profile for fshotwell@gmail.com
      client_secret.json             # OAuth client ID (from GCP Console)
      credentials.enc                # Encrypted refresh token (from `gws auth login`)
      token_cache.json               # Cached access token (auto-managed)
    crux/                            # Profile for fshotwell@cruxcapacity.com
      client_secret.json
      credentials.enc
      token_cache.json
```

This keeps credentials out of the project directory, lets multiple projects share the same auth, and supports seamless concurrent account switching via direnv.

### Setting up a new profile

```bash
# 1. Create the profile directory
mkdir -p ~/.config/gws/profiles/{label}

# 2. Copy your GCP project's OAuth client credentials into it
cp ~/Downloads/client_secret_*.json ~/.config/gws/profiles/{label}/client_secret.json

# 3. Authenticate (sets credentials.enc + token_cache.json)
GOOGLE_WORKSPACE_CLI_CONFIG_DIR=~/.config/gws/profiles/{label} \
  gws auth login -s drive,docs,sheets,gmail,calendar
```

### Extending to other accounts

To add a new account context (e.g., a client project):

1. Create a profile directory: `mkdir -p ~/.config/gws/profiles/{label}`
2. Copy OAuth `client_secret.json` from the account's GCP project into the profile
3. Run `gws auth login` with `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` pointed at the profile
4. Create `envs/{label}.env` from `envs/.env.example`, setting `GWS_ACCOUNT_LABEL={label}`
5. Create a project directory with the label as suffix (e.g., `my-project-clientname/`)
6. Add a `.envrc` that sources the right env file (see `envs/.envrc.example`)
7. `direnv allow` the directory

Now `cd my-project-clientname` loads that account's Google context automatically.

**Token expiry**: In GCP OAuth "Testing" mode, refresh tokens expire every 7 days. If you see `invalid_rapt` or auth errors, re-run `gws auth login` with the profile's config dir set.

## File conventions

```
gws-agent-shootout/
  CLAUDE.md                           # This file (the protocol)
  AGENTS.md                           # Codex CLI project instructions (configs D, D2)
  GEMINI.md                           # Gemini CLI project instructions (config E)
  README.md                           # Public-facing summary (written last)
  .envrc.example                      # Root direnv config (copy to .envrc)
  envs/
    .env.example                      # Template for new account env files
    .envrc.example                    # Template for subdirectory .envrc files
    gmail.env                         # Account vars for fshotwell@gmail.com
    workspace.env                     # Account vars for fshotwell@cruxcapacity.com
  fixtures/
    seed-doc-content.md               # Exact content for the seed Google Doc
    seed-sheet-data.csv               # Exact data for the seed Google Sheet
    upload-test.txt                   # File every config uploads in operation #2
    create-doc-content.md             # Content for operation #5 (create Doc)
    create-sheet-data.csv             # Data for operation #9 (create Sheet)
    seed-ids-gmail.json               # File IDs for @gmail.com seed artifacts
    seed-ids-workspace.json           # File IDs for @workspace seed artifacts
  scripts/
    run-codex.sh                      # Wrapper: invoke Codex CLI in full-auto mode
    run-gemini.sh                     # Wrapper: invoke Gemini CLI in yolo mode
    setup-codex-mcp.sh                # Configure google_workspace_mcp for Codex
    setup-gemini-workspace.sh         # Install Workspace extension for Gemini
  results/
    {config}-{account}/               # e.g., claude-code-gws-cli-gmail/
      setup.md                        # Install + config steps for connector(s)
      session-log.md                  # Raw session log from template
      codex-raw-output.jsonl          # (configs D, D2) Raw Codex JSONL output
      gemini-raw-output.json          # (config E) Raw Gemini JSON output
      screenshots/                    # Evidence: auth flows, consent screens, results
    cleanup-log.md                    # Post-testing cleanup record
  synthesis/
    comparison.md                     # Cross-config analysis (written after all tests)
    blog-draft.md                     # v2 blog post draft
  templates/
    session-log-template.md           # Template for raw session logs
    setup-template.md                 # Template for setup documentation
    publication-spec.md               # Audience, voice, structure for publishable outputs
  .claude/commands/                   # Slash commands for driving the workflow
    seed.md                           # /seed {gmail|workspace}
    run-test.md                       # /run-test {config} {account}
    run-phase.md                      # /run-phase {0-6}
    status.md                         # /status
    next.md                           # /next
    synthesize.md                     # /synthesize
    cleanup.md                        # /cleanup {gmail|workspace|both}
```

## Session log rules

1. **Use the template.** Every test run produces `session-log.md` from `templates/session-log-template.md`.
2. **Observation only.** Record what happened. No interpretation, no "this was easy," no "minor friction." Save analysis for the synthesis step.
3. **Timestamps.** Record wall-clock time for each operation.
4. **Exact output.** Copy terminal output, error messages, API responses verbatim. Summarize only if output exceeds 100 lines (link to full output).
5. **Screenshots.** Capture auth flows, consent screens, error states, and any UI showing results (e.g., the created Doc in Google Docs).
6. **Intervention count.** Track every time the human had to step in (approve a prompt, fix an error, restart a flow). Autonomous operation is the goal.

## Synthesis rules

1. **Separate session.** The synthesis is written by a fresh Claude session that reads all raw logs. Not by the session that ran the tests.
2. **Evidence-first.** Every claim in the comparison must cite a specific session log and operation number.
3. **No smoothing.** If a tool failed, say it failed. If it was slow, say how slow. The v1 mistake was making rough edges sound like minor friction.

## Publication spec

See `templates/publication-spec.md` for the full spec. Key points:

- **Audience**: Technical decision-makers and hands-on developers evaluating how to connect AI agents to Google Workspace.
- **Voice**: Practitioner-to-practitioner. Direct, evidence-backed, no marketing language. Crux Capacity is the byline, not the sales pitch.
- **Quality bar**: Every recommendation cites a specific test result. Every setup instruction was executed and verified during testing. No "should work" --- only "we verified this works."
- **Meta-narrative**: The v1/v2 process comparison (same tools, same person, better protocol) is part of the story but secondary to the practical guide content.

## Done criteria

- [ ] Phase 0: Seed data created in both accounts, IDs recorded in `fixtures/`
- [ ] All 14 test runs completed with session logs
- [ ] Setup docs completed for each connector (GWS CLI, google_workspace_mcp, Gemini Workspace ext.)
- [ ] Component test results tabulated in a cross-config matrix
- [ ] Integration test completed for at least configs B, C, D, D2, E
- [ ] Synthesis comparison written by a separate session (per publication spec)
- [ ] Blog draft v2 written, linking back to v1 for process comparison
- [ ] README written as the public entry point
- [ ] Cleanup completed and documented in `results/cleanup-log.md`
- [ ] Token efficiency analysis: investigate Codex's 933K-token schema-reading pattern — can a condensed CLI reference or cached subskill eliminate the "tool discovery tax"? Generalize findings across agents. (See `results/codex-gws-cli-gmail/codex-raw-output.jsonl` for raw data.)
