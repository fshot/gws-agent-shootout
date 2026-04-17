# Setup: F / @gmail.com

**Date**: 2026-04-16
**Config**: F — ChatGPT + Google Drive connector
**Account**: fshotwell@gmail.com
**Starting from**: clean (ChatGPT built-in connectors)

## Prerequisites

- **OS**: Any (web browser)
- **Runtime versions**: N/A (web UI)
- **GCP project**: Not required — ChatGPT uses its own OAuth integration
- **Billing**: ChatGPT Plus subscription required for connected apps

## Agent setup

**Agent**: ChatGPT
**Version**: Thinking 5.4, Standard effort (web UI at chatgpt.com)
**Non-default config**: Model set to "Thinking 5.4" — the default "Instant 5.3" returned a wall of FAIL without attempting any tool calls.

## Connector installation

### Steps — Desktop app (FAILED)

1. Opened ChatGPT macOS desktop app (v1.2026.051)
2. Settings > Apps > Browse Apps > searched "google"
3. Available connectors: Google Drive, Google Calendar, Google Contacts
4. Attempted to connect Google Drive — OAuth consent screen appeared
5. After Google sign-in, received `NSURLErrorDomain error -1100` ("URL not found on server")
6. Same error on retry, and on attempts to connect Google Calendar and Gmail
7. **Desktop app connector setup abandoned due to OAuth callback bug.**

### Steps — Web UI (SUCCEEDED)

1. Opened chatgpt.com in browser
2. Settings > Apps > Connected apps
3. Connected Google Drive — OAuth flow completed successfully in browser
4. Connected Google Calendar — OAuth flow completed successfully
5. Gmail connector not explicitly listed but ChatGPT accessed Gmail during testing (unclear which connected app provides this)

### Config files created/modified

| File | Location | What changed |
|------|----------|-------------|
| N/A | N/A | All config is in ChatGPT's web UI settings |

## GCP project configuration

Not applicable — ChatGPT manages its own OAuth application. No user-side GCP project needed.

## First-run auth flow

### Desktop app
1. Settings > Apps > Google Drive > "Continue to Google Drive"
2. Browser opened to Google sign-in page ("Sign in to continue to OpenAI")
3. Entered fshotwell@gmail.com
4. `NSURLErrorDomain error -1100` after Google sign-in — OAuth callback URL not found

### Web UI
1. Settings > Apps > Google Drive > Connect
2. Google OAuth consent screen in browser ("This page will redirect to Google")
3. Signed in as fshotwell@gmail.com, granted permissions
4. Redirected back to ChatGPT — connector shown as connected

## Resulting artifacts

| Artifact | Location | Notes |
|----------|----------|-------|
| Google Drive connection | ChatGPT Settings > Connected apps | OAuth token managed by ChatGPT |
| Google Calendar connection | ChatGPT Settings > Connected apps | OAuth token managed by ChatGPT |

## Account-type differences

Not tested with @workspace account. Config F is @gmail.com only per protocol.

## Gotchas

1. **Desktop app OAuth is broken.** `NSURLErrorDomain error -1100` on every Google connector (Drive, Calendar, Gmail). Affects macOS app v1.2026.051. Web UI works fine.
2. **Model matters.** "Instant 5.3" immediately returned 0/15 FAIL without attempting any tool calls. "Thinking 5.4" actually invoked the connected app tools and passed 10/15.
3. **No auto-approve.** Every tool invocation requires manual approval via a modal dialog. ~8 approval prompts for the full test run. No "always allow" option.
4. **Gmail access is opaque.** Gmail search, read, and send all worked, but Gmail is not explicitly listed as a connected app. Unclear whether it's bundled with Google Drive or a separate implicit connection.
5. **Calendar create is limited.** Can list events on any calendar but create-event API doesn't expose `calendar_id` — locked to primary calendar only.
