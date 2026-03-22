# Context Engine - Cheat Sheet

## Full Workflow

```
/init              Detect project, populate .context/ (once)
      |
/research [topic]  Explore codebase, save notes     -> researcher agent
      |
/plan [notes]      Create PRP, pick test strategy   -> planner agent
      |
    /clear
      |
/implement [PRP]   Execute steps one at a time      -> implementer agent
      |
    /clear
      |
/validate [PRP]    Review + simplify + learn         -> reviewer agent
      |
    commit or PR (prompted)
```

## All Commands

| Command | What It Does |
|---------|-------------|
| `/init` | Bootstrap `.context/`, detect tech stack, set testing strategy |
| `/research [topic]` | Explore codebase, produce NOTES.md |
| `/plan [notes path]` | Create PRP, prompt for testing strategy |
| `/plan-quick [task]` | Quick plan + implement for small tasks |
| `/implement [PRP path]` | Safety checks, branch, execute PRP steps |
| `/validate [PRP path]` | Run tests, review, simplify, capture learnings |
| `/debug [error]` | Diagnose bug, fix, capture to error index |
| `/refactor [goal]` | Restructure code with test safety checks |
| `/status` | Project briefing - what's built, in progress, recently learned |
| `/resume` | Reload state after `/clear` or new session |
| `/learn [insight]` | Manually capture error, pattern, decision, or insight |
| `/update-arch` | Refresh architecture docs after big changes |

## Agents

## Orchestration

**Agent Teams** (parallel work - implement, validate, debug, refactor):
```
Create an agent team to [task]. Spawn teammates:
- Teammate 1: [role, files owned, instructions]
- Teammate 2: [role, files owned, instructions]
Use shared task list with blockedBy for dependencies.
```

**Subagents** (focused sequential work - research, plan, small tasks):
```
Use the researcher agent to [explore/find/map]
Use the planner agent to [create PRP for]
```

| Role | Team Mode | Subagent Mode | Memory |
|------|-----------|---------------|--------|
| `researcher` | - | Yes | Codebase structure |
| `planner` | - | Yes | Estimation, approaches |
| `implementer` | 3+ parallel steps | Fallback | Patterns, build quirks |
| `reviewer` | 3+ files changed | Fallback | Recurring issues |
| `debugger` | Complex bugs | Fallback | Error patterns |

All have `memory: project` - they get smarter across sessions.

## Testing Strategy

**Resolution order**: PRP `## Testing Strategy:` -> CLAUDE.md default -> `implement-then-test`

| Strategy | Meaning |
|----------|---------|
| `test-first` | Write test -> fail -> implement -> pass |
| `implement-then-test` | Implement -> write test -> verify |
| `tests-optional` | Implement only. Tests deferred. |

Prompted during `/plan`. Validation always runs regardless.

## Context Budget

| Level | Action |
|-------|--------|
| < 50% | Keep working |
| 50-60% | Save state, prepare to clear |
| > 60% | Stop. Save. `/clear`. `/resume`. |

**Prefer `/clear` + `/resume` over `/compact`.**
Disable auto-compact: `/config` -> Auto-compact: false

## Project Knowledge (`.context/`)

| File | Contains |
|------|----------|
| `architecture/OVERVIEW.md` | System design, components |
| `architecture/TECH_STACK.md` | Languages, frameworks, dev commands |
| `architecture/DIRECTORY_MAP.md` | Annotated project structure |
| `patterns/CODE_PATTERNS.md` | Approved conventions |
| `patterns/ANTI_PATTERNS.md` | Known bad patterns |
| `errors/INDEX.md` | Error signatures + fixes |
| `decisions/ADR-NNN-*.md` | Architecture decision records |
| `features/FEATURES.md` | Feature index (status tracker) |
| `knowledge/LEARNINGS.md` | Quick session insights |
| `knowledge/libraries/` | Per-library quirks and workarounds |
| `knowledge/stack/` | Stack config recipes |
| `knowledge/dependencies/PINS.md` | Version pins and upgrade blockers |

