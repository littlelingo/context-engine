# /plan-quick - Quick Plan for Small Tasks

Streamlined for bug fixes, single-file changes, minor improvements. Stays in one context.

## Process

1. **Understand**: Restate the request.
2. **MUST delegate**: Use `researcher` agent to scan relevant files (max 3-5).
3. **Check** `.context/errors/INDEX.md` for related known issues.
4. **Propose**:
   ```
   ## Quick Plan: [Task]
   **Files**: [files to touch]
   **Approach**: [1-3 sentences]
   **Testing**: [project default] - change? (test-first / implement-then-test / tests-optional)
   **Validation**: [command]
   **Known Issues**: [from .context/errors/]
   Approve?
   ```
5. **Implement** after approval, following chosen strategy.
6. **Reflect**: Capture errors, patterns, or insights to `.context/` after completion.

## Rules
- LOW complexity only. If bigger than expected, switch to full `/plan`.
- MUST delegate to `researcher` for file exploration.
- Always reflect after implementation completes.

## User Input
$ARGUMENTS
