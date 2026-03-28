---
name: Context Engine Optimization Analysis
description: Deep analysis of how the Context Engine achieves context efficiency - skills, hooks, /adapt, token budgeting, CLAUDE.md leanness, and shared instructions
type: project
---

# Context Engine: Context Optimization Analysis

> "Context is the bottleneck, not intelligence. Skills load domain expertise on-demand."
> — CLAUDE.md mission statement

This document analyzes whether and how the system achieves that stated goal across six dimensions.

---

## 1. Progressive Disclosure: The Skill AutoLoad System

### How It Works

Skills live in `skills/[name]/SKILL.md`. The autoload system is entirely **metadata-driven**: each skill file has a YAML frontmatter `description` field. Claude's runtime uses that description to decide when to surface the skill based on what files are being touched.

There is no explicit trigger-matching code — no glob patterns, no file watchers, no routing config. The mapping between file patterns and skills lives in a human-readable reference table inside `skills/context-system/SKILL.md` (lines 21–41), which itself auto-loads when working with `.context/`, `commands/`, or `agents/`.

**The trigger table (from context-system/SKILL.md):**

| Skill | Loads When |
|-------|-----------|
| `context-system` | .context/, commands/, agents/ |
| `testing-conventions` | test/spec files |
| `api-conventions` | route/controller files |
| `react-frontend` | .tsx/.jsx, components/ |
| `python-backend` | views/, routers/ .py |
| `postgres` | .sql, db/ files |
| `deployment-cicd` | Dockerfile, workflows/ |
| `auth-security` | auth/, middleware/ files |
| `prompt-efficiency` | **Always loaded** |
| `context7-docs` | package.json, requirements |
| `mcp-tools` | .mcp.json |
| `sequential-thinking` | PRP.md, ADR-*, errors/ |
| `puppeteer` | e2e/, screenshots/ |
| `postgres-mcp` | .sql, migrations/, db/ |
| `google-workspace` | spreadsheet, gdoc, gsheet |
| `knowledge-base` | .context/knowledge/, package.json |

### The Skill Profile Filter

`/init` generates `.context/architecture/.skill-profile.json` with three arrays:
- `detected_stack`: what languages/frameworks were found
- `relevant_skills`: skills that match the stack
- `irrelevant_skills`: skills to deprioritize at runtime

This is the key efficiency lever: if a project has no Ruby, the `ruby` skill's frontmatter description won't match anything it reads, and the skill profile flags it as irrelevant if it somehow does trigger. Skills can still override this if a new technology is genuinely being added.

### Two-Tier Skill Design

Several skills have a companion `REFERENCE.md` alongside their `SKILL.md`:
- `mcp-tools/`, `puppeteer/`, `postgres-mcp/`, `google-workspace/`

The rule (from `skills/prompt-efficiency/SKILL.md` line 23): load only `SKILL.md` (Tier 1) by default; read `REFERENCE.md` only when editing MCP configs or the user explicitly asks for setup details. REFERENCE.md files contain verbose MCP configuration blocks — keeping them out of routine context is a meaningful token saving.

### Assessment

The progressive disclosure system is **effective in principle but implicit in implementation**. There is no deterministic routing — it relies on Claude reading the trigger table in `context-system/SKILL.md` and the skill frontmatter descriptions, then making a judgment call. The skill profile filter adds a deterministic layer for eliminating irrelevant-stack skills. In practice this means:

- **Works well**: stack-specific skills (ruby, react, python) get properly filtered by skill profile
- **Works well**: MCP tool reference files stay unloaded unless explicitly needed
- **Gap**: The trigger descriptions use natural language ("auto-loaded when working with..."), not executable glob patterns. This means edge cases depend on Claude's interpretation.

---

## 2. The Hook System

The hook system is the **deterministic enforcement layer** of the framework. It operates via shell scripts called by Claude Code's hook lifecycle events.

### Hook Architecture

Two configuration files exist:
- `hooks/hooks.json` — plugin-mode config (uses `${CLAUDE_PLUGIN_ROOT}` path expansion)
- `.claude/settings.json` — local dev config (uses relative `hooks/scripts/` paths)

The local settings.json intentionally omits `context-budget.sh` and `classify-request.sh` from its hook registrations, though the plugin config includes both.

### Hook Inventory

