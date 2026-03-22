# Context Engine

A reusable contextual engineering framework for Claude Code. Structured workflows, Agent Teams for parallel execution, persistent project knowledge, and auto-learning from every session.

## Quick Start

### Option A: Project-Level Install (recommended for teams)
```bash
./install.sh /path/to/your/project
cd /path/to/your/project
claude
/ce-init                   # auto-detect project, populate .context/
/ce-research [feature]     # begin first feature
```

### Option B: Plugin Install (recommended for personal use)
```bash
# Add marketplace (one-time)
/plugin marketplace add your-org/context-engine

# Install plugin
/plugin install context-engine@context-engine

# In any project:
/context-engine:ce-init
```

See `docs/PLUGIN.md` for full plugin distribution guide.

## How It Works

```
Init -----> Research -----> Plan -----> Implement ---------> Validate
(once)      researcher     planner     Agent Team            Agent Team
            subagent       subagent    (parallel tracks)     (parallel review)
               |              |              |                     |
            NOTES.md       PRP.md      Code + Tests           Learnings
                                           |                  captured
                           [/clear between phases to manage context]
```

Commands choose Agent Teams or subagents based on task complexity. Each command ends with the exact next command to run.

## Structure

```
.claude/
  agents/          researcher, planner, implementer, reviewer, debugger
  commands/        ce-init, ce-research, ce-plan, ce-plan-quick,
                   ce-implement, ce-validate, ce-debug, ce-refactor,
                   ce-status, ce-resume, ce-learn, ce-update-arch
  skills/          18 progressive-disclosure skills (context-system,
                   testing, api, git, database, auth, deployment,
                   react, python, postgres, redis, ruby, context7,
                   mcp-tools, sequential-thinking, puppeteer,
                   postgres-mcp, google-workspace, knowledge-base)
  hooks/           guard-protected-files, block-destructive, auto-format,
                   preserve-context, capture-learnings, verify-agent-output,
                   session-track
.context/
  architecture/    OVERVIEW.md, TECH_STACK.md, DIRECTORY_MAP.md
  features/        FEATURES.md + PRPs per feature
  patterns/        CODE_PATTERNS.md, ANTI_PATTERNS.md
  decisions/       Architecture Decision Records
  errors/          INDEX.md + detail/
  knowledge/       LEARNINGS.md + libraries/ + stack/ + dependencies/
  checkpoints/     MANIFEST.md + CP-NNN snapshots (auto-created)
  metrics/         HEALTH.md (velocity, errors, knowledge, agents, context)
```

**Plugin packaging** (optional - for marketplace distribution):
```
marketplace.json       Marketplace catalog for /plugin marketplace add
build-plugin.sh        Transforms project structure into plugin format
docs/PLUGIN.md         Plugin distribution guide
```

## Commands

| Command | Phase | Purpose |
|---------|-------|---------|
| `/ce-init` | Setup | Bootstrap `.context/` |
| `/ce-research` | 1 | Explore codebase |
| `/ce-plan` | 2 | Create PRP with testing strategy prompt |
| `/ce-plan-quick` | 2 (lite) | Quick plan for small tasks |
| `/ce-implement` | 3 | Agent Team for parallel steps, or subagent for sequential |
| `/ce-validate` | 4 | Agent Team for parallel review, or subagent for small changes |
| `/ce-debug` | Any | Agent Team for parallel hypothesis testing, or subagent |
| `/ce-refactor` | Any | Agent Team for multi-track refactors, or subagent |
| `/ce-status` | Any | Project briefing and onboarding (read-only) |
| `/ce-resume` | Any | Reload after `/clear` |
| `/ce-learn` | Any | Route knowledge to deep reference (libraries, stack, dependencies, insights) |
| `/ce-knowledge` | Any | Browse, search, promote knowledge base |
| `/ce-checkpoint` | Any | Create, list, rollback hybrid checkpoints (git tag + .context/ snapshot) |
| `/ce-health` | Any | Metrics dashboard: velocity, errors, knowledge, agents, context efficiency |
| `/ce-update-arch` | Any | Refresh architecture docs |

