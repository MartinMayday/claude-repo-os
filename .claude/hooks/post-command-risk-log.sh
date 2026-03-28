#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
RISK_LOG="$PROJECT_ROOT/ops/risk/RISK_REGISTER.md"
CMD="${1:-}"
RESULT="${2:-unknown}"

[[ -z "$CMD" ]] && exit 0
[[ -f "$RISK_LOG" ]] || exit 0

{
  echo ""
  echo "- Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "  Action: $CMD"
  echo "  Result: $RESULT"
} >> "$RISK_LOG"

exit 0
