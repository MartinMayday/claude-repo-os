# PROTECTED_PATHS.md

## Always protected
- .env
- .env.*
- secrets/**
- credentials/**
- **/*.pem
- **/*.key
- **/*.p12
- **/*.crt

## Approval-required
- infra/**
- terraform/**
- pulumi/**
- k8s/**
- helm/**
- ansible/**
- docker-compose*.yml
- compose*.yml
- .github/workflows/**
- migrations/**
- prisma/migrations/**
- db/migrate/**
- package-lock.json
- pnpm-lock.yaml
- yarn.lock

## Repo-defined do-not-touch
- Add project-specific paths here when adapting to a real repo.
