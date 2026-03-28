# DESTRUCTIVE_COMMANDS.md

## Block by default
- rm -rf
- git reset --hard
- git clean -fd
- git clean -fdx
- docker system prune
- kubectl delete
- terraform apply
- terraform destroy
- pulumi destroy
- drop database
- truncate table

## Approval-required
- git push --force
- git rebase -i
- npm install / pnpm add / yarn add when lockfile changes matter
- migration generation or execution commands
- deployment commands