## Orchestration

Two modes. Commands pick automatically based on complexity.

**Agent Teams** - Used by implement, validate, debug, refactor when work has parallel tracks. Teammates work independently, communicate directly, coordinate via shared task list with dependency ordering. Each teammate owns specific files (no conflicts). Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (set in settings.json).

**Subagents** - Used by research, plan, and as fallback for small tasks. Single specialist works in isolated context, returns summary. Cheaper, simpler, best for focused sequential work.

Five role definitions (`agents/`) serve as both subagent configs and teammate spawn templates:

| Role | Agent Team | Subagent | Remembers |
|------|-----------|----------|-----------|
| **researcher** | - | Yes | File locations, codebase structure |
| **planner** | - | Yes | Estimation accuracy, recurring risks |
| **implementer** | Teammate | Fallback | Code patterns, build quirks |
| **reviewer** | Teammate | Fallback | Recurring issues, fragile areas |
| **debugger** | Teammate | Fallback | Error patterns, diagnostic shortcuts |

All roles have `memory: project` - they learn across sessions automatically.

## Testing Strategy

Configurable per-project (CLAUDE.md default) and per-plan (PRP header override).

| Strategy | When to Use |
|----------|-------------|
| `test-first` | Clear acceptance criteria. TDD. |
| `implement-then-test` | General development (default). |
| `tests-optional` | Spikes, prototypes, exploration. |

During `/ce-plan`, you're prompted to choose. The implementer and reviewer both respect the choice. Validation is always mandatory regardless of strategy.

## Auto-Learning

Learning is automatic by default:

**Phase reflection** - Every command writes discoveries to `.context/` before handing off. Errors, patterns, architecture changes, decisions, and insights are captured without manual intervention.

**Agent memory** - All five roles persist knowledge across sessions. The researcher maps the codebase, the implementer remembers what works, the reviewer tracks recurring issues.

**Deep knowledge layer** - Hybrid capture model. The implementer and debugger auto-capture library quirks, version pins, and stack recipes during work. Use `/ce-learn` for manual capture during research and planning. Knowledge is stored in `.context/knowledge/` with three tiers: quick insights (LEARNINGS.md), per-library reference (libraries/), stack config recipes (stack/), and dependency pins (dependencies/). Browse with `/ce-knowledge`.

## Hooks (Enforced Gates)

Hooks are deterministic scripts that run at Claude Code lifecycle events. Unlike CLAUDE.md rules which are advisory, hooks enforce behavior automatically.

| Hook | Event | What It Does |
|------|-------|-------------|
| `guard-protected-files` | PreToolUse | Blocks edits to .env, lockfiles, .git/, settings.json |
| `block-destructive` | PreToolUse | Blocks dangerous rm, DROP TABLE, disk operations |
| `auto-format` | PostToolUse | Runs project formatter after every file edit |
| `preserve-context` | PreCompact | Injects active PRP, branch, progress before compaction |
| `capture-learnings` | Stop | Reminds to capture learnings if code changed but .context/ wasn't updated |
| `verify-agent-output` | SubagentStop | Flags if implementer completed without file changes |
| `session-track` | UserPromptSubmit | Creates session marker for other hooks |

Hooks are configured in `hooks/hooks.json` (plugin) or `.claude/settings.json` (local dev). Scripts live in `hooks/scripts/`. View active hooks with `/hooks`.

## Context Budget

| Usage | Action |
|-------|--------|
| < 50% | Keep working |
| 50-60% | Save state, prepare to clear |
| > 60% | Stop, save, `/clear`, `/ce-resume` |

## Parallel Work

```bash
git worktree add ../project-feature-a feature-a
cd ../project-feature-a && claude
```

Each worktree gets its own Claude Code session. `.context/` is shared via git.

## Credits

Built on patterns from Anthropic's Agent Teams docs, Ashley Ha's workflow, Cole Medin's context engineering, FlineDev's ContextKit, ContextX, Context Forge, and PubNub's agent workflow.

MIT License.
