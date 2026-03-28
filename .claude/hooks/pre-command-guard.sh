#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-}"
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
    echo "BLOCKED: destructive command -> $pattern"
    exit 2
  fi
done

for pattern in "${approval_required[@]}"; do
  if [[ "$CMD" == *"$pattern"* ]]; then
    echo "APPROVAL REQUIRED: guarded command -> $pattern"
    exit 3
  fi
done

exit 0
