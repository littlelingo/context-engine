# /adapt - Adapt Project to Plugin Standards

Audit the project against the plugin's prescribed standards and refactor the project to conform. Run after `/init` to identify gaps, then apply fixes per dimension.

Default mode is **audit** (read-only gap analysis). Use `/adapt apply [dimension]` to execute fixes.

## Prerequisites
- `.context/` must exist (run `/init` first)
- `.context/architecture/TECH_STACK.md` should be populated (by `/init`)

## Scope

Parse `$ARGUMENTS`:
- `/adapt` — full audit across all dimensions (read-only)
- `/adapt [dimension]` — audit one dimension only
- `/adapt apply [dimension]` — execute fixes for a dimension
- `/adapt apply all` — execute fixes for all dimensions (confirm each)

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
1. Read CLAUDE.md for framework-level standards
2. Read `.context/architecture/TECH_STACK.md` to determine which skills apply
3. Read relevant skills based on detected stack:
   - Python detected → python-backend/SKILL.md, database-migrations/SKILL.md
   - React/TS detected → react-frontend/SKILL.md
   - Always: auth-security, deployment-cicd, git-workflow, testing-conventions, api-conventions
   - If Postgres detected → postgres/SKILL.md
4. Read CODE_PATTERNS.md and ANTI_PATTERNS.md for project-specific standards already captured
5. Compile concrete checklist of rules to verify

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
```

### Phase 4: Apply

Only runs when `/adapt apply [dimension]` is invoked.

1. **Safety checks** (same as `/refactor`):
   a. Clean working tree — if dirty, stop
   b. Tests pass — if failing, stop
   c. Correct branch — if on main/master, create `refactor/adapt-[dimension]` branch

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
