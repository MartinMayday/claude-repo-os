# RISK_POLICY.md

## Risk levels

### Low
Examples:
- read-only inspection,
- narrow code edits in known-safe paths,
- linting, typecheck, unit tests.

Behavior:
- allowed without approval,
- must still log validation evidence when relevant.

### Medium
Examples:
- non-trivial refactors inside one package,
- lockfile updates,
- schema-adjacent code changes without migration execution,
- changes affecting auth-adjacent logic.

Behavior:
- require explicit plan,
- prefer minimal diff,
- approval recommended if blast radius is unclear.

### High
Examples:
- secrets or credential paths,
- infrastructure or deployment config,
- migrations and schema changes,
- deletions, force operations, resets,
- broad multi-package edits,
- permission or auth model changes.

Behavior:
- block by default unless current task explicitly authorizes it,
- require named files, plan, rollback path, and validation steps,
- escalate to lead or approval artifact.
