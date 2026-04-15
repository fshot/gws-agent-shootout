#!/usr/bin/env bash
# Run a Gemini CLI test configuration (E)
# Usage: ./scripts/run-gemini.sh <account>
#   account: gmail or workspace

set -euo pipefail

ACCOUNT="${1:?Usage: $0 <gmail|workspace>}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [[ "$ACCOUNT" != "gmail" && "$ACCOUNT" != "workspace" ]]; then
  echo "Error: account must be gmail or workspace, got: $ACCOUNT" >&2
  exit 1
fi

RESULTS_DIR="$PROJECT_DIR/results/gemini-cli-workspace-${ACCOUNT}"

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

mkdir -p "$RESULTS_DIR/screenshots"

PROMPT="You are running config E for account ${EMAIL}.
The other test account (for sharing/emailing) is ${OTHER_EMAIL}.
Read GEMINI.md for full instructions, then read the fixture files in fixtures/.
Execute all 15 component tests and 6 integration test steps.
Record all results in the structured format specified in GEMINI.md.
Working directory: ${PROJECT_DIR}"

echo "=== GWS Agent Shootout: Config E / ${ACCOUNT} ==="
echo "Results: ${RESULTS_DIR}"
echo "Account: ${EMAIL}"
echo "Starting at: $(date -Iseconds)"
echo ""

# Run Gemini in yolo mode with JSON output
gemini \
  --prompt "$PROMPT" \
  --yolo \
  --output-format json \
  2>&1 | tee "$RESULTS_DIR/gemini-raw-output.json"

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "Finished at: $(date -Iseconds)"
echo "Exit code: ${EXIT_CODE}"

# Extract readable response
if command -v jq &>/dev/null; then
  echo ""
  echo "=== Extracting readable output ==="
  jq -r '.response // empty' \
    "$RESULTS_DIR/gemini-raw-output.json" \
    > "$RESULTS_DIR/gemini-readable-output.md" 2>/dev/null || true
  echo "Readable output: ${RESULTS_DIR}/gemini-readable-output.md"
fi

exit $EXIT_CODE
