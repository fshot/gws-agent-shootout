# Run a single test configuration

Execute the full component test + integration test for one config/account combination.

**Arguments**: $ARGUMENTS (format: `{config} {account}`, e.g., `B gmail` or `C workspace`)

## Instructions

Parse the arguments:
- First word: config ID (A, B, C, D, D2, E, or F)
- Second word: account type (`gmail` → `fshotwell@gmail.com`, `workspace` → `fshotwell@cruxcapacity.com`)

### Pre-flight checks

1. Read `CLAUDE.md` to load the full protocol — especially the operation checklist, failure handling, and naming conventions.
2. Read `fixtures/seed-ids-{account}.json` and confirm seed data IDs are populated (not null). If any are null, STOP and tell the operator to run `/project:seed {account}` first.
3. Check if `results/{config-name}-{account}/session-log.md` already exists. If so, warn the operator and ask whether to overwrite or abort.

### Determine the results directory name

| Config | Directory prefix |
|--------|-----------------|
| A | `claude-cowork-connectors` |
| B | `claude-code-gws-cli` |
| C | `claude-code-mcp` |
| D | `codex-gws-cli` |
| D2 | `codex-mcp` |
| E | `gemini-cli-workspace` |
| F | `chatgpt-drive` |

Full directory: `results/{prefix}-{gmail|workspace}/`

### Execution

1. **Create the results directory** and `screenshots/` subdirectory.

2. **Write setup.md** from `templates/setup-template.md`. Fill in what you can (agent version, date, account). For the connector installation steps, either:
   - Reference an earlier config's setup doc if this connector was already documented (e.g., config D references config B's GWS CLI setup).
   - Document the full setup if this is the first time this connector is being used.

3. **Create the isolation folder** in Drive: `[GWS-{CONFIG}] Shootout Results`

4. **Run all 15 component tests** in order per the operation checklist in CLAUDE.md.
   - Use the exact test data specified in the checklist.
   - Record each result in the session log table as you go.
   - Follow the failure handling protocol: retry transient errors up to 2x, skip on persistent failure, mark dependents as BLOCKED.
   - Capture timestamps for each operation.

5. **Run the integration test** (6 steps) per the protocol.

6. **Write the session log** from `templates/session-log-template.md` with all results filled in.

7. **Print a summary**: pass/fail counts, intervention count, total time.

### Connector-specific execution

#### Configs B, C (Claude Code — run directly)

- **Config B**: Use the GWS CLI (`gws` command) for all operations.
- **Config C**: Use the google_workspace_mcp MCP server tools.
- Execute tests directly in this Claude Code session.

#### Config A (Claude Code — built-in connectors)

- Use Claude's built-in Google Drive/Gmail/Calendar connectors (MCP tools prefixed `mcp__claude_ai_`).
- Execute tests directly in this Claude Code session.

#### Configs D, D2 (Codex CLI — dispatch via script)

These run in Codex CLI, not Claude Code. Dispatch autonomously:

1. Run `./scripts/run-codex.sh {D|D2} {gmail|workspace}` via Bash tool.
   - This invokes `codex exec --full-auto` with the test protocol from `AGENTS.md`.
   - Codex reads `AGENTS.md` automatically as its project instructions.
   - Raw JSONL output is captured to `results/{dir}/codex-raw-output.jsonl`.
   - Readable output is extracted to `results/{dir}/codex-readable-output.md`.

2. After the script completes, read `codex-readable-output.md` to get the structured results.

3. Parse the results and write the `session-log.md` from the template, filling in the results table from Codex's output.

4. If Codex fails to start or crashes, record that in the session log and note the exit code and any error output.

#### Config E (Gemini CLI — dispatch via script)

This runs in Gemini CLI, not Claude Code. Dispatch autonomously:

1. Run `./scripts/run-gemini.sh {gmail|workspace}` via Bash tool.
   - This invokes `gemini --prompt "..." --yolo --output-format json`.
   - Gemini reads `GEMINI.md` automatically as its project instructions.
   - Raw JSON output is captured to `results/{dir}/gemini-raw-output.json`.
   - Readable output is extracted to `results/{dir}/gemini-readable-output.md`.

2. After the script completes, read `gemini-readable-output.md` to get the structured results.

3. Parse the results and write the `session-log.md` from the template.

#### Config F (ChatGPT — manual)

This is a ChatGPT web UI test. Print step-by-step instructions for the operator to:
1. Open ChatGPT with Google Drive connector enabled
2. Execute each test operation manually
3. Record results in the session log template
4. Take screenshots of each operation

Do NOT attempt to automate config F.

### Important

- Do NOT interpret results or add commentary. Record observations only.
- Do NOT attempt workarounds for failures.
- Do NOT clean up test artifacts after the run.
- For Codex/Gemini dispatches: the wrapper scripts handle invocation, output capture, and exit codes. Your job is to run the script, parse the output, and write the session log.
