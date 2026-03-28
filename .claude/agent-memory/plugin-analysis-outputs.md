---
name: Plugin MD Files Analysis
description: Structural and token-efficiency analysis of all skills/, commands/, and .claude/instructions/ markdown files
type: project
---

# Plugin MD Files Analysis

**Scope**: skills/ (24 files), commands/ (18 files), .claude/instructions/ (4 files)
**Date**: 2026-03-28
**Why**: To assess structure, size, token density, redundancy, and progressive-disclosure compliance

---

## 1. Skills Directory

### Size Distribution

| Range | Count | Files |
|-------|-------|-------|
| 22–40 lines | 10 | testing-conventions, api-conventions, puppeteer/SKILL, postgres-mcp/SKILL, mcp-tools/SKILL, google-workspace/SKILL, database-migrations, postgres, context-system, prompt-efficiency |
| 41–55 lines | 9 | redis, react-frontend, auth-security, ruby, deployment-cicd, python-backend, git-workflow, context7-docs, sequential-thinking |
| 56–65 lines | 2 | knowledge-base, sequential-thinking |
| 62–86 lines | 4 | REFERENCE files: postgres-mcp/REFERENCE (72), mcp-tools/REFERENCE (62), puppeteer/REFERENCE (59), google-workspace/REFERENCE (86) |

**Average SKILL.md size**: ~42 lines (well under the 300-line file limit)
**Average REFERENCE.md size**: ~70 lines

### Structural Patterns

Every SKILL.md follows this consistent pattern:
```
---
description: [one-line description used for auto-load triggering]
---

# [Skill Name]

[Optional intro sentence]

## [Sections...]
```

**Section anatomy by skill type:**

- **Stack/language skills** (python-backend, ruby, react-frontend, redis, postgres, deployment-cicd, auth-security, database-migrations): use titled sections per concern (`## FastAPI`, `## Caching Patterns`, etc.) + a `## Common Pitfalls` closer. Dense bullet lists, no prose padding.

- **MCP tool skills** (context7-docs, sequential-thinking, puppeteer, postgres-mcp, google-workspace, mcp-tools): use `## When to Use` / `## When NOT to Use` / `## Workflow` / `## Rules` structure. Include tool-call signatures or code examples only when needed.

- **Meta/framework skills** (context-system, knowledge-base, prompt-efficiency): use reference tables and tiered categorization. context-system is a lookup table; prompt-efficiency is rule-based.

- **Template-skeleton skills** (testing-conventions, api-conventions): intentionally sparse — HTML comment placeholders like `<!-- Populated by /init -->`. This is by design: they're populated per-project during `/init`.

### SKILL.md vs REFERENCE.md Split

Four skills (mcp-tools, puppeteer, postgres-mcp, google-workspace) use a two-tier file structure:

- **SKILL.md** (Tier 1): When-to-use and lightweight workflow. Ends with "For details, read REFERENCE.md."
- **REFERENCE.md** (Tier 2): Full config blocks, tool tables, setup instructions, auth workflows.

This is a strong progressive disclosure implementation. The SKILL.md is the always-loaded context; REFERENCE.md is pulled only when installing or configuring. The `prompt-efficiency/SKILL.md` explicitly documents this rule (line 23): "load only SKILL.md by default; read REFERENCE.md only when editing MCP configs or the user explicitly asks for setup details."

### Token Efficiency Assessment

**High efficiency**: python-backend, ruby, redis, postgres, auth-security, deployment-cicd, react-frontend, database-migrations. These are maximally dense — each line carries a concrete rule or pattern. No filler sentences, no re-explaining what the language is.

**Good efficiency**: context7-docs, sequential-thinking, mcp-tools SKILL.md, google-workspace SKILL.md. The MCP tool workflow descriptions are slightly more verbose but justified — they need to teach the call sequence.

**Justified verbosity**: knowledge-base (61 lines). This skill is itself a meta-system with tiered rules, promotion rules, and a comparison table. The length is structural, not padded.

**Template skeletons**: testing-conventions (25 lines) and api-conventions (28 lines) are mostly comment placeholders. These look sparse but are intentionally so — they're meant to be populated by `/init`. Not a verbosity issue, but a design trade-off: an empty skeleton loads every session even when unpopulated, consuming tokens for no benefit until `/init` runs.

**Minor redundancy noted**: The `context7-docs/SKILL.md` MCP configuration block (lines 37-48) duplicates content that lives in `mcp-tools/REFERENCE.md`. If a project has the MCP catalog loaded, this is double-coverage. Low impact given the ~12 lines involved.

