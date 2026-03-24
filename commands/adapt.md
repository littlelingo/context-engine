# /adapt - Adapt Plugin to Project

Deep-analyze the target project's actual source code and populate the plugin's context layer with project-specific conventions, patterns, and knowledge. Run after `/init` to fast-track `.context/` from empty templates to actionable content.

## Prerequisites
- `.context/` must exist (run `/init` first)
- `.context/architecture/TECH_STACK.md` should be populated (by `/init`)

## Scope
Parse `$ARGUMENTS` for targeted runs:
- `/adapt` — full adaptation (all phases below)
- `/adapt skills` — phase 4 only
- `/adapt patterns` — phase 5 only
- `/adapt knowledge` — phase 6 only
- `/adapt claude` — phase 7 only
- `/adapt [skill-name]` — populate one specific skill

## File Integrity Zones

These zones govern every write operation in this command:

- **Zone A — IMMUTABLE**: SKILL.md frontmatter `description` fields, all section headers in `.context/` files, HTML comment format blocks (`<!-- Format: ... -->`), CLAUDE.md framework sections, file paths in Project Knowledge table. **Never modify.**
- **Zone B — POPULATE**: Empty content sections under existing headers, skills with only placeholder comments, empty knowledge templates. **Safe to fill.**
- **Zone C — PRESERVE**: All user-authored content in populated skills, all entries in CODE_PATTERNS.md and ANTI_PATTERNS.md, all learnings entries, all library/stack/dependency files, all architecture descriptions, all feature PRPs, CLAUDE.local.md. **Never overwrite.**
- **Zone D — MERGE**: Skills with existing content (add `## Project-Specific Conventions` section), CLAUDE.md (add project conventions), pattern files with existing entries (append, never rewrite). **Additive only.**

## Process

### Phase 1: Inventory
Read `.context/` files to understand what's already populated vs template. Categorize each file as:
- **empty-template** — only headers and HTML comments (Zone B — safe to populate)
- **partially-populated** — some sections filled, others empty (Zone D — merge carefully)
- **fully-populated** — substantial content exists (Zone C — preserve, append only)

This determines what `/adapt` will write vs skip.

### Phase 2: Deep Analysis
Delegate to `researcher` agent with a structured analysis prompt. The researcher must sample **actual source files** (10-15 minimum across directories), not just config files.

Analysis dimensions:

1. **Architecture & layering** — service layers, route handlers, models, dependency direction, separation of concerns. Trace actual import chains.
2. **Naming conventions** — variable/function/file/class casing, prefixes, suffixes. Note any inconsistencies between areas of the codebase.
3. **Code organization** — import ordering, export patterns, barrel files vs direct imports, colocation vs separation, file size norms.
4. **Error handling** — try/catch patterns, custom error classes, HTTP status conventions, validation approach, error response shapes.
5. **Data flow** — state management (frontend), ORM patterns (backend), query patterns, caching, how data moves between layers.
6. **API patterns** — route structure, middleware chains, request/response shapes, auth patterns, pagination, filtering.
7. **Testing patterns** — framework, fixtures, mocking strategy (real DB vs mocks), assertion style, file structure, coverage approach.
8. **Component/module patterns** — framework-specific idioms (React hooks, FastAPI dependencies, Rails concerns, service objects, etc.)
9. **Key library usage** — for each major dependency, HOW it's used with 2-3 concrete examples (file paths + brief description). Not just "uses React Query" but "uses React Query with object syntax, query key factories, invalidation on mutation".
10. **Gotchas & inconsistencies** — patterns that conflict, footguns discovered, things that would trip up a new contributor.

Researcher output: structured report with file paths and brief code descriptions (not raw dumps). One section per dimension.

### Phase 3: Validate Findings
Review researcher output against the Phase 1 inventory:
- Remove findings that duplicate what's already documented in `.context/`
- Flag findings that **contradict** existing documented patterns — ask user to resolve before writing
- Prioritize findings by impact: patterns used project-wide > patterns in one file

### Phase 4: Populate Skills
For each of these code-convention skills, check relevance based on researcher findings:
- `testing-conventions`, `api-conventions`, `react-frontend`, `python-backend`, `ruby`
- `auth-security`, `database-migrations`, `deployment-cicd`, `git-workflow`
- `postgres`, `redis`

