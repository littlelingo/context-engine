# /init - Initialize Context Engine

Bootstrap the context engineering system. Run this first on any new or existing project. Analyzes the codebase and populates `.context/`.

## Subcommands

Parse `$ARGUMENTS`:
- `/init` (no args) — full initialization (default).
- `/init verify` — check that `.context/` is fully populated; report any 0-byte or missing files. Read-only.
- `/init repair` — re-seed any missing/empty template-managed files from the bundled templates. **Never overwrites populated files.** Use this after a plugin update or when `/init verify` reports gaps.
- `/init force` — overwrite ALL template-managed files from the bundled templates. **DANGEROUS** — confirms first. Only use to deliberately reset.

For `verify`, `repair`, and `force`, run **only** the corresponding template script invocation below and stop. Do not run the full init flow.

## Process (full `/init`)

1. **Check existing**: If `.context/` exists, ask whether to refresh or skip. If skip, proceed only with `/init verify` to confirm health.
2. **Create structure**: Use the deterministic template seeder. This is the **mandatory first step** — never skip and never substitute LLM-written file creation:
   ```
   ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/init-templates.sh seed .
   ```
   This script copies all canonical stubs from the bundled `context-templates/` into `.context/`. It is idempotent — existing populated files are preserved. If the script reports any "source-missing" files, stop and report a plugin installation problem.

3. **Create shared instructions**: Ensure `.claude/instructions/` exists with the 5 framework instruction files referenced by agents and commands:
   - `MEMORY-PATH.md` - agent memory conventions
   - `CAPTURE-FORMAT.md` - learnings capture format
   - `TESTING-STRATEGY.md` - testing strategy resolution
   - `SAFETY-CHECKS.md` - branch and safety checks
   - `DELEGATION.md` - agent delegation patterns
   These are framework-defined files (not project-specific). If the plugin installed them, they already exist — skip. If running `/init` standalone, copy them from `${CLAUDE_PLUGIN_ROOT}/instructions/`.

4. **Delegate research**: Use `researcher` agent to scan the project:
   - Directory structure (top 3 levels)
   - Tech stack (languages, frameworks, package managers)
   - Config files (package.json, pyproject.toml, etc.)
   - Test/lint/format/type-check commands
   - Initial code patterns (naming conventions, file organization, error handling style) observable in 10–20 sample files

5. **Populate architecture and patterns** from researcher findings. **Each of these files MUST end up with substantive content — not just stub headers.** The seeder placed canonical stubs; this step replaces them with project-specific content.
   - `.context/architecture/OVERVIEW.md` — system description, component map, data flow, integration points, constraints
   - `.context/architecture/TECH_STACK.md` — languages, frameworks, versions, **fully populated dev commands table** (install, test, lint, format, type-check, build, dev server)
   - `.context/architecture/DIRECTORY_MAP.md` — annotated tree of the actual project structure
   - `.context/patterns/CODE_PATTERNS.md` — at minimum: naming conventions, file organization, error handling, testing patterns, and API patterns observed in this codebase
   - `.context/patterns/ANTI_PATTERNS.md` — leave the section headings (the seeder placed them); only add entries if real anti-patterns are observed in the audit. Do not invent.

6. **Generate skill profile**: Based on the detected tech stack, write `.context/architecture/.skill-profile.json` mapping detected languages/frameworks to relevant skills. This enables runtime skill filtering.
   ```json
   {
     "detected_stack": ["python", "fastapi", "react", "typescript"],
     "relevant_skills": ["python-backend", "react-frontend", "api-conventions", ...],
     "irrelevant_skills": ["ruby", "redis", ...]
   }
   ```
   Use this mapping: Python→python-backend, JS/TS→react-frontend, Ruby→ruby, Go/Rust→deployment-cicd, SQL/Postgres→postgres+postgres-mcp+database-migrations, Redis→redis, Docker→deployment-cicd. Always include: context-system, knowledge-base, prompt-efficiency, testing-conventions, git-workflow, auth-security, mcp-tools, context7-docs, sequential-thinking.

