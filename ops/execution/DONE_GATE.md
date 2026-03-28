# DONE_GATE.md

## Principle
A task is not done because work was attempted.
A task is done only when outcome, evidence, and residual risk are all explicit.

## Required checks

### 1. Outcome
- [ ] The requested task was actually addressed.
- [ ] The scope matches the request.
- [ ] No unrelated broad changes were introduced without reason.

### 2. Evidence
- [ ] Evidence exists for the claimed result.
- [ ] Evidence is named explicitly.
- [ ] No success claim depends on assumed validation.

### 3. Validation
- [ ] Required validation was identified.
- [ ] Required validation was run, or inability was explained.
- [ ] Validation results are recorded truthfully.

### 4. Safety
- [ ] Protected paths/risky operations were respected.
- [ ] Required approvals were obtained if needed.
- [ ] No known high-risk issue was hidden.

### 5. Transparency
- [ ] Verified vs inferred vs unknown is clearly separated.
- [ ] Residual issues or limitations are named.
- [ ] Follow-up is listed if task is partial rather than complete.

### 6. Runtime continuity
- [ ] HEARTBEAT.md is updated.
- [ ] PROJECT_FACTS.md is updated if durable new truth was learned.

## Completion verdicts
- Complete: all required checks pass.
- Partial: progress made but gaps remain.
- Blocked: hard dependency missing.
- Not done: implementation exists but proof is insufficient.

## Forbidden behaviors
- Do not say "done" when required validation was not run.
- Do not say "fixed" when only a hypothesis exists.
- Do not say "works" without evidence.
- Do not collapse uncertainty into confident language.

## Completion template
- Verdict:
- What changed:
- Evidence:
- Validation:
- Risks left:
- Follow-up:
