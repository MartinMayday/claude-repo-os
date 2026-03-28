<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

## Map of Content — claude-repo-os

This MOC covers the full session: what was built, why, how it fits together, and where each piece lives.

***

## Origin

Started as a reconstruction of a "precision execution mode" prompt from screenshots.
Evolved into a full Claude Code repo-operating-system built around one governing principle: **truth and evidence before confidence and autonomy**.

***

## Governing philosophy

| Principle | Meaning |
| :-- | :-- |
| Accuracy first | Never fabricate repo facts, validation, or capabilities |
| Minimal diff | Smallest correct change, not broadest rewrite |
| Bounded autonomy | Continue without nudging, but stop at real blockers |
| Verified completion | Done means evidence exists, not code was written |
| Native vs custom | Always distinguish Claude Code features from repo conventions |


***

## System layers

| Layer | Purpose | Status |
| :-- | :-- | :-- |
| 1. Baseline policy | Precision-execution behavior, anti-drift rules | Done |
| 2. Root control | `CLAUDE.md`, settings, startup posture | Done |
| 3. Skill workflows | plan, implement, debug, review-pr | Done |
| 4. Hook enforcement | Lifecycle automation, safety guards | Done |
| 5. Runtime memory | HEARTBEAT, PROJECT_FACTS, BOOT, IDENTITY, USER, TOOLS, SOUL | Done |
| 6. Bounded autonomy | Done gate, stop rules, validation evidence | Done |
| 7. Council layer | Quick Council, full Debate, transcript, decision artifact | Done |
| 8. Specialist execution | Subagents by role, scoped tools, synthesis | Done |
| 9. Agent teams | Lead/worker, task protocol, handoffs, synthesis | Done |
| 10. Packaging | Bootstrap script, installer, reuse pattern | Done |
| 11. Evaluation | Scorecards, run log, failure patterns, improvement backlog | Done |


***

## File manifest

### Native Claude Code

```
CLAUDE.md
.claude/settings.json
.claude/agents/architect.md
.claude/agents/implementer.md
.claude/agents/reviewer.md
.claude/agents/researcher.md
.claude/agents/security.md
.claude/agents/chair.md
.claude/hooks/pre-edit-guard.sh
.claude/hooks/pre-command-guard.sh
.claude/hooks/approval-check.sh
.claude/hooks/post-command-risk-log.sh
```


### Custom operating layer — ops/

```
ops/bootstrap/
  REPO_PROFILE.md          repo identity, commands, risk surfaces
  BOOT.md                  session startup sequence and decision ladder
  ADAPTATION_CHECKLIST.md  steps to adapt OS to a new real repo

ops/runtime/
  HEARTBEAT.md             active task state, mode, blockers, next actions
  PROJECT_FACTS.md         verified durable repo truths only
  IDENTITY.md              stable behavioral identity of the system
  USER.md                  operator preferences and stack context
  TOOLS.md                 tool trust model and constraints
  AGENTS.md                role map, routing rules, shared contract
  SOUL.md                  long-horizon intent and drift recovery

ops/execution/
  DONE_GATE.md             completion contract, required checks, verdicts
  VALIDATION.md            accepted proof types, minimums by change type
  DECISION_TABLE.md        mode selection: direct vs subagent vs team vs Council
  TASK_LIFECYCLE.md        standard task flow: understand, plan, execute, validate, update
  BLOCKERS.md              hard vs soft blockers, report format, rules

ops/risk/
  RISK_POLICY.md           low / medium / high risk definitions and handling
  PROTECTED_PATHS.md       always-blocked and approval-required paths
  APPROVALS.md             explicit approval artifacts, scope-bound
  RISK_REGISTER.md         append-only log of risky operations
  DESTRUCTIVE_COMMANDS.md  blocked and approval-gated shell commands

ops/council/
  COUNCIL_POLICY.md        when Council is justified, trigger list, hard rules
  COUNCIL_REQUEST.md       decision question, context, options, criteria
  COUNCIL_DECISION.md      recommendation, tradeoffs, execution guidance

ops/teams/
  TEAM_OPERATING_MODEL.md  when teams are justified, lead/teammate contracts
  TASK_PROTOCOL.md         task template, decomposition rules, status lifecycle
  HANDOFF_TEMPLATE.md      standard artifact for specialist-to-lead handoff
  SYNTHESIS_TEMPLATE.md    lead merge judgment and final integrated result

ops/evaluation/
  EVALUATION.md            when and how to evaluate runs
  SUCCESS_METRICS.md       7 scoring dimensions, 0-5 scale, evidence examples
  SESSION_SCORECARD.md     per-run score, evidence, verdict
  RUN_LOG.md               compact chronological run history
  MODE_COMPARISON.md       direct vs subagent vs team vs Council over time
  FAILURE_PATTERNS.md      recurring failure classes and preventive changes
  IMPROVEMENT_BACKLOG.md   evidence-tied OS improvement items
```


