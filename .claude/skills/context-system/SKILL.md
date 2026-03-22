---
description: Context Engine framework reference. Auto-loaded when working with .context/, agents, commands, or hooks. The full system reference.
globs:
  - ".context/**/*"
  - ".claude/agents/*"
  - ".claude/commands/ce-*"
  - ".claude/hooks/*"
  - ".claude/skills/*/SKILL.md"
---

# Context Engine - Full Reference

## Commands
| Command | Delegation | Purpose |
|---------|-----------|---------|
| `/ce-init` | Direct | Bootstrap `.context/`, detect stack, set testing strategy |
| `/ce-research` | Subagent (researcher) | Explore codebase, gather context |
| `/ce-plan` | Subagent (planner) | Create PRP from requirements |
| `/ce-plan-quick` | Subagent (researcher) | Quick plan for small tasks |
| `/ce-implement` | Agent Team (3+ steps) or subagent | Execute PRP steps per strategy |
| `/ce-validate` | Agent Team (3+ files) or subagent | Review, simplify, capture learnings |
| `/ce-debug` | Agent Team (complex) or subagent | Diagnose and fix bugs |
| `/ce-refactor` | Agent Team (3+ tracks) or subagent | Restructure code safely |
| `/ce-status` | Direct | Project briefing (read-only) |
| `/ce-resume` | Direct | Reload after `/clear` |
| `/ce-learn` | Direct | Manual capture to .context/ (routes to deep knowledge) |
| `/ce-knowledge` | Direct | Browse, search, promote knowledge base |
| `/ce-checkpoint` | Direct | Create, list, rollback, clean checkpoints |
| `/ce-health` | Direct | Metrics dashboard and deep analysis |
| `/ce-update-arch` | Subagent (researcher) | Refresh architecture docs |

## Roles (`.claude/agents/`)
| Role | Mode | Memory |
|------|------|--------|
| `researcher` | Subagent | Codebase structure |
| `planner` | Subagent | Estimation, approaches |
| `implementer` | Subagent or Teammate | Patterns, build quirks |
| `reviewer` | Subagent or Teammate | Recurring issues |
| `debugger` | Subagent or Teammate | Error patterns |

## Skills (19 total - progressive disclosure)
| Skill | Loads When | Purpose |
|-------|-----------|---------|
| `context-system` | .context/, ce-* files | This reference |
| `testing-conventions` | test/spec files | Test patterns, frameworks |
| `api-conventions` | route/controller files | API patterns, validation |
| `git-workflow` | .github/, git files | Branching, commits, PRs |
| `database-migrations` | migrations/, .sql files | Schema changes, ORMs |
| `auth-security` | auth/, middleware/ files | JWT, OAuth, OWASP |
| `deployment-cicd` | Dockerfile, workflows/ | Docker, GitHub Actions |
| `react-frontend` | .tsx/.jsx, components/ | React patterns, hooks, state |
| `python-backend` | views/, routers/ .py | FastAPI, Django, Flask |
| `postgres` | .sql, db/ files | Queries, indexing, performance |
| `redis` | cache/, queue/ files | Caching, sessions, pub/sub |
| `ruby` | .rb, Gemfile | Rails, RSpec, ActiveRecord |
| `context7-docs` | package.json, requirements | Library doc lookup via MCP |
| `mcp-tools` | .mcp.json | MCP server catalog |
| `sequential-thinking` | PRP.md, ADR-*, errors/ | Structured problem decomposition via MCP |
| `puppeteer` | e2e/, screenshots/ | Browser automation via MCP |
| `postgres-mcp` | .sql, migrations/, db/ | Live database queries via MCP |
| `google-workspace` | spreadsheet, gdoc, gsheet | Google Docs/Sheets/Drive via MCP |
| `knowledge-base` | .context/knowledge/, package.json | Deep knowledge layer management |

## Hooks (`.claude/hooks/`)
| Hook | Event | Enforcement |
|------|-------|------------|
| `guard-protected-files` | PreToolUse | Blocks .env, lockfiles, .git/ |
| `block-destructive` | PreToolUse | Blocks rm -rf, DROP TABLE |
| `auto-format` | PostToolUse | Runs formatter after edits |
| `preserve-context` | PreCompact | Saves PRP/branch/progress |
| `capture-learnings` | Stop | Reminds if .context/ not updated |
| `verify-agent-output` | SubagentStop | Flags empty implementer runs |
| `session-track` | UserPromptSubmit | Session marker for other hooks |

## Handoffs
init -> research -> plan [notes] -> /clear -> implement [PRP] -> /clear -> validate [PRP] -> commit/PR

## Testing Strategy
PRP field -> CLAUDE.md default -> `implement-then-test`
Options: `test-first` | `implement-then-test` | `tests-optional`

## Context Budget
< 50% keep working | 50-60% save + clear | > 60% stop + clear + resume
