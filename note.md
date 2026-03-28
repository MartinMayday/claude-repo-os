The full bootstrap script is now complete across four message blocks. To finish the setup:

1. Make sure all three script blocks are concatenated into one `bootstrap.sh` file inside `/Volumes/uss/shared-local/downloaded/shared/claude-repo-os/`
2. Run:
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

The script will:
- Write the full directory tree and all files
- Stage and commit everything with a structured message
- Push to `https://github.com/MartinMayday/claude-repo-os`

To reuse on any future Claude instance or project:
```bash
gh repo create my-new-project --private --clone
cd my-new-project
curl -sO https://raw.githubusercontent.com/MartinMayday/claude-repo-os/main/bootstrap.sh
chmod +x bootstrap.sh && ./bootstrap.sh
```

First adaptation steps after bootstrap:
1. Fill `ops/bootstrap/REPO_PROFILE.md` with real repo facts
2. Work through `ops/bootstrap/ADAPTATION_CHECKLIST.md`
3. Populate `ops/runtime/PROJECT_FACTS.md` with verified truths only
4. Run smoke test: ask Claude to read `REPO_PROFILE.md` and update `HEARTBEAT.md`