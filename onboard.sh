#!/usr/bin/env bash
set -euo pipefail

# ══════════════════════════════════════════════════════════════════════════════
# claude-repo-os onboarding script
# Asks targeted questions and writes:
#   ops/bootstrap/REPO_PROFILE.md
#   CLAUDE.md (mission section updated)
#   ops/runtime/PROJECT_FACTS.md
#   ops/execution/VALIDATION.md
#   ops/risk/PROTECTED_PATHS.md
# ══════════════════════════════════════════════════════════════════════════════

BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

ask() {
  local prompt="$1"
  local default="${2:-}"
  local answer
  if [[ -n "$default" ]]; then
    read -rp "$(echo -e "${BOLD}${prompt}${RESET} ${DIM}[${default}]${RESET}: ")" answer
    echo "${answer:-$default}"
  else
    read -rp "$(echo -e "${BOLD}${prompt}${RESET}: ")" answer
    echo "${answer}"
  fi
}

ask_multi() {
  local prompt="$1"
  echo -e "${BOLD}${prompt}${RESET} ${DIM}(comma-separated, or leave blank)${RESET}:"
  local answer
  read -rp "> " answer
  echo "${answer}"
}

echo ""
echo -e "${GREEN}══════════════════════════════════════════${RESET}"
echo -e "${GREEN}  claude-repo-os onboarding${RESET}"
echo -e "${GREEN}══════════════════════════════════════════${RESET}"
echo ""
echo -e "${DIM}This script will ask ~20 questions and write your repo-specific OS files.${RESET}"
echo -e "${DIM}Press Enter to accept defaults where shown.${RESET}"
echo ""

# ── Section 1: Identity ───────────────────────────────────────────────────────
echo -e "${YELLOW}── SECTION 1: Repo identity ──────────────────────────${RESET}"
REPO_NAME=$(ask "Repo name")
REPO_PURPOSE=$(ask "One-sentence purpose of this repo")
REPO_TYPE=$(ask "Repo type (app / service / library / infra / monorepo / other)" "app")
PRIMARY_LANG=$(ask "Primary language" "TypeScript")
FRAMEWORK=$(ask "Framework / runtime" "Node.js")
PKG_MANAGER=$(ask "Package manager (npm / pnpm / yarn / pip / uv / other)" "pnpm")
DEPLOY_TARGET=$(ask "Deployment target (GCP / Oracle / AWS / local / other)" "GCP")

# ── Section 2: Commands ───────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── SECTION 2: Commands ───────────────────────────────${RESET}"
CMD_INSTALL=$(ask "Install command" "${PKG_MANAGER} install")
CMD_LINT=$(ask "Lint command" "${PKG_MANAGER} run lint")
CMD_TYPECHECK=$(ask "Typecheck command" "${PKG_MANAGER} run typecheck")
CMD_TEST=$(ask "Test command" "${PKG_MANAGER} run test")
CMD_BUILD=$(ask "Build command" "${PKG_MANAGER} run build")
CMD_DEV=$(ask "Dev/run command" "${PKG_MANAGER} run dev")
CMD_FORMAT=$(ask "Format command" "${PKG_MANAGER} run format")

# ── Section 3: Structure ──────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── SECTION 3: Repo structure ─────────────────────────${RESET}"
PATH_APP=$(ask "Main app/service path" "src/")
PATH_INFRA=$(ask "Infra path (or leave blank if none)" "")
PATH_MIGRATIONS=$(ask "Migration path (or leave blank if none)" "")
PATH_CONFIG=$(ask "Config path" "config/")
PATH_DOCS=$(ask "Docs path" "docs/")

# ── Section 4: Risk surfaces ──────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── SECTION 4: Risk surfaces ──────────────────────────${RESET}"
echo -e "${DIM}These become your protected and approval-required paths.${RESET}"
SECRETS_PATHS=$(ask_multi "Secret/credential paths (e.g. .env, secrets/, vault/)")
INFRA_PATHS=$(ask_multi "Infra/deploy paths (e.g. terraform/, k8s/, .github/workflows/)")
MIGRATION_PATHS=$(ask_multi "Migration/database paths")
LOCKFILES=$(ask "Lockfile name(s)" "${PKG_MANAGER}-lock.yaml")
EXTRA_PROTECTED=$(ask_multi "Any other do-not-touch paths")

