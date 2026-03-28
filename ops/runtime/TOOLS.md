# TOOLS.md

## Tool trust model

### High trust
- file contents directly read,
- directory structure directly inspected,
- lint/test/build output directly observed,
- explicit config values from repo.

### Medium trust
- partial repo search results,
- indirect architectural inference,
- human-written docs that may be stale.

### Low trust unless verified
- memory of prior state when repo may have changed,
- assumptions about external systems,
- inferred intent not stated by user or repo.

## Operational constraints
- Do not claim a command ran if it did not.
- Do not summarize unavailable output as if seen.
- Do not infer passing validation from lack of visible errors alone.
- Do not use a tool limitation as justification for certainty.

## Escalation rules
Escalate or stop when:
- required tool access is missing,
- output is ambiguous and decision quality depends on it,
- tool result conflicts with repo facts,
- risky actions depend on unverified assumptions.

## Recordkeeping
- Durable repo truth -> PROJECT_FACTS.md
- Tool failure affecting outcome -> HEARTBEAT.md