**PreToolUse (guard before action):**
- `guard-protected-files.sh` — blocks writes to `.env`, lock files, `.claude/settings.json`, and nested `.claude/` directories. Uses regex matching against file paths. Enforces "agent memory at root only" rule.
- `block-destructive.sh` — blocks `rm -rf` targeting root/home/parent dirs, requires confirmation for SQL DROP/TRUNCATE/DELETE, blocks disk-level operations. Also blocks `mkdir .claude` from subdirectories.

**PostToolUse (react after action):**
- `auto-format.sh` — fires on Write/Edit/MultiEdit. Detects project formatter (prettier, eslint, ruff, black, gofmt, rustfmt) with a 5-minute TTL cache to avoid re-detection on every edit. Skips `.md`, `.json`, `.yaml`, `.context/`, `.claude/`, `dist/`, `node_modules/`. This cache optimization is notable — formatter detection is expensive if re-run 50 times per session.
- `context-budget.sh` — fires on Read/Bash. Uses a `/tmp` counter file as a proxy for context usage. Warns at 50 calls ("consider wrapping up") and 80 calls ("strongly recommend /clear + /resume"). Counter resets when a new session marker is newer than the counter file.

**PreCompact (before context compression):**
- `preserve-context.sh` — injects `additionalContext` JSON with current branch, active PRP path, completed/total steps, feature name, and testing strategy. This is the session-continuity mechanism: if `/compact` runs, the next response still knows where it was. Falls back gracefully to "no active PRP found."

**Stop (session end):**
- `capture-learnings.sh` — checks if code files changed (via `git diff`) but no `.context/` files were updated since session start. If so, injects a reminder to capture learnings. The check uses `-newer /tmp/.session-start` file comparison.

**SubagentStop (agent completion):**
- `verify-agent-output.sh` — checks if the implementer agent actually made file changes (`git diff --name-only | wc -l`). If zero changes, warns that the agent may have only planned rather than implemented. Only fires for agents matching "implement" in the name.

**UserPromptSubmit (per-prompt):**
- `session-track.sh` — creates `/tmp/.session-start` marker on first prompt (or if marker is >120 minutes old). Used as timestamp reference by `capture-learnings.sh` and `context-budget.sh`.
- `classify-request.sh` — injects task complexity hint. MINIMAL triggers for "typo", "rename", "fix import", "one-line", etc. HEAVY triggers for command names like `/debug`, `/refactor`, `/adapt`, `/validate`, "parallel tracks", "complex bug". Complexity hint then governs delegation decisions in `prompt-efficiency/SKILL.md`.

### Hook Interaction With Generated Files

The auto-formatter has deliberate exclusions for framework-generated files:
```
*.md|*.json|*.yaml|*.yml|*.toml|*.lock  → skip (config/docs)
*.context/*|*.claude/*|*/dist/*          → skip (framework dirs)
```

This means agent writes to `.context/` never trigger formatting, preventing accidental modification of structured knowledge files. The protected files guard also blocks writes to `.claude/settings.json` itself — the framework configuration cannot be modified by any agent action.

### Assessment

The hook system is **well-designed and genuinely deterministic** where it matters most:
- Safety guards (file protection, destructive command blocking) are unconditional
- Context budget uses a simple but effective proxy (tool call count vs. actual token count)
- The 5-minute formatter cache is a smart optimization worth noting
- Session state persists across compaction via `preserve-context.sh`

The main limitation is that `context-budget.sh` counts tool calls, not tokens. A session with 30 deep file reads burns more context than one with 80 shallow Bash calls. The threshold (80 calls = warning) is conservative enough to work in practice but is not semantically precise.

---

## 3. The `/adapt` Command

`/adapt` is the **project conformance system** — it transforms arbitrary projects to meet the framework's standards. It is not primarily a context optimization tool but does affect context efficiency indirectly.

### What It Does

`/adapt` (audit mode) reads standards from skills and checks project source files against them across six dimensions:
1. **Structure** — file sizes, directory layout, import patterns
2. **Documentation** — docstrings/JSDoc on public functions
3. **Code Quality** — naming conventions, type hints, anti-patterns
4. **Testing** — test coverage, test structure consistency
5. **Security** — OWASP patterns, input validation, secrets management
6. **DevOps** — Docker, CI/CD, conventional commits

`/adapt apply [dimension]` (apply mode) executes fixes by generating a PRP and delegating to `/refactor` or the `implementer` agent.

### Context Optimization Angle

