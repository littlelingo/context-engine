# Context Engine

An agentic orchestration framework for Claude Code. Structured workflows with explicit phase hand-offs, Agent Teams for parallel execution, 23 progressive-disclosure skills, persistent project knowledge, enforced safety hooks, and auto-learning from every session.

> Context is the bottleneck, not intelligence. Skills load domain expertise on-demand.

**v0.1.7** | MIT License

## Quick Start

### Option A: Project-Level Install (recommended for teams)
```bash
./install.sh /path/to/your/project
cd /path/to/your/project
claude
/init                   # auto-detect project, populate .context/
/research [feature]     # begin first feature
```

### Option B: Plugin Install (recommended for personal use)
```bash
# Install plugin
claude plugin add --path ./dist/context-engine-plugin

# In any project:
/context-engine:init
```

See `docs/PLUGIN.md` for the full plugin distribution guide.

## How It Works

```
/init ──> /adapt ──> /research ──> /planner ──> /implement ──> /validate ──> commit/PR
(once)   (optional)  researcher    planner      Agent Team     Agent Team
                     subagent      subagent     or subagent    or subagent
                        │             │              │               │
                     NOTES.md      PRP.md      Code + Tests     Learnings
                                                    │            captured
                                [/clear + /resume between phases as needed]
```

Each command ends with the exact next command to run. Hand-offs are explicit. Commands choose Agent Teams or subagents automatically based on task complexity.

## Project Structure

```
commands/              21 user-facing commands (slash commands)
agents/                6 agent role definitions
skills/                23 progressive-disclosure skills (loaded on-demand)
hooks/                 11 enforcement scripts + hooks.json
.claude/
  agent-memory/        Per-role persistent memory
  instructions/        Shared framework instructions (5 files)
.context/
  architecture/        OVERVIEW.md, TECH_STACK.md, DIRECTORY_MAP.md
  features/            FEATURES.md + per-feature NOTES.md and PRP.md
  patterns/            CODE_PATTERNS.md, ANTI_PATTERNS.md
  decisions/           Architecture Decision Records (ADR-NNN.md)
  errors/              INDEX.md + detail/ for complex errors
  knowledge/           LEARNINGS.md + libraries/ + stack/ + dependencies/
  checkpoints/         MANIFEST.md + CP-NNN snapshots
  metrics/             HEALTH.md (velocity, errors, knowledge, agents, context)
  templates/           PRP and NOTES templates
docs/                  PLUGIN.md, CHEATSHEET.md, WALKTHROUGH.md
dist/                  Built plugin output
```

## Commands

### Core Workflow

| Command | Phase | Purpose |
|---------|-------|---------|
| `/init` | Setup | Bootstrap `.context/`, detect tech stack |
| `/adapt` | Setup | Context-aware research for new projects |
| `/research [topic]` | 1 | Explore codebase, produce NOTES.md |
| `/planner [notes]` | 2 | Create PRP with testing strategy |
| `/implement [PRP]` | 3 | Execute PRP steps (Agent Team or subagent) |
| `/validate [PRP]` | 4 | Review, simplify, capture learnings, ship prompt |

### Utility Commands

| Command | Purpose |
|---------|---------|
| `/plan-quick [task]` | Quick plan + implement for small tasks |
| `/debug [error]` | Diagnose and fix bugs |
| `/refactor [goal]` | Restructure code with safety checks |
| `/security-review` | Standalone security review |
| `/simplify` | Dead code, duplication, over-abstraction pass |
| `/status` | Project briefing (add `onboard` for extended version) |
| `/resume` | Reload state after `/clear` or new session |
| `/cancel` | Abandon a feature in progress |

### Knowledge & Metrics

| Command | Purpose |
|---------|---------|
| `/learn [insight]` | Route knowledge to deep reference layer |
| `/knowledge` | Browse, search, promote knowledge base |
| `/checkpoint [action]` | Create, list, rollback hybrid checkpoints |
| `/health [action]` | Metrics dashboard with deep-dive modes |
| `/update-arch` | Refresh architecture docs |
| `/create-skill` | Create a new skill |
| `/update-skill` | Update an existing skill |

## Orchestration

Two modes. Commands pick automatically based on complexity.

### Agent Teams
Used by `/implement`, `/validate`, `/debug`, `/refactor` when work has 3+ parallel tracks. Teammates work independently on owned files, communicate directly, and coordinate via shared task list with dependency ordering.

### Subagents
Used by `/research`, `/planner`, and as fallback for small tasks. Single specialist works in isolated context, returns a summary.

### Agent Roles

| Role | Team Mode | Subagent Mode | Memory |
|------|-----------|---------------|--------|
| **researcher** | - | Yes | Codebase structure, file locations |
| **planner** | - | Yes | Estimation accuracy, recurring risks |
| **implementer** | Teammate | Fallback | Code patterns, build quirks |
| **reviewer** | Teammate | Fallback | Recurring issues, fragile areas |
| **debugger** | Teammate | Fallback | Error patterns, diagnostic shortcuts |
| **mcp-researcher** | - | Yes | MCP tool operations, compressed summaries |

All roles have `memory: project` - they learn across sessions automatically.

## Skills (Progressive Disclosure)

23 skills load domain expertise on-demand when you touch relevant files. Never front-loaded.

**Auto-loaded by file context:**

