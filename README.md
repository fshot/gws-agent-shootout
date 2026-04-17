# GWS Agent Shootout v2

Structured comparison of AI agent tools for programmatic Google Workspace access. We tested 7 agent/connector configurations — each against a personal Gmail and a paid Workspace account — running 15 component tests across Drive, Docs, Sheets, Gmail, and Calendar, plus a 6-step integration test simulating a real meeting workflow. 13 of 14 planned runs completed.

This is the v2 follow-up to a [sloppy first attempt](https://cruxcapacity.com/blog/2026-04-14/) where Claude drove the research with no protocol. Same tools, same person, same Claude — better structure.

## Results

Component test pass rates (15 tests per run):

| Config | Agent | Connector | Gmail | Workspace | Interventions |
|--------|-------|-----------|-------|-----------|---------------|
| **B** | Claude Code | GWS CLI | [15/15](results/claude-code-gws-cli-gmail/session-log.md) | [15/15](results/claude-code-gws-cli-workspace/session-log.md) | 0 |
| **D** | Codex CLI | GWS CLI | [15/15](results/codex-gws-cli-gmail/session-log.md) | [15/15](results/codex-gws-cli-workspace/session-log.md) | 1^a |
| **D2** | Codex CLI | google_workspace_mcp | [15/15](results/codex-mcp-gmail/session-log.md) | [15/15](results/codex-mcp-workspace/session-log.md) | 0 |
| **C** | Claude Code | google_workspace_mcp | [15/15](results/claude-code-mcp-gmail/session-log.md) | [14/15](results/claude-code-mcp-workspace/session-log.md) | 1^b |
| **A** | Claude Desktop | google_workspace_mcp | [14/15](results/claude-cowork-connectors-gmail/session-log.md) | [15/15](results/claude-cowork-connectors-workspace/session-log.md) | 2^c |
| **F** | ChatGPT | Built-in connectors | [10/15](results/chatgpt-drive-gmail/session-log.md) | — | ~8^d |
| **E** | Gemini CLI | Workspace extension | [9/15](results/gemini-cli-workspace-gmail/session-log.md) | [6/15*](results/gemini-cli-workspace-workspace/session-log.md) | 0 |

Integration test (6-step meeting lifecycle): Configs A, B, C, D, D2 scored 6/6 on both accounts. Config F scored 5/6. Config E scored 3/6 (gmail).

**\*** E/workspace results are invalid — the extension silently used the gmail account's credentials for all operations.

^a Codex `--full-auto` sandbox blocks network; required `--dangerously-bypass-approvals-and-sandbox`. Free-tier quota exhausted by one run.
^b OAuth re-auth triggered mid-test for Sheets scopes (incremental scoping).
^c OAuth re-auth for account switch + 18 per-tool permission prompts in Claude Desktop.
^d Every ChatGPT tool call requires manual approval via modal dialog.

## Recommendations

**Full CRUD across all GWS services:** Use GWS CLI with Claude Code (config B) or Codex (config D). Only connector that passed all 15 tests on both accounts with no tool-level workarounds.

**Desktop experience without a CLI:** Use Claude Desktop with google_workspace_mcp (config A). 14-15/15 on both accounts. Functional coverage is nearly equivalent to GWS CLI; doc creation is more verbose.

**Headless/scheduled operation:** GWS CLI configs (B, D) only. MCP configs can work but need OAuth token monitoring. ChatGPT has no headless mode.

**Multiple Google accounts:** GWS CLI with direnv + profile directories. Seamless switching, zero manual intervention. MCP works with re-auth clicks. Gemini Workspace extension doesn't support it.

## How to Reproduce

1. Read the full [protocol](CLAUDE.md) for test methodology, fixtures, and naming conventions
2. Setup guides for each connector are in `results/{config}/setup.md`
3. Test fixtures in `fixtures/` — seed data content, upload files, expected values
4. Run with: `/seed {account}` then `/run-test {config} {account}` (see [commands reference](#commands-reference))

## Methodology

The [full protocol](CLAUDE.md) defines 15 component operations and a 6-step integration test, each with exact test data, success criteria, and failure handling rules. Every run uses identical fixtures. Session logs record wall-clock timestamps, exact CLI output, error messages, and artifact IDs. The [synthesis](synthesis/comparison.md) was written by a separate session that read all raw logs — not by the session that ran the tests.

The [v1 experiment](https://cruxcapacity.com/blog/2026-04-14/) tested the same tools without a protocol. The v1/v2 process comparison is documented in the [blog post](synthesis/blog-draft.md).

## Commands Reference

| Command | What it does |
|---------|-------------|
| `/next` | What to do next |
| `/status` | Dashboard of all runs and done criteria |
| `/seed gmail\|workspace` | Create seed test data |
| `/run-test {config} {account}` | Run one test (e.g., `B gmail`) |
| `/run-phase {0-6}` | Run all tests in a phase |
| `/synthesize` | Write comparison + blog draft from all logs |
| `/cleanup gmail\|workspace\|both` | Remove test artifacts |

## File Overview

| Path | Purpose |
|------|---------|
| [CLAUDE.md](CLAUDE.md) | Full research protocol |
| [synthesis/comparison.md](synthesis/comparison.md) | Cross-config analysis with per-operation results |
| [synthesis/blog-draft.md](synthesis/blog-draft.md) | Blog post draft |
| [results/](results/) | Session logs, setup docs, raw output per config |
| [fixtures/](fixtures/) | Seed data content and test fixtures |
| [skills/gws-cli-reference.md](skills/gws-cli-reference.md) | The ~1,900-token GWS CLI skill that eliminated 91K tokens of schema discovery |
| [templates/](templates/) | Publication spec, session log template, setup template |

---

*A [Crux Capacity](https://cruxcapacity.com) experiment.*
