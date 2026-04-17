#!/usr/bin/env bash
# Set up direnv for the GWS Agent Shootout project.
# Creates .envrc files in the project root and all results directories
# so the correct Google account context is loaded automatically.
#
# Usage: ./scripts/setup-direnv.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "=== Setting up direnv for GWS Agent Shootout ==="
echo ""

# Check direnv is installed
if ! command -v direnv &>/dev/null; then
  echo "Error: direnv is not installed." >&2
  echo "Install it:" >&2
  echo "  brew install direnv     # macOS" >&2
  echo "  sudo apt install direnv # Debian/Ubuntu" >&2
  echo "" >&2
  echo "Then add the hook to your shell:" >&2
  echo "  # fish:  echo 'direnv hook fish | source' >> ~/.config/fish/config.fish" >&2
  echo "  # bash:  echo 'eval \"\$(direnv hook bash)\"' >> ~/.bashrc" >&2
  echo "  # zsh:   echo 'eval \"\$(direnv hook zsh)\"' >> ~/.zshrc" >&2
  exit 1
fi

# Create profile directories for GWS CLI account switching
mkdir -p "${HOME}/.config/gws/profiles/gmail"
mkdir -p "${HOME}/.config/gws/profiles/crux"
echo "Created GWS CLI profile directories:"
echo "  ~/.config/gws/profiles/gmail/    (fshotwell@gmail.com)"
echo "  ~/.config/gws/profiles/crux/     (fshotwell@cruxcapacity.com)"
echo ""
echo "Each profile needs: client_secret.json (from GCP Console)."
echo "Run 'gws auth login' with GOOGLE_WORKSPACE_CLI_CONFIG_DIR pointed at the"
echo "profile to generate credentials.enc and token_cache.json."

# Set up root .envrc
if [[ ! -f .envrc ]]; then
  cp .envrc.example .envrc
  echo "Created root .envrc from .envrc.example"
else
  echo "Root .envrc already exists, skipping"
fi

# Define all results directories
DIRS=(
  "results/claude-cowork-connectors-gmail"
  "results/claude-cowork-connectors-workspace"
  "results/claude-code-gws-cli-gmail"
  "results/claude-code-gws-cli-workspace"
  "results/claude-code-mcp-gmail"
  "results/claude-code-mcp-workspace"
  "results/codex-gws-cli-gmail"
  "results/codex-gws-cli-workspace"
  "results/codex-mcp-gmail"
  "results/codex-mcp-workspace"
  "results/gemini-cli-workspace-gmail"
  "results/gemini-cli-workspace-workspace"
  "results/chatgpt-drive-gmail"
  "results/chatgpt-drive-workspace"
)

echo ""
echo "Setting up results directories..."

for dir in "${DIRS[@]}"; do
  mkdir -p "$dir/screenshots"

  if [[ ! -f "$dir/.envrc" ]]; then
    cp envs/.envrc.example "$dir/.envrc"
    echo "  Created $dir/.envrc"
  else
    echo "  $dir/.envrc already exists, skipping"
  fi
done

echo ""
echo "=== direnv allow ==="
echo ""
echo "Now allow direnv in each directory. Run:"
echo ""
echo "  direnv allow ."

for dir in "${DIRS[@]}"; do
  echo "  direnv allow $dir"
done

echo ""
echo "Or allow all at once:"
echo ""
echo "  direnv allow . && for d in results/*/; do direnv allow \"\$d\"; done"

echo ""
echo "=== Verify ==="
echo ""
echo "Test it by cd-ing into a results directory and running gws:"
echo ""
echo "  cd results/claude-code-gws-cli-gmail"
echo "  gws auth status 2>&1 | grep user    # → fshotwell@gmail.com"
echo ""
echo "  cd ../claude-code-gws-cli-workspace"
echo "  gws auth status 2>&1 | grep user    # → fshotwell@cruxcapacity.com"
echo ""
echo "The GOOGLE_WORKSPACE_CLI_CONFIG_DIR env var switches GWS CLI"
echo "profiles automatically — no manual credential swapping needed."
echo ""
echo "=== Done ==="
