# ADAPTATION_CHECKLIST.md

## Purpose
Complete this checklist when installing the repo OS into a new project.
Fill REPO_PROFILE.md first, then work through the items below.

## Step 1: Identity
- [ ] Repo name recorded
- [ ] Repo type identified
- [ ] Primary language confirmed
- [ ] Framework/runtime confirmed
- [ ] Package manager confirmed
- [ ] Deployment target confirmed

## Step 2: Commands
- [ ] Install command confirmed and working
- [ ] Lint command confirmed and working
- [ ] Typecheck command confirmed and working
- [ ] Test command confirmed and working
- [ ] Build command confirmed and working
- [ ] Dev/run command confirmed and working

## Step 3: Risk surfaces
- [ ] Secret/credential paths identified
- [ ] Infra/deploy paths identified
- [ ] Migration paths identified
- [ ] CI/workflow paths identified
- [ ] Lockfiles identified
- [ ] PROTECTED_PATHS.md updated

## Step 4: Validation defaults
- [ ] Minimum validation defined for normal changes
- [ ] Minimum validation defined for risky changes
- [ ] VALIDATION.md updated

## Step 5: Architecture
- [ ] Main entrypoints documented
- [ ] Key modules/services documented
- [ ] Known fragile areas documented
- [ ] PROJECT_FACTS.md populated with verified facts only

## Step 6: Hooks
- [ ] .claude/settings.json reviewed
- [ ] PreToolUse hook with Edit matcher tested
- [ ] PreToolUse hook with Bash matcher tested
- [ ] Blocked patterns match actual risk surfaces

## Step 7: Subagents
- [ ] Architect role appropriate for this repo
- [ ] Implementer role appropriate for this repo
- [ ] Reviewer role appropriate for this repo
- [ ] Unused roles removed or noted as inactive

## Step 8: Smoke test
- [ ] Claude can read REPO_PROFILE.md and summarize mission
- [ ] Claude updates HEARTBEAT.md correctly
- [ ] Claude refuses to mark done without evidence
- [ ] Claude blocks or surfaces a protected-path edit
