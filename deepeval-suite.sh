#!/usr/bin/env bash
# deepeval-suite.sh — Deep evaluation for repo-OS v0.1 hook system
#
# Categories:
#   A. Security edge cases (injection, bypass, traversal)
#   B. Input fuzzing (random, malformed, oversized)
#   C. Idempotency (repeated runs produce same results)
#   D. Schema validation (settings.json structural correctness)
#   E. Performance (timeout, throughput)
#   F. Regression prevention (old patterns must NOT work)
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0
TOTAL=0

pass() { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); echo -e "  ${GREEN}PASS${RESET} Test $TOTAL: $1"; }
fail() { FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); echo -e "  ${RED}FAIL${RESET} Test $TOTAL: $1"; }

# ── Helper: run hook with stdin and check exit code ─────────────────────────
run_hook() {
  local hook="$1" stdin="$2" expected_exit="$3" description="$4"
  local actual_exit
  actual_exit=$(echo "$stdin" | bash "$hook" 2>/dev/null; echo $?)
  if [[ "$actual_exit" -eq "$expected_exit" ]]; then
    pass "$description (exit=$actual_exit)"
  else
    fail "$description (expected=$expected_exit, got=$actual_exit)"
  fi
}

# ── Helper: run hook with stdin and check stderr contains pattern ────────────
run_hook_stderr() {
  local hook="$1" stdin="$2" expected_exit="$3" pattern="$4" description="$5"
  local stderr_out actual_exit
  stderr_out=$(echo "$stdin" | bash "$hook" 2>&1 >/dev/null) && actual_exit=0 || actual_exit=$?
  if [[ "$actual_exit" -eq "$expected_exit" ]] && echo "$stderr_out" | grep -q "$pattern"; then
    pass "$description (exit=$actual_exit, stderr has '$pattern')"
  else
    fail "$description (expected exit=$expected_exit stderr~'$pattern', got exit=$actual_exit stderr='$stderr_out')"
  fi
}

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════"
echo " repo-OS v0.1 — Deep Evaluation Suite"
echo "══════════════════════════════════════════════════════════${RESET}"
echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo -e "${CYAN}── A. Security Edge Cases ──────────────────────────────${RESET}"
# ══════════════════════════════════════════════════════════════════════════════

# A1: Path traversal attempt
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"tool_input":{"file_path":"../../../etc/passwd"}}' \
  0 "A1: path traversal ../../../etc/passwd allowed (not in blocklist)"

# A2: Hidden credential file
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"tool_input":{"file_path":"/app/.env.production"}}' \
  2 "A2: .env.production blocked"

# A3: Credential directory
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"tool_input":{"file_path":"/home/user/secrets/db-password"}}' \
  2 "A3: /secrets/ directory blocked"

# A4: PEM key file
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"tool_input":{"file_path":"/etc/ssl/server.pem"}}' \
  2 "A4: .pem file blocked"

# A5: Command injection attempt in bash hook
run_hook .claude/hooks/pre-command-guard.sh \
  '{"tool_input":{"command":"ls; rm -rf /"}}' \
  2 "A5: command injection with rm -rf blocked"

# A6: Obfuscated destructive command
run_hook .claude/hooks/pre-command-guard.sh \
  '{"tool_input":{"command":"echo hello && git reset --hard HEAD"}}' \
  2 "A6: chained git reset --hard blocked"

# A7: Sudo destructive
run_hook .claude/hooks/pre-command-guard.sh \
  '{"tool_input":{"command":"sudo rm -rf /var/log"}}' \
  2 "A7: sudo rm -rf blocked"

# A8: Terraform destroy
run_hook .claude/hooks/pre-command-guard.sh \
  '{"tool_input":{"command":"cd infra && terraform destroy -auto-approve"}}' \
  2 "A8: terraform destroy blocked"

# A9: Protected path - terraform directory
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"tool_input":{"file_path":"/project/infra/main.tf"}}' \
  2 "A9: /infra/ edit blocked"

# A10: Protected path - GitHub workflows
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"tool_input":{"file_path":"./.github/workflows/ci.yml"}}' \
  2 "A10: .github/workflows/ edit blocked"

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo -e "${CYAN}── B. Input Fuzzing ─────────────────────────────────────${RESET}"
# ══════════════════════════════════════════════════════════════════════════════

# B1: Completely empty stdin
run_hook .claude/hooks/pre-edit-guard.sh \
  "" \
  0 "B1: empty stdin → graceful exit 0"

# B2: Null bytes in input
run_hook .claude/hooks/pre-edit-guard.sh \
  $'\x00{"tool_input":{"file_path":"test.ts"}}' \
  0 "B2: null byte prefix → graceful exit 0"

# B3: Valid JSON but missing tool_input
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"session_id":"abc"}' \
  0 "B3: JSON without tool_input → graceful exit 0"

# B4: tool_input is array not object
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"tool_input":["file.ts"]}' \
  0 "B4: tool_input as array → graceful exit 0"

