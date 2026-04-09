# /adapt - Adapt Project to Plugin Standards

Audit the project against the plugin's prescribed standards and refactor the project to conform. Run after `/init` to identify gaps, then apply fixes per dimension.

`/adapt` does **two** things:
1. **Populate** architecture and patterns documentation from the actual codebase (Phase 0). This is the back-fill step that closes gaps left by `/init` — historically `/init` produced thin or empty `architecture/*.md` and `patterns/*.md` files, and `/adapt` is what makes them real.
2. **Audit** the codebase against plugin standards and report violations (Phases 1–4).

By default (`/adapt` with no args) Phase 0 runs automatically before the audit, but only writes to files that are missing, empty, or stub-only. Files with substantive content are never overwritten unless `/adapt populate force` is invoked.

## Prerequisites
- `.context/` must exist (run `/init` first)
- The seeder (`init-templates.sh`) must have placed canonical stub templates. If `/init verify` reports gaps, run `/init repair` first.

## Scope

Parse `$ARGUMENTS`:
- `/adapt` — Phase 0 (populate thin files) + full audit across all dimensions
- `/adapt populate` — Phase 0 only (populate architecture + patterns from codebase, no audit)
- `/adapt populate force` — Phase 0 with overwrite of existing populated files. **DANGEROUS** — confirms first.
- `/adapt audit` — full audit only, skip Phase 0 (use when architecture/patterns are already correct)
- `/adapt [dimension]` — Phase 0 + audit one dimension only
- `/adapt apply [dimension]` — execute fixes for a dimension
- `/adapt apply all` — execute fixes for all dimensions (confirm each)

Dimensions: `structure`, `docs`, `quality`, `testing`, `security`, `devops`

## Phase 0: Populate Architecture and Patterns from Codebase

**Runs automatically before the audit unless `/adapt audit` is specified.** Also runs standalone via `/adapt populate`.

### When this runs

For each of the following files, classify its current state as **empty**, **stub-only**, or **populated**:

| File | Empty | Stub-only | Populated |
|---|---|---|---|
| `architecture/OVERVIEW.md` | 0 bytes or missing | < 25 lines, only headers and HTML comments, no project-specific text | Has system description, components, or data flow |
| `architecture/TECH_STACK.md` | 0 bytes or missing | < 20 lines, dev command rows still contain `[command]` placeholders | Lists at least one detected language and has populated dev commands |
| `architecture/DIRECTORY_MAP.md` | 0 bytes or missing | < 5 directory entries from the actual project | Annotated tree with real project paths |
| `patterns/CODE_PATTERNS.md` | 0 bytes or missing | Only the canonical headings, no entries under any heading | Has at least one entry under at least one heading |
| `patterns/ANTI_PATTERNS.md` | 0 bytes or missing | Only canonical headings | Has at least one entry OR a comment noting "no anti-patterns observed yet" |

A file is considered **needing population** if it is empty or stub-only. A populated file is left alone (preserve user edits).

### Process

