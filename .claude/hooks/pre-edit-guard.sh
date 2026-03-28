#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook for Edit/Write — guard protected paths
# Input: stdin JSON with { "tool_input": { "file_path": "..." } }
# Exit 0 = allow, Exit 2 = block

INPUT=$(cat)

TARGET=""
if command -v python3 &>/dev/null; then
  TARGET=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null) || true
elif command -v jq &>/dev/null; then
  TARGET=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null) || true
fi

[[ -z "$TARGET" ]] && exit 0

case "$TARGET" in
  *.env|.env|.env.*|*"/secrets/"*|*"/credentials/"*|*.pem|*.key|*.p12|*.crt)
    echo "BLOCKED: protected secret or credential path -> $TARGET" >&2
    exit 2
    ;;
  *"/infra/"*|*"/terraform/"*|*"/pulumi/"*|*"/k8s/"*|*"/helm/"*|\
  *"/ansible/"*|*"/migrations/"*|*".github/workflows/"*|\
  *"package-lock.json"|*"pnpm-lock.yaml"|*"yarn.lock")
    # Approval-required operations mapped to block (hooks only support allow/block)
    echo "BLOCKED: risky edit target requires manual approval -> $TARGET" >&2
    exit 2
    ;;
  *)
    exit 0
    ;;
esac
