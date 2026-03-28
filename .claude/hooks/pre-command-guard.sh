#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook for Bash — guard destructive commands
# Input: stdin JSON with { "tool_input": { "command": "..." } }
# Exit 0 = allow, Exit 2 = block

INPUT=$(cat)

CMD=""
if command -v python3 &>/dev/null; then
  CMD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null) || true
elif command -v jq &>/dev/null; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null) || true
fi

[[ -z "$CMD" ]] && exit 0

blocked=(
  "rm -rf"
  "git reset --hard"
  "git clean -fd"
  "git clean -fdx"
  "docker system prune"
  "terraform destroy"
  "pulumi destroy"
)

approval_required=(
  "git push --force"
  "terraform apply"
  "pulumi up"
  "kubectl delete"
  "npm install"
  "pnpm add"
  "yarn add"
)

for pattern in "${blocked[@]}"; do
  if [[ "$CMD" == *"$pattern"* ]]; then
    echo "BLOCKED: destructive command -> $pattern" >&2
    exit 2
  fi
done

for pattern in "${approval_required[@]}"; do
  if [[ "$CMD" == *"$pattern"* ]]; then
    echo "BLOCKED: guarded command requires manual approval -> $pattern" >&2
    exit 2
  fi
done

exit 0