---

## 2. Commands Directory

### Size Distribution

| Range | Count | Files |
|-------|-------|-------|
| 28–40 lines | 5 | status, resume, update-arch, research, plan-quick |
| 41–65 lines | 7 | plan, plan-quick, knowledge, learn, debug, simplify, security-review |
| 64–90 lines | 4 | implement, refactor, health, init |
| 103–123 lines | 2 | validate, checkpoint |
| 203 lines | 1 | adapt |

**Average**: ~68 lines per command file
**Largest**: adapt.md at 203 lines (still under the 300-line limit)
**Total corpus**: 1,224 lines across 18 files

### Structural Patterns

Every command file follows:
```
# /[command] - [Short Title]

[1-2 sentence purpose description]

## Process

[Numbered steps]

## Rules
[Bullet list of hard constraints]

## User Input
$ARGUMENTS
```

The `## Rules` section appears in every command without exception — this is a structural invariant. The `## User Input\n$ARGUMENTS` footer is also universal, confirming the plugin framework's argument injection mechanism.

**Inline output templates**: The larger commands embed their expected output format directly as fenced code blocks in the steps. This is load-bearing — it's instruction, not documentation, because Claude uses these as the generation target. Example from validate.md (lines 65-73), adapt.md (lines 123-149). This is appropriate verbosity.

### Progressive Disclosure Compliance

Commands are already lean for their function. The commands that are longest (adapt, validate, checkpoint) are inherently complex workflows with multiple branches (`/adapt`, `/adapt apply`, `/adapt apply all`; `rollback`, `resume`, `create`, `list`, `clean` for checkpoint). The branching logic accounts for most of the length.

Commands use pointer-delegation rather than inlining:
- "Use formats from `.claude/instructions/CAPTURE-FORMAT.md`" appears in implement.md, validate.md, debug.md, plan-quick.md — shared format spec is referenced, not repeated.
- "Delegate to `researcher` agent" / "Delegate to `planner` agent" pattern appears across research, plan, refactor, simplify, security-review, update-arch — the agent's own instructions handle the details.

### Token Efficiency Assessment

**Most efficient** (high instruction density, low line count): status (28), resume (29), update-arch (33), research (32), plan-quick (37), plan (37). These are tight and clearly scoped.

**Justified length**: validate (123 lines) and checkpoint (108 lines). Validate has 14 numbered steps handling test runs, agent teams, learning capture, metrics, commit/PR prompts, and branch cleanup — this genuinely requires the space. Checkpoint has 5 distinct sub-commands with divergent logic paths.

**Most verbose relative to function**: adapt.md at 203 lines. This is the most complex command and covers a full audit + apply cycle across 6 dimensions. However, it does show some structural repetition: the "Phase 4: Apply" section (lines 154-180) repeats safety check rules already established elsewhere. The integrity zone table (lines 181-186) and the Rules section (lines 188-201) are both needed but together run 26 lines of constraint documentation, some of which overlaps with standard project conventions.

**Internal redundancy in adapt.md**: Lines 156-159 re-state the same safety check sequence as implement.md and refactor.md. This is copied rather than referenced. A pointer to `/refactor` safety check protocol would save ~4 lines and reduce drift risk if that protocol changes.

**Repeated handoff pattern**: Every phase command (plan, implement, validate) ends with an explicit "if yes → invoke the next command, if no → ask what instead" block. This appears near-verbatim in 3 files. The phrasing is consistent which is good for reliability, but it's ~5 lines repeated 3x.

---

## 3. .claude/instructions/ Files

### Size and Purpose

| File | Lines | Role |
|------|-------|------|
| CAPTURE-FORMAT.md | 44 | Shared format spec for error/learning/pattern capture |
| TESTING-STRATEGY.md | 24 | Shared test strategy execution protocol (test-first, impl-then-test, optional) |
| DELEGATION.md | 8 | 5-rule delegation pattern, universally applicable |
| MEMORY-PATH.md | 5 | Memory location convention |

**Total**: 81 lines across 4 files.

### Structural Patterns

No frontmatter — these are raw reference docs, not skill-style files. CAPTURE-FORMAT.md uses fenced code blocks to show exact format templates. TESTING-STRATEGY.md uses numbered sub-steps per strategy. DELEGATION.md is a simple numbered list.

### Token Efficiency Assessment

