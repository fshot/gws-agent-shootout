#!/usr/bin/env bash
# Configure the google_workspace_mcp server for Codex CLI (config D2)
# Run this AFTER the MCP server has been installed (during config C setup)
#
# Prerequisites:
# - Codex CLI installed
# - google_workspace_mcp cloned and dependencies installed
# - OAuth credentials configured (from config C setup)

set -euo pipefail

echo "=== Configuring google_workspace_mcp for Codex CLI ==="
echo ""

# Check if codex is installed
if ! command -v codex &>/dev/null; then
  echo "Error: codex CLI not found. Install it first." >&2
  exit 1
fi

# Prompt for the MCP server path
MCP_SERVER_PATH="${1:-}"
if [[ -z "$MCP_SERVER_PATH" ]]; then
  echo "Usage: $0 <path-to-google_workspace_mcp>"
  echo ""
  echo "Example: $0 ~/code/google_workspace_mcp"
  exit 1
fi

if [[ ! -d "$MCP_SERVER_PATH" ]]; then
  echo "Error: directory not found: $MCP_SERVER_PATH" >&2
  exit 1
fi

# Add the MCP server to Codex config
# This uses the codex mcp add command
echo "Adding google_workspace_mcp to Codex..."
echo ""

# Determine the start command based on what's in the MCP server directory
if [[ -f "$MCP_SERVER_PATH/package.json" ]]; then
  echo "Detected Node.js MCP server"
  codex mcp add google_workspace_mcp -- node "$MCP_SERVER_PATH/dist/index.js"
elif [[ -f "$MCP_SERVER_PATH/pyproject.toml" ]] || [[ -f "$MCP_SERVER_PATH/setup.py" ]]; then
  echo "Detected Python MCP server"
  codex mcp add google_workspace_mcp -- uvx --from "$MCP_SERVER_PATH" google_workspace_mcp
else
  echo "Warning: could not auto-detect server type. Adding with generic command."
  echo "You may need to edit ~/.codex/config.toml manually."
  codex mcp add google_workspace_mcp -- "$MCP_SERVER_PATH/start.sh"
fi

echo ""
echo "Done. Verify with: codex mcp list"
echo ""
echo "If the server needs environment variables (e.g., for OAuth credentials),"
echo "edit ~/.codex/config.toml and add them under [mcp_servers.google_workspace_mcp]:"
echo ""
echo '  [mcp_servers.google_workspace_mcp]'
echo '  env = { GOOGLE_CLIENT_ID = "...", GOOGLE_CLIENT_SECRET = "..." }'
echo ""
echo "Then test with: codex exec --full-auto 'List my Google Drive files'"