| Skill | Triggers On |
|-------|------------|
| `context-system` | `.context/`, agents, commands, hooks |
| `testing-conventions` | Test files (`*.test.*`, `*.spec.*`) |
| `api-conventions` | Routes, controllers, endpoints |
| `git-workflow` | `.github/`, git operations |
| `database-migrations` | Migrations, `.sql`, schema files |
| `auth-security` | Auth middleware, security files |
| `deployment-cicd` | Dockerfile, workflows, CI configs |
| `typescript` | `.ts`, `tsconfig.json`, `.d.ts` |
| `react-frontend` | `.tsx`, `.jsx`, components |
| `node-backend` | `server.ts/js`, routes, middleware |
| `python-backend` | `.py`, FastAPI, Django, Flask |
| `postgres` | `.sql`, database configs |
| `redis` | Cache, queue, pub/sub files |
| `ruby` | `.rb`, Gemfile, Rails directories |
| `knowledge-base` | `.context/knowledge/` |
| `prompt-efficiency` | Always loaded (context budget rules) |

**MCP-integrated:**

| Skill | Capability |
|-------|-----------|
| `context7-docs` | Library documentation lookup |
| `mcp-tools` | MCP server catalog and configuration |
| `sequential-thinking` | Structured problem decomposition |
| `puppeteer` | Browser automation |
| `postgres-mcp` | Live database queries and schema inspection |
| `google-workspace` | Google Docs, Sheets, Drive operations |
| `chrome-devtools` | Chrome DevTools debugging and performance |

## Hooks (Enforced Gates)

Deterministic scripts that run at Claude Code lifecycle events. Unlike CLAUDE.md rules (advisory), hooks enforce behavior automatically.

| Hook | Event | Purpose |
|------|-------|---------|
| `guard-protected-files` | PreToolUse | Blocks edits to `.env`, lockfiles, `.git/`, `settings.json` |
| `block-destructive` | PreToolUse | Blocks `rm -rf /`, `DROP TABLE`, dangerous disk ops |
| `auto-format` | PostToolUse | Runs project formatter after every file edit |
| `context-budget` | PostToolUse | Monitors context budget thresholds |
| `mcp-output-advisor` | PostToolUse | Processes MCP tool output |
| `preserve-context` | PreCompact | Saves active PRP, branch, progress before compaction |
| `capture-learnings` | Stop | Reminds to capture learnings if code changed |
| `verify-agent-output` | SubagentStop | Flags if implementer completed without file changes |
| `verify-metrics` | Stop | Ensures metrics are updated |
| `session-track` | UserPromptSubmit | Creates session marker for other hooks |
| `classify-request` | UserPromptSubmit | Classifies incoming request type |

Scripts live in `hooks/scripts/`. Config in `hooks/hooks.json` (plugin) or `.claude/settings.json` (local dev).

## Testing Strategy

Configurable per-project (CLAUDE.md default) and per-plan (PRP header override).

| Strategy | When to Use |
|----------|-------------|
| `test-first` | Clear acceptance criteria, TDD |
| `implement-then-test` | General development (default) |
| `tests-optional` | Spikes, prototypes, exploration |

During `/planner`, you're prompted to choose. The implementer and reviewer both respect the choice. Validation is always mandatory regardless of strategy.

## Auto-Learning

Learning is automatic. No manual action needed.

- **Phase reflection** - Every command captures discoveries to `.context/` before handing off
- **Agent memory** - All roles persist knowledge across sessions in `.claude/agent-memory/`
- **Deep knowledge layer** - Implementer and debugger auto-capture library quirks, version pins, and stack recipes during work
- **Hooks** - `capture-learnings` hook enforces learning capture at session end

Manual capture: `/learn` | Browse: `/knowledge` | Metrics: `/health`

## Knowledge Base

Stored in `.context/knowledge/` with four tiers:

| Tier | Location | Contains |
|------|----------|----------|
| Quick insights | `LEARNINGS.md` | Session discoveries, patterns found |
| Library reference | `libraries/[name].md` | Per-library quirks, workarounds, version notes |
| Stack recipes | `stack/[name].md` | Integration recipes, trial-and-error solutions |
| Dependency pins | `dependencies/PINS.md` | Version pins, upgrade blockers |

## Checkpoints

Hybrid checkpoints: git tag (code state) + `.context/checkpoints/CP-NNN/` (context state).

Auto-created at phase boundaries and before Agent Team spawns. Manual operations:

```
/checkpoint create [label]     Create a checkpoint
/checkpoint list               List all checkpoints
/checkpoint rollback CP-NNN    Rollback (offers full or soft)
/checkpoint resume CP-NNN      Resume from checkpoint
/checkpoint clean --keep 5     Clean old checkpoints
```

## Context Budget

| Usage | Action |
|-------|--------|
| < 50% | Keep working |
| 50-60% | Save state, prepare to clear |
| > 60% | Stop. `/clear`. `/resume`. |

Prefer `/clear` + `/resume` over `/compact`.

## Parallel Work

```bash
git worktree add ../project-feature-a feature-a
cd ../project-feature-a && claude
```

Each worktree gets its own Claude Code session. `.context/` is shared via git.

## Docs

- `docs/CHEATSHEET.md` - Quick reference for all commands and features
- `docs/WALKTHROUGH.md` - Full tutorial walkthrough
- `docs/PLUGIN.md` - Plugin distribution and marketplace publishing guide

## Credits

Built on patterns from Anthropic's Agent Teams docs, Ashley Ha's workflow, Cole Medin's context engineering, FlineDev's ContextKit, ContextX, Context Forge, and PubNub's agent workflow.

MIT License.
