# /init - Initialize Context Engine

Bootstrap the context engineering system. Run this first on any new or existing project. Analyzes the codebase and populates `.context/`.

## Process

1. **Check existing**: If `.context/` exists, ask whether to refresh or skip.
2. **Create structure**:
   ```
   .context/
   ├── architecture/
   ├── patterns/
   ├── decisions/
   ├── errors/detail/
   ├── features/
   ├── knowledge/
   │   ├── libraries/
   │   ├── stack/
   │   └── dependencies/
   ├── checkpoints/
   └── metrics/
   ```
3. **Copy templates** into the structure:
   - `decisions/ADR-000-template.md` - architecture decision record template
   - `errors/detail/.gitkeep` - placeholder for detailed error analysis
   - `features/.gitkeep` - placeholder for feature directories
   - `knowledge/libraries/TEMPLATE.md` - per-library quirks template
   - `knowledge/stack/TEMPLATE.md` - integration recipe template
   - `knowledge/dependencies/PINS.md` - version pins and upgrade blockers
   - `checkpoints/MANIFEST.md` - checkpoint registry
   - `metrics/HEALTH.md` - framework health metrics
   - `metrics/RECOMMENDATIONS.md` - signal→recommendation lookup
4. **Delegate**: Use `researcher` agent to scan the project:
   - Directory structure (top 3 levels)
   - Tech stack (languages, frameworks, package managers)
   - Config files (package.json, pyproject.toml, etc.)
   - Test/lint/format/type-check commands
5. **Generate docs** (all paths relative to `.context/`):
   - `architecture/OVERVIEW.md` - system architecture
   - `architecture/TECH_STACK.md` - languages, frameworks, versions, commands
   - `architecture/DIRECTORY_MAP.md` - annotated project tree
   - `patterns/CODE_PATTERNS.md` - initial patterns from existing code
   - `patterns/ANTI_PATTERNS.md` - empty template (grows via auto-learning)
   - `errors/INDEX.md` - empty template (grows via `/debug` and `/validate`)
   - `knowledge/LEARNINGS.md` - empty template (grows via `/implement` and `/debug`)
   - `features/FEATURES.md` - empty feature index
6. **Generate CLAUDE.md**:
   - Start with the context-engine CLAUDE.md as the base template (provides: Project Knowledge table, Workflow, Testing Strategy, Code Standards, Context Management, Hooks, Auto-Learning, Skills sections)
   - Update with project-specific findings from the researcher: project name, detected tech stack, test/lint/build commands, any project-specific conventions discovered
   - If a CLAUDE.md already exists in the target project, merge its content — preserve any project-specific rules, preferences, or notes the user has added. Don't overwrite, integrate.
   - Review and optimize the merged result — remove duplicates, ensure `.context/` paths are correct, tighten language, verify no contradictions between base template and project-specific content
   - The result should be a meaty, actionable CLAUDE.md — not a stub
7. **Populate skills** based on what the researcher found:
   - If test files detected: populate `skills/testing-conventions/SKILL.md` with detected test framework, file naming, structure patterns
   - If API/route files detected: populate `skills/api-conventions/SKILL.md` with detected patterns for routes, middleware, error handling
   - If neither detected, leave skills as skeletons - they'll grow through auto-learning
8. **Configure testing strategy**: Ask the user:
   ```
   What should be the default testing strategy for this project?
   1. test-first - TDD, write tests before code
   2. implement-then-test - Code first, then tests (recommended default)
   3. tests-optional - Defer tests (for prototyping projects)
   ```
   Update CLAUDE.md's `**Default**:` line with their choice.
9. **Verify** with user and correct as needed.
10. **Report**:
   ```
   Context Engine initialized.

   Detected: [tech stack], Test: [cmd], Lint: [cmd]
   Testing strategy: [choice]
   Skills populated: [testing-conventions, api-conventions, or "none - will grow via auto-learning"]
   Run /research [topic] to begin.
   ```

## User Input
$ARGUMENTS
