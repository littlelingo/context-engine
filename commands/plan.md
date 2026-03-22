# /plan - Phase 2: Create Implementation Plan

No code in this phase. Create a PRP that guides implementation.

If no research exists, recommend `/research` first.

## Process

1. **Load context**: Read `$ARGUMENTS` (research notes), plus `.context/architecture/OVERVIEW.md`, `.context/patterns/CODE_PATTERNS.md`, `.context/errors/INDEX.md`
2. **MUST delegate**: Use the `planner` agent to create the PRP. The planner owns the PRP template.
3. **Review**: Verify file paths are specific, steps are ordered by dependency, validation criteria are runnable.
4. **Ask testing strategy**: "Testing strategy: [project default from CLAUDE.md]. Override? (y/N)". Only show full options if user says yes. Record choice in PRP's `## Testing Strategy:` field.
5. **Get approval**: Present PRP to user, iterate on feedback.
6. **Save**: Write PRP to the same feature directory as the research notes (e.g., `.context/features/[NNN]-[topic]/PRP.md`). Rename the directory if the feature name evolved during planning.
7. **Update PRP status** to `APPROVED`. Update `## Status:` field in the PRP.
8. **Checkpoint**: Create checkpoint `CP-NNN: post-plan [feature-name]` (trigger: phase-boundary). See `/checkpoint create` for the process - snapshot .context/ state and create git tag.
9. **Update feature index**: Add a row to `.context/features/FEATURES.md`:
   `| [NNN] | [feature-name] | APPROVED | [strategy] | .context/features/[NNN]-[name]/PRP.md |`
10. **Reflect**: Capture any new decisions (ADR), risks, or patterns discovered during planning.
11. **Hand off**:
   ```
   PRP saved to: [path]
   Testing strategy: [choice]
   Next: /implement [path] (run /clear first if context > 50%)
   ```

## Rules
- No code. Planning only.
- Always confirm testing strategy before finalizing.
- Always hand off with the exact `/implement` command.
- If complexity is HIGH, break into multiple PRPs.
- Monitor context budget per CLAUDE.md thresholds.

## User Input
$ARGUMENTS
