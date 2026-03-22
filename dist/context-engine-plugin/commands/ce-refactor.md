# /ce-refactor - Refactor Existing Code

Restructure code without adding features. Uses Agent Team for multi-module refactors or single subagent for focused changes.

## Process

1. **Understand the goal**: Extract from `$ARGUMENTS`. Common types: extract module, consolidate duplicates, rename across codebase, upgrade pattern, split large file.

2. **Delegate to `researcher` subagent** to map scope:
   - Files affected, dependencies, existing test coverage.

3. **Create refactor plan** (lighter than full PRP):
   ```
   ## Refactor: [Description]
   **Goal**: [What improvement]
   **Scope**: [N files]
   **Risk**: LOW / MEDIUM / HIGH

   ### Tracks (parallel where possible)
   | Track | Files | Owner |
   |-------|-------|-------|
   | [e.g., API layer] | [paths] | Teammate 1 |
   | [e.g., Data layer] | [paths] | Teammate 2 |
   | [e.g., Test updates] | [paths] | Teammate 3 |

   ### Steps (with dependencies)
   1. [ ] [step] - Track: [track] - Validate: [command]
   2. [ ] [step] - Track: [track] - Blocked by: step 1

   ### Safety
   - [ ] Tests pass before starting: `[command]`
   - [ ] Tests pass after each step: `[command]`
   ```

4. **Safety checks** (MUST pass before any changes):
   a. **Clean working tree**: If dirty, stop.
   b. **Tests pass**: If failing, stop - don't refactor broken code.
   c. **Correct branch**: If on `main`/`master`, create `refactor/[scope]` branch.

5. **Get approval**: Present plan to user. Iterate if needed.

6. **Save plan**: Write to `.context/features/[NNN]-refactor-[name]/PRP.md`. Update FEATURES.md.

7. **Checkpoint** (trigger: phase-boundary): Create checkpoint `CP-NNN: pre-refactor [scope]`. Snapshot .context/ state, tag current git state. This is the rollback point if the refactor breaks things.

8. **Execute**:
   - **Multi-track refactor** (3+ independent tracks): Create Agent Team.

     **Checkpoint** (trigger: pre-agent-team): Create checkpoint `CP-NNN: pre-refactor-team [scope]` before spawning refactor teammates.

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
   Next: /ce-validate [PRP path]
   ```

## Rules
- Use Agent Team when refactor has 3+ independent tracks. Use `implementer` subagent otherwise.
- Tests must pass BEFORE starting and AFTER every step.
- Each teammate owns specific files - no two teammates edit the same file.
- No feature additions during refactoring. Note them in NOTES.md.
- Keep steps small - each independently safe to commit.
- If scope expands beyond the plan, stop and revise with user.

## User Input
$ARGUMENTS
