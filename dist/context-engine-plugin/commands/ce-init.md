# /ce-init - Initialize Context Engine

Bootstrap the context engineering system. Run this first on any new or existing project. Analyzes the codebase and populates `.context/`.

## Process

1. **Check existing**: If `.context/` exists, ask whether to refresh or skip.
2. **Create structure**: `.context/{architecture,features,patterns,decisions,errors/detail,knowledge}`
3. **Delegate**: Use `researcher` agent to scan the project:
   - Directory structure (top 3 levels)
   - Tech stack (languages, frameworks, package managers)
   - Config files (package.json, pyproject.toml, etc.)
   - Test/lint/format/type-check commands
4. **Generate docs**:
   - `OVERVIEW.md` - system architecture
   - `TECH_STACK.md` - languages, frameworks, versions, commands
   - `DIRECTORY_MAP.md` - annotated project tree
   - `CODE_PATTERNS.md` - initial patterns from existing code
   - `ANTI_PATTERNS.md`, `INDEX.md`, `LEARNINGS.md` - empty templates
   - `FEATURES.md` - empty feature index
5. **Populate skills** based on what the researcher found:
   - If test files detected: populate `skills/testing-conventions/SKILL.md` with detected test framework, file naming, structure patterns
   - If API/route files detected: populate `skills/api-conventions/SKILL.md` with detected patterns for routes, middleware, error handling
   - If neither detected, leave skills as skeletons - they'll grow through auto-learning
6. **Configure testing strategy**: Ask the user:
   ```
   What should be the default testing strategy for this project?
   1. test-first - TDD, write tests before code
   2. implement-then-test - Code first, then tests (recommended default)
   3. tests-optional - Defer tests (for prototyping projects)
   ```
   Update CLAUDE.md's `**Default**:` line with their choice.
7. **Verify** with user and correct as needed.
8. **Report**:
   ```
   Context Engine initialized.

   Detected: [tech stack], Test: [cmd], Lint: [cmd]
   Testing strategy: [choice]
   Skills populated: [testing-conventions, api-conventions, or "none - will grow via auto-learning"]
   Run /ce-research [topic] to begin.
   ```

## User Input
$ARGUMENTS
