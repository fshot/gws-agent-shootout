# Synthesis Framing Notes

These are editorial decisions made during testing that should guide the synthesis and blog draft. Written by the operator + Claude Code after completing all test runs.

## Why we didn't cross-test agents with every connector

We tested each agent with the GWS connectors available to it — the configurations a real user would encounter:

- **Claude Code and Codex** were tested with both GWS CLI and the community google_workspace_mcp server, because those are the connectors their users would reach for.
- **Gemini CLI** was tested with its own Workspace extension (the gemini-cli-extensions/workspace project), because that's what exists for Gemini.
- **ChatGPT** was tested with its built-in Google Drive, Calendar, and Gmail connectors, because that's what OpenAI ships.

We did **not** cross-test every agent with every connector (e.g., Gemini + GWS CLI, ChatGPT + MCP). Here's why:

1. **ChatGPT desktop MCP is broken.** The macOS app's OAuth callback fails with `NSURLErrorDomain -1100` on every Google connector. We couldn't connect MCP even if we wanted to.

2. **Gemini + GWS CLI is a synthetic pairing.** Nobody would naturally use Gemini CLI with GWS CLI — the Workspace extension exists specifically for Gemini. Testing fabricated pairings muddies the practical guidance.

3. **The asymmetry is the finding.** Some agents have richer connector ecosystems than others. Claude Code and Codex benefit from GWS CLI (a mature, full-CRUD tool) and a growing MCP ecosystem. Gemini has a purpose-built but limited extension. ChatGPT has built-in connectors that work surprisingly well for Drive/Docs/Gmail but can't target secondary calendars or upload arbitrary files. That ecosystem difference is itself a result worth reporting.

4. **We're comparing configurations, not agents in a vacuum.** The test matrix has 7 configs, not 7 agents. Each config is an agent + connector pairing that someone would actually use. The comparison answers "which setup should I use?" not "which LLM is smartest?"

### What this means for the synthesis

- Frame results as "Config X achieved Y" not "Agent X is better than Agent Z."
- When a config fails, note whether the limitation is likely the agent or the connector, but don't claim certainty unless we tested the same connector with another agent (which we did for GWS CLI: configs B and D, and for MCP: configs C and D2).
- Acknowledge the asymmetry in the limitations section. A fair future test would be to run all agents against a common connector (e.g., all agents + GWS CLI). We chose practical realism over laboratory control.

## Model selection matters (ChatGPT finding)

ChatGPT's result was dramatically model-dependent:
- **Instant 5.3**: returned 0/15 immediately without attempting any tool calls
- **Thinking 5.4**: achieved 10/15 with actual tool invocations

This is worth calling out — the same agent, same connectors, same prompt, but the "fast" model didn't even try. The synthesis should note that model selection within an agent can matter as much as agent selection itself.

## Intervention burden

ChatGPT required ~8 manual approval clicks for the full run (every tool call gets a modal dialog, no auto-approve option). Other agents (Claude Code, Codex in full-auto, Gemini in yolo mode) ran with zero or near-zero intervention after initial setup. This is a meaningful UX difference for anyone planning to use these in automation or scheduled jobs.
