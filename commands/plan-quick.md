# /plan-quick - Quick Plan for Small Tasks

Streamlined for bug fixes, single-file changes, minor improvements. Stays in one context.

## Process

1. **Understand**: Restate the request.
2. **MUST delegate**: Use `researcher` agent to scan relevant files (max 3-5).
3. **Propose**:
   ```
   ## Quick Plan: [Task]
   **Files**: [files to touch]
   **Approach**: [1-3 sentences]
   **Testing**: [project default from CLAUDE.md]
   **Validation**: [command]
   **Known Issues**: [from .context/errors/INDEX.md]
   Approve?
   ```
4. **Implement** after approval, following project testing strategy.
5. **Reflect**: Capture errors, patterns, or insights to `.context/` after completion.
6. **Hand off**:
   ```
   Done. Suggest: fix/feat: [description]
   Commit + PR? (y / commit-only / skip)
   ```

## Rules
- LOW complexity only. If bigger than expected, switch to full `/plan`.
- MUST delegate to `researcher` for file exploration.
- Always reflect after implementation completes.

## User Input
$ARGUMENTS
