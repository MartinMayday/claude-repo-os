# claude-repo-os

A precision-first Claude Code operating system for autonomous repo work.

## What this is
A structured repo-native execution framework for Claude Code, providing:
- root control policy
- startup and runtime continuity
- risk enforcement via hooks
- specialist subagents
- Council-based deliberation
- team orchestration
- evaluation and self-improvement

## Native vs custom
### Native Claude Code
- CLAUDE.md
- .claude/settings.json
- .claude/agents/*
- .claude/hooks/*

### Custom operating layer
- ops/**

## Install modes

### MVP
Minimum viable: root control, facts, heartbeat, done gate, risk basics.

### Recommended
MVP + hooks + approvals + subagents + execution policy.

### Full
Recommended + Council + teams + evaluation.

## Bootstrap
```bash
gh repo create your-project --private --clone
cd your-project
curl -sO https://raw.githubusercontent.com/MartinMayday/claude-repo-os/main/bootstrap.sh
chmod +x bootstrap.sh && ./bootstrap.sh
```

## Adapt
Fill these files first:
1. ops/bootstrap/REPO_PROFILE.md
2. CLAUDE.md mission section
3. ops/runtime/PROJECT_FACTS.md
4. ops/execution/VALIDATION.md
5. ops/risk/PROTECTED_PATHS.md
