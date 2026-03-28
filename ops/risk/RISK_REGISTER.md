# RISK_REGISTER.md

## Purpose
Append-only record of risky, guarded, approved, blocked, or ambiguous operations.

## Entries
- Timestamp:
  Action:
  Result:
  Risk level:
  Related paths:
  Approval ID:
  Reason:
  Follow-up:

## Rules
- Record blocked and approved high-risk attempts.
- Keep entries short and factual.
- Do not hide near-misses; they are useful signals.

- Timestamp: 2026-03-28T13:14:56Z
  Action: kubectl get pods --all-namespaces
  Result: pod-a running
pod-b running

- Timestamp: 2026-03-28T13:17:55Z
  Action: kubectl get pods --all-namespaces
  Result: pod-a running
pod-b running

- Timestamp: 2026-03-28T13:23:41Z
  Action: kubectl get pods --all-namespaces
  Result: pod-a running
pod-b running

- Timestamp: 2026-03-28T13:36:59Z
  Action: kubectl get pods --all-namespaces
  Result: pod-a running
pod-b running
