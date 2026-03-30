---
name: context-system
description: Context Engine framework reference. Auto-loaded when working with .context/, agents, commands, or hooks. Supplements CLAUDE.md with role and skill details.
user-invocable: false
---

# Context Engine - Supplemental Reference

> Commands, workflow, hooks, testing strategy, and context budget are in CLAUDE.md (always loaded). This skill adds role and skill details only.

## Roles (`agents/`)
| Role | Mode | Memory Focus |
|------|------|--------|
| `researcher` | Subagent | Codebase structure |
| `planner` | Subagent | Estimation, approaches |
| `implementer` | Subagent or Teammate | Patterns, build quirks |
| `reviewer` | Subagent or Teammate | Recurring issues |
| `debugger` | Subagent or Teammate | Error patterns |
| `mcp-researcher` | Subagent | MCP output compression |

## Skills (23 total - progressive disclosure)
| Skill | Loads When | Purpose |
|-------|-----------|---------|
| `context-system` | .context/, commands/, agents/ | This reference |
| `testing-conventions` | test/spec files | Test patterns, frameworks |
| `api-conventions` | route/controller files | API patterns, validation |
| `git-workflow` | .github/, git files | Branching, commits, PRs |
| `database-migrations` | migrations/, .sql files | Schema changes, ORMs |
| `auth-security` | auth/, middleware/ files | JWT, OAuth, OWASP |
| `deployment-cicd` | Dockerfile, workflows/ | Docker, GitHub Actions |
| `typescript` | .ts, tsconfig.json, .d.ts files | Type safety, generics, config |
| `react-frontend` | .tsx/.jsx, components/ | React patterns, hooks, state |
| `python-backend` | views/, routers/ .py | FastAPI, Django, Flask |
| `postgres` | .sql, db/ files | Queries, indexing, performance |
| `redis` | cache/, queue/ files | Caching, sessions, pub/sub |
| `node-backend` | server.ts/js, app.ts/js, routes/ | Express, Fastify, NestJS patterns |
| `ruby` | .rb, Gemfile | Rails, RSpec, ActiveRecord |
| `context7-docs` | package.json, requirements | Library doc lookup via MCP |
| `mcp-tools` | .mcp.json | MCP server catalog |
| `sequential-thinking` | PRP.md, ADR-*, errors/ | Structured problem decomposition via MCP |
| `puppeteer` | e2e/, screenshots/ | Browser automation via MCP |
| `postgres-mcp` | .sql, migrations/, db/ | Live database queries via MCP |
| `google-workspace` | Google Docs/Sheets/Drive operations | Google Docs/Sheets/Drive via MCP |
| `chrome-devtools` | browser debugging, DevTools | Chrome DevTools debugging via MCP |
| `knowledge-base` | .context/knowledge/ files | Deep knowledge layer management |
| `prompt-efficiency` | Always loaded | Context budget and token efficiency rules |
