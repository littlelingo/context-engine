# /update-arch - Refresh Architecture Docs

Update `.context/architecture/` after significant codebase changes. Called by `/validate` when structural changes are detected, or manually after major refactors.

## When to Run
- After `/validate` detects architecture changes (new modules, renamed components, changed data flow)
- After `/refactor` completes a structural change
- Manually after adding/removing major dependencies or services
- Periodically after several features if architecture docs feel stale

## Process

1. **Delegate**: Use `researcher` agent to scan current structure and dependencies.
2. **Compare** with existing `.context/architecture/` files:
   - `OVERVIEW.md` - component map, data flow, integration points
   - `TECH_STACK.md` - languages, frameworks, versions, dev commands
   - `DIRECTORY_MAP.md` - annotated project tree
3. **Update incrementally** - don't rewrite from scratch. Keep files under 300 lines (per project code standards).
4. **Report** what changed:
   ```
   Architecture docs updated:
   - OVERVIEW.md: [what changed]
   - TECH_STACK.md: [what changed]
   - DIRECTORY_MAP.md: [what changed]
   ```

## Rules
- Preserve existing rationale and decisions.
- Mark removed components as deprecated rather than deleting docs.
- Update TECH_STACK.md dev commands if build/test/lint commands changed.

## User Input
$ARGUMENTS