# ── Section 5: Validation ─────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── SECTION 5: Validation defaults ───────────────────${RESET}"
VALIDATE_NORMAL=$(ask "Minimum validation for normal code change (e.g. lint,test)" "lint,typecheck,test")
VALIDATE_RISKY=$(ask "Minimum validation for risky change" "lint,typecheck,test,build")
VALIDATE_DOCS=$(ask "Validation for docs/comments only" "manual review note")

# ── Section 6: Execution defaults ────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── SECTION 6: Execution defaults ────────────────────${RESET}"
DEFAULT_MODE=$(ask "Default execution mode (direct / subagent / team)" "direct")
SUBAGENT_WHEN=$(ask "Use subagents when" "task crosses modules or design ambiguity exists")
TEAM_WHEN=$(ask "Use team mode when" "work can be decomposed into parallel bounded tasks")
COUNCIL_WHEN=$(ask "Use Council when" "competing options exist with meaningful tradeoffs")

# ── Section 7: Architecture facts ────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── SECTION 7: Known architecture facts ──────────────${RESET}"
ARCH_ENTRYPOINTS=$(ask "Main entrypoints (files or paths)")
ARCH_KEY_MODULES=$(ask_multi "Key modules or services")
ARCH_DATA_STORES=$(ask_multi "Data stores (e.g. Postgres, Qdrant, Redis)")
ARCH_INTEGRATIONS=$(ask_multi "External integrations (e.g. Stripe, OpenAI, N8N)")
ARCH_FRAGILE=$(ask_multi "Known fragile or high-risk areas")

# ── Section 8: Constraints ────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}── SECTION 8: Constraints ────────────────────────────${RESET}"
ARCH_CONSTRAINTS=$(ask_multi "Architecture constraints (e.g. no ORM, no global state)")
NAMING_CONVENTIONS=$(ask "Naming conventions" "kebab-case files, camelCase vars")
BRANCH_POLICY=$(ask "Branch/PR policy" "feature branches, PR required")

# ══════════════════════════════════════════════════════════════════════════════
# write files
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p ops/bootstrap ops/runtime ops/execution ops/risk

echo ""
echo -e "${GREEN}==> Writing ops/bootstrap/REPO_PROFILE.md...${RESET}"

cat > ops/bootstrap/REPO_PROFILE.md << EOF
# REPO_PROFILE.md

## Repo identity
- Name: ${REPO_NAME}
- Purpose: ${REPO_PURPOSE}
- Repo type: ${REPO_TYPE}
- Primary language: ${PRIMARY_LANG}
- Framework/runtime: ${FRAMEWORK}
- Package manager: ${PKG_MANAGER}
- Deployment target: ${DEPLOY_TARGET}

## Commands
- Install: ${CMD_INSTALL}
- Lint: ${CMD_LINT}
- Typecheck: ${CMD_TYPECHECK}
- Test: ${CMD_TEST}
- Build: ${CMD_BUILD}
- Dev: ${CMD_DEV}
- Format: ${CMD_FORMAT}

## Structure
- Main app/service path: ${PATH_APP}
- Infra path: ${PATH_INFRA:-none}
- Migration path: ${PATH_MIGRATIONS:-none}
- Config path: ${PATH_CONFIG}
- Docs path: ${PATH_DOCS}

## Risk surfaces
- Secrets/credential paths: ${SECRETS_PATHS:-none defined}
- Infra/deploy paths: ${INFRA_PATHS:-none defined}
- Migration/database paths: ${MIGRATION_PATHS:-none defined}
- Lockfiles: ${LOCKFILES}
- Other protected areas: ${EXTRA_PROTECTED:-none}

## Preferred execution defaults
- Default mode: ${DEFAULT_MODE}
- Use subagents when: ${SUBAGENT_WHEN}
- Use team mode when: ${TEAM_WHEN}
- Use Council when: ${COUNCIL_WHEN}

## Validation defaults
- Normal code change: ${VALIDATE_NORMAL}
- Risky change: ${VALIDATE_RISKY}
- Docs/comments only: ${VALIDATE_DOCS}

## Repo conventions
- Naming conventions: ${NAMING_CONVENTIONS}
- Branch/PR policy: ${BRANCH_POLICY}
- Architecture constraints: ${ARCH_CONSTRAINTS:-none defined}

## Known gaps
- Missing docs:
- Missing validation:
- High-risk unclear areas:
EOF

echo -e "${GREEN}==> Writing ops/runtime/PROJECT_FACTS.md...${RESET}"

