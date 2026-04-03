# /plan-quick - Quick Plan for Small Tasks

Streamlined for bug fixes, single-file changes, minor improvements. Stays in one context.

## Process

1. **Safety checks**: Follow `.claude/instructions/SAFETY-CHECKS.md`. Exception: if the change is truly a one-liner (typo, string change), skip the branch requirement and commit directly.
2. **Understand**: Restate the request.
3. **MUST delegate**: Use `researcher` agent to scan relevant files (max 3-5).
4. **Propose**:
   ```
   ## Quick Plan: [Task]
   **Files**: [files to touch]
   **Approach**: [1-3 sentences]
   **Testing**: [project default from CLAUDE.md]
   **Validation**: [command]
   **Known Issues**: [from .context/errors/INDEX.md]
   Approve?
   ```
5. **Implement** after approval, following project testing strategy.
6. **Reflect**: Capture after completion using standard formats:
   - Errors -> `.context/errors/INDEX.md` (format: `### ERR-NNN: [desc]` with Signature, Cause, Fix, Prevention)
   - Patterns -> `.context/patterns/CODE_PATTERNS.md` (format: `### [Name]` with context, example, rationale)
   - Insights -> `.context/knowledge/LEARNINGS.md` (format: `### [Date] - [Topic]` with 2-3 sentence insight)
   For complex learnings, use `/learn [type]: [content]`.
7. **Record metrics**: Even quick plans produce data worth tracking.
   - If a FEATURES.md entry does not already exist for this task, append a lightweight row: `| [next NNN] | [task name] | [today] | [today] | quick | 1 | 1 | 0 |` with type `quick`.
   - Append a row to `.context/metrics/HEALTH.md` Knowledge Growth table if any learnings were captured in step 6.
   - Set the `Metrics` column in FEATURES.md to `AUTO`.

8. **Hand off**:
   ```
   Done. Suggest: fix/feat: [description]
   Commit + PR? (y / commit-only / skip)
   ```

## Rules
- LOW complexity only. If bigger than expected, switch to full `/planner`.
- MUST delegate to `researcher` for file exploration.
- Always reflect after implementation completes.

## User Input
$ARGUMENTS
