# Session Log: A / workspace

**Date**: 2026-04-16
**Config**: A — Claude Desktop (Cowork) + google_workspace_mcp
**Model**: Opus 4.6 (tested for consistency with other configs run 2026-04-15/16; Opus 4.7 was available but not used)
**Account**: fshotwell@cruxcapacity.com
**Operator**: Frank Shotwell
**Session duration**: ~10 minutes (estimated from Cowork output cadence)

## Setup

**Time to first operation**: ~3 minutes (includes OAuth re-auth flow, state token expiry/retry, and 19 permission approval prompts)
**Setup doc**: [setup.md](setup.md) (references gmail setup)
**Setup summary**: Reused Claude Desktop MCP config from A / gmail. MCP server detected account mismatch and prompted for OAuth re-auth to workspace account.
**Auth notes**: The MCP server was authenticated as fshotwell@gmail.com from the gmail run. On first tool call (`search_drive_files`), it detected the account mismatch and returned an OAuth authorization URL. First auth attempt failed with "Invalid or expired OAuth state parameter" — the state token expired between URL generation and the user clicking through. Cowork self-recovered by triggering a fresh auth request. Second attempt succeeded. Account verified as fshotwell@cruxcapacity.com via seed file ID match before proceeding.

## Pre-test: Isolation Folder

**Folder created**: yes
**Folder name**: `[GWS-A] Shootout Results`
**Folder ID**: `{folder-id}`

## Component Tests

Result values: `PASS`, `FAIL`, `BLOCKED (by #N)`, `SKIP`