## Auto-Learning

Happens by default. No manual action needed.
- **Phase reflection**: Every command captures discoveries to `.context/`
- **Agent memory**: Each agent persists knowledge across sessions
- **Hooks**: Enforced gates at lifecycle events (`hooks/`)
- **Deep knowledge**: Implementer + debugger auto-capture library quirks, version pins, stack recipes
- `/learn` routes to deep knowledge files (prefix hints: `library quirk:`, `stack recipe:`, `dependency pin:`)
- `/knowledge` browses, searches, promotes knowledge base

## Hooks (`hooks/`)

```
PreToolUse:   guard-protected-files   Blocks .env, lockfiles, .git/
              block-destructive       Blocks rm -rf /, DROP TABLE
PostToolUse:  auto-format             Runs prettier/ruff/gofmt after edits
PreCompact:   preserve-context        Saves PRP path, branch, progress
Stop:         capture-learnings       Reminds if .context/ not updated
SubagentStop: verify-agent-output     Flags empty implementer runs
```

View: `/hooks` | Disable: comment out in `.claude/settings.json`

## Checkpoints

Hybrid: git tag (code) + `.context/checkpoints/CP-NNN/` (context state).

```
Auto-created at:
  Phase boundaries:    post-plan, pre-implement, pre-validate, post-validate, pre-refactor
  Pre-Agent-Team:      pre-team, pre-review-team, pre-debug-team, pre-refactor-team
```

| Action | Command |
|--------|---------|
| Create manually | `/checkpoint create [label]` |
| List all | `/checkpoint list` |
| Rollback | `/checkpoint rollback CP-NNN` (offers full or soft) |
| Clean old | `/checkpoint clean --keep 5` |

## Metrics (`/health`)

Auto-captured after every `/validate`. Manual deep analysis anytime.

```
5 categories:
  Velocity:    features completed, avg elapsed, steps/feature, trend
  Errors:      total indexed, hit rate, novel vs repeat
  Knowledge:   library files, stack recipes, pins, learnings growth
  Agents:      team vs subagent ratio, rollback rate, empty runs
  Context:     clears/feature, knowledge consulted, compactions
```

| Action | Command |
|--------|---------|
| Dashboard | `/health` |
| Velocity deep dive | `/health velocity` |
| Error analysis | `/health errors` |
| Knowledge audit | `/health knowledge` |
| Agent performance | `/health agents` |
| Manual record | `/health record [feature-NNN]` |

Per-feature metrics also embedded in each completed PRP (section 7).

## Validate Flow (Step Order)

```
1. Load PRP
2. Check testing strategy
3. Checkpoint (pre-validate)
4. Run validation checklist (tests, lint, types, manual)
5. Reviewer agent (code review + security)
6. Fix critical issues
7. Simplification pass (dead code, duplication, over-abstraction)
8. Capture learnings (MANDATORY)
9. Update PRP status -> COMPLETE
10. Capture feature metrics -> HEALTH.md + PRP section 7
11. Checkpoint (post-validate)
12. Report
13. Ship prompt (commit only / commit + PR / edit / skip)
```

## Quick Reference

```bash
# Install into project
./install.sh /path/to/project

# Parallel work
git worktree add ../project-feature-a feature-a
cd ../project-feature-a && claude

# Check context usage
/context

# Resume after break
/resume

# Quick fix (skip full cycle)
/plan-quick fix the null pointer in getUserById

# Debug a bug
/debug TypeError: Cannot read property 'id' of undefined in /api/users

# Refactor existing code
/refactor extract auth logic from route handlers into middleware

# Project briefing
/status
/status onboard    # extended version for new team members

# Plugin packaging
./build-plugin.sh                                    # build plugin from project
claude plugin add --path ./dist/context-engine-plugin  # install locally
claude plugin validate ./dist/context-engine-plugin    # validate structure
```
