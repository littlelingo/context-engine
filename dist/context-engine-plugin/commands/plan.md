# /plan - Phase 2: Create Implementation Plan

No code in this phase. Create a PRP that guides implementation.

If no research exists, recommend `/research` first.

## Process

1. **Load context**: Read `$ARGUMENTS` (research notes), plus `.context/architecture/OVERVIEW.md`, `.context/patterns/CODE_PATTERNS.md`, `.context/errors/INDEX.md`
2. **MUST delegate**: Use the `planner` agent to create the PRP. The planner owns the PRP template.
3. **Review**: Verify file paths are specific, steps are ordered by dependency, validation criteria are runnable.
4. **Ask testing strategy**:
   ```
   Which testing strategy for this feature?
   1. test-first - TDD, tests before code
   2. implement-then-test - Code first, then tests
   3. tests-optional - Defer tests (spikes/prototypes)
   4. Use project default ([read from CLAUDE.md])
   ```
   Record choice in the PRP's `## Testing Strategy:` field.
5. **Get approval**: Present PRP to user, iterate on feedback.
6. **Save**: Write to `.context/features/[NNN]-[feature-name]/PRP.md`
7. **Checkpoint**: Create checkpoint `CP-NNN: post-plan [feature-name]` (trigger: phase-boundary). See `/checkpoint create` for the process - snapshot .context/ state and create git tag.
8. **Update feature index**: Add a row to `.context/features/FEATURES.md`:
   `| [NNN] | [feature-name] | PLANNING | [strategy] | .context/features/[NNN]-[name]/PRP.md |`
9. **Reflect**: Capture any new decisions (ADR), risks, or patterns discovered during planning.
10. **Hand off**:
   ```
   PRP saved to: [path]
   Testing strategy: [choice]
   Next: /clear then /implement [path]
   ```

## Rules
- No code. Planning only.
- Always ask user to choose testing strategy before finalizing.
- Always hand off with the exact `/implement` command.
- If complexity is HIGH, break into multiple PRPs.
- If context > 50%, save PRP and recommend `/clear`.

## User Input
$ARGUMENTS
