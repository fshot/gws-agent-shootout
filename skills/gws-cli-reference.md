---
description: "Use Google Workspace CLI (gws) to access Drive, Docs, Gmail, Calendar, Sheets, and more"
---

# Google Workspace CLI (gws)

You have access to the `gws` command-line tool for interacting with Google Workspace services. Use it to read and write Google Docs, Drive files, Gmail, Calendar, Sheets, and other Workspace APIs.

## Command Pattern

```
gws <service> <resource> <method> [flags]
```

## Account Configuration

GWS CLI authenticates ONE user at a time. The user has two Google accounts:

### Personal account: fshotwell@gmail.com
- **GCP Project**: `hdca-workspace-tools` (owned by this account)
- **Use for**: Personal Drive, HDCA volunteer docs, personal Gmail/Calendar
- **Auth command**: `gws auth login -s drive,docs,sheets,gmail,calendar`
- **Scopes**: Full read/write (drive, docs, sheets, gmail, calendar)

### Workspace account: fshotwell@cruxcapacity.com
- **GCP Project**: `crux-workspace` (owned by this account)
- **Use for**: Crux Capacity business docs, work Gmail/Calendar
- **Auth command**: `gws auth login -s drive,docs,sheets,gmail,calendar`
- **Important**: This project has domain restriction (`iam.allowedPolicyMemberDomains`) — only @cruxcapacity.com users can use it

### Checking which account is active
```bash
gws auth status 2>&1 | grep -E '"(user|project_id|token_valid|scope_count)"'
```

### Switching accounts
GWS CLI supports one authenticated user at a time. To switch:
```bash
# Switch the underlying gcloud account first (if needed for project admin)
gcloud config set account TARGET@EMAIL.COM

# Then re-auth gws with the target account
gws auth login -s drive,docs,sheets,gmail,calendar
# Browser opens → pick the target account → approve scopes
```

Config files live at `~/.config/gws/`:
- `client_secret.json` — OAuth client ID (tied to a GCP project)
- `credentials.enc` — encrypted refresh token (tied to the authenticated user)
- `token_cache.json` — cached access token

**To use a different GCP project's credentials**, replace `client_secret.json` before running `gws auth login`.

### Token expiry
In Testing mode (the default for personal OAuth apps), refresh tokens expire every **7 days**. If you see `invalid_rapt` or auth errors, re-run `gws auth login`.

## Auth Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `insufficientPermissions` | Token cached with wrong scopes | Delete `~/.config/gws/token_cache.json`, re-run `gws auth login` |
| `invalid_rapt` | Token expired (7-day limit in Testing mode) | Re-run `gws auth login` |
| `org_internal` (403) | OAuth app set to "Internal" | Change OAuth consent screen to "External" in GCP Console |
| `access_denied` (not verified) | User not in test users list | Add email to OAuth consent screen → Test users in GCP Console |
| `serviceusage.services.use` | User not in project IAM | Add user with `Service Usage Consumer` role, or use a project owned by the same account |
| Stale scopes after re-auth | Old token_cache.json | `rm ~/.config/gws/token_cache.json` and retry |

## MCP Server Status

**`gws mcp` was removed in v0.8.0** (March 2026) for security reasons. Do NOT attempt to use `gws mcp`. Online docs referencing it are stale.

To use GWS from Claude Code, call `gws` commands directly via Bash. No MCP wrapper needed — Claude Code can shell out to `gws` natively.

## Key Services

| Service | Common Uses |
|---------|-------------|
| `gws docs` | Read/write Google Docs |
| `gws drive` | List, download, upload files |
| `gws gmail` | Read, send, search email |
| `gws calendar` | List events, create events |
| `gws sheets` | Read/write spreadsheet data |
| `gws chat` | Send messages |
| `gws tasks` | Manage task lists |
| `gws people` | Contact info |

## Discovering Commands

Always inspect before calling an unfamiliar method:

```bash
# List resources for a service
gws <service> --help

# Inspect a method's params, types, and defaults
gws schema <service>.<resource>.<method>
```

