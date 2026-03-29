# /planner - Phase 2: Create Implementation Plan

No code in this phase. Create a PRP that guides implementation.

If no research exists, recommend `/research` first.

## Plan Mode

**Enter Plan mode immediately** using the `EnterPlanMode` tool before doing any work. This ensures the editor is in read-only planning mode so the user can review the plan before any files are written. All research and context loading happens in Plan mode. Exit Plan mode (via `ExitPlanMode`) only after the user approves the PRP in step 5.

## Process

1. **Enter Plan mode**: Use `EnterPlanMode` tool. All subsequent steps through step 5 are read-only exploration and planning.
2. **Load context**: Read `$ARGUMENTS` (research notes), plus `.context/architecture/OVERVIEW.md`, `.context/patterns/CODE_PATTERNS.md`, `.context/errors/INDEX.md`, and any relevant ADRs in `.context/decisions/` that relate to the feature area. If context files are mostly empty (normal after /init), proceed using research notes as primary context.
3. **MUST delegate**: Use the `planner` agent to create the PRP. The planner owns the PRP template. Follow `.claude/instructions/DELEGATION.md` delegation pattern.
4. **Review**: Verify file paths are specific, steps are ordered by dependency, validation criteria are runnable.
5. **Ask testing strategy**: "Testing strategy: [project default from CLAUDE.md]. Override? (y/N)". Only show full options if user says yes. Record choice in PRP's `## Testing Strategy:` field.
6. **Get approval and exit Plan mode**: Present PRP to user, iterate on feedback. Once approved, use `ExitPlanMode` tool to leave read-only mode and proceed with saving.
7. **Save**: Write PRP to the same feature directory as the research notes (e.g., `.context/features/[NNN]-[topic]/PRP.md`). Rename the directory if the feature name evolved during planning.
8. **Update PRP status** to `APPROVED`. Update `## Status:` field in the PRP.
9. **Checkpoint**: Create checkpoint `CP-NNN: post-plan [feature-name]` (trigger: phase-boundary). See `/checkpoint create` for the process - snapshot .context/ state and create git tag.
10. **Update feature index**: Add a row to `.context/features/FEATURES.md`:
   `| [NNN] | [feature-name] | APPROVED | [strategy] | .context/features/[NNN]-[name]/PRP.md | |`
11. **Reflect**: Capture any new decisions as `.context/decisions/ADR-NNN-[title].md` using the ADR-000-template.md format. Also capture new risks or patterns to `.context/patterns/`.
12. **Commit plan artifacts** (automatic — no user prompt): Stage and commit all `.context/` changes (PRP.md, FEATURES.md, checkpoint, ADRs, pattern updates) with `docs: plan [feature-name]`. These are framework bookkeeping, not user code — commit silently so artifacts survive branch creation, worktree spawns, and `/clear` + `/resume` cycles.
13. **Hand off**:
   ```
   PRP saved to: [path]
   Testing strategy: [choice]
   Next: /implement [path] (run /clear first if context > 50%)
   Proceed? (y/n)
   ```
   If yes: invoke `/implement` with the PRP path as the argument (use the Skill tool with skill="implement"). Remind about `/clear` first if context > 50%. If no: ask the user what they'd like to do instead.

## Rules
- No code. Planning only.
- Always enter Plan mode at start, exit after approval.
- Always confirm testing strategy before finalizing.
- Always hand off with the exact `/implement` command.
- If complexity is HIGH, break into multiple PRPs.
- Monitor context budget per CLAUDE.md thresholds.

## User Input
$ARGUMENTS