# B5: Extraordinarily long command string
LONG_CMD=$(python3 -c "print('a' * 10000)")
run_hook .claude/hooks/pre-command-guard.sh \
  "{\"tool_input\":{\"command\":\"$LONG_CMD\"}}" \
  0 "B5: 10KB command string → graceful exit 0"

# B6: Unicode in file path
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"tool_input":{"file_path":"/home/用户/文件.ts"}}' \
  0 "B6: unicode path → graceful exit 0"

# B7: Newline in command — contains rm -rf substring, correctly blocked
run_hook .claude/hooks/pre-command-guard.sh \
  '{"tool_input":{"command":"echo hello\nrm -rf /"}}' \
  2 "B7: newline-wrapped rm -rf correctly blocked (exit 2)"

# B8: JSON with extra fields
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"tool_input":{"file_path":"test.ts","old_string":"x","new_string":"y","extra":123}}' \
  0 "B8: extra JSON fields ignored → exit 0"

# B9: Numeric file_path instead of string
run_hook .claude/hooks/pre-edit-guard.sh \
  '{"tool_input":{"file_path":12345}}' \
  0 "B9: numeric file_path → graceful exit 0"

# B10: Boolean command instead of string
run_hook .claude/hooks/pre-command-guard.sh \
  '{"tool_input":{"command":true}}' \
  0 "B10: boolean command → graceful exit 0"

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo -e "${CYAN}── C. Idempotency ───────────────────────────────────────${RESET}"
# ══════════════════════════════════════════════════════════════════════════════

# C1: Same input produces same result (5 runs)
CONSISTENT=true
for i in $(seq 1 5); do
  EXIT=$(echo '{"tool_input":{"file_path":"test.ts"}}' | bash .claude/hooks/pre-edit-guard.sh 2>/dev/null; echo $?)
  if [[ "$EXIT" != "0" ]]; then CONSISTENT=false; fi
done
if $CONSISTENT; then
  pass "C1: idempotent across 5 runs (test.ts always exit 0)"
else
  fail "C1: inconsistent results across 5 runs"
fi

# C2: Blocked path always blocked (5 runs)
CONSISTENT=true
for i in $(seq 1 5); do
  EXIT=$(echo '{"tool_input":{"file_path":".env"}}' | bash .claude/hooks/pre-edit-guard.sh 2>/dev/null; echo $?)
  if [[ "$EXIT" != "2" ]]; then CONSISTENT=false; fi
done
if $CONSISTENT; then
  pass "C2: .env blocked consistently across 5 runs"
else
  fail "C2: inconsistent blocking of .env"
fi

# C3: patch-hooks.sh produces same output on re-run
FIRST=$(cat .claude/settings.json | md5sum)
bash patch-hooks.sh >/dev/null 2>&1
SECOND=$(cat .claude/settings.json | md5sum)
if [[ "$FIRST" == "$SECOND" ]]; then
  pass "C3: settings.json unchanged after re-running patch-hooks.sh"
else
  fail "C3: settings.json CHANGED after re-running patch-hooks.sh"
fi

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo -e "${CYAN}── D. Schema Validation ────────────────────────────────${RESET}"
# ══════════════════════════════════════════════════════════════════════════════

# D1: settings.json is valid JSON
if python3 -c "import json; json.load(open('.claude/settings.json'))" 2>/dev/null; then
  pass "D1: settings.json is valid JSON"
else
  fail "D1: settings.json is NOT valid JSON"
fi

