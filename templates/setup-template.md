# Setup: {CONFIG} / {ACCOUNT}

**Date**: YYYY-MM-DD
**Config**: {A|B|C|D|D2|E|F} — {agent} + {connector}
**Account**: {email}
**Starting from**: {clean install | reusing config from config X}

## Prerequisites

- **OS**: {e.g., macOS 15.x}
- **Runtime versions**: {Node vX.Y, Python X.Y, etc.}
- **GCP project**: {new project created | existing project reused from config X}
- **Billing**: {required | not required}

## Agent setup

**Agent**: {name}
**Version**: {version}
**Non-default config**: {any settings changed from defaults, or "none"}

{Skip detailed install steps for well-documented agents. Note version and config only.}

## Connector installation

### Steps

```bash
# Paste exact commands in order
```

### Config files created/modified

| File | Location | What changed |
|------|----------|-------------|
| | | |

## GCP project configuration

### APIs enabled

| API | How enabled |
|-----|------------|
| | {Console UI / `gcloud services enable ...`} |

### OAuth consent screen

- **User type**: {Internal | External}
- **App name**: {name shown on consent screen}
- **Scopes requested**: {list exact scopes}
- **Publishing status**: {Testing | Production}
- **Test users added**: {list emails, if applicable}

Screenshot: `screenshots/consent-screen.png`

### OAuth client

- **Type**: {Desktop app | Web app}
- **Client ID**: {redacted or noted where stored}
- **Credential file location**: {path}

## First-run auth flow

{Narrate what happened step by step when the connector was used for the first time.}

1. {Ran command X}
2. {Browser opened to URL}
3. {Consent screen appeared — screenshot: `screenshots/auth-flow-1.png`}
4. {Approved scopes: ...}
5. {Redirect back, token stored at ...}

## Resulting artifacts

| Artifact | Location | Notes |
|----------|----------|-------|
| OAuth token | | |
| Config file | | |
| Env vars | | |

## Account-type differences

{Note anything that differs for @gmail.com vs @workspace. If this is the second account type, note what changed from the first run.}

## Gotchas

{Anything that failed, was unclear, or required debugging. Record error messages verbatim.}