7. **Generate CLAUDE.md**:
   - Start with the context-engine CLAUDE.md as the base template (provides: Project Knowledge table, Workflow, Testing Strategy, Code Standards, Context Management, Hooks, Auto-Learning, Skills sections)
   - Update with project-specific findings from the researcher: project name, detected tech stack, test/lint/build commands, any project-specific conventions discovered
   - If a CLAUDE.md already exists in the target project, merge its content — preserve any project-specific rules, preferences, or notes the user has added. Don't overwrite, integrate.
   - Review and optimize the merged result — remove duplicates, ensure `.context/` paths are correct, tighten language, verify no contradictions between base template and project-specific content
   - The result should be a meaty, actionable CLAUDE.md — not a stub

8. **Populate skills** based on what the researcher found:
   - If test files detected: populate `skills/testing-conventions/SKILL.md` with detected test framework, file naming, structure patterns
   - If API/route files detected: populate `skills/api-conventions/SKILL.md` with detected patterns for routes, middleware, error handling
   - If neither detected, leave skills as skeletons - they'll grow through auto-learning

9. **Configure testing strategy**: Ask the user:
   ```
   What should be the default testing strategy for this project?
   1. test-first - TDD, write tests before code
   2. implement-then-test - Code first, then tests (recommended default)
   3. tests-optional - Defer tests (for prototyping projects)
   ```
   Update CLAUDE.md's `**Default**:` line with their choice.

10. **Verify everything landed** — this step is **mandatory** and **non-skippable**. Run:
    ```
    ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/init-templates.sh verify .
    ```
    If verify reports any MISSING or EMPTY files, immediately re-run the seeder (`init-templates.sh repair .`) and re-verify. After seeder repair, **also re-check** that the architecture/patterns files from step 5 still have non-stub content (the seeder won't overwrite them, but if they were never written, this is your last chance to fix it).

    Then sanity-check the architecture files contain real content, not just the stub headers:
    - `architecture/OVERVIEW.md` should be > 25 lines and mention the project name
    - `architecture/TECH_STACK.md` should list at least one detected language and have populated dev command rows
    - `architecture/DIRECTORY_MAP.md` should contain at least 5 directory entries from the actual project
    - `patterns/CODE_PATTERNS.md` should have at least one real entry under at least one heading

    If any of these checks fail, report the gap to the user and re-delegate to the researcher to fill it in. Do not declare init complete with thin architecture docs — that is the bug this verification block exists to prevent.

11. **Report**:
    ```
    Context Engine initialized.

    Detected: [tech stack], Test: [cmd], Lint: [cmd]
    Testing strategy: [choice]
    Skills populated: [testing-conventions, api-conventions, or "none - will grow via auto-learning"]
    Templates: [N seeded, M preserved] (from init-templates.sh)
    Architecture: [populated / partial — list any gaps]

    Recommended: /adapt (audit project against standards)
    Or: /research [topic] to begin a feature.
    ```

## Process (`/init verify`)

Run **only** this and report results:
```
${CLAUDE_PLUGIN_ROOT}/hooks/scripts/init-templates.sh verify .
```
Then additionally check the substance of architecture/patterns files (same checks as step 10 above) and report any thin/stub-only files. Recommend `/init repair` (for missing template files) or `/adapt` (to populate architecture from real code) as appropriate.

## Process (`/init repair`)

Run **only** this:
```
${CLAUDE_PLUGIN_ROOT}/hooks/scripts/init-templates.sh repair .
```
Then run verify and report. If architecture/patterns files are still thin after repair, recommend `/adapt` to populate them from actual code (the seeder only restores stubs — `/adapt` does the real population).

## Process (`/init force`)

Run **only** this and let the script's confirmation prompt gate the destructive overwrite:
```
${CLAUDE_PLUGIN_ROOT}/hooks/scripts/init-templates.sh force .
```

## Rules
- Step 2 (seeder) is the FIRST operation and is non-negotiable. Never create `.context/` files via Write/Edit when the seeder can do it deterministically.
- Step 10 (verify) is the LAST operation before reporting and is non-negotiable. If verify fails, init is not complete.
- The seeder NEVER overwrites populated files (unless `force` is invoked with explicit confirmation). Running `/init` on an existing project is safe.
- Architecture and patterns files in step 5 must contain real content. Stubs from the seeder are placeholders, not the final state.

## User Input
$ARGUMENTS