Adaptation improves context efficiency indirectly:
- **300-line file limit** keeps individual file reads fast. Files >500 lines get HIGH severity findings.
- **Docstrings on public functions** means future agents can understand intent from function signatures without reading full implementations.
- **Consistent naming conventions** means grep searches return precise results rather than noisy false positives.
- The `/adapt` process itself is context-heavy (15-20 files sampled, multiple skills loaded). The command notes: "If context > 50% during full audit, suggest targeted dimension audits."

### Integrity Zones

The `/adapt` command defines four zones (lines 183-186 of `commands/adapt.md`):
- Zone A IMMUTABLE: `.context/` framework structure, SKILL.md frontmatter
- Zone B SAFE TO MODIFY: Project source code
- Zone C PRESERVE: Business logic substance (adapt form, not function)
- Zone D NEVER TOUCH: `.env`, secrets, vendor, generated code, lock files, `CLAUDE.local.md`

---

## 4. Token Budgeting and Efficiency Strategies

The system employs multiple layered strategies:

### Explicit Budget Thresholds (CLAUDE.md + prompt-efficiency/SKILL.md)

| Threshold | Action |
|-----------|--------|
| < 40% | Full Agent Teams allowed |
| 40-50% | Prefer single subagent over Agent Team |
| 50-60% | Save state, prepare to /clear |
| > 60% | Stop. /clear. /resume. |

The 40% threshold for Agent Teams is notable — spawning multiple parallel agents multiplies context consumption, so the system prevents that at 40% rather than 50%.

### Delegation Efficiency Rules (`.claude/instructions/DELEGATION.md` + `prompt-efficiency/SKILL.md`)

- Pass only `task + relevant file paths` to subagents, not full context summaries
- Agents read `.context/` independently — never duplicate its content in delegation prompts
- Agent Team teammates get only their file scope, not the full PRP
- Agents follow their own instructions — don't repeat agent rules in command prompts

These rules address a common failure mode: commands that include a "context summary" paragraph before delegating, which doubles the context load for the subagent.

### Context Loading Rules

From `prompt-efficiency/SKILL.md`:
- Read only the section needed from `.context/` files, not the full file
- Tier 1 SKILL.md vs Tier 2 REFERENCE.md split for MCP skills
- Shared instructions referenced by pointer, not inlined

### /clear + /resume Pattern

The system explicitly prefers `/clear` (native context clearing) over `/compact` (compression). The `preserve-context.sh` hook handles the compaction path as a fallback. `/resume` is designed to be lightweight — it reads only FEATURES.md (for active PRP path), the PRP itself (for step status), and skims OVERVIEW.md and INDEX.md. It explicitly does not re-read implementation files.

### Skill Profile Filtering

`.context/architecture/.skill-profile.json` enables runtime filtering of irrelevant skills at the framework level. The `prompt-efficiency` skill is flagged as **Always loaded** — its efficiency rules are the one piece of domain knowledge that must always be in context.

### Anti-Patterns Catalogued

`prompt-efficiency/SKILL.md` explicitly lists token waste patterns (lines 35-40):
- Repeating agent instructions in command prompts
- Loading full MCP config blocks when only querying data
- Summarizing `.context/` docs in delegation prompts
- Spawning Agent Teams for < 3 independent steps
- Loading irrelevant-stack skills

---

## 5. CLAUDE.md Leanness Analysis

### Current State

CLAUDE.md is 97 lines. It contains:
- Project Knowledge table (14 rows, pointers to `.context/` docs)
- Workflow table (5 phases + 8 quick-command references)
- Context Management rules (5 bullets)
- Orchestration summary (Agent Teams vs Subagents, 4 lines)
- Feature Lifecycle (3 lines)
- Testing Strategy (3 lines)
- Code Standards (6 bullets)
- Hooks summary (5 bullets)
- Auto-Learning (3 points)
- Skills section (2 lines + pointer)

### Effectiveness as Index

CLAUDE.md functions effectively as a pointer document. It contains:
- No implementation details — those live in `commands/`, `skills/`, `.context/`
- No duplicated content — skills are referenced by path, not inlined
- No full SKILL.md content — only a count ("20 skills in skills/") and a pointer to context-system for the full catalog
- The Project Knowledge table is a pure lookup table — 14 file pointers in tabular form

The opening tagline ("Context is the bottleneck, not intelligence") and the two-sentence skills description ("Domain expertise loads on-demand. Not front-loaded.") serve as behavioral priming for the AI reading the file.

### Areas Where It Could Be Leaner

- The Hooks section lists 5 named hooks. These are also fully documented in `hooks/hooks.json` and individual scripts. However, the CLAUDE.md listing serves as a quick reference so the agent knows hooks exist without having to discover them.
- The Code Standards section (6 bullets) is short but could theoretically live in a CODE_STANDARDS.md file. In practice 6 bullets is minimal enough to keep inline.