# D2: Only valid event names present
INVALID=$(python3 -c "
import json
valid = {'PreToolUse','PostToolUse','SessionStart','Stop','SessionEnd','UserPromptSubmit'}
d = json.load(open('.claude/settings.json'))
hooks = d.get('hooks', {})
bad = set(hooks.keys()) - valid
print(','.join(bad) if bad else '')
")
if [[ -z "$INVALID" ]]; then
  pass "D2: only valid Claude Code event names in settings.json"
else
  fail "D2: invalid event names found: $INVALID"
fi

# D3: Each event has array of objects with hooks wrapper
SCHEMA_OK=$(python3 -c "
import json
d = json.load(open('.claude/settings.json'))
hooks = d.get('hooks', {})
ok = True
for event, entries in hooks.items():
  if not isinstance(entries, list): ok = False; break
  for entry in entries:
    if not isinstance(entry, dict): ok = False; break
    if 'hooks' not in entry: ok = False; break
    if not isinstance(entry['hooks'], list): ok = False; break
    for h in entry['hooks']:
      if not isinstance(h, dict): ok = False; break
      if 'type' not in h or 'command' not in h: ok = False; break
print('ok' if ok else 'bad')
")
if [[ "$SCHEMA_OK" == "ok" ]]; then
  pass "D3: settings.json has correct nested schema (event→[{matcher,hooks:[{type,command}]}])"
else
  fail "D3: settings.json schema is malformed"
fi

# D4: All referenced hook files exist
FILES_EXIST=$(python3 -c "
import json, os
d = json.load(open('.claude/settings.json'))
missing = []
for event, entries in d.get('hooks', {}).items():
  for entry in entries:
    for h in entry.get('hooks', []):
      cmd = h.get('command', '')
      # Strip leading ./
      if cmd.startswith('./'):
        cmd = cmd[2:]
      if not os.path.exists(cmd):
        missing.append(cmd)
print(','.join(missing) if missing else '')
")
if [[ -z "$FILES_EXIST" ]]; then
  pass "D4: all hook files referenced in settings.json exist"
else
  fail "D4: missing hook files: $FILES_EXIST"
fi

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo -e "${CYAN}── E. Performance ──────────────────────────────────────${RESET}"
# ══════════════════════════════════════════════════════════════════════════════

# E1: Hook completes within 2 seconds
START=$(date +%s%N)
echo '{"tool_input":{"file_path":"test.ts"}}' | bash .claude/hooks/pre-edit-guard.sh >/dev/null 2>&1
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))
if [[ $ELAPSED_MS -lt 2000 ]]; then
  pass "E1: pre-edit-guard completes in ${ELAPSED_MS}ms (< 2000ms)"
else
  fail "E1: pre-edit-guard took ${ELAPSED_MS}ms (>= 2000ms)"
fi

# E2: 50 sequential runs complete within 10 seconds total
START=$(date +%s%N)
for i in $(seq 1 50); do
  echo '{"tool_input":{"command":"ls"}}' | bash .claude/hooks/pre-command-guard.sh >/dev/null 2>&1
done
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))
if [[ $ELAPSED_MS -lt 10000 ]]; then
  pass "E2: 50 sequential runs in ${ELAPSED_MS}ms (< 10s)"
else
  fail "E2: 50 sequential runs took ${ELAPSED_MS}ms (>= 10s)"
fi

echo ""

# ══════════════════════════════════════════════════════════════════════════════
echo -e "${CYAN}── F. Regression Prevention ────────────────────────────${RESET}"
# ══════════════════════════════════════════════════════════════════════════════

# F1: No old event names in settings.json
if grep -qE '"preEdit"|"preCommand"|"postCommand"' .claude/settings.json 2>/dev/null; then
  fail "F1: old event names still in settings.json"
else
  pass "F1: no old event names (preEdit/preCommand/postCommand) in settings.json"
fi

# F2: No $1 positional arg usage in active hooks
if grep -qlE 'TARGET=.*\$\{1|CMD=.*\$\{1|RESULT=.*\$\{2' .claude/hooks/pre-edit-guard.sh .claude/hooks/pre-command-guard.sh .claude/hooks/post-command-risk-log.sh .claude/hooks/approval-check.sh 2>/dev/null; then
  fail "F2: positional $1/$2 usage still found in hooks"
else
  pass "F2: no \$1/\$2 positional arg usage in any hook"
fi

# F3: No exit 3 in active hooks
if grep -q 'exit 3' .claude/hooks/pre-edit-guard.sh .claude/hooks/pre-command-guard.sh .claude/hooks/post-command-risk-log.sh .claude/hooks/approval-check.sh 2>/dev/null; then
  fail "F3: exit 3 still found in hooks"
else
  pass "F3: no exit 3 in any hook"
fi

# F4: All active hooks use INPUT=$(cat) pattern
ALL_STDIN=true
for hook in .claude/hooks/pre-edit-guard.sh .claude/hooks/pre-command-guard.sh .claude/hooks/post-command-risk-log.sh .claude/hooks/approval-check.sh; do
  if ! grep -q 'INPUT=\$(cat)' "$hook" 2>/dev/null; then
    ALL_STDIN=false
  fi
done
if $ALL_STDIN; then
  pass "F4: all 4 hooks use INPUT=\$(cat) stdin pattern"
else
  fail "F4: not all hooks use INPUT=\$(cat)"
fi

# F5: bootstrap.sh generates correct event names
if grep -qE '"preEdit"|"preCommand"|"postCommand"' bootstrap.sh 2>/dev/null; then
  fail "F5: bootstrap.sh still has old event names"
else
  pass "F5: bootstrap.sh free of old event names"
fi

# F6: ops/ free of old event names
if grep -rqE '"preEdit"|"preCommand"|"postCommand"' ops/ 2>/dev/null; then
  fail "F6: ops/ still has old event name references"
else
  pass "F6: ops/ free of old event name references"
fi

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════${RESET}"
echo -e " ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}, $TOTAL total"
echo -e "${CYAN}══════════════════════════════════════════════════════════${RESET}"
echo ""

if [[ $FAIL -eq 0 ]]; then
  echo -e "${GREEN}ALL $TOTAL DEEP EVALUATION TESTS PASSED${RESET}"
else
  echo -e "${RED}$FAIL TESTS FAILED — see details above${RESET}"
fi

exit $FAIL
