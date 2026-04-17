#!/usr/bin/env bash
# Run a Codex CLI test configuration (D or D2)
# Usage: ./scripts/run-codex.sh <config> <account>
#   config:  D or D2
#   account: gmail or workspace

set -euo pipefail

CONFIG="${1:?Usage: $0 <D|D2> <gmail|workspace>}"
ACCOUNT="${2:?Usage: $0 <D|D2> <gmail|workspace>}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Validate inputs
if [[ "$CONFIG" != "D" && "$CONFIG" != "D2" ]]; then
  echo "Error: config must be D or D2, got: $CONFIG" >&2
  exit 1
fi

if [[ "$ACCOUNT" != "gmail" && "$ACCOUNT" != "workspace" ]]; then
  echo "Error: account must be gmail or workspace, got: $ACCOUNT" >&2
  exit 1
fi

# Determine results directory
if [[ "$CONFIG" == "D" ]]; then
  RESULTS_DIR="$PROJECT_DIR/results/codex-gws-cli-${ACCOUNT}"
else
  RESULTS_DIR="$PROJECT_DIR/results/codex-mcp-${ACCOUNT}"
fi

# Load account env if direnv hasn't already set it
if [[ -f "$PROJECT_DIR/envs/${ACCOUNT}.env" ]]; then
  set -a
  source "$PROJECT_DIR/envs/${ACCOUNT}.env"
  set +a
fi

# Resolve account email (env vars take precedence, then fallback)
EMAIL="${GWS_ACCOUNT:-}"
OTHER_EMAIL="${GWS_TARGET_ACCOUNT:-}"
if [[ -z "$EMAIL" ]]; then
  if [[ "$ACCOUNT" == "gmail" ]]; then
    EMAIL="fshotwell@gmail.com"
    OTHER_EMAIL="fshotwell@cruxcapacity.com"
  else
    EMAIL="fshotwell@cruxcapacity.com"
    OTHER_EMAIL="fshotwell@gmail.com"
  fi
fi

# Create results directory
mkdir -p "$RESULTS_DIR/screenshots"

# Build the prompt
PROMPT="You are running config ${CONFIG} for account ${EMAIL}.
The other test account (for sharing/emailing) is ${OTHER_EMAIL}.
Read AGENTS.md for full instructions, then read the fixture files in fixtures/.
Execute all 15 component tests and 6 integration test steps.
Record all results in the structured format specified in AGENTS.md.
Working directory: ${PROJECT_DIR}"

echo "=== GWS Agent Shootout: Config ${CONFIG} / ${ACCOUNT} ==="
echo "Results: ${RESULTS_DIR}"
echo "Account: ${EMAIL}"
echo "Starting at: $(date -Iseconds)"
echo ""

# Run Codex with full access sandbox (needed for network + keyring access to gws CLI)
# --full-auto uses workspace-write sandbox which blocks network; gws needs DNS + HTTPS
codex exec \
  --dangerously-bypass-approvals-and-sandbox \
  --json \
  "$PROMPT" \
  2>&1 | tee "$RESULTS_DIR/codex-raw-output.jsonl"

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "Finished at: $(date -Iseconds)"
echo "Exit code: ${EXIT_CODE}"

# Extract the final text response from JSONL for easier reading
if command -v jq &>/dev/null; then
  echo ""
  echo "=== Extracting readable output ==="
  jq -r 'select(.type == "item.completed" and .item.type == "assistant_message") | .item.content // empty' \
    "$RESULTS_DIR/codex-raw-output.jsonl" \
    > "$RESULTS_DIR/codex-readable-output.md" 2>/dev/null || true
  echo "Readable output: ${RESULTS_DIR}/codex-readable-output.md"
fi

exit $EXIT_CODE
