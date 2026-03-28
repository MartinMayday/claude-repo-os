#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"
[[ -z "$TARGET" ]] && exit 0

case "$TARGET" in
  *.env|.env|.env.*|*"/secrets/"*|*"/credentials/"*|*.pem|*.key|*.p12|*.crt)
    echo "BLOCKED: protected secret or credential path -> $TARGET"
    exit 2
    ;;
  *"/infra/"*|*"/terraform/"*|*"/pulumi/"*|*"/k8s/"*|*"/helm/"*|\
*"/ansible/"*|*"/migrations/"*|*".github/workflows/"*|\
*"package-lock.json"|*"pnpm-lock.yaml"|*"yarn.lock")
    echo "APPROVAL REQUIRED: risky edit target -> $TARGET"
    exit 3
    ;;
  *)
    exit 0
    ;;
esac
