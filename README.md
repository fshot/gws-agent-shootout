# GWS Agent Shootout v2

Structured comparison of AI agent tools for programmatic Google Workspace access. Can an AI agent create, read, edit, and share Docs, Sheets, Drive files, Gmail, and Calendar events on your behalf?

This is the v2 follow-up to a [sloppy first attempt](https://cruxcapacity.com/blog/2026-04-14-ai-google-workspace-v1/) where Claude drove the research with no protocol and produced disorganized results. Same tools, same person, same Claude — better structure.

**Status: protocol complete, testing not yet started.**

## What we're testing

Seven agent/connector combinations, each against a personal Gmail and a paid Google Workspace account (14 total runs). Each run executes 15 component tests across Drive, Docs, Sheets, Gmail, and Calendar, plus a 6-step integration test simulating a real meeting workflow.

| Config | Agent | GWS Connector |
|--------|-------|---------------|
| **A** | Claude Cowork (desktop) | Built-in connectors |
| **B** | Claude Code | GWS CLI |
| **C** | Claude Code | [google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp) |
| **D** | Codex CLI | GWS CLI |
| **D2** | Codex CLI | google_workspace_mcp |
| **E** | Gemini CLI | [Workspace extension](https://github.com/gemini-cli-extensions/workspace) |
| **F** | ChatGPT | Google Drive connector |

Full protocol: [CLAUDE.md](CLAUDE.md)

---

## Operator Guide

This section is for the human running the shootout. Claude Code orchestrates most of the work, but you need to handle prerequisites, authentication flows, and a few manual steps.

### Prerequisites

Before starting, make sure you have:

- [ ] **Claude Code** installed and authenticated
- [ ] **Codex CLI** installed (`npm i -g @openai/codex`) and `OPENAI_API_KEY` set
- [ ] **Gemini CLI** installed and authenticated with Google
- [ ] **ChatGPT** paid plan with Google Drive connector enabled
- [ ] **GWS CLI** — will be installed during Phase 1 (config B setup)
- [ ] **A GCP project** — will be created during Phase 1
- [ ] Access to both test accounts:
  - `fshotwell@gmail.com` (personal)
  - `fshotwell@cruxcapacity.com` (Workspace)

### Quick start

Open Claude Code in this directory and run:

```
/project:next
```

This tells you exactly what to do next. Follow its instructions, then run `/project:next` again. Repeat until done.

### The workflow

The project runs in six phases. You can run them one at a time with `/project:run-phase {N}` or one test at a time with `/project:run-test {config} {account}`.

```
Phase 0  →  Phase 1  →  Phase 2  →  Phase 3  →  Phase 4  →  Phase 5  →  Phase 6
 Seed        B(CLI)      C(MCP)     D,D2(Codex)  E,A,F       Synthesis   Cleanup
```

#### Phase 0 — Seed data

Creates identical test fixtures in both Google accounts so every config tests against the same data.

```
/project:seed gmail
/project:seed workspace
```

**What you'll need to do**: Approve OAuth consent screens during first-time authentication. The seed command will walk you through it.

#### Phase 1 — Claude Code + GWS CLI (config B)

This is the first real test run and also sets up the GWS CLI infrastructure that configs D and D2 will reuse.

```
/project:run-test B gmail
/project:run-test B workspace
```

**What you'll need to do**: 
- Install GWS CLI if not already installed
- Create a GCP project, enable APIs, set up OAuth credentials
- Approve the OAuth consent screen on first `gws` command

Claude Code will guide you through setup and document every step in `setup.md`. This becomes the canonical GWS CLI setup guide.

#### Phase 2 — Claude Code + MCP (config C)

Sets up the google_workspace_mcp server and tests it.

```
/project:run-test C gmail
/project:run-test C workspace
```

**What you'll need to do**: Clone the MCP repo, install dependencies, configure OAuth (may reuse GCP project from Phase 1). Approve consent screens.

#### Phase 3 — Codex CLI (configs D, D2)

These run autonomously — Claude Code dispatches to Codex via wrapper scripts.

```
/project:run-phase 3
```

**What you'll need to do**:
- Before D: Verify Codex can access `gws` CLI (should already be set up from Phase 1)
- Before D2: Run `./scripts/setup-codex-mcp.sh <path-to-mcp>` to register the MCP server with Codex
- Approve any first-time auth prompts if Codex hasn't authenticated with GWS yet

Codex runs in `--full-auto` mode, reads `AGENTS.md` for instructions, and outputs structured results. Claude Code parses the output and writes the session logs.

#### Phase 4 — Gemini, Cowork, ChatGPT (configs E, A, F)

```
/project:run-phase 4
```

**What you'll need to do**:
- **Config E**: Before first run, install the Workspace extension: `./scripts/setup-gemini-workspace.sh`. Approve OAuth. After that, it runs autonomously via `./scripts/run-gemini.sh`.
- **Config A**: Runs directly in Claude Code using built-in connectors. May prompt for Google Drive/Gmail/Calendar authorization.
- **Config F**: This one is manual. Claude Code will print step-by-step instructions for you to execute in the ChatGPT web UI. Copy results back into the session log.

#### Phase 5 — Synthesis

```
/project:synthesize
```

A fresh context reads all session logs and writes the comparison analysis and blog draft. No human input needed.

#### Phase 6 — Cleanup

```
/project:cleanup both
```

Removes all test artifacts from both Google accounts. Will ask for confirmation before deleting.

### Commands reference

| Command | What it does |
|---------|-------------|
| `/project:next` | One-line recommendation: what to do next |
| `/project:status` | Full dashboard of all runs and done criteria |
| `/project:seed gmail\|workspace` | Create seed test data in an account |
| `/project:run-test {config} {account}` | Run one test (e.g., `B gmail`, `D2 workspace`) |
| `/project:run-phase {0-6}` | Run all tests in a phase |
| `/project:synthesize` | Write comparison + blog draft from all logs |
| `/project:cleanup gmail\|workspace\|both` | Remove test artifacts from accounts |

### When things go wrong

**Auth failures mid-run**: The test will mark operations as FAIL and continue. Re-authenticate and re-run the specific config/account.

**Codex or Gemini crash**: Check the raw output files in the results directory (`codex-raw-output.jsonl` or `gemini-raw-output.json`). The exit code and error will be in the wrapper script output. Fix the issue and re-run.

**Seed data missing**: `/project:run-test` checks for seed data before starting. If it's missing, it will tell you to run `/project:seed` first.

**Want to re-run a test**: Just run `/project:run-test` again. It will warn you that a session log already exists and ask whether to overwrite.

### Where results go

```
results/
  claude-code-gws-cli-gmail/        # Config B, @gmail.com
    setup.md                         # How GWS CLI was installed and configured
    session-log.md                   # Test results: 15 component + 6 integration
    screenshots/                     # Auth flows, consent screens, result verification
  claude-code-mcp-workspace/         # Config C, @workspace
    ...
  codex-gws-cli-gmail/               # Config D — ran by Codex CLI autonomously
    codex-raw-output.jsonl           # Raw Codex output (JSONL)
    session-log.md                   # Parsed into standard format by Claude Code
    ...
```

### Environment setup (direnv)

The project uses `direnv` + `.env` files so that `cd`-ing into a results directory automatically loads the right Google account context. This means credentials, project IDs, and account emails switch seamlessly as you navigate between test directories.

```bash
# One-time setup
./scripts/setup-direnv.sh

# Verify
cd results/claude-code-gws-cli-gmail
echo $GWS_ACCOUNT      # → fshotwell@gmail.com
echo $GWS_CONFIG        # → B

cd ../codex-mcp-workspace
echo $GWS_ACCOUNT      # → fshotwell@cruxcapacity.com
echo $GWS_CONFIG        # → D2
```

The env files live in `envs/`:
- `envs/gmail.env` — personal account variables
- `envs/workspace.env` — Workspace account variables
- `envs/.env.example` — template for adding new accounts

OAuth credentials are stored in `~/.config/gws/`, organized by account label (e.g., `credentials-gmail.json`, `token-workspace.json`). This keeps secrets out of the repo and lets multiple projects share the same auth.

#### Extending to other accounts

This pattern works beyond the shootout. To add a client account:

1. Copy `envs/.env.example` to `envs/{client-name}.env`, fill in the account details
2. Create a project directory with the label as suffix (e.g., `my-project-clientname/`)
3. Add a `.envrc` that sources the right env file (see `envs/.envrc.example`)
4. `direnv allow` the directory

Now `cd my-project-clientname` loads that client's Google context automatically — right credentials, right project, right scopes. No manual switching, no environment contamination between accounts.

### File overview

| File | Purpose |
|------|---------|
| [CLAUDE.md](CLAUDE.md) | Full research protocol — the source of truth |
| [AGENTS.md](AGENTS.md) | Test instructions for Codex CLI (configs D, D2) |
| [GEMINI.md](GEMINI.md) | Test instructions for Gemini CLI (config E) |
| [templates/publication-spec.md](templates/publication-spec.md) | Audience, voice, and structure for published outputs |
| [templates/session-log-template.md](templates/session-log-template.md) | Template for raw test session logs |
| [templates/setup-template.md](templates/setup-template.md) | Template for connector setup documentation |
| [fixtures/](fixtures/) | Seed data content and test fixtures |
| [scripts/](scripts/) | Wrapper scripts for Codex/Gemini dispatch and setup |
| [envs/](envs/) | Per-account `.env` files and direnv templates |

---

*A [Crux Capacity](https://cruxcapacity.com) experiment.*
