#!/usr/bin/env bash
# Install and configure the Workspace extension for Gemini CLI (config E)
#
# Prerequisites:
# - Gemini CLI installed and authenticated
# - A Google account with Workspace access

set -euo pipefail

echo "=== Setting up Gemini CLI Workspace Extension ==="
echo ""

# Check if gemini is installed
if ! command -v gemini &>/dev/null; then
  echo "Error: gemini CLI not found. Install it first." >&2
  echo "See: https://github.com/google-gemini/gemini-cli" >&2
  exit 1
fi

# Install the Workspace extension
echo "Installing Workspace extension..."
gemini extensions install https://github.com/gemini-cli-extensions/workspace

echo ""
echo "Configuring extension..."
gemini extensions config workspace

echo ""
echo "=== Next steps ==="
echo ""
echo "1. The extension will prompt for OAuth authentication on first use."
echo "   A browser window will open for Google account authorization."
echo ""
echo "2. Test the extension:"
echo "   gemini -p 'List my recent Google Drive files' --yolo"
echo ""
echo "3. If running headless (SSH/CI), the extension supports headless OAuth:"
echo "   - It will print a URL to open in any browser"
echo "   - Sign in and paste the credentials JSON back"
echo ""
echo "4. To run the shootout test:"
echo "   ./scripts/run-gemini.sh gmail"
echo "   ./scripts/run-gemini.sh workspace"
