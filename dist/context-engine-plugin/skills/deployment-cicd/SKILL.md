---
description: Deployment and CI/CD patterns - Docker, GitHub Actions, pipelines, infrastructure. Auto-loaded when working with deployment configs, workflows, or container files.
---

# Deployment & CI/CD

## Docker
- Multi-stage builds to minimize image size
- Pin base image versions (e.g., `node:20.11-bookworm`, not `node:latest`)
- Non-root user in production containers
- `.dockerignore` mirrors `.gitignore` plus `node_modules`, `.git`, `.env`
- Health checks in docker-compose and Dockerfile

## GitHub Actions
- Cache dependencies (`actions/cache`) to speed up builds
- Use matrix builds for multi-version testing
- Pin action versions to SHA, not tags (`actions/checkout@v4` -> SHA)
- Secrets via repository settings, never hardcoded
- Fail fast on lint/type-check before running expensive tests

## Pipeline Structure
```
lint -> type-check -> unit-tests -> build -> integration-tests -> deploy
```
- Each stage gates the next
- Lint and type-check are cheap - run them first
- Deploy only from main/release branches

## Environment Promotion
- dev -> staging -> production (never skip staging)
- Same Docker image promoted between environments (different config only)
- Feature flags for gradual rollout
- Rollback plan before every production deploy

## Common Pitfalls
- Secrets in Docker build args (visible in image history)
- Running `npm install` instead of `npm ci` in CI
- Missing `.dockerignore` - copying `node_modules` into build context
- No health check endpoint for container orchestrators
