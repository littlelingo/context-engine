---
description: Context Engine core rules. Always active when the plugin is installed.
globs:
  - "**/*"
---
# CLAUDE.md - Context Engine

> Context is the bottleneck, not intelligence. Skills load domain expertise on-demand.
> This file stays lean - details live in `.claude/skills/` and `.claude/commands/`.

## Project Knowledge

<!-- Auto-maintained by /ce-init and /ce-update-arch -->

| Doc | Location |
|-----|----------|
| Architecture | `.context/architecture/OVERVIEW.md` |
| Tech Stack | `.context/architecture/TECH_STACK.md` |
| Directory Map | `.context/architecture/DIRECTORY_MAP.md` |
| Code Patterns | `.context/patterns/CODE_PATTERNS.md` |
| Anti-Patterns | `.context/patterns/ANTI_PATTERNS.md` |
| Known Errors | `.context/errors/INDEX.md` |
| Decisions | `.context/decisions/` |
| Features | `.context/features/FEATURES.md` |
| Learnings | `.context/knowledge/LEARNINGS.md` |
| Library Quirks | `.context/knowledge/libraries/` |
| Stack Recipes | `.context/knowledge/stack/` |
| Dependency Pins | `.context/knowledge/dependencies/PINS.md` |
| Checkpoints | `.context/checkpoints/MANIFEST.md` |
| Metrics | `.context/metrics/HEALTH.md` |

## Workflow

`/ce-init` (once) -> `/ce-research` -> `/ce-plan` -> `/clear` -> `/ce-implement` -> `/clear` -> `/ce-validate` -> commit/PR

| Phase | Command | Delegation |
|-------|---------|-----------|
| Research | `/ce-research` | Subagent (researcher) |
| Plan | `/ce-plan` | Subagent (planner) |
| Implement | `/ce-implement` | Agent Team or subagent |
| Validate | `/ce-validate` | Agent Team or subagent |

Quick: `/ce-plan-quick` | Bugs: `/ce-debug` | Refactor: `/ce-refactor` | Status: `/ce-status` | Resume: `/ce-resume` | Knowledge: `/ce-knowledge` | Health: `/ce-health`

Each command ends with the exact next command. Handoffs are explicit.
Checkpoints are created automatically at phase boundaries and before Agent Team spawns. Rollback: `/ce-checkpoint rollback CP-NNN`.

## Context Management
- **< 50%**: Keep working
- **50-60%**: Save state, prepare to clear
- **> 60%**: Stop. `/clear`. `/ce-resume`.
- Prefer `/clear` + `/ce-resume` over `/compact`. PreCompact hook preserves PRP state if compaction occurs.

## Orchestration

**Agent Teams**: Used by implement, validate, debug, refactor when 3+ parallel tracks exist. Teammates own specific files, communicate directly, coordinate via shared task list.

**Subagents**: Used by research, plan, and as fallback for small tasks. Single specialist, isolated context, returns summary.

Roles (`.claude/agents/`): `researcher`, `planner`, `implementer`, `reviewer`, `debugger` - all with `memory: project`.

## Testing Strategy
**Default**: `implement-then-test` | Override per-plan in PRP header
Options: `test-first` | `implement-then-test` | `tests-optional`
Validation always runs regardless of strategy.

## Code Standards
- Max 300 lines per file
- Public functions need docstrings/JSDoc
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Never implement on `main`/`master` - create feature branch first
- Hooks auto-format files after every edit (`.claude/hooks/auto-format.sh`)

## Hooks (Enforced Gates)
Safety and quality rules enforced deterministically via `.claude/hooks/`:
- **PreToolUse**: Protected file guard, destructive command blocker
- **PostToolUse**: Auto-formatter
- **PreCompact**: PRP/branch/progress preservation
- **Stop**: Learning capture reminder
- **SubagentStop**: Agent output verification
View: `/hooks` | Config: `.claude/settings.json`

## Auto-Learning
1. **Phase reflection** - Commands write to `.context/` before handing off
2. **Agent memory** - Persists across sessions per role
3. **Hooks** - Stop hook enforces learning capture
Manual: `/ce-learn` | Architecture refresh: `/ce-update-arch`

## Skills (Progressive Disclosure)
Domain expertise loads on-demand when you touch relevant files. Not front-loaded.
19 skills in `.claude/skills/` - check context-system skill for the full reference.
