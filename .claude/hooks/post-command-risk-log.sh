#!/usr/bin/env bash
set -euo pipefail

# PostToolUse hook for Bash — log risk-relevant commands
# Input: stdin JSON with { "tool_input": { "command": "..." }, "tool_result": "..." }
# Exit 0 = always (PostToolUse cannot block)

INPUT=$(cat)

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
RISK_LOG="$PROJECT_ROOT/ops/risk/RISK_REGISTER.md"

[[ -f "$RISK_LOG" ]] || exit 0

CMD=""
RESULT=""
if command -v python3 &>/dev/null; then
  CMD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null) || true
  RESULT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); r=d.get('tool_result',''); print(r[:200] if r else 'unknown')" 2>/dev/null) || true
elif command -v jq &>/dev/null; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null) || true
  RESULT=$(echo "$INPUT" | jq -r '.tool_result[:200] // "unknown"' 2>/dev/null) || true
fi

[[ -z "$CMD" ]] && exit 0

{
  echo ""
  echo "- Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "  Action: $CMD"
  echo "  Result: ${RESULT:-unknown}"
} >> "$RISK_LOG"

exit 0
