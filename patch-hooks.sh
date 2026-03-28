#!/usr/bin/env bash
# patch-hooks.sh — Idempotent repair for repo-OS v0.1 hook system
#
# Fixes:
#   1. settings.json: wrong event names → correct Claude Code schema
#   2. Hook scripts: $1/$2 positional args → stdin JSON parsing
#   3. Exit code 3 (invalid) → exit 2 (block) for approval-required cases
#   4. Missing ops/evaluation/ directory
#
# Safe to run multiple times. Backs up originals on first run only.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

log()  { echo -e "${GREEN}[PATCH]${RESET} $*"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $*"; }
fail() { echo -e "${RED}[FAIL]${RESET} $*"; exit 1; }

# ── 1. Back up originals (idempotent — skip if backup exists) ────────────────

backup_dir=".claude/hooks/backup-pre-patch"
if [[ ! -d "$backup_dir" ]]; then
  mkdir -p "$backup_dir"
  cp .claude/settings.json "$backup_dir/settings.json.bak" 2>/dev/null || true
  for f in .claude/hooks/pre-edit-guard.sh .claude/hooks/pre-command-guard.sh .claude/hooks/post-command-risk-log.sh; do
    [[ -f "$f" ]] && cp "$f" "$backup_dir/"
  done
  log "Backed up originals to $backup_dir/"
else
  log "Backup already exists, skipping"
fi

# ── 2. Fix settings.json ─────────────────────────────────────────────────────

SETTINGS=".claude/settings.json"
log "Patching $SETTINGS — replacing event names"

cat > "$SETTINGS" << 'SETTINGS_EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/pre-edit-guard.sh"
          }
        ]
      },
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/pre-edit-guard.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/pre-command-guard.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/post-command-risk-log.sh"
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF

log "settings.json patched: preEdit→PreToolUse(Edit,Write), preCommand→PreToolUse(Bash), postCommand→PostToolUse(Bash)"

# ── 3. Fix pre-edit-guard.sh ─────────────────────────────────────────────────

log "Patching pre-edit-guard.sh — stdin JSON, extract tool_input.file_path"

cat > .claude/hooks/pre-edit-guard.sh << 'HOOK_EOF'
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
HOOK_EOF

chmod +x .claude/hooks/pre-edit-guard.sh

# ── 4. Fix pre-command-guard.sh ───────────────────────────────────────────────

log "Patching pre-command-guard.sh — stdin JSON, extract tool_input.command"

cat > .claude/hooks/pre-command-guard.sh << 'HOOK_EOF'
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
HOOK_EOF

chmod +x .claude/hooks/pre-command-guard.sh

# ── 5. Fix post-command-risk-log.sh ──────────────────────────────────────────

log "Patching post-command-risk-log.sh — stdin JSON"

cat > .claude/hooks/post-command-risk-log.sh << 'HOOK_EOF'
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
HOOK_EOF

chmod +x .claude/hooks/post-command-risk-log.sh

# ── 6. Create ops/evaluation/ if missing ─────────────────────────────────────

if [[ ! -d "ops/evaluation" ]]; then
  mkdir -p ops/evaluation
  cat > ops/evaluation/EVALUATION.md << 'EVAL_EOF'
# Evaluation

Post-execution evaluation criteria and results.

## Purpose
Verify that completed work meets the done gate criteria defined in ops/execution/DONE_GATE.md.

## Structure
- Each evaluation records: what was tested, how, result, and evidence.
- Evaluations are append-only — never delete past evaluations.
EVAL_EOF
  log "Created ops/evaluation/EVALUATION.md"
else
  log "ops/evaluation/ already exists, skipping"
fi

# ── 7. Verification ──────────────────────────────────────────────────────────

echo ""
log "=== VERIFICATION ==="
echo ""

# Check settings.json has correct event names
if grep -q '"PreToolUse"' .claude/settings.json && \
   grep -q '"PostToolUse"' .claude/settings.json && \
   ! grep -q '"preEdit"' .claude/settings.json && \
   ! grep -q '"preCommand"' .claude/settings.json && \
   ! grep -q '"postCommand"' .claude/settings.json; then
  log "PASS: settings.json uses correct event names (PreToolUse, PostToolUse)"
else
  fail "FAIL: settings.json still contains wrong event names"
fi

# Check hook scripts read from stdin, not $1
for script in pre-edit-guard.sh pre-command-guard.sh post-command-risk-log.sh; do
  path=".claude/hooks/$script"
  if [[ ! -f "$path" ]]; then
    fail "FAIL: $path does not exist"
  fi
  if grep -q 'INPUT=\$(cat)' "$path"; then
    log "PASS: $script reads stdin (INPUT=\$(cat))"
  else
    fail "FAIL: $script does not read stdin"
  fi
  if grep -qq '\$1' "$path" 2>/dev/null; then
    warn "WARN: $script still references \$1"
  fi
  if grep -q 'exit 3' "$path"; then
    warn "WARN: $script still uses exit code 3"
  fi
done

# Check exit code 3 is gone
if grep -rq 'exit 3' .claude/hooks/*.sh 2>/dev/null; then
  warn "WARN: Some hook scripts still use exit code 3"
else
  log "PASS: No hook uses exit code 3"
fi

# Check ops/evaluation exists
if [[ -d "ops/evaluation" ]]; then
  log "PASS: ops/evaluation/ directory exists"
else
  fail "FAIL: ops/evaluation/ directory missing"
fi

# Check all scripts are executable
for script in .claude/hooks/pre-edit-guard.sh .claude/hooks/pre-command-guard.sh .claude/hooks/post-command-risk-log.sh; do
  if [[ -x "$script" ]]; then
    log "PASS: $script is executable"
  else
    fail "FAIL: $script is not executable"
  fi
done

echo ""
log "=== PATCH COMPLETE ==="
echo ""
echo "Before: preEdit/preCommand/postCommand events, \$1 positional args, exit 3"
echo "After:  PreToolUse/PostToolUse events, stdin JSON parsing, exit 0/2 only"
echo ""
echo "Unverified after patching:"
echo "  - Whether tool_result field is present in PostToolUse stdin JSON"
echo "  - Whether approval-check.sh (not in settings.json) needs similar fix"
echo "  - Whether bootstrap.sh should be updated to generate correct settings"
echo "  - Whether onboard.sh references old event names"