***

## Decision ladder

```
Direct execution
  └── if one domain dominates
        └── Single specialist subagent
              └── if task crosses domains
                    └── Multiple subagents + Chair synthesis
                          └── if fast perspective check needed
                                └── Quick Council
                                      └── if costly / contested / high-impact
                                            └── Full Council Debate
```


***

## Install modes

| Mode | Files |
| :-- | :-- |
| MVP | CLAUDE.md + ops/bootstrap + ops/runtime + ops/execution + ops/risk basics |
| Recommended | MVP + .claude/settings + hooks + subagents + DECISION_TABLE + TASK_LIFECYCLE |
| Full | Recommended + Council + Teams + Evaluation |


***

## Install order

```
1.  CLAUDE.md
2.  ops/bootstrap/REPO_PROFILE.md
3.  ops/bootstrap/BOOT.md
4.  ops/runtime/HEARTBEAT.md
5.  ops/runtime/PROJECT_FACTS.md
6.  ops/execution/VALIDATION.md
7.  ops/execution/DONE_GATE.md
8.  ops/risk/RISK_POLICY.md
9.  ops/risk/PROTECTED_PATHS.md
10. .claude/settings.json
11. .claude/hooks/*
12. ops/risk/APPROVALS.md + RISK_REGISTER.md
13. ops/execution/BLOCKERS.md + DECISION_TABLE.md + TASK_LIFECYCLE.md
14. .claude/agents/*
15. ops/runtime/IDENTITY.md + USER.md + TOOLS.md + AGENTS.md + SOUL.md
16. ops/council/*
17. ops/teams/*
18. ops/evaluation/*
```


***

## Adaptation sequence

When dropping this OS into a real repo:

```
1. Fill REPO_PROFILE.md           → repo identity, commands, risk surfaces
2. Tighten CLAUDE.md mission      → project-specific purpose
3. Populate PROJECT_FACTS.md      → verified truths only, no guesses
4. Set HEARTBEAT.md               → current state
5. Tune VALIDATION.md             → real commands for this stack
6. Tune PROTECTED_PATHS.md        → real sensitive paths for this repo
7. Review hooks                   → match patterns to actual risk surfaces
8. Review subagents               → remove unused roles
9. Run smoke test                 → read profile, update heartbeat, refuse fake done
10. Add Council / teams / eval    → only when real workload justifies them
```


***

## Reuse command

```bash
gh repo create my-new-project --private --clone
cd my-new-project
curl -sO https://raw.githubusercontent.com/MartinMayday/claude-repo-os/main/bootstrap.sh
chmod +x bootstrap.sh && ./bootstrap.sh
```


***

## Live repo

`https://github.com/MartinMayday/claude-repo-os`

***

## What this enables

A Claude Code instance that can:

- start from a PRD or task,
- choose its own execution mode,
- implement with minimal diff,
- validate before claiming done,
- escalate to specialists or Council when the task earns it,
- maintain state across interrupted sessions,
- score its own runs honestly,
- and improve the operating system over time from real evidence.