1. **Scan target files** above and bucket them as empty / stub-only / populated. Report the bucket counts.
2. **If everything is populated** and the user invoked `/adapt` (not `/adapt populate force`), report "All architecture and patterns files already populated — skipping Phase 0" and proceed to Phase 1.
3. **Delegate to researcher** with this exact mandate:
   > Read the project's source tree, package manifests (package.json, pyproject.toml, Cargo.toml, go.mod, Gemfile, etc.), config files (tsconfig, eslint, ruff, etc.), test files, and 15–20 sample source files spanning the major directories. From this evidence, produce concrete content for the following files. Each output must be substantive — no placeholders, no `[fill in]` markers, no HTML comments asking the next reader to populate something.
   >
   > **Files to produce content for** (only those marked needing population in the bucketing step):
   > - `OVERVIEW.md`: 2-3 sentence system description, component map (a list or simple ASCII diagram of the main modules and how they relate), data flow (how requests/data move through), integration points (databases, APIs, external services), constraints (any performance/security/scaling limits visible in code or configs).
   > - `TECH_STACK.md`: Languages and frameworks with versions from manifests. Fully populated dev commands table — find the actual `test`, `lint`, `format`, `type-check`, `build`, `dev` commands by reading package.json scripts, Makefile, justfile, pyproject.toml `[tool.*]`, CI workflows, etc.
   > - `DIRECTORY_MAP.md`: Annotated tree of the top 2-3 levels of the actual project structure with one-line descriptions per significant directory (what lives there, what its responsibility is).
   > - `CODE_PATTERNS.md`: Real conventions observed in the code under the headings (Naming, File Organization, Error Handling, Testing, API Patterns). Cite specific files as evidence (e.g., "snake_case for Python modules — see backend/app/services/import_commit.py"). Only document patterns you can point to; do not invent.
   > - `ANTI_PATTERNS.md`: Real anti-patterns observed during sampling (with file:line evidence). If none observed, leave the file as the stub. Do not invent anti-patterns.
   >
   > Return the content of each file as a separate block. Do not write the files yourself — the lead agent will write them after review.

4. **Review the researcher output** for plausibility:
   - Does each file mention the actual project (not generic content)?
   - Are dev commands real (matched to files like package.json scripts)?
   - Is the directory map sourced from the real tree?
   - Reject and re-delegate if the output looks hallucinated or generic.

5. **Write the files**:
   - For files in the **needs population** bucket: write the new content, replacing the stub.
   - For files NOT in the bucket (already populated): leave alone.
   - For `populate force`: write all files, but show a per-file diff first and require confirmation.

6. **Re-verify**: Run the same bucketing as step 1. Every previously-thin file should now be in the populated bucket. If any are still thin, that's a bug — report and stop.

7. **Report**:
   ```
   Phase 0 — Populate Architecture & Patterns
     OVERVIEW.md:       [populated/preserved/skipped]
     TECH_STACK.md:     [populated/preserved/skipped]
     DIRECTORY_MAP.md:  [populated/preserved/skipped]
     CODE_PATTERNS.md:  [populated/preserved/skipped]
     ANTI_PATTERNS.md:  [populated/preserved/skipped]

   Status: [N populated, M preserved, K still thin]
   ```

   If invoked as `/adapt populate` standalone: stop here.
   If invoked as part of `/adapt`: continue to Phase 1.

## Audit Dimensions

Dimensions: `structure`, `docs`, `quality`, `testing`, `security`, `devops`

## Audit Dimensions

### Dimension 1: Structure
**Standards**: CLAUDE.md (300-line limit), python-backend/SKILL.md (directory layout), react-frontend/SKILL.md (colocation), CODE_PATTERNS.md (file organization)

Check:
- Files exceeding 300 lines — propose specific split points based on logical groupings
- Directory structure matches tech-stack conventions (e.g., Python: api/, models/, services/, schemas/, utils/)
- Colocation of tests, styles, types where prescribed
- Import/export patterns match conventions

### Dimension 2: Documentation
**Standards**: CLAUDE.md (public functions need docstrings/JSDoc), api-conventions/SKILL.md

Check:
- Public functions/methods missing docstrings (Python) or JSDoc (TypeScript)
- Exported utility functions without documentation
- Missing module-level docstrings
- Route handlers without docstrings describing the endpoint

### Dimension 3: Code Quality
**Standards**: ANTI_PATTERNS.md, python-backend/SKILL.md, react-frontend/SKILL.md, CODE_PATTERNS.md

Check:
- Naming convention violations per language (snake_case for Python, camelCase for JS/TS)
- Missing type hints on function signatures (Python) or loose TypeScript config
- Anti-patterns: N+1 queries, bare except, circular imports, useEffect as event handler, mutating state directly
- Error handling gaps: swallowed errors, missing error boundaries, inconsistent HTTP status usage