| # | Operation | Result | Time | Retries | Notes |
|---|-----------|--------|------|---------|-------|
| 1 | Drive: search for `gws-shootout-seed.txt` | PASS | ~2s | 0 | Returned expected ID `{drive-id}`. Used as account verification step. |
| 2 | Drive: upload `fixtures/upload-test.txt` | PASS | ~3s | 0 | File ID: `{drive-id}`. |
| 3 | Drive: share uploaded file with fshotwell@gmail.com | PASS | ~2s | 0 | Reader permission granted, permission ID `{perm-id}`. |
| 4 | Docs: read `GWS Shootout — Seed Document` | PASS | ~2s | 0 | All headings, paragraphs, bullets, and preservation paragraph present. |
| 5 | Docs: create `[GWS-A] Created Test Doc` | PASS | ~10s | 0 | Multi-step: create → insert text → inspect structure → apply formatting (H1, bold, H2, bullets) → move to isolation folder. Doc ID: `{folder-id}`. |
| 6 | Docs: edit (append to Doc from #5) | PASS | ~5s | 0 | Appended H2 "Added by A" with paragraph and 3 bullets. Original content unchanged. |
| 7 | Sheets: read A1:C5 from `GWS Shootout — Seed Sheet` | PASS | ~2s | 0 | Read succeeded. Values differ from fixture spec (roles/scores mismatch, e.g. "PM" vs "Manager", "92" vs "95") — seed data modified by prior config runs. Tool works correctly. |
| 8 | Sheets: write D1:F1 to seed Sheet | PASS | ~2s | 0 | D1="Updated", E1="by", F1="A" written successfully. |
| 9 | Sheets: create `[GWS-A] Created Test Sheet` | PASS | ~4s | 0 | Sheet ID: `{sheet-id}`. Headers + 5 data rows. |
| 10 | Gmail: search for `GWS Shootout — Seed Email` | PASS | ~2s | 0 | Found 2 messages matching subject. |
| 11 | Gmail: read message from #10 | PASS | ~2s | 0 | Body contains `This is a seed email for search and read testing.` |
| 12 | Gmail: send `[GWS-A] Test Email from Shootout` to fshotwell@gmail.com | PASS | ~2s | 0 | Message ID: `{msg-id}`. |
| 13 | Calendar: list events on `GWS Shootout` calendar | PASS | ~2s | 0 | Returned seed event `GWS Shootout — Seed Event` (ID `{event-id}`). |
| 14 | Calendar: create `[GWS-A] Test Event` | PASS | ~3s | 0 | Event ID: `{event-id}`. 10:00 AM CDT on 2026-04-19. |
| 15 | Calendar: update event from #14 (move +1 hour) | PASS | ~2s | 0 | Moved to 11:00 AM CDT (16:00 UTC). |

**Pass**: 15/15
**Fail**: 0/15
**Blocked**: 0/15
**Intervention count**: 2 (OAuth re-auth click + retry after state token expiry; 19 permission approvals were pre-test setup, same as gmail run)

## Integration Test: Meeting Lifecycle

| Step | Operation | Result | Time | Retries | Notes |
|------|-----------|--------|------|---------|-------|
| 1 | Search Drive + read `GWS Shootout — Seed Document` | PASS | ~3s | 0 | Seed document found, content matches. |
| 2 | Create `[GWS-A] April 2026 Committee Agenda` | PASS | ~8s | 0 | Doc ID: `{doc-id}`. H1, H2, bold, bullets applied. |
| 3 | Update `[GWS-A] Test Event` description with agenda link | PASS | ~4s | 1 | First attempt failed: `Missing end time.` Must include start_time/end_time even when only changing description. Retry succeeded. |
| 4 | Send `[GWS-A] Committee Meeting Reminder` to fshotwell@gmail.com | PASS | ~2s | 0 | Message ID: `{msg-id}`. Body includes agenda Doc URL. |
| 5 | Create `[GWS-A] April 2026 Committee Summary` | PASS | ~6s | 0 | Doc ID: `{doc-id}`. H1, 2 H2s, 3 decision bullets, 3 action item bullets. |
| 6 | Append row to `[GWS-A] Created Test Sheet` | PASS | ~2s | 0 | Row appended to A7:C7: `Meeting`, `2026-04-15`, `3 attendees`. |

**Total time**: ~25s (excluding setup/auth)
**Intervention count**: 0 (during integration test)

## Account Switching Behavior

The google_workspace_mcp handled the account switch correctly:

1. **Detection**: On first tool call, the MCP server detected it was authenticated as fshotwell@gmail.com (from the gmail run) and returned an OAuth authorization URL for re-auth.
2. **State token expiry**: First auth attempt failed — "Invalid or expired OAuth state parameter." The state token expired between URL generation and the user clicking through.
3. **Self-recovery**: Cowork autonomously triggered a fresh auth request. Second attempt succeeded.
4. **Verification**: The prompt's account verification step confirmed the correct account via seed file ID match before proceeding with tests.

Contrast with Gemini CLI Workspace extension (config E / workspace): the Gemini extension silently proceeded against the wrong account with no re-auth prompt, producing invalid results. The google_workspace_mcp's behavior is superior — it detects the mismatch and prompts for re-auth, even though the OAuth state token UX is rough.

## Observations

1. **Perfect score.** 15/15 component + 6/6 integration with correct account. The only non-tool issue (#7 seed data mismatch) was correctly identified as seed contamination, not a tool failure.

2. **Doc creation moved to isolation folder.** Unlike the gmail run where docs landed in Drive root, Cowork moved created docs into the isolation folder via `move_drive_file` after creation. The `create_doc` tool still lacks a `folder_id` parameter.

3. **Same `manage_event` retry pattern.** Integration Step 3 failed on first attempt (missing end_time), self-corrected on retry — identical to the gmail run.

4. **19 permission prompts.** Claude Desktop re-prompted for all MCP tool permissions in the new conversation (permissions are per-conversation, not persistent). Same friction as the gmail run.

5. **Parallel tool calls.** Cowork batched independent operations (e.g., #2 upload + #4 Docs read; Steps 3 + 4 of integration test) where possible.

## Screenshots

- `screenshots/cowork-auth-prompt.png` — MCP server OAuth re-auth prompt (CleanShot 2026-04-16 at 17.08.53)
- `screenshots/cowork-oauth-error.png` — State token expiry error (CleanShot 2026-04-16 at 17.09.52)
- `screenshots/cowork-oauth-error-2.png` — Second state token expiry (CleanShot 2026-04-16 at 17.10.40)
- `screenshots/cowork-auth-recovered.png` — Successful re-auth and account verification (CleanShot 2026-04-16 at 17.11.25)

## Notes for Synthesis

Config A with google_workspace_mcp achieves a perfect score on both accounts — the only config in the shootout to do so (pending #7 seed data clarification). The MCP server is the differentiator: same server powers config C (Claude Code CLI) and config A (Claude Desktop) with equivalent results. The agent shell (CLI vs. desktop) is a UX choice, not a capability gap.

The account switching story is nuanced:
- **google_workspace_mcp**: detects mismatch, prompts for re-auth, works after 1 intervention. OAuth state token UX is rough but functional.
- **Gemini Workspace extension**: no detection, silently uses wrong account, invalid results.
- **GWS CLI**: seamless profile-based switching via env vars, zero intervention. Best multi-account experience.

For the blog: config A is the recommended path for non-CLI users who want full GWS agent access from a desktop app. The 19 permission prompts are a one-time annoyance. The OAuth re-auth for account switching is manual but at least it works correctly.