## Common Operations

### Read a Google Doc by ID
```bash
gws docs documents get --params '{"documentId": "DOC_ID"}'
```

### Create a Google Doc
```bash
gws docs documents create --json '{"title": "My New Doc"}'
```

### List Drive files (most recent)
```bash
gws drive files list --params '{"pageSize": 10, "orderBy": "modifiedTime desc", "fields": "files(id,name,mimeType,modifiedTime)"}'
```

### Search Drive files by name
```bash
gws drive files list --params '{"q": "name contains '\''search term'\''", "pageSize": 10}'
```

### Search Drive by MIME type
```bash
# Google Docs only
gws drive files list --params '{"q": "mimeType='\''application/vnd.google-apps.document'\''", "pageSize": 10}'
# Google Sheets only
gws drive files list --params '{"q": "mimeType='\''application/vnd.google-apps.spreadsheet'\''", "pageSize": 10}'
```

### Download/export a file
```bash
gws drive files export --params '{"fileId": "FILE_ID", "mimeType": "text/plain"}' --output output.txt
```

### Read a spreadsheet
```bash
gws sheets spreadsheets.values get --params '{"spreadsheetId": "SHEET_ID", "range": "Sheet1!A1:Z100"}'
```

### Write to a spreadsheet
```bash
gws sheets spreadsheets.values update --params '{"spreadsheetId": "SHEET_ID", "range": "Sheet1!A1", "valueInputOption": "USER_ENTERED"}' --json '{"values": [["Col1", "Col2"], ["val1", "val2"]]}'
```

### Search Gmail
```bash
gws gmail users.messages list --params '{"userId": "me", "q": "from:someone@example.com"}'
```

### Read a Gmail message
```bash
gws gmail users.messages get --params '{"userId": "me", "id": "MESSAGE_ID"}'
```

### Send an email
```bash
# Requires base64-encoded RFC 2822 message
gws gmail users.messages send --params '{"userId": "me"}' --json '{"raw": "BASE64_ENCODED_MESSAGE"}'
```

### List calendar events
```bash
gws calendar events list --params '{"calendarId": "primary", "maxResults": 10, "timeMin": "2026-04-01T00:00:00Z"}'
```

### Create a calendar event
```bash
gws calendar events insert --params '{"calendarId": "primary"}' --json '{"summary": "Meeting", "start": {"dateTime": "2026-04-15T19:00:00-07:00"}, "end": {"dateTime": "2026-04-15T20:00:00-07:00"}}'
```

## Important Flags

| Flag | Purpose |
|------|---------|
| `--format json` | JSON output (default) |
| `--format table` | Human-readable table |
| `--dry-run` | Preview without executing |
| `--page-all` | Auto-paginate all results |
| `--page-limit N` | Limit pagination to N pages |
| `--output FILE` | Save response to file |
| `--upload FILE` | Upload file (multipart) |

## Working with .gdoc/.gsheet Pointer Files

Files in Google Drive mount directories (e.g., `~/gd-crux/`) with `.gdoc` or `.gsheet` extensions are JSON pointer files, not actual content. To read the real content:

1. Read the pointer file to extract the `doc_id` field
2. Use gws to fetch the actual document:
```bash
# For .gdoc files
gws docs documents get --params '{"documentId": "DOC_ID"}'

# For .gsheet files
gws sheets spreadsheets.values get --params '{"spreadsheetId": "DOC_ID", "range": "Sheet1"}'
```

## Shell Escaping Notes

- Wrap `--params` and `--json` values in single quotes
- In zsh, `!` triggers history expansion inside double quotes; use single quotes for sheet ranges
- For queries with apostrophes, use `'\''` to break out and re-enter single quotes

## Safety Rules

- Never expose API keys or tokens in output
- Confirm before executing write/delete operations (especially gmail send, drive delete, calendar delete)
- Prefer `--dry-run` for destructive commands
- All output is structured JSON suitable for further processing
