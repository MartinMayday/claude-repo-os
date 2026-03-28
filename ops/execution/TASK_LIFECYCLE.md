# TASK_LIFECYCLE.md

## Purpose
Define the standard lifecycle for meaningful repo tasks.

## Lifecycle

### 1. Understand
- Restate the task in repo terms.
- Identify affected systems and files.
- Separate verified context from unknowns.

### 2. Choose mode
- Use DECISION_TABLE.md.
- Prefer the lightest sufficient mode.

### 3. Plan
- Define the smallest viable path.
- Note validation requirements.
- Note risk level and approvals if needed.

### 4. Execute
- Make the change or produce the design/review artifact.
- Stay within scope.
- Surface blockers instead of guessing.

### 5. Validate
- Run the required checks when possible.
- Record what ran and what did not.
- Treat missing validation as a real status condition, not a footnote.

### 6. Judge completion
- Apply DONE_GATE.md.
- Use complete / partial / blocked / not done truthfully.

### 7. Update runtime state
- Update HEARTBEAT.md.
- Update PROJECT_FACTS.md if durable repo truth was learned.

### 8. Evaluate when applicable
- If the task is non-trivial, risky, blocked, or used escalation, create a scorecard.

## Hard rules
- Do not skip from execute to done.
- Do not treat code written as validation.
- Do not confuse partial progress with completion.
