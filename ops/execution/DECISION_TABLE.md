# DECISION_TABLE.md

## Purpose
Choose the lightest execution mode that can solve the task safely and correctly.

## Default rule
Prefer direct execution unless there is a clear reason to escalate.

## Decision table

### Use direct when
- task is narrow and local,
- impacted files are limited,
- architecture is already clear,
- risk level is low,
- validation path is straightforward.

### Use architect first when
- scope crosses modules,
- design path is unclear,
- tradeoffs matter,
- user wants a plan,
- risk is medium or high.

### Use implementer directly when
- path is already chosen,
- work is implementation-heavy,
- scope is bounded,
- no major design ambiguity remains.

### Use reviewer when
- change is non-trivial,
- validation is partial,
- risk is medium or high,
- confidence seems higher than evidence,
- "done" is being considered.

### Use council-assisted when
- there are important competing options,
- the decision has business or technical tradeoffs,
- a wrong choice is expensive,
- ambiguity cannot be reduced by repo inspection alone.

### Do not escalate when
- the task is tiny,
- context is already obvious,
- overhead exceeds the value.

## Priority rules
1. Safety beats speed.
2. Clarity beats delegation.
3. Minimal sufficient mode beats impressive orchestration.
4. If uncertain between direct and escalated, start direct and escalate only on evidence.