### Assessment

CLAUDE.md is lean at 97 lines. It serves as a behavioral constitution (priming + rules) and an index (pointer table), not a knowledge base. The split between "always-loaded constitution" (CLAUDE.md) and "on-demand expertise" (skills/) is well-executed.

---

## 6. Shared Instructions in `.claude/instructions/`

Four shared instruction files exist:

| File | Content | Used By |
|------|---------|---------|
| `CAPTURE-FORMAT.md` | Exact markdown formats for writing to each `.context/` subdirectory | `commands/implement.md` (line 51), `commands/debug.md`, `commands/validate.md` |
| `DELEGATION.md` | 5-rule delegation pattern (pass task not summary, agent reads .context/ independently, etc.) | Referenced by multiple commands |
| `MEMORY-PATH.md` | One rule: agent memory lives at `.claude/agent-memory/` at git root | Agent role files, guard-protected-files.sh enforces it |
| `TESTING-STRATEGY.md` | Full TDD/implement-then-test/tests-optional cycle descriptions | `commands/implement.md`, agent roles |

### How They Reduce Duplication

Without these files, each command that involves implementation would need to inline:
- The full testing strategy cycle descriptions (~30 lines each for 3 strategies = 90 lines)
- The capture format templates (~40 lines)
- The delegation rules (5 rules)

With shared instructions, commands reference by pointer. `implement.md` line 51 simply says "using formats from `.claude/instructions/CAPTURE-FORMAT.md`" rather than inlining all the templates.

The `guard-protected-files.sh` hook enforces the `MEMORY-PATH.md` rule deterministically — the instruction is both documented (for the agent reading it) and enforced (for the agent that ignores it).

### Assessment

The instructions directory is small (4 files) but covers the highest-repetition content: format templates and protocol rules that would otherwise appear verbatim in every command that does implementation or delegation. This is effective deduplication.

---

## Overall System Assessment

### Does It Achieve Its Stated Goal?

**Partially yes, with some gaps.**

**Strengths:**
1. CLAUDE.md at 97 lines is genuinely lean — it primes behavior and indexes knowledge without duplicating it
2. The skill profile filter provides deterministic elimination of irrelevant-stack skills
3. The two-tier skill design (SKILL.md vs REFERENCE.md) for MCP tools meaningfully reduces routine context load
4. The delegation rules prevent the common "duplicate context" failure mode
5. `/clear` + `/resume` is preferred over `/compact`, and `/resume` is designed to be fast
6. The hook system enforces safety deterministically, not probabilistically
7. `prompt-efficiency/SKILL.md` being always-loaded means efficiency rules are never absent from context

**Gaps:**
1. Skill autoloading relies on natural language description matching, not executable glob patterns. Edge cases depend on Claude's interpretation of frontmatter descriptions.
2. The `context-budget.sh` proxy (tool call count) does not correlate linearly with actual token consumption. A session doing 30 deep file reads vs 80 Bash echo calls would hit different real-context levels at the same counter value.
3. `classify-request.sh` uses simple string matching (keyword grep) to determine task complexity. Commands with HEAVY keywords in filenames or arguments that don't actually require Agent Teams will get HEAVY classification.
4. The `.context/` knowledge base is empty on a fresh repo — `testing-conventions/SKILL.md` is a skeleton until `/init` or `/learn` populates it. This means the system's effectiveness scales with usage, which is by design but means early sessions get less context benefit.
5. The `verify-agent-output.sh` SubagentStop hook only checks for "implement" in agent names. Reviewer or debugger agents producing only text analysis (no file changes) won't trigger the warning even if they should have made changes.

### Key Design Insight

The system treats context efficiency as a multi-layer problem:
- **Layer 1 (structural)**: CLAUDE.md is an index, not a knowledge base
- **Layer 2 (conditional)**: Skills load domain expertise only when relevant files are touched
- **Layer 3 (filtered)**: Skill profile eliminates irrelevant-stack skills at runtime
- **Layer 4 (behavioral)**: Delegation rules prevent context duplication between lead and subagents
- **Layer 5 (deterministic)**: Hooks enforce safety and inject warnings when budget is at risk
- **Layer 6 (recovery)**: /clear + /resume + preserve-context.sh handles the inevitable context overflow

No single layer is complete on its own. The system's effectiveness comes from all six operating together.
