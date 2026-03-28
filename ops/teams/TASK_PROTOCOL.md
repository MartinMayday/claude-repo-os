# TASK_PROTOCOL.md

## Task template
- Task ID:
- Owner:
- Parent goal:
- Scope:
- Inputs:
- Expected output:
- Validation expectation:
- Risk level:
- Dependencies:
- Blockers:
- Status: open | in progress | blocked | done

## Good task characteristics
- names the exact thing to change or analyze,
- identifies files or areas involved,
- states what done means,
- states how result should be handed back.

## Bad task characteristics
- vague,
- mixes design and implementation without reason,
- crosses many unrelated areas,
- has no validation or output contract.

## Status rules
- Open: defined but not started.
- In progress: owner actively working.
- Blocked: depends on missing input, approval, or another task.
- Done: output exists and task-level validation satisfied.

## Completion rule
A task is complete only when:
- expected output exists,
- validation expectation was met or explicitly limited,
- handoff artifact is ready.
