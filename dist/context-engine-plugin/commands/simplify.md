# /simplify - Standalone Simplification Review

Identify and apply code simplifications: dead code, duplication, over-abstraction, and consolidation opportunities. Use ad-hoc when you want a focused cleanup pass outside the `/validate` workflow.

## Process

1. **Determine scope** from `$ARGUMENTS`:
   - If file paths provided: review those specific files
   - If "recent" or no arguments: review uncommitted changes via `git diff` and `git diff --cached`
   - If a PRP path provided: review all files changed by that PRP
   - If a directory provided: scan all files in that directory

2. **Delegate to `reviewer` agent** with simplification-focused prompt:

   Run a simplification review on [scope]. Look for:
   - **Dead code**: Unused imports, unreachable branches, commented-out blocks, unused variables/functions
   - **Duplication**: Repeated logic that should be extracted, copy-paste patterns, similar functions that could be unified
   - **Over-abstraction**: Premature abstractions, unnecessary indirection layers, wrapper functions that just pass through, interfaces with single implementations
   - **Consolidation**: Related small files that could be merged, scattered utilities that belong together, configuration that could be centralized
   - **Complexity**: Functions that do too much (> 30 lines of logic), deeply nested conditionals, complex boolean expressions that could be named

   Also read `.context/patterns/CODE_PATTERNS.md` for project conventions on file size limits and structure.

3. **Present findings** ranked by impact:
   ```
   ## Simplification Review: [scope]
   **Files reviewed**: [N files]
   **Estimated reduction**: [lines/files that could be removed or consolidated]

   ### High Impact (significant cleanup)
   1. **[file:line]** - [what] -> [simplification]

   ### Medium Impact (cleaner code)
   1. **[file:line]** - [what] -> [simplification]

   ### Low Impact (minor polish)
   1. **[file:line]** - [what] -> [simplification]
   ```

4. **Offer to apply**: Ask user which simplifications to apply:
   - `all` — apply everything, re-run tests after
   - `high` — apply only high-impact items
   - `none` — just keep the report
   - `[N,N,N]` — apply specific numbered items

5. **If applying**: Make the changes, run tests to verify no regressions. If simplifications are too large (multi-file restructuring, module extraction), suggest `/refactor [scope]` instead.

6. **Capture learnings**: If simplifications reveal patterns worth preserving:
   - Add to `.context/patterns/ANTI_PATTERNS.md` (what to avoid next time)
   - Add to `.context/knowledge/LEARNINGS.md` (insights about code structure)

## Rules
- Every suggestion must include a concrete "before -> after" or specific action.
- Don't suggest changes that alter behavior — simplification is refactoring, not feature work.
- Respect the project's 300-line file limit from CODE_PATTERNS.md.
- Run tests after applying any changes.
- If scope is large enough to warrant a plan, suggest `/refactor` instead.

## User Input
$ARGUMENTS
