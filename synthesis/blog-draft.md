# Can AI Agents Actually Manage Your Google Workspace? We Tested 7 Configurations to Find Out.

Last month, I let Claude loose on the question "which AI agent can best manage Google Workspace?" The result was a [disorganized mess](https://cruxcapacity.com/blog/2026-04-14/) — interesting observations buried in rambling session logs, no reproducible test protocol, and conclusions I couldn't defend with data. Same tools, same person, same Claude. What was missing was structure.

So I wrote a protocol, pre-defined the test data, built fixture files, and ran the whole thing again. Here's what happened.

## What We Tested

Seven agent/connector configurations, each tested against a personal Gmail and a paid Google Workspace account. Each run executed 15 component tests across Drive, Docs, Sheets, Gmail, and Calendar — searching files, uploading documents, sharing with other users, reading spreadsheets, sending emails, creating and updating calendar events — plus a 6-step integration test simulating a real meeting workflow (find last month's notes, create an agenda, update the calendar, send a reminder, write a summary, log attendance).

The configurations:

- **A**: Claude Desktop + google_workspace_mcp (community MCP server)
- **B**: Claude Code + GWS CLI (Go-based CLI wrapping all Google APIs)
- **C**: Claude Code + google_workspace_mcp
- **D**: Codex CLI + GWS CLI
- **D2**: Codex CLI + google_workspace_mcp
- **E**: Gemini CLI + Workspace extension
- **F**: ChatGPT + built-in Google connectors

14 total runs, 13 completed (ChatGPT's workspace test was not finished).

## What Surprised Us

**The connector mattered more than the agent.** Claude Code and Codex, given the same GWS CLI connector, both scored 15/15 on both accounts. Given the same MCP server, both scored 15/15 on gmail and 14-15/15 on workspace. The LLM driving the session was not the differentiating factor — the tool it was given to talk to Google determined what was possible.

**Multi-account identity switching is the hardest unsolved problem.** Most people who need GWS agent access work across multiple Google accounts — personal and work, or multiple client domains. We tested every connector against both a personal Gmail and a paid Workspace account, and the range of multi-account behavior was striking. GWS CLI uses profile directories keyed by an environment variable, which enables the humble yet mighty 'direnv' tool to enable `cd`-ing into a different project directory to switch Google identity automatically — zero clicks, zero prompts. The google_workspace_mcp detected the account mismatch and prompted for OAuth re-auth (functional but manual). The Gemini Workspace extension silently continued using the first-authenticated account's credentials for all operations against the second account, producing results that looked like passes but were executing against the wrong identity. No error, no warning — just wrong data.

## The Results

Pass rates across all component tests (15 total) — gmail run first, workspace second:

| Config | Agent + Connector | Gmail | Workspace |
|--------|-------------------|-------|-----------|
| B | Claude Code + GWS CLI | 15/15 | 15/15 |
| D | Codex + GWS CLI | 15/15 | 15/15 |
| D2 | Codex + MCP | 15/15 | 15/15 |
| C | Claude Code + MCP | 15/15 | 14/15 |
| A | Claude Desktop + MCP | 14/15 | 15/15 |
| F | ChatGPT + built-in | 10/15 | — |
| E | Gemini + Workspace ext | 9/15 | 6/15* |

*E/workspace results are invalid — extension used the wrong account for all operations.

The integration test (6-step meeting lifecycle) showed the same pattern: configs B, D, D2, C, and A all scored 6/6 on both accounts. Config F scored 5/6 (blocked by the calendar limitation). Config E scored 3/6 on gmail and 2/6 on the invalid workspace run.

Full results, including per-operation timing, error messages, and artifact IDs, are in the [comparison analysis](https://github.com/fshot/gws-agent-shootout/blob/main/synthesis/comparison.md).

## The Hidden Cost of Tool Discovery

Every agent in this shootout had to learn how to talk to Google's APIs. How they learned — and what it cost in tokens — varied wildly.

Codex, given the GWS CLI with no reference material, did what any developer would: it ran `gws schema` to read the API schema for each endpoint it needed. Ten endpoints, read twice (once per failed attempt, once for the corrected run), totaling ~91,000 tokens of raw JSON schema. On its second run (different account), Codex independently discovered it could truncate the output with `sed -n '1,220p'`, cutting discovery to ~25,000 tokens. Smart, but still expensive.

Claude Code, given the same GWS CLI, never read a single schema. It had a curated `/gws` skill — a 7,560-byte reference file (~1,900 tokens) containing command patterns, common operations, and auth troubleshooting. That 1,900-token file replaced 91,000 tokens of schema probing. Config B's sessions were faster and had zero discovery failures.

MCP landed in between. The google_workspace_mcp server registers 70 tools with JSON schemas totaling ~30-40K tokens. In Claude Code, these load on demand (you pay for schemas only when you use them). In Codex, they're in the system prompt on every turn — and each turn re-sends them. Codex + MCP (config D2) used 1,244-1,357K total input tokens for the same 21 operations that Codex + GWS CLI (config D) completed in 416-933K.

The per-turn compounding is the real cost. Codex D generated a single bash script and ran all 21 operations in one command execution. Codex D2 made individual MCP tool calls — 12 separate round-trips, each carrying the full schema payload. The script approach used 3.3x fewer tokens for identical results.

The kicker: the skill that eliminated all that waste wasn't written as a token optimization. It was a [reference file](https://github.com/fshot/gws-agent-shootout/blob/main/skills/gws-cli-reference.md) someone wrote while learning the tool three weeks earlier — command patterns, common operations, auth troubleshooting. Just good documentation practice. The 48x token savings was a side effect.

The takeaway: if you expect to do GWS work regularly, write a curated reference for your tools and embed it in your agent's instruction file. A cheat sheet costs 50x less than raw schema probing and produces better results. MCP's token overhead is real but overblown — an agent discovering an unfamiliar CLI burns comparable tokens on schema reads. The difference is that MCP's cost is visible in your system prompt while CLI discovery is hidden in shell output.

## The v1/v2 Comparison

Was the protocol overhead worth it? Yes, unambiguously.

The v1 experiment took roughly the same calendar time but produced a blog post I had to heavily caveat. I couldn't tell you exactly which operations succeeded or failed for each tool, because I hadn't defined them in advance. I couldn't compare across tools because each one was tested with different data and different expectations. The "findings" were impressions, not measurements.

v2 produced a 15-row results matrix where every cell is backed by a session log with timestamps, exact commands, error messages, and artifact IDs. When I say "Config E can't upload files," I can point to the specific test that proved it. When I say "Config B completed in 5 minutes with zero interventions," that's a wall-clock measurement, not an estimate.

The protocol itself — the test fixtures, the naming conventions, the session log template — was written by Claude in a single session. The structure didn't slow us down. It's what made the results usable.

## Recommendations

**If you need full CRUD across Drive, Docs, Sheets, Gmail, and Calendar:** Use GWS CLI with either Claude Code or Codex. It's the only connector that passed everything on both accounts with zero tool-level workarounds needed.

**If you want a desktop experience without a CLI:** Use Claude Desktop with google_workspace_mcp. It achieved 14-15/15 on both accounts. Doc creation is more verbose (4 API round-trips vs. 1 CLI command), and you'll click through ~18 permission prompts on first use, but the functional coverage is nearly equivalent.

**If you need headless/scheduled operation:** GWS CLI configs (B, D) are the only tested options that work without any human in the loop after initial setup. MCP-based configs can work but require monitoring OAuth token expiry (7-day limit in GCP "Testing" mode). ChatGPT requires manual approval for every tool call — no headless mode exists.

### The setup worth stealing: folder-context identity switching

If you work across multiple Google accounts — personal and work, or multiple client domains — the most valuable thing we built for this project wasn't the test protocol. It was the `direnv` + GWS CLI profile setup that makes `cd` switch your Google identity.

The idea: each Google account gets its own profile directory under `~/.config/gws/profiles/`, containing its OAuth credentials. An environment variable (`GOOGLE_WORKSPACE_CLI_CONFIG_DIR`) tells GWS CLI which profile to use. `direnv` sets that variable automatically when you enter a project directory.

```
~/.config/gws/profiles/
  gmail/                    # fshotwell@gmail.com
    client_secret.json      # OAuth client ID (from GCP Console)
    credentials.enc         # Encrypted refresh token (from gws auth login)
    token_cache.json        # Cached access token (auto-managed)
  crux/                     # fshotwell@cruxcapacity.com
    client_secret.json
    credentials.enc
    token_cache.json
```

Each project directory gets a `.envrc` that sources the right account:

```bash
# results/claude-code-gws-cli-gmail/.envrc
source_up                   # inherit parent direnv
source_env ../../envs/gmail.env
```

```bash
# envs/gmail.env
export GWS_ACCOUNT=fshotwell@gmail.com
export GWS_TARGET_ACCOUNT=fshotwell@cruxcapacity.com
export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="${HOME}/.config/gws/profiles/gmail"
export GCP_PROJECT=hdca-workspace-tools
```

Now `cd results/claude-code-gws-cli-gmail && gws auth status` returns `fshotwell@gmail.com`, and `cd ../claude-code-gws-cli-workspace && gws auth status` returns `fshotwell@cruxcapacity.com`. No manual credential swapping. No re-authentication. No clicking through OAuth flows. The agent inherits the right identity from the directory it's working in.

To add a new account: create a profile directory, drop in a `client_secret.json` from a GCP project, run `gws auth login` once, and create an env file. Total time: 5 minutes. After that, every AI agent that uses GWS CLI in that directory context — Claude Code, Codex, a cron job — gets the right Google identity automatically.

This pattern isn't GWS-specific. Any CLI tool that reads credentials from an environment-variable-controlled path can use the same approach. The [full setup script](https://github.com/fshot/gws-agent-shootout/blob/main/scripts/setup-direnv.sh) and [env file templates](https://github.com/fshot/gws-agent-shootout/tree/main/envs) are in the repo.

## What's Next

The full test protocol, all 13 session logs, setup guides for each connector, and the raw data are in the [gws-agent-shootout repo](https://github.com/fshot/gws-agent-shootout). Everything needed to reproduce these results — or adapt the protocol for your own tool evaluation — is there.

The Workspace extension gaps (file upload, formatted docs, sheet writes) are specific to the current extension version. The Gemini CLI itself supports MCP servers and shell commands, so connecting it to GWS CLI or google_workspace_mcp would likely fill those gaps. We didn't test those cross-pairings because they aren't what Gemini users would naturally reach for today, but they're technically possible.

Similarly, ChatGPT's connector limitations may change as OpenAI expands their Google integration. The macOS desktop app's broken OAuth is presumably a bug, not a design choice. What we tested was the state of these tools in April 2026.

---

*This post is part of Crux Capacity's work on AI-assisted operations. The [v1 experiment](https://cruxcapacity.com/blog/2026-04-14/) and [full v2 protocol](https://github.com/fshot/gws-agent-shootout) are both public.*
