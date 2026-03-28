#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
APPROVALS_FILE="$PROJECT_ROOT/ops/risk/APPROVALS.md"
TARGET="${1:-}"

[[ -z "$TARGET" ]] && { echo "No target supplied"; exit 1; }
[[ -f "$APPROVALS_FILE" ]] || { echo "No APPROVALS.md found"; exit 1; }

grep -F "$TARGET" "$APPROVALS_FILE" >/dev/null 2>&1 && exit 0

echo "No matching approval for: $TARGET"
exit 1
