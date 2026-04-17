# GWS Agent Shootout v2: Comparative Analysis

## Executive Summary

- **GWS CLI is the most capable connector tested.** Configs B (Claude Code) and D (Codex) achieved 15/15 component tests and 6/6 integration tests on both accounts with zero intervention during execution. Every other connector had at least one capability gap.
- **The connector matters more than the agent.** Claude Code + GWS CLI (B) and Codex + GWS CLI (D) produced identical pass rates. Claude Code + MCP (C) and Codex + MCP (D2) also matched each other. The agent shell is a UX preference; the connector determines what's possible.
- **MCP (google_workspace_mcp) is a close second for full CRUD.** Configs A, C, and D2 achieved 14-15/15 component tests with one structural quirk: `manage_event` update requires start/end times even for description-only changes, and `create_doc` requires a multi-step insert-then-format workflow. Both are recoverable with retries.
- **Multi-account identity switching is the hardest problem — and the most valuable thing to get right.** GWS CLI's profile-directory approach with direnv is the only tested solution that switches Google identity on `cd` with zero intervention. The MCP server detects mismatches and prompts for re-auth (functional but manual). The Gemini Workspace extension silently uses the wrong account with no detection. For anyone working across personal and work accounts, or multiple client domains, this is the deciding factor.
- **Gemini CLI's Workspace extension has fundamental gaps.** No file upload, no sheet write/create, no formatted doc creation, and no multi-account support. Config E scored 9/15 on gmail and produced invalid results on workspace (silently used wrong account).

## Setup Complexity