### Dimension 4: Testing
**Standards**: testing-conventions/SKILL.md, CLAUDE.md (testing strategy)

Check:
- Testing strategy declared in CLAUDE.md
- Source modules with no corresponding test file
- Test structure matches convention (describe/it, arrange-act-assert)
- Mocking approach consistency (real DB vs mocks)

### Dimension 5: Security
**Standards**: auth-security/SKILL.md (OWASP, input validation, token handling)

Check:
- Input validation at API boundaries
- Parameterized queries (no string interpolation in SQL)
- Auth patterns (httpOnly cookies, token validation)
- Secrets management (.env in .gitignore, no hardcoded secrets)
- Error messages that leak internals
- File upload validation (MIME type, size limits)

### Dimension 6: DevOps
**Standards**: deployment-cicd/SKILL.md, git-workflow/SKILL.md

Check:
- Docker: multi-stage builds, pinned base images, non-root user, .dockerignore
- CI pipeline: correct stage ordering (lint -> type-check -> test -> build -> deploy)
- Conventional commits in recent history
- Branch naming convention compliance
- Dev-only flags in production configs (e.g., --reload)

## Process

### Phase 1: Load Standards

After Phase 0 has populated (or preserved) architecture/patterns files, this phase loads them as inputs to the audit.

1. **Verify framework prerequisites**:
   - Check `.claude/instructions/` exists and contains: `MEMORY-PATH.md`, `CAPTURE-FORMAT.md`, `TESTING-STRATEGY.md`, `SAFETY-CHECKS.md`, `DELEGATION.md`. If any are missing, report as **CRITICAL** finding: "Missing shared instruction files — agents and commands reference these but they don't exist. Fix: re-run `/init` or copy from plugin source."
   - Run `${CLAUDE_PLUGIN_ROOT}/hooks/scripts/init-templates.sh verify .` and report any MISSING/EMPTY template files as **CRITICAL** with the fix: "Run `/init repair`."
2. Read CLAUDE.md for framework-level standards
3. Read `.context/architecture/TECH_STACK.md` to determine which skills apply (Phase 0 populated this if it was thin)
4. Read relevant skills based on detected stack:
   - Python detected → python-backend/SKILL.md, database-migrations/SKILL.md
   - React/TS detected → react-frontend/SKILL.md
   - Always: auth-security, deployment-cicd, git-workflow, testing-conventions, api-conventions
   - If Postgres detected → postgres/SKILL.md
5. Read CODE_PATTERNS.md and ANTI_PATTERNS.md for project-specific standards already captured
6. Compile concrete checklist of rules to verify

### Phase 2: Audit
Delegate to `researcher` agent with the compiled standards checklist.

The researcher must:
- Sample **actual source files** (15-20 minimum across directories), not just configs
- For each dimension in scope, systematically check each standard
- Report violations with **exact file paths and line numbers**
- For file-size violations: read the file and propose concrete split points based on logical groupings (e.g., "split at line 180 — methods above handle CRUD, methods below handle queries")
- For missing docs: identify specific public functions by name and location
- For anti-patterns: show the violating code location and the prescribed alternative
- For missing tests: list which source modules lack test files
- For security: trace data flow from input to use for injection risks

Researcher output format — one section per dimension, each finding:
```
**[SEVERITY]** [file:line] — [violation description]
Standard: [which skill/doc prescribes this]
Fix: [specific, actionable remediation]
```

Severity levels:
- **CRITICAL**: Security vulnerabilities, data loss risks
- **HIGH**: Anti-patterns, files >500 lines, missing input validation
- **MEDIUM**: Files 300-500 lines, missing docstrings on important functions, naming violations
- **LOW**: Style inconsistencies, missing docs on internal helpers, minor convention drift

### Phase 3: Report

Present the gap report:

