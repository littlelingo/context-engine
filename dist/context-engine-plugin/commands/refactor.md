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

9. **After each step/track**: Full test suite must pass. If anything breaks, stop and fix.

10. **When complete**: Clean up team, then hand off:
   ```
   Refactor complete. All tests passing.
   Next: /validate [PRP path] (run /clear first if context > 50%)
   ```

## Rules
- Tests must pass BEFORE starting and AFTER every step.
- No feature additions during refactoring. Note them in NOTES.md.
- If scope expands beyond the plan, stop and revise with user.

## User Input
$ARGUMENTS