For each relevant skill:
1. Read current SKILL.md
2. **PRESERVE** the frontmatter `description` field (Zone A — never modify)
3. **PRESERVE** all existing non-template content (Zone C)
4. If skill is empty template: populate sections with discovered patterns
5. If skill has content: add `## Project-Specific Conventions` section with `<!-- Last adapted: YYYY-MM-DD -->` marker
6. On re-run: find and **update** the marked section, don't duplicate

**Skip** MCP-only skills: `postgres-mcp`, `google-workspace`, `puppeteer`, `context7-docs`, `sequential-thinking`, `mcp-tools`.
**Skip** meta skills: `context-system` (framework reference), `knowledge-base` (managed by `/learn`).

### Phase 5: Populate Patterns

**CODE_PATTERNS.md**:
1. PRESERVE all section headers (Zone A)
2. PRESERVE all existing pattern entries (Zone C)
3. For each empty section, populate with discovered patterns
4. Each pattern entry: name, file path example, brief description
5. Organize by layer (Backend, Frontend, Shared) if full-stack project
6. Add `<!-- Populated by /adapt: YYYY-MM-DD -->` after the header comment

**ANTI_PATTERNS.md**:
1. PRESERVE header and format comment (Zone A)
2. PRESERVE all existing entries (Zone C)
3. Add discovered gotchas using the established format:
   ```
   ### [Name]
   Don't: [bad pattern]
   Do: [good pattern]
   Why: [reason]
   ```
4. Only add genuine gotchas (inconsistencies, footguns) — not style preferences

### Phase 6: Seed Knowledge

1. **Library files**: For each major dependency used substantially:
   - Check if `.context/knowledge/libraries/[name].md` exists
   - If not, create from TEMPLATE.md with version, usage patterns, any quirks found
   - If exists, PRESERVE entirely (Zone C)
2. **Stack recipes**: For key integrations (e.g., "FastAPI + SQLAlchemy async"):
   - Create `.context/knowledge/stack/[recipe].md` from TEMPLATE.md
   - Populate "What This Solves" and "Configuration" sections
   - If exists, PRESERVE entirely (Zone C)
3. **Dependency pins**: Update `.context/knowledge/dependencies/PINS.md`:
   - PRESERVE all existing entries (Zone C)
   - Append entries for major deps with detected versions
   - Only add pin reasons if evidence found (lockfile constraints, etc.)

### Phase 7: Enrich CLAUDE.md

1. Read current CLAUDE.md
2. PRESERVE all framework sections (Zone A)
3. If project-specific conventions were discovered that aren't covered by existing sections or skills, add a `## Project Conventions` section with `<!-- Last adapted: YYYY-MM-DD -->` marker
4. Keep additions minimal — prefer putting detail in skills and `.context/` rather than bloating CLAUDE.md
5. On re-run: update the marked section, don't duplicate

### Phase 8: Report

```
Adaptation complete.

## Inventory (before)
- Empty templates: [N] files
- Partially populated: [N] files
- Fully populated: [N] files

## Changes Made
- Skills populated: [list with brief description of what was added]
- CODE_PATTERNS.md: [N] patterns added
- ANTI_PATTERNS.md: [N] anti-patterns added
- Knowledge: [N] library files, [N] stack recipes created
- CLAUDE.md: [what was added, or "no changes needed"]

## Files Analyzed
~[N] source files sampled across [N] directories

## Skipped (already populated)
[list of files that were preserved as-is]

Next: Review the changes in .context/, then /research [topic] to begin work.
```

## Rules
- NEVER modify SKILL.md frontmatter `description` fields
- NEVER overwrite existing user-authored content in `.context/`
- NEVER touch CLAUDE.local.md
- NEVER populate MCP-only or meta skills
- Always use section markers (`<!-- Last adapted: YYYY-MM-DD -->`) for auto-generated content
- On re-run, update marked sections — never duplicate
- If a finding contradicts existing documented patterns, ask user to resolve
- Respect 300-line file limit — split into multiple entries if needed
- If context > 50% during full run, pause and suggest targeted runs
- Researcher must sample actual source files, not just config/package files

## User Input
$ARGUMENTS
