# BLOCKERS.md

## Purpose
Define what must stop execution rather than be worked around silently.

## Hard blockers
Stop immediately and surface to user when:
- required credentials or secrets are missing,
- required external system is unreachable,
- protected path edit requires approval that does not exist,
- validation failure has no clear root cause,
- task requires destructive action without explicit approval,
- repo state contradicts key assumptions and resolution is unclear.

## Soft blockers
Pause and state uncertainty when:
- a required file is missing but may exist elsewhere,
- a command fails but a fallback may exist,
- architecture is unclear but inspection might resolve it,
- an assumption is unverified but checkable.

## Blocker report format
- Blocker type: hard | soft
- Description:
- What is missing or unclear:
- What would unblock it:
- Risk of proceeding without resolution:

## Rules
- Do not silently work around a hard blocker.
- Do not mark partial progress as complete to avoid surfacing a blocker.
- A soft blocker should be investigated before being escalated to hard.
