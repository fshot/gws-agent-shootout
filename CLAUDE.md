# GWS Agent Shootout: v2 Research Protocol

## Purpose

Structured comparison of AI agent tools for programmatic Google Workspace access.
This is the v2 follow-up to a [sloppy v1 experiment](https://cruxcapacity.com/blog/2026-04-14-ai-google-workspace-v1/)
where Claude drove the research with no protocol and produced disorganized results.

The v1/v2 process comparison is part of the story: same tools, same person, same Claude, better structure.

## What we're testing

Can an AI agent create, read, edit, and share Google Workspace content (Docs, Sheets, Drive, Gmail, Calendar) on your behalf, triggered by a command, voice prompt, or scheduled job?

Not: "does Gemini work inside Google Docs?" We're testing external, agent-driven access.

## Tool matrix

Six configurations, each tested against two account types:

| Config | Agent | GWS connector | Notes |
|--------|-------|---------------|-------|
| **A** | Claude Cowork (desktop) | Built-in connectors | Baseline. Read-only reference point. |
| **B** | Claude Code | GWS CLI | v1 winner for coverage. Full CRUD. |
| **C** | Claude Code | google_workspace_mcp | Community MCP: [taylorwilsdon/google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp). 12 services, OAuth 2.1. |
| **D** | Codex CLI | GWS CLI | OpenAI's agent + same GWS CLI. Head-to-head with config B. |
| **E** | Gemini CLI | Workspace extension | [gemini-cli-extensions/workspace](https://github.com/gemini-cli-extensions/workspace). Pre-configured OAuth. |
| **F** | ChatGPT | Google Drive connector | Paid plan. Included for completeness. |

Account types per config:
- **@gmail.com** (free personal account)
- **@workspace** (paid Google Workspace account)

Total: 12 test runs (6 configs x 2 accounts). Config F may be @gmail.com only.

## Operation checklist

Each test run executes these operations in order. Record pass/fail, timing, and exact output.

### Component tests

| # | Category | Operation | Success criteria |
|---|----------|-----------|-----------------|
| 1 | Drive | Search for a file by name | Returns correct file with ID |
| 2 | Drive | Upload a local file | File appears in Drive, correct content |
| 3 | Drive | Share a file with another user | Permission granted, sharee can access |
| 4 | Docs | Read a Doc's content | Full text returned, structure preserved |
| 5 | Docs | Create a new Doc with formatted content | Doc created with headings, bold, lists |
| 6 | Docs | Edit an existing Doc (append + format) | Changes applied, existing content preserved |
| 7 | Sheets | Read cell range | Correct values returned |
| 8 | Sheets | Write to cell range | Values written, verifiable in Sheets UI |
| 9 | Sheets | Create a new Sheet with headers + data | Sheet created, data matches input |
| 10 | Gmail | Search messages | Correct messages returned |
| 11 | Gmail | Read a message body | Full body content returned |
| 12 | Gmail | Send an email | Email received by target, correct content |
| 13 | Calendar | List upcoming events | Events returned with correct details |
| 14 | Calendar | Create an event | Event appears on calendar |
| 15 | Calendar | Update an event (change time) | Change reflected in calendar |

### Integration test: meeting lifecycle

After component tests pass, run this end-to-end scenario:

1. Find last month's meeting notes (Drive search + Docs read)
2. Create this month's agenda Doc from a template
3. Update the recurring calendar event with agenda link
4. Send a reminder email to the committee
5. After the "meeting": create a summary Doc, log attendance in a Sheet

This mirrors real HDCA committee work. Record total time and intervention count.

## File conventions

```
gws-agent-shootout/
  CLAUDE.md                           # This file
  README.md                           # Public-facing summary (written last)
  results/
    {config}-{account}/               # e.g., claude-code-gws-cli-gmail/
      session-log.md                  # Raw session log from template
      screenshots/                    # Evidence screenshots
  synthesis/
    comparison.md                     # Cross-config analysis (written after all tests)
    blog-draft.md                     # v2 blog post draft
  templates/
    session-log-template.md           # Template for raw session logs
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

## Done criteria

- [ ] All 12 test runs completed with session logs
- [ ] Component test results tabulated in a cross-config matrix
- [ ] Integration test completed for at least configs B, C, D, E
- [ ] Synthesis comparison written by a separate session
- [ ] Blog draft v2 written, linking back to v1 for process comparison
- [ ] README written as the public entry point
