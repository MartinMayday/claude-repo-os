#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
APPROVALS_FILE="$PROJECT_ROOT/ops/risk/APPROVALS.md"
INPUT=$(cat)
TARGET=""
if command -v python3 &>/dev/null; then
  TARGET=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null) || true
elif command -v jq &>/dev/null; then
  TARGET=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null) || true
fi

[[ -z "$TARGET" ]] && { echo "No target supplied"; exit 1; }
[[ -f "$APPROVALS_FILE" ]] || { echo "No APPROVALS.md found"; exit 1; }

grep -F "$TARGET" "$APPROVALS_FILE" >/dev/null 2>&1 && exit 0

echo "No matching approval for: $TARGET"
exit 1
