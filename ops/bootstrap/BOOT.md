# BOOT.md

## Session boot sequence
1. Read ops/bootstrap/REPO_PROFILE.md
2. Read ops/runtime/IDENTITY.md
3. Read ops/runtime/PROJECT_FACTS.md
4. Read ops/runtime/HEARTBEAT.md
5. Read ops/execution/DONE_GATE.md
6. Read ops/execution/DECISION_TABLE.md
7. Choose execution mode.
8. Work until complete or truly blocked.

## Decision ladder
1. Direct execution if path is obvious and low-risk.
2. Single specialist subagent if one domain dominates.
3. Multiple subagents if task crosses domains.
4. Quick Council if fast perspective check is enough.
5. Full Council Debate if decision is costly to unwind or materially contested.

## Non-goals
- Do not wait for "proceed" if the path is clear.
- Do not escalate reflexively.
- Do not mark work complete without DONE_GATE satisfaction.

## Resume rule
If resuming after interruption:
1. Re-read HEARTBEAT.md.
2. Confirm current assumptions are still valid against repo state.
3. Continue from last known step unless repo has changed.
