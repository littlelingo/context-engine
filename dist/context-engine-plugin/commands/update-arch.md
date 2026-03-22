# /update-arch - Refresh Architecture Docs

Update `.context/architecture/` after significant codebase changes.

## Process

1. **Delegate**: Use `researcher` agent to scan current structure and dependencies.
2. **Compare** with existing `.context/architecture/` files.
3. **Update incrementally** - don't rewrite from scratch. Keep files under 150 lines.
4. **Report** what changed.

## Rules
- Preserve existing rationale and decisions.
- Mark removed components as deprecated rather than deleting docs.

## User Input
$ARGUMENTS
