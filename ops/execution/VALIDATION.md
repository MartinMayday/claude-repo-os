# VALIDATION.md

## Purpose
Define what counts as proof for this repo.

## Accepted evidence
- Lint ran and passed.
- Typecheck ran and passed.
- Tests ran and passed.
- Build ran and succeeded.
- Manual verification note with explicit description.

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

## Minimum validation by change type

### Trivial / docs / comments
- Manual review note sufficient.

### Config change
- Lint if applicable.
- Manual review note.

### Code change in one file
- Lint.
- Relevant unit tests if present.

### Code change across multiple files
- Lint.
- Typecheck.
- Relevant tests.

### Risky / cross-cutting / infra change
- Full lint, typecheck, test, build.
- Manual verification note.
- Approval artifact if protected paths involved.