These are maximally efficient. Each file is a single-purpose spec:
- CAPTURE-FORMAT.md is a format reference — all content is the format itself, no padding.
- TESTING-STRATEGY.md is a protocol definition — 3 strategies, 3-5 steps each.
- DELEGATION.md is 8 lines of rules used by every delegation-heavy command.
- MEMORY-PATH.md is a 5-line convention reminder.

The key token-efficiency win here is **factoring shared content out of commands**. Before this pattern, each command that captures learnings had to embed the format spec. Now it's a single pointer: "Use formats from `.claude/instructions/CAPTURE-FORMAT.md`." This eliminates ~30 lines of repetition across implement, validate, debug, and plan-quick.

---

## 4. Cross-Cutting Observations

### What Works Well

1. **Skill auto-load descriptions are precise**. Every SKILL.md frontmatter description is a single line identifying both the domain and the trigger condition (e.g., "Auto-loaded when working with auth, middleware, or security files"). This is how the skills-as-progressive-disclosure mechanism fires correctly.

2. **SKILL.md/REFERENCE.md split is well-executed** for the 4 MCP tool skills. Each SKILL.md ends with an explicit pointer to REFERENCE.md for setup details, and the line between them is clear: SKILL.md = usage, REFERENCE.md = configuration.

3. **Commands share a lockstep structure** (Process → Rules → $ARGUMENTS). This consistency means an agent reading a new command can orient quickly without scanning for where the constraints live.

4. **`.claude/instructions/` deduplication** is working. CAPTURE-FORMAT.md and TESTING-STRATEGY.md are each referenced by 3-4 commands via pointer. This is the right factoring.

5. **No command file exceeds 300 lines.** adapt.md at 203 is the ceiling. The constraint is holding.

### Potential Issues / Risks

1. **Template skeleton skills load empty**. testing-conventions/SKILL.md and api-conventions/SKILL.md are mostly comment placeholders until `/init` runs on a project. They auto-load based on file triggers but contain no actionable content for a new project. A small "Not yet populated — run /init to fill this skill" note at the top would make the empty state explicit, preventing an agent from reading them and inferring the project has no test conventions.

2. **adapt.md safety checks are duplicated**, not referenced. Lines 156-159 restate safety checks already defined in implement.md and refactor.md. If those rules change, adapt.md must be updated separately. A pointer to the refactor safety protocol would be cleaner.

3. **context7-docs/SKILL.md duplicates MCP config** already in mcp-tools/REFERENCE.md (lines 37-48 of context7-docs/SKILL.md). Minor redundancy; the config block is 11 lines. However, the context7-docs skill is in the "always check relevant libs" category, so this config is loaded more often than REFERENCE.md. The duplication may be intentional (self-contained skill) but worth noting.

4. **No explicit skill for ADR authoring**. Multiple commands reference `decisions/ADR-NNN-[title].md` and `ADR-000-template.md`, but the ADR format and decision-capture criteria aren't in any SKILL.md — they're implied. The knowledge-base skill covers LEARNINGS.md routing but not ADR creation triggers. This is a mild gap: when an agent decides to write an ADR, there's no single authoritative reference for the format (beyond the template file itself).

5. **The `plan-quick` command delegates to `researcher` for file scanning (step 2)**, but also "implements after approval" inline. The boundary between quick-plan and full-plan/implement is defined only by the "LOW complexity only" rule, with no mechanical enforcement. Complexity escalation is left to judgment.

6. **`health.md` velocity/error tracking relies entirely on agents manually writing to HEALTH.md** after each feature (validate.md, steps 41-57). If validate is skipped or context runs out before step 41, the metrics row is never written. There's no recovery mechanism documented except the `record` sub-command of `/health`, which requires the user to remember to call it.

### Summary Statistics

| Category | Files | Total Lines | Avg Lines | Max Lines | Under 300? |
|----------|-------|-------------|-----------|-----------|------------|
| skills/SKILL.md | 20 | ~812 | 41 | 61 | All yes |
| skills/REFERENCE.md | 4 | 279 | 70 | 86 | All yes |
| commands/ | 18 | 1,224 | 68 | 203 | All yes |
| .claude/instructions/ | 4 | 81 | 20 | 44 | All yes |
| **Total** | **46** | **~2,396** | — | 203 | **100%** |

**Why:** This analysis was requested to assess MD file token density, structure, and progressive disclosure compliance across the plugin's prompt content.
**How to apply:** Use these findings when evaluating whether to slim any skill or command files, identifying duplication targets for refactoring, or diagnosing why agents receive unhelpful content from empty template skills.