```
## Adaptation Audit: [project name]
**Tech Stack**: [from TECH_STACK.md]
**Files Sampled**: ~[N] across [N] directories
**Standards Checked**: [N] rules from [N] skills

### Summary
| Dimension    | Critical | High | Medium | Low | Status |
|--------------|----------|------|--------|-----|--------|
| Structure    |          |      |        |     | PASS/GAPS |
| Documentation|          |      |        |     | PASS/GAPS |
| Code Quality |          |      |        |     | PASS/GAPS |
| Testing      |          |      |        |     | PASS/GAPS |
| Security     |          |      |        |     | PASS/GAPS |
| DevOps       |          |      |        |     | PASS/GAPS |

### [Dimension] Findings
[Per-dimension findings grouped by severity, each with file:line, violation, standard, and fix]

### Recommended Order
1. [dimension] — [reason, e.g., "2 critical security findings"]
2. [dimension] — [reason]
...

Next: `/adapt apply [dimension]` to fix a category.
Proceed? (y/n)
```
If yes: invoke `/adapt` with `apply [dimension]` as the argument (use the Skill tool with skill="adapt"). If no: ask the user what they'd like to do instead.

### Phase 4: Apply

Only runs when `/adapt apply [dimension]` is invoked.

1. **Safety checks**: Follow `.claude/instructions/SAFETY-CHECKS.md`
   If on main/master, create `refactor/adapt-[dimension]` branch.

2. **Generate lightweight PRP**:
   - Extract findings for the selected dimension from the audit
   - Group into logical steps (e.g., "split oversized files" is one step per file, "add docstrings to services/" is one step)
   - Write PRP to `.context/features/[NNN]-adapt-[dimension]/PRP.md`
   - Update FEATURES.md with the adaptation entry
   - Testing strategy: `implement-then-test`

3. **Delegate execution**:
   - Structure changes (file splits, directory reorganization) → delegate to `/refactor`
   - Documentation additions (docstrings, JSDoc) → delegate to `implementer` agent
   - Code quality fixes (type hints, naming, anti-patterns) → delegate to `/refactor`
   - Testing gaps (new test files) → delegate to `implementer` agent
   - Security fixes → delegate to `/refactor` with caution
   - DevOps changes (Dockerfile, CI config) → delegate to `implementer` agent

4. **Post-apply**:
   - Run full test suite
   - Report what was changed
   - Suggest `/validate [PRP path]`

## Integrity Zones

- **Zone A — IMMUTABLE**: `.context/` framework structure, SKILL.md frontmatter descriptions. Never modify.
- **Zone B — SAFE TO MODIFY**: Project source code that violates plugin standards. This is the whole point of `/adapt apply`.
- **Zone C — PRESERVE**: Business logic substance — adapt the form (naming, types, structure, docs) without changing what the code does.
- **Zone D — NEVER TOUCH**: .env files, secrets, vendor/third-party code, generated code, lock files, CLAUDE.local.md.

## Rules
- Phase 0 (populate) writes to `.context/architecture/*` and `.context/patterns/*` only. It NEVER modifies project source code.
- Phase 0 only writes to files that are empty or stub-only — populated files are preserved unless `populate force` is invoked.
- Audit mode is ALWAYS read-only — never modify project files during audit
- Apply mode requires explicit invocation (`/adapt apply [dimension]`)
- Every finding must include file path, line number, the specific standard violated, and a concrete fix
- Apply mode creates a branch — never modify code on main/master
- Tests must pass before and after every apply operation
- If apply breaks tests, stop and suggest `/debug` or `/checkpoint rollback`
- For `/adapt apply all`: confirm each dimension with the user before proceeding
- Delegate structural refactoring to `/refactor` — reuse existing infrastructure
- CRITICAL security findings should be resolved first — warn the user
- Safe to run `/adapt` (audit) multiple times — regenerates report from scratch
- If context > 50% during full audit, suggest targeted dimension audits
- Preserve business logic substance — adapt form, not function

## User Input
$ARGUMENTS