cat > ops/runtime/PROJECT_FACTS.md << EOF
# PROJECT_FACTS.md

## Purpose
Store durable repo truths.
Only record facts verified from the repo, validated outputs, or explicit user instruction.

## Verified facts
- Fact: Repo is ${REPO_TYPE} written in ${PRIMARY_LANG}
  - Source: onboarding
  - Last checked: $(date -u +"%Y-%m-%d")

## Architecture
- Entry points: ${ARCH_ENTRYPOINTS}
- Main services/modules: ${ARCH_KEY_MODULES:-unknown - inspect repo}
- Data stores: ${ARCH_DATA_STORES:-unknown - inspect repo}
- External integrations: ${ARCH_INTEGRATIONS:-unknown - inspect repo}
- Background jobs/workers: unknown - inspect repo
- Deployment shape: ${DEPLOY_TARGET}

## Commands confirmed working
- Command: ${CMD_INSTALL}
  - Purpose: install dependencies
  - Last verified: $(date -u +"%Y-%m-%d")
- Command: ${CMD_LINT}
  - Purpose: lint
  - Last verified: not yet verified
- Command: ${CMD_TEST}
  - Purpose: run tests
  - Last verified: not yet verified

## Important conventions
- Convention: ${NAMING_CONVENTIONS}
  - Evidence/source: onboarding

## Protected or fragile areas
$(if [[ -n "${ARCH_FRAGILE}" ]]; then
  IFS=',' read -ra items <<< "${ARCH_FRAGILE}"
  for item in "${items[@]}"; do
    echo "- Area: $(echo "$item" | xargs)"
    echo "  - Why sensitive: user-identified during onboarding"
    echo "  - Evidence/source: onboarding"
  done
else
  echo "- Area: none identified yet - inspect repo"
fi)

## Unknowns
- Unknown: full module dependency map
  - Why it matters: needed for safe cross-module changes
  - How to verify: inspect repo structure and imports
- Unknown: test coverage percentage
  - Why it matters: affects confidence in validation
  - How to verify: run coverage report

## Rules
- Do not store guesses as facts.
- If uncertain, put it under Unknowns, not Verified facts.
EOF

echo -e "${GREEN}==> Writing ops/execution/VALIDATION.md...${RESET}"

cat > ops/execution/VALIDATION.md << EOF
# VALIDATION.md

## Purpose
Define what counts as proof for this repo.

## Accepted evidence
- Lint ran and passed: ${CMD_LINT}
- Typecheck ran and passed: ${CMD_TYPECHECK}
- Tests ran and passed: ${CMD_TEST}
- Build ran and succeeded: ${CMD_BUILD}
- Manual verification note with explicit description.

## Minimum validation by change type

### Trivial / docs / comments
- ${VALIDATE_DOCS}

### Normal code change
$(IFS=',' read -ra items <<< "${VALIDATE_NORMAL}"; for i in "${items[@]}"; do echo "- $(echo "$i" | xargs)"; done)

### Risky / cross-cutting change
$(IFS=',' read -ra items <<< "${VALIDATE_RISKY}"; for i in "${items[@]}"; do echo "- $(echo "$i" | xargs)"; done)
- Manual verification note required.
- Approval artifact required if protected paths involved.

## Insufficient evidence
- "It should work" without running anything.
- "No errors visible" without running checks.
- Assumed passing because no failure was seen.
- Prior run results assumed still valid after changes.

## When validation cannot run
State explicitly:
- which validation could not run,
- why it could not run,
- what the risk is of proceeding without it,
- what would be needed to verify later.
EOF

echo -e "${GREEN}==> Writing ops/risk/PROTECTED_PATHS.md...${RESET}"

generate_path_block() {
  local raw="$1"
  if [[ -z "$raw" ]]; then
    echo "- none defined during onboarding - review and add"
    return
  fi
  IFS=',' read -ra items <<< "$raw"
  for item in "${items[@]}"; do
    echo "- $(echo "$item" | xargs)"
  done
}

cat > ops/risk/PROTECTED_PATHS.md << EOF
# PROTECTED_PATHS.md

