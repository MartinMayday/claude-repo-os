#!/usr/bin/env bash
# Integration tests for repo-OS v0.1 hooks
# Tests stdin JSON handling, exit codes, and side effects

set -uo pipefail

PROJ="/home/nosrcadmin/.claude/.hive-memory/upgrade-projects/claude-repo-os_v0.1"
HOOKS="$PROJ/.claude/hooks"

PASS=0
FAIL=0
TOTAL=10

RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[1;33m'
RST='\033[0m'

result() {
  local num="$1" desc="$2" got="$3" want="$4"
  if [ "$got" = "$want" ]; then
    printf "${GRN}PASS${RST} Test %2d: %s (exit=%s)\n" "$num" "$desc" "$got"
    PASS=$((PASS + 1))
  else
    printf "${RED}FAIL${RST} Test %2d: %s (got exit=%s, want exit=%s)\n" "$num" "$desc" "$got" "$want"
    FAIL=$((FAIL + 1))
  fi
}

echo "========================================================"
echo " repo-OS v0.1 Hook Integration Tests"
echo "========================================================"
echo ""

# -------------------------------------------------------
# pre-edit-guard.sh tests (1-4)
# -------------------------------------------------------
echo "--- pre-edit-guard.sh ---"

# Test 1: .env file path -> should exit 2 (block)
echo '{"tool_input":{"file_path":"/app/.env"}}' | bash "$HOOKS/pre-edit-guard.sh" >/dev/null 2>&1
result 1 ".env file path blocked" $? 2

# Test 2: normal .ts file -> should exit 0 (allow)
echo '{"tool_input":{"file_path":"/app/src/index.ts"}}' | bash "$HOOKS/pre-edit-guard.sh" >/dev/null 2>&1
result 2 "normal .ts file allowed" $? 0

# Test 3: empty stdin -> should exit 0 (allow, no target)
echo "" | bash "$HOOKS/pre-edit-guard.sh" >/dev/null 2>&1
result 3 "empty stdin allowed" $? 0

# Test 4: malformed JSON -> should exit 0 (graceful fallback)
echo '{this is not json!!!' | bash "$HOOKS/pre-edit-guard.sh" >/dev/null 2>&1
result 4 "malformed JSON allowed" $? 0

# -------------------------------------------------------
# pre-command-guard.sh tests (5-8)
# -------------------------------------------------------
echo ""
echo "--- pre-command-guard.sh ---"

# Test 5: "rm -rf /" -> should exit 2 (block)
echo '{"tool_input":{"command":"rm -rf /"}}' | bash "$HOOKS/pre-command-guard.sh" >/dev/null 2>&1
result 5 "rm -rf / blocked" $? 2

# Test 6: "git push --force origin main" -> should exit 2 (block)
echo '{"tool_input":{"command":"git push --force origin main"}}' | bash "$HOOKS/pre-command-guard.sh" >/dev/null 2>&1
result 6 "git push --force blocked" $? 2

# Test 7: "ls -la" -> should exit 0 (allow)
echo '{"tool_input":{"command":"ls -la"}}' | bash "$HOOKS/pre-command-guard.sh" >/dev/null 2>&1
result 7 "ls -la allowed" $? 0

# Test 8: empty stdin -> should exit 0 (allow)
echo "" | bash "$HOOKS/pre-command-guard.sh" >/dev/null 2>&1
result 8 "empty stdin allowed" $? 0

# -------------------------------------------------------
# post-command-risk-log.sh tests (9-10)
# -------------------------------------------------------
echo ""
echo "--- post-command-risk-log.sh ---"

# Test 9: valid command JSON -> should exit 0 and append to RISK_REGISTER.md
RISK_LOG="$PROJ/ops/risk/RISK_REGISTER.md"
BEFORE_LINES=$(wc -l < "$RISK_LOG")
TEST_CMD="kubectl get pods --all-namespaces"
echo "{\"tool_input\":{\"command\":\"$TEST_CMD\"},\"tool_result\":\"pod-a running\\npod-b running\"}" \
  | CLAUDE_PROJECT_DIR="$PROJ" bash "$HOOKS/post-command-risk-log.sh" >/dev/null 2>&1
EXIT_9=$?
AFTER_LINES=$(wc -l < "$RISK_LOG")
# Verify exit 0 AND that new lines were appended (should be 3 new lines: blank, timestamp, action, result)
if [ "$EXIT_9" -eq 0 ] && [ "$AFTER_LINES" -gt "$BEFORE_LINES" ]; then
  printf "${GRN}PASS${RST} Test  9: valid command logged to RISK_REGISTER (exit=0, lines %d->%d)\n" "$BEFORE_LINES" "$AFTER_LINES"
  PASS=$((PASS + 1))
else
  printf "${RED}FAIL${RST} Test  9: valid command log (exit=%s, lines %d->%d, expected growth)\n" "$EXIT_9" "$BEFORE_LINES" "$AFTER_LINES"
  FAIL=$((FAIL + 1))
fi

# Test 10: no RISK_REGISTER.md -> should exit 0 gracefully
echo '{"tool_input":{"command":"ls -la"}}' \
  | CLAUDE_PROJECT_DIR="/tmp/nonexistent_project_$$" bash "$HOOKS/post-command-risk-log.sh" >/dev/null 2>&1
result 10 "missing RISK_REGISTER graceful exit" $? 0

# -------------------------------------------------------
# Summary
# -------------------------------------------------------
echo ""
echo "========================================================"
if [ "$FAIL" -eq 0 ]; then
  printf "${GRN}All %d/%d tests passed.${RST}\n" "$PASS" "$TOTAL"
else
  printf "${YEL}%d/%d tests passed, %d failed.${RST}\n" "$PASS" "$TOTAL" "$FAIL"
fi
echo "========================================================"

exit $FAIL