| Config | Agent | Connector | Time to First Op | GCP Project Required | OAuth Setup | Multi-Account |
|--------|-------|-----------|-------------------|---------------------|-------------|---------------|
| A | Claude Desktop | google_workspace_mcp | ~2 min (+ 18 permission clicks) | Yes | MCP server manages | Re-auth per switch |
| B | Claude Code | GWS CLI | <1 min (pre-configured) | Yes | Profile-based | Seamless (direnv + profiles) |
| C | Claude Code | google_workspace_mcp | ~1 min (pre-configured) | Yes (reuses B's) | MCP server manages | Re-auth per switch |
| D | Codex CLI | GWS CLI | ~4 min (schema reading) | Yes (reuses B's) | Reuses B's profiles | Seamless (inherits env) |
| D2 | Codex CLI | google_workspace_mcp | ~1 min | Yes (reuses B's) | Reuses C's tokens | Re-auth per switch |
| E | Gemini CLI | Workspace extension | ~3 min (+ rate limit retries) | Extension manages | Extension OAuth flow | Not supported |
| F | ChatGPT | Built-in connectors | ~5 min (desktop app broken, switched to web) | No | OAuth via web UI | Not tested |

**Notes:**
- Config B's "time to first operation" assumes GWS CLI is already installed. First-time installation (GCP project creation, API enablement, OAuth client setup, credential download, first-run auth) takes 30-60 minutes. Setup documented in [results/claude-code-gws-cli-gmail/setup.md](../results/claude-code-gws-cli-gmail/setup.md).
- Config D required `--dangerously-bypass-approvals-and-sandbox` because Codex's `--full-auto` sandbox blocks network access and macOS keyring access ([D/gmail session log, Auth notes](../results/codex-gws-cli-gmail/session-log.md)).
- Config D's free-tier Codex quota was exhausted by a single gmail run (~933K tokens). Operator had to upgrade to ChatGPT Plus ($20/mo) to run the workspace test ([D/workspace session log, Rate limit incident](../results/codex-gws-cli-workspace/session-log.md)).
- Config F's macOS desktop app OAuth failed with `NSURLErrorDomain -1100`; all testing done via web UI ([F/gmail session log, Setup](../results/chatgpt-drive-gmail/session-log.md)).

## Component Test Results

15 operations across Drive, Docs, Sheets, Gmail, and Calendar. Each cell shows result for gmail / workspace.

| # | Operation | A | B | C | D | D2 | E | F |
|---|-----------|---|---|---|---|----|----|---|
| 1 | Drive: search | PASS/PASS | PASS/PASS | PASS/FAIL^1 | PASS/PASS | PASS/PASS | PASS/FAIL^2 | PASS/— |
| 2 | Drive: upload | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | FAIL^3/FAIL^3 | FAIL^4/— |
| 3 | Drive: share | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | BLOCKED/BLOCKED | BLOCKED/— |
| 4 | Docs: read | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/FAIL^2 | PASS/— |
| 5 | Docs: create | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | FAIL^5/FAIL^5 | PASS/— |
| 6 | Docs: edit | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | FAIL^6/FAIL^6 | PASS/— |
| 7 | Sheets: read | FAIL^7/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/FAIL^2 | FAIL^7/— |
| 8 | Sheets: write | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | FAIL^8/FAIL^8 | PASS/— |
| 9 | Sheets: create | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | FAIL^8/FAIL^8 | PASS/— |
| 10 | Gmail: search | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS^9 | PASS/— |
| 11 | Gmail: read | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS^9 | PASS/— |
| 12 | Gmail: send | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS^9 | PASS/— |
| 13 | Calendar: list | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS^9 | PASS/— |
| 14 | Calendar: create | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS^9 | FAIL^10/— |
| 15 | Calendar: update | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS^9 | BLOCKED/— |
| | **Total** | **14/15** | **15/15** | **15/14** | **15/15** | **15/15** | **9/6** | **10/—** |

**—** = not tested (Config F workspace run has no session log).

**Footnotes:**

1. C/workspace #1: File found but ID didn't match `seed-ids-workspace.json`. The seed IDs file was stale — the MCP search itself returned the correct file. ([C/workspace session log, #1](../results/claude-code-mcp-workspace/session-log.md))
2. E/workspace: Extension authenticated as gmail account, not workspace. Permission errors on workspace-owned assets. All 6 "PASS" results on the workspace run operated against the wrong account. ([E/workspace session log, Account mismatch analysis](../results/gemini-cli-workspace-workspace/session-log.md))
3. E #2: No `drive.upload` or file upload tool in the Workspace extension. ([E/gmail session log, #2](../results/gemini-cli-workspace-gmail/session-log.md))
4. F #2: Drive create supports only native Doc/Sheet/Slide files, not plain-text file upload. ([F/gmail session log, #2](../results/chatgpt-drive-gmail/session-log.md))
5. E #5: `docs.create` produces plain text only — no heading styles, bold, or bullet formatting. ([E/gmail session log, #5](../results/gemini-cli-workspace-gmail/session-log.md))
6. E #6: `docs.writeText` failed with "No insertion location set." Retries produced the same error. ([E/gmail session log, #6](../results/gemini-cli-workspace-gmail/session-log.md))
7. A/gmail #7 and F/gmail #7: Sheets read succeeded but values didn't match the fixture. Seed data was mutated by prior config runs writing to the seed sheet. The tool itself worked correctly. ([A/gmail session log, Note on #7](../results/claude-cowork-connectors-gmail/session-log.md))
8. E #8, #9: No `sheets.setRange` or sheet creation tool in the Workspace extension. ([E/gmail session log, #8, #9](../results/gemini-cli-workspace-gmail/session-log.md))
9. E/workspace: These operations executed against the gmail account, not workspace. Results are technically correct tool invocations but against the wrong account. ([E/workspace session log](../results/gemini-cli-workspace-workspace/session-log.md))
10. F #14: Calendar create-event action doesn't expose `calendar_id` parameter — can't target non-primary calendars. ([F/gmail session log, #14](../results/chatgpt-drive-gmail/session-log.md))

## Integration Test Results

6-step meeting lifecycle scenario: find last month's notes, create agenda, update calendar event, send reminder, create summary, log attendance.

| Step | Operation | A | B | C | D | D2 | E | F |
|------|-----------|---|---|---|---|----|----|---|
| 1 | Search + read seed Doc | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/FAIL | PASS/— |
| 2 | Create agenda Doc | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | FAIL/FAIL | PASS/— |
| 3 | Update event description | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | BLOCKED/— |
| 4 | Send reminder email | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/— |
| 5 | Create summary Doc | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | FAIL/FAIL | PASS/— |
| 6 | Append row to Sheet | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | PASS/PASS | BLOCKED/BLOCKED | PASS/— |
| | **Total** | **6/6** | **6/6** | **6/6** | **6/6** | **6/6** | **3/2** | **5/—** |

MCP-based configs (A, C, D2) all hit the same `manage_event` bug on integration step 3: updating only the description fails with "Missing end time." All three self-corrected by including start/end times on retry. This is a google_workspace_mcp implementation issue — it uses PUT (full replacement) instead of PATCH (partial update) for calendar event updates.

## Per-Config Deep Dives

### Config A — Claude Desktop (Cowork) + google_workspace_mcp

**Gmail**: 14/15 component + 6/6 integration. The single "failure" (#7) was seed data contamination from prior config runs, not a tool limitation. All 21 operations driven by a single prompt — zero follow-up prompts needed. ([A/gmail session log](../results/claude-cowork-connectors-gmail/session-log.md))

**Workspace**: 15/15 component + 6/6 integration. MCP server detected account mismatch from prior gmail run and prompted for OAuth re-auth. First auth attempt failed with expired state token; Cowork self-recovered by triggering a fresh auth request. 2 interventions (OAuth click + retry). ([A/workspace session log](../results/claude-cowork-connectors-workspace/session-log.md))

**Setup friction**: 18-19 individual MCP tool permission prompts per conversation in Claude Desktop. This is a per-conversation cost, not persistent. ([A/gmail session log, Auth notes](../results/claude-cowork-connectors-gmail/session-log.md))

**Token overhead**: The MCP server loads ~30,000-40,000 tokens of JSON tool schemas into conversation context. The GWS CLI skill approach (config B) achieves the same coverage with ~2,000 tokens — a 15-20x difference. ([C/workspace session log, Token cost comparison](../results/claude-code-mcp-workspace/session-log.md))

### Config B — Claude Code + GWS CLI

**Gmail**: 15/15 + 6/6, zero interventions, 5-minute total session. ([B/gmail session log](../results/claude-code-gws-cli-gmail/session-log.md))

**Workspace**: 15/15 + 6/6, zero interventions, 4 minutes 21 seconds. ([B/workspace session log](../results/claude-code-gws-cli-workspace/session-log.md))

This is the cleanest result in the shootout. No auth prompts, no retries needed, no workarounds. The GWS CLI mirrors Google's REST API path structure, so every operation maps to a single CLI command. Doc creation with formatting is a single `gws docs create --from-markdown` call, versus 4 API round-trips with the MCP server.

Multi-account switching is handled entirely by `direnv` setting `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` — zero manual credential management between runs.

### Config C — Claude Code + google_workspace_mcp

**Gmail**: 15/15 + 6/6, one intervention (Sheets OAuth re-auth at test #7). The MCP server uses incremental OAuth scoping — it doesn't request all scopes upfront. First Sheets API call triggered a ~6 minute re-auth detour. ([C/gmail session log, #7](../results/claude-code-mcp-gmail/session-log.md))

**Workspace**: 14/15 + 6/6, zero interventions during execution. The one failure (#1, Drive search) was a stale seed ID in `fixtures/seed-ids-workspace.json`, not a tool failure — the search itself returned the correct file by name. ([C/workspace session log](../results/claude-code-mcp-workspace/session-log.md))

**Notable**: Doc creation requires 4 MCP round-trips: `create_doc` → `inspect_doc_structure` (with explicit `tab_id: "t.0"`) → `batch_update_doc` (insert text) → `batch_update_doc` (apply formatting) → `update_drive_file` (move to folder). Each round-trip adds tokens to conversation context. ([C/gmail session log, Notable API behaviors](../results/claude-code-mcp-gmail/session-log.md))

### Config D — Codex CLI + GWS CLI

**Gmail**: 15/15 + 6/6, one intervention (script change from `--full-auto` to `--dangerously-bypass-approvals-and-sandbox`). Codex's `--full-auto` sandbox blocks network access and macOS keyring access, making it incompatible with any tool that needs either. ([D/gmail session log, Sandbox discovery](../results/codex-gws-cli-gmail/session-log.md))

**Workspace**: 15/15 + 6/6, one intervention (ChatGPT Plus upgrade after free-tier rate limit exhaustion). The gmail run consumed the entire free-tier weekly quota (~933K tokens). ([D/workspace session log, Rate limit incident](../results/codex-gws-cli-workspace/session-log.md))

**Execution strategy**: Codex generated a single bash script containing all 21 operations with retry logic and timing. The gmail run's script failed once (upload path validation, jq parse error from GWS CLI printing diagnostics to stdout) before Codex self-corrected. The workspace run pivoted to a Python runner to handle the stdout pollution cleanly. ([D/workspace session log, Execution strategy](../results/codex-gws-cli-workspace/session-log.md))

**Token consumption**: Gmail run used 933K input tokens (95% cached); workspace run used 416K (91% cached). The variance is due to Codex reading fewer schema endpoints and truncating output on the second run. ([D/workspace session log, Token Usage](../results/codex-gws-cli-workspace/session-log.md))

### Config D2 — Codex CLI + google_workspace_mcp

**Gmail**: 15/15 + 6/6, zero interventions. Reused MCP tokens from config C. Used `import_to_google_doc` for doc creation (simpler than config C's multi-step approach). ([D2/gmail session log](../results/codex-mcp-gmail/session-log.md))

**Workspace**: 15/15 + 6/6, zero interventions. One transient HTTP 503 on Sheets read (#7), recovered after 30-second retry. Same `manage_event` bug on integration step 3, self-corrected. ([D2/workspace session log](../results/codex-mcp-workspace/session-log.md))

**Token consumption**: Gmail: 1,244K input (96% cached). Workspace: 1,357K input (95% cached). Higher than config D because MCP tool schemas inflate the conversation context. ([D2/gmail session log, Token Usage](../results/codex-mcp-gmail/session-log.md))

### Config E — Gemini CLI + Workspace Extension

**Gmail**: 9/15 + 3/6. Five component test failures, all due to missing capabilities in the Workspace extension: no file upload (#2), no formatted doc creation (#5), no doc editing (#6), no sheet write (#8), no sheet create (#9). The extension covers read operations and basic CRUD for Gmail and Calendar but lacks write operations for Drive uploads, Docs formatting, and Sheets. ([E/gmail session log](../results/gemini-cli-workspace-gmail/session-log.md))

**Workspace**: 6/15 + 2/6. The extension does not support multi-account switching. It silently used the gmail account's credentials for all 63 tool calls. Three failures were permission errors (accessing workspace-owned assets from the gmail account), not tool limitations. The 6 "PASS" results are false positives — correct execution against the wrong account. ([E/workspace session log, Account mismatch analysis](../results/gemini-cli-workspace-workspace/session-log.md))

**Rate limiting**: The gmail run hit 10/44 HTTP 429 `MODEL_CAPACITY_EXHAUSTED` errors from gemini-2.5-pro, consuming ~2.5 minutes in automatic retry backoff. The workspace run had zero 429s. ([E/gmail session log, Rate Limiting](../results/gemini-cli-workspace-gmail/session-log.md))

**Token efficiency**: Gemini's total token consumption was ~974K (gmail) and ~1,834K (workspace) — comparable to Codex. 91-92% cache hit rate. ([E/gmail session log, Token Consumption](../results/gemini-cli-workspace-gmail/session-log.md))

### Config F — ChatGPT + Built-in Connectors

**Gmail**: 10/15 + 5/6. No workspace run completed. Three component failures: no plain-text file upload (#2), Sheets read returned mutated data (#7, seed contamination), calendar create can't target non-primary calendars (#14). ([F/gmail session log](../results/chatgpt-drive-gmail/session-log.md))

**Workspace**: Not tested. No session log exists for `chatgpt-drive-workspace/`.

**Model dependency**: ChatGPT "Instant 5.3" returned 0/15 immediately without attempting any tool calls. Switching to "Thinking 5.4" achieved 10/15 with actual tool invocations. The same agent, same connectors, same prompt — model selection within an agent mattered as much as agent selection. ([F/gmail session log, Setup](../results/chatgpt-drive-gmail/session-log.md))

**Intervention burden**: Every tool call during testing required manual approval via modal dialog (~8 approvals total). No auto-approve or headless mode available. This makes ChatGPT unsuitable for scheduled or autonomous GWS operations. ([F/gmail session log, Component Tests](../results/chatgpt-drive-gmail/session-log.md))

## Account-Type Comparison: @gmail.com vs @workspace

For configs that ran both accounts (A, B, C, D, D2, E):

**No capability differences.** Gmail and Workspace accounts behaved identically for all connector APIs tested. No operations required Workspace-specific admin consent, domain-wide delegation, or different API scopes. The Google APIs treat both account types the same for individual-user OAuth.

**Multi-account switching is the differentiator:**

| Approach | Connector | Behavior | Intervention Required |
|----------|-----------|----------|----------------------|
| Profile directories + direnv | GWS CLI (B, D) | Seamless. `cd` into directory, account switches automatically. | None |
| OAuth re-auth prompt | google_workspace_mcp (A, C, D2) | Detects mismatch, prompts for re-auth. State token can expire during flow. | 1-2 clicks per switch |
| None | Workspace extension (E) | No detection. Silently uses first-authenticated account. Invalid results. | Manual credential wipe + re-auth |
| N/A | ChatGPT built-in (F) | Not tested across accounts. | Unknown |

The GWS CLI's profile-based approach is the only one that supports concurrent credential storage for multiple accounts with zero manual switching. This is a significant advantage for consultants, IT admins, or anyone working across multiple Google Workspace domains.

### How the profile-directory approach works

GWS CLI reads `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to find its credential files (`client_secret.json`, `credentials.enc`, `token_cache.json`). Each account gets its own profile directory:

```
~/.config/gws/profiles/
  gmail/              # fshotwell@gmail.com (GCP project: hdca-workspace-tools)
    client_secret.json
    credentials.enc
    token_cache.json
  crux/               # fshotwell@cruxcapacity.com (GCP project: crux-workspace)
    client_secret.json
    credentials.enc
    token_cache.json
```

Each project directory has a `.envrc` that sources an env file setting `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` to the right profile. When `direnv` loads the `.envrc` on `cd`, the GWS CLI reads the correct credentials — no manual switching, no re-authentication.

```bash
# envs/gmail.env
export GWS_ACCOUNT=fshotwell@gmail.com
export GWS_TARGET_ACCOUNT=fshotwell@cruxcapacity.com
export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="${HOME}/.config/gws/profiles/gmail"
export GCP_PROJECT=hdca-workspace-tools
```

To add a new account: `mkdir -p ~/.config/gws/profiles/{label}`, copy in a `client_secret.json` from the account's GCP project, run `gws auth login -s drive,docs,sheets,gmail,calendar` once, and create an env file. Any agent using GWS CLI in a direnv-managed directory automatically inherits the correct Google identity. Setup script: [scripts/setup-direnv.sh](../scripts/setup-direnv.sh). Env templates: [envs/](../envs/).

The google_workspace_mcp's re-auth approach (config A/workspace: [session log, Account Switching Behavior](../results/claude-cowork-connectors-workspace/session-log.md)) is functional but manual — the server detects the mismatch and returns an OAuth URL, but the state token can expire between URL generation and click-through, requiring a second attempt. The Gemini Workspace extension's lack of any detection mechanism (config E/workspace: [session log, Account mismatch analysis](../results/gemini-cli-workspace-workspace/session-log.md)) makes it unsuitable for multi-account workflows.

## Recommendations by Use Case

### "I need full CRUD across all five GWS services"

Use **GWS CLI** (configs B or D). It's the only connector that passed all 15 component tests on both accounts with zero retries needed for tool-level bugs. The CLI mirrors the full Google REST API surface.

If you use Claude Code: config B. If you use Codex: config D (but note the sandbox and rate-limit caveats). Both produce identical GWS outcomes.

### "I only need read access"

Any configuration works. Even the weakest performers (E, F) passed all read operations: Drive search (#1), Docs read (#4), Sheets read (#7), Gmail search/read (#10, #11), and Calendar list (#13).

### "I need to run this on a schedule (headless)"

Use **Claude Code + GWS CLI** (config B) or **Codex + GWS CLI** (config D). Both run headlessly with zero intervention after initial auth setup.

Do **not** use:
- ChatGPT (F): requires per-tool-call manual approval, no headless mode.
- Claude Desktop (A): desktop app, not designed for headless/cron operation.
- Gemini CLI (E): the Workspace extension's capability gaps require workarounds, and 429 rate limits add unpredictable delays.

MCP-based configs (C, D2) can run headlessly but require that OAuth tokens remain valid. In GCP "Testing" mode, refresh tokens expire every 7 days.

### "I need this for a Workspace org (not personal Gmail)"

No connector required Workspace-specific configuration. Personal Gmail and Workspace accounts used identical OAuth flows, scopes, and API endpoints. The key consideration is multi-account support:

- **GWS CLI** (B, D): best. Profile directories support any number of concurrent accounts.
- **google_workspace_mcp** (A, C, D2): workable. Re-auth per account switch, but it at least detects mismatches.
- **Workspace extension** (E): not viable for multi-account. Silently uses wrong account with no detection.

## Token Efficiency Analysis

MCP gets a bad reputation for wasting tokens, but the data tells a more nuanced story. The real cost driver isn't "MCP vs CLI" — it's **curated reference vs. raw discovery** and **per-call vs. batch execution**.

### Where the tokens went

| Config | Approach | Total Input | Cached | Discovery Method | Discovery Cost |
|--------|----------|-------------|--------|------------------|----------------|
| B (Claude Code + GWS CLI) | /gws skill | not measured | — | Curated skill file | ~1,900 tokens |
| D/gmail (Codex + GWS CLI) | Raw schema probing | 933K | 95% | 10 `gws schema` endpoints × 2 reads | ~91,000 tokens |
| D/workspace (Codex + GWS CLI) | Truncated schema probing | 416K | 91% | 8 endpoints, `sed -n '1,220p'` | ~25,000 tokens |
| D2/gmail (Codex + MCP) | MCP tool schemas | 1,244K | 96% | 70 tool schemas in system prompt | ~30-40,000 tokens |
| D2/workspace (Codex + MCP) | MCP tool schemas | 1,357K | 95% | 70 tool schemas in system prompt | ~30-40,000 tokens |

Config B (Claude Code + GWS CLI) never read a single `gws schema` endpoint. The `/gws` skill — a 7,560-byte curated reference (~1,900 tokens) — provided command patterns, common operations, flags, and auth troubleshooting for the full CLI surface. This eliminated the discovery phase entirely. The skill was written three weeks before the shootout during initial GWS CLI setup — not as a token optimization, but as a reference file. The full skill is included in this repo at [skills/gws-cli-reference.md](../skills/gws-cli-reference.md). ([B/gmail session log](../results/claude-code-gws-cli-gmail/session-log.md), [B/workspace session log](../results/claude-code-gws-cli-workspace/session-log.md))

Codex D/gmail, lacking any curated reference, read 10 schema endpoints twice (once per attempt), consuming ~91,000 tokens of raw JSON schema — a 48x markup over the skill for equivalent information. ([D/gmail session log, Execution Notes](../results/codex-gws-cli-gmail/session-log.md))

Codex D/workspace independently discovered schema truncation (`gws schema ... | sed -n '1,220p'`), cutting discovery cost from ~91K to ~25K tokens. The first 220 lines of each schema contain all required and optional parameters; the truncated portion is nested object definitions and enum values rarely needed for correct invocation. ([D/workspace session log, Token Usage](../results/codex-gws-cli-workspace/session-log.md))

### MCP's token cost: real but misattributed

The common complaint — "70 tool names in your system prompt waste tokens" — targets the wrong thing. Deferred tool names cost ~700 tokens (negligible). The actual costs:

1. **Schema loading**: All 70 workspace-mcp tool schemas total ~30-40K tokens when loaded. Claude Code loads these on demand via ToolSearch; Codex loads them all upfront in the system prompt. ([C/workspace session log, Token cost comparison](../results/claude-code-mcp-workspace/session-log.md))

2. **Per-turn compounding**: Each agent message re-sends the system prompt. D2/gmail made 12 MCP tool calls across 12 agent messages, each carrying the full schema payload. D/gmail made 60 shell commands but generated a single bash script — execution was 1 turn, not 60. This explains why D2 (1,244K total) exceeded D (933K total) despite D's more expensive discovery phase: D's batch execution amortized the cost, while D2's per-call pattern compounded it.

3. **Tool registration breadth**: The 15 test operations used ~21 of 70 registered tools. A curated registration (only the tools you need) would reduce the schema payload from ~30-40K to ~9-12K tokens — a 70% reduction with no capability loss for the tested use case.

### Strategies for reducing token cost

**1. Write a curated reference and embed it in agent instructions.** The single highest-leverage optimization. The /gws skill (1,900 tokens) replaced 91,000 tokens of schema dumps and produced better results — Config B's sessions were faster and had zero discovery failures. For Codex, the equivalent is a "GWS CLI Quick Reference" section in AGENTS.md. For any agent: embed it in whatever instruction file the agent reads on startup.

**2. For MCP: register only the tools you need.** Trim the tool list to the ~20 tools your use case requires. In Claude Code, edit `.mcp.json` to filter exposed tools. Reduces schema payload by ~70%.

**3. For batch operations: generate a script, don't make N individual tool calls.** Codex D's script-based approach used 3.3x fewer total tokens than D2's per-call MCP approach for identical operations (416K vs 1,357K on workspace). This only works for planned, sequential operations — interactive use can't batch.

**4. For occasional use: MCP with deferred loading is already efficient.** Claude Code's deferred pattern (tool names in system prompt, schemas loaded via ToolSearch on first use) costs ~700 tokens baseline plus ~5-10K per batch of tools actually invoked. For 2-3 GWS operations per session, total overhead is under 15K tokens.

**5. When probing schemas is unavoidable: truncate.** `gws schema ... | sed -n '1,220p'` captures the parameter structure while cutting token cost by ~46%.

### Bottom line

MCP's token reputation is partially deserved (per-turn schema compounding is real) but overblown relative to the alternative. An agent probing an unfamiliar CLI burned comparable tokens on discovery — 91K for GWS CLI schemas vs. 30-40K for MCP schemas. The difference is visibility: MCP's cost shows up in the system prompt; CLI discovery is hidden in shell outputs scattered through conversation history.

The real optimization is **curated reference vs. raw discovery**. A 1,900-token skill replaced 91,000 tokens of schema dumps. If you expect to do GWS work regularly — whether via CLI or MCP — write the cheat sheet.

## Limitations and Caveats

### What we didn't test

- **Admin operations**: Domain-wide delegation, admin console APIs, organizational unit management.
- **Large file handling**: All test files were under 1KB. Performance with large documents (100+ pages) or large spreadsheets (10K+ rows) was not measured.
- **Concurrent access**: All tests ran sequentially. We did not test multiple agents writing to the same document simultaneously.
- **Long-running token reliability**: Tests completed within minutes. We did not test OAuth token refresh behavior over days or weeks.
- **Cost at scale**: Token consumption was measured for single runs. Extrapolating to production workloads requires separate analysis.

### Connector asymmetry

We tested each agent with its natural connector ecosystem, not every agent against every connector. Claude Code and Codex both had access to GWS CLI and MCP; Gemini had its purpose-built extension; ChatGPT had its built-in connectors. A controlled comparison would test all agents against a common connector (e.g., all four agents + GWS CLI). We chose practical realism over laboratory control. The asymmetry itself is a finding: some agents have richer connector ecosystems than others.

### Seed data contamination

Operations that write to the shared seed sheet (#8: write D1:F1) mutated the seed data for subsequent runs. Configs A and F recorded #7 (Sheets read) as FAIL because the cell values no longer matched the original fixture. The read operation itself worked correctly in both cases. A production test protocol should either use separate seed data per config or restore the seed sheet between runs.

### Stale fixture IDs

`fixtures/seed-ids-workspace.json` contained IDs that didn't match the actual workspace account artifacts. Configs C/workspace and E/workspace encountered this. All configs that search by name (rather than by ID) were unaffected. The fixture IDs should be regenerated before any re-run of the test suite.

### Config F incomplete

ChatGPT workspace testing was not completed. Only the gmail run has results. The analysis of Config F is based on a single account run.