## Always protected
- .env
- .env.*
- secrets/**
- credentials/**
- **/*.pem
- **/*.key
- **/*.p12
- **/*.crt
$(generate_path_block "${SECRETS_PATHS}")

## Approval-required
- .github/workflows/**
- ${LOCKFILES}
$(generate_path_block "${INFRA_PATHS}")
$(generate_path_block "${MIGRATION_PATHS}")
$(generate_path_block "${EXTRA_PROTECTED}")

## Repo-defined do-not-touch
$(if [[ -n "${ARCH_FRAGILE}" ]]; then
  IFS=',' read -ra items <<< "${ARCH_FRAGILE}"
  for item in "${items[@]}"; do
    echo "- $(echo "$item" | xargs)"
  done
else
  echo "- none identified yet"
fi)
EOF

echo -e "${GREEN}==> Updating CLAUDE.md mission section...${RESET}"

cat > CLAUDE.md << EOF
# CLAUDE.md

## Mission
Operate as a precision-first execution system for: ${REPO_NAME}

Purpose: ${REPO_PURPOSE}

Primary goals:
- Understand the real task before acting.
- Prefer evidence over confidence.
- Make the smallest correct change that solves the problem.
- Validate before claiming success.
- Stop and surface blockers instead of guessing.

## Repo context
- Type: ${REPO_TYPE}
- Stack: ${PRIMARY_LANG} / ${FRAMEWORK}
- Package manager: ${PKG_MANAGER}
- Deploy target: ${DEPLOY_TARGET}

## Core behavior
- Do not fabricate facts, capabilities, results, logs, validations, or external knowledge.
- Do not claim something is complete unless there is explicit evidence.
- Distinguish clearly between verified, inferred, and unknown.
- When uncertain, say what is missing and what would verify it.
- Prefer repo truth over assumptions.
- Prefer minimal diffs over broad refactors unless scope explicitly requires otherwise.

## Execution hierarchy
1. Understand the request and current repo state.
2. Check repo facts and active heartbeat.
3. Choose the simplest suitable execution mode.
4. Execute within risk boundaries.
5. Validate results.
6. Pass the done gate.
7. Update runtime state.

## Default mode policy
- Default: ${DEFAULT_MODE}
- Use subagents when: ${SUBAGENT_WHEN}
- Use team mode when: ${TEAM_WHEN}
- Use Council when: ${COUNCIL_WHEN}

## Safety rules
- Never bypass protected paths or risky operations silently.
- If approval is required, stop and surface it.
- If validation cannot run, do not pretend it ran.
- If a requested action conflicts with repo safety policy, explain the conflict.

## Completion rule
A task is not done because code was written.
A task is done only when:
- the requested outcome is addressed,
- evidence exists,
- unresolved risks are named,
- runtime state is updated.

## Runtime sources
Consult these files when present:
- ops/bootstrap/REPO_PROFILE.md
- ops/runtime/HEARTBEAT.md
- ops/runtime/PROJECT_FACTS.md
- ops/execution/DONE_GATE.md

## Working style
- Be concise, explicit, and operational.
- Surface assumptions before they cause drift.
- Preserve momentum, but never at the cost of truthfulness.
EOF

# ── commit onboarding output ──────────────────────────────────────────────────
echo ""
echo -e "${GREEN}==> Staging onboarding output...${RESET}"
git add -A
git commit -m "chore: onboard ${REPO_NAME}

Repo-specific files generated by onboard.sh:
- ops/bootstrap/REPO_PROFILE.md
- ops/runtime/PROJECT_FACTS.md
- ops/execution/VALIDATION.md
- ops/risk/PROTECTED_PATHS.md
- CLAUDE.md (mission updated)

Stack: ${PRIMARY_LANG} / ${FRAMEWORK} / ${PKG_MANAGER}
Deploy: ${DEPLOY_TARGET}
Default mode: ${DEFAULT_MODE}"

git push

echo ""
echo -e "${GREEN}══════════════════════════════════════════${RESET}"
echo -e "${GREEN}  Onboarding complete for: ${REPO_NAME}${RESET}"
echo -e "${GREEN}══════════════════════════════════════════${RESET}"
echo ""
echo -e "${BOLD}Next steps:${RESET}"
echo "  1. Review and verify ops/runtime/PROJECT_FACTS.md against actual repo"
echo "  2. Work through ops/bootstrap/ADAPTATION_CHECKLIST.md"
echo "  3. Verify lint/test/build commands actually run cleanly"
echo "  4. Run smoke test: ask Claude to read REPO_PROFILE and update HEARTBEAT"
echo "  5. Add ops/council, ops/teams, ops/evaluation when workload justifies"
echo ""