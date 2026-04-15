# Run an entire phase of the execution plan

Execute all test runs in a given phase, dispatching each as a subagent for context isolation.

**Phase**: $ARGUMENTS (must be `0`, `1`, `2`, `3`, `4`, `5`, or `6`)

## Instructions

Read `CLAUDE.md` section "Execution plan" to determine which configs/accounts belong to the requested phase.

### Phase mapping

| Phase | Configs | Runs |
|-------|---------|------|
| 0 | Seed data | `/project:seed gmail`, then `/project:seed workspace` |
| 1 | B | B/gmail, B/workspace |
| 2 | C | C/gmail, C/workspace |
| 3 | D, D2 | D/gmail, D/workspace, D2/gmail, D2/workspace |
| 4 | E, A, F | E/gmail, E/workspace, A/gmail, A/workspace, F/gmail, F/workspace |
| 5 | Synthesis | `/project:synthesize` |
| 6 | Cleanup | `/project:cleanup both` |

### Execution strategy

**Phase 0**: Run seed commands sequentially (gmail first, then workspace). Seed email step requires cross-account sending — handle both in sequence.

**Phases 1-2**: Run sequentially within the phase. The first run (gmail) produces the canonical setup doc; the second run (workspace) references it.

**Phase 3**: D and D2 can run in parallel (they use different connectors). Within each config, run gmail before workspace.
- **D/gmail → D/workspace**: dispatched via `./scripts/run-codex.sh D {account}`
- **D2/gmail → D2/workspace**: dispatched via `./scripts/run-codex.sh D2 {account}`

**Phase 4**: Configs E, A, and F are independent. Within each config, run gmail before workspace.
- **Config E**: Dispatched via `./scripts/run-gemini.sh {account}` — runs autonomously in Gemini CLI.
- **Config A**: Run directly in Claude Code using built-in connectors.
- **Config F**: Print operator instructions for ChatGPT web UI — cannot be automated.

**Phase 5**: Single synthesis run — invoke `/project:synthesize`.

**Phase 6**: Single cleanup run — invoke `/project:cleanup both`.

### Dispatch model

Different configs use different execution paths:

| Config | How dispatched | Orchestrated by |
|--------|---------------|-----------------|
| A, B, C | Subagent (Agent tool) running `/project:run-test` | Claude Code directly |
| D, D2 | `./scripts/run-codex.sh` via Bash tool | Codex CLI (reads AGENTS.md) |
| E | `./scripts/run-gemini.sh` via Bash tool | Gemini CLI (reads GEMINI.md) |
| F | Manual instructions printed for operator | Human (ChatGPT web UI) |

For configs D, D2, and E:
1. Run the wrapper script via Bash tool (with a generous timeout — up to 10 minutes per run).
2. After the script completes, read the `*-readable-output.md` file from the results directory.
3. Parse the structured results from the agent's output.
4. Write the `session-log.md` by filling in the template with the parsed results.

For configs A, B, C:
- Dispatch a subagent (Agent tool) with the config ID, account, and instructions to follow the `/project:run-test` workflow.
- Wait for each agent to complete before starting the next run in sequence.

### Progress tracking

After each run completes, print a progress line:
```
[Phase {N}] {config}/{account}: {pass}/{fail}/{blocked} — {total time}
```

After all runs in the phase complete, print a phase summary and suggest the next phase.
