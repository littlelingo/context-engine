# /refactor - Refactor Existing Code

Restructure code without adding features. Uses Agent Team for multi-module refactors or single subagent for focused changes.

## Process

1. **Understand the goal**: Extract from `$ARGUMENTS`. Common types: extract module, consolidate duplicates, rename across codebase, upgrade pattern, split large file.

2. **Delegate to `researcher` subagent** to map scope:
   - Files affected, dependencies, existing test coverage.

3. **Create refactor plan** (lighter than full PRP) with:
   - Goal, scope (N files), risk level (LOW/MEDIUM/HIGH)
   - Tracks table: track name, files, owner (parallel where possible)
   - Steps with dependencies: `[ ] [step] - Track: [track] - Validate: [command]`
   - Safety: tests pass before starting and after each step

4. **Safety checks** (MUST pass before any changes):
   a. **Clean working tree**: If dirty, stop.
   b. **Tests pass**: If failing, stop - don't refactor broken code.
   c. **Correct branch**: If on `main`/`master`, create `refactor/[scope]` branch.

5. **Get approval**: Present plan to user. Iterate if needed.

6. **Save plan**: Write to `.context/features/[NNN]-refactor-[name]/PRP.md`. Update FEATURES.md.

7. **Checkpoint** (trigger: phase-boundary): Create checkpoint `CP-NNN: pre-refactor [scope]`. Snapshot .context/ state, tag current git state. This is the rollback point if the refactor breaks things.

8. **Execute**:
   - **Multi-track refactor** (3+ independent tracks): Create Agent Team.

     **Checkpoint**: Create checkpoint `CP-NNN: pre-refactor-team [scope]` ONLY if steps were completed since the last checkpoint.

     Create an agent team to execute the refactor plan at [PRP path].

     Spawn teammates per track:
     - Each teammate owns their specific files - no overlap
     - Testing strategy is always `implement-then-test` for refactors
     - Run full test suite after every step
     - Message other teammates when changing interfaces or types they depend on
     - If tests break, stop and fix before continuing

     Set up shared task list with dependencies from the plan.

   - **Single-track refactor**: Delegate to `implementer` subagent, one step at a time.

9. **After each step/track**: Full test suite must pass. If anything breaks with a non-obvious cause, run `/debug [failing test or error]` before continuing. For simple regressions, fix inline.

10. **Capture learnings** (MANDATORY — use formats from `.claude/instructions/CAPTURE-FORMAT.md`):
   - Structural decisions -> `.context/decisions/ADR-NNN-[title].md` if the refactor introduced a new architectural pattern
   - New code patterns -> `.context/patterns/CODE_PATTERNS.md`
   - Anti-patterns removed -> `.context/patterns/ANTI_PATTERNS.md` (mark as resolved or add prevention guidance)
   - Insights -> `.context/knowledge/LEARNINGS.md`
   - **Library quirks**: If you discovered non-obvious behavior during the refactor, create/update `.context/knowledge/libraries/[name].md`

11. **When complete**: Clean up team, then hand off:
   ```
   Refactor complete. All tests passing.

   Next step options:
     1. /validate [PRP path]  (recommended — full review + tests + metrics)
     2. commit                (skip review — learnings already captured, writes metrics first)
     3. pause                 (checkpoint and stop — resume later)

   Choose (1/2/3):
   ```
   - **Option 1** (validate): Invoke `/validate` with the PRP path as the argument (use the Skill tool with skill="validate"). Remind about `/clear` first if context > 50%.
   - **Option 2** (commit without validation): Learnings were captured in step 10. Before committing, you MUST still:
     1. **Write metrics** — append a row to `.context/metrics/HEALTH.md` Feature Velocity table with available data (mark review columns as `SKIPPED`). Update FEATURES.md status to `COMPLETE (unvalidated)`.
     2. **Then** generate a conventional commit message and prompt for commit + PR.
   - **Option 3** (pause): Create checkpoint `CP-NNN: paused-refactor [scope]`, leave status as IN_PROGRESS, and stop.

## Rules
- Tests must pass BEFORE starting and AFTER every step.
- No feature additions during refactoring. Note them in NOTES.md.
- If scope expands beyond the plan, stop and revise with user.
- If the refactor breaks more than it fixes, use `/checkpoint rollback CP-NNN` to restore pre-refactor state. The pre-refactor checkpoint exists for exactly this reason.

## User Input
$ARGUMENTS
