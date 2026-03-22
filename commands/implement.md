# /implement - Phase 3: Execute Implementation

Execute the PRP using an Agent Team for parallel step execution.

## Process

1. **Safety checks** (MUST pass before any code is written):
   a. **Clean working tree**: Run `git status`. If uncommitted changes, stop and ask user to commit or stash.
   b. **Tests pass**: Run the project's test command from TECH_STACK.md. If tests fail, stop.
   c. **Correct branch**: If on `main`/`master`, derive branch name from PRP (`feat/`, `fix/`, `refactor/`), ask user to confirm, create it.
   If resuming (steps already marked `[x]`), skip safety checks.

2. **Load PRP** from `$ARGUMENTS` (or find most recent APPROVED/IN_PROGRESS PRP). Set status to IN_PROGRESS. Update FEATURES.md.

3. **Determine testing strategy**: PRP field -> CLAUDE.md default -> `implement-then-test`.

4. **Checkpoint** (trigger: phase-boundary): Create checkpoint `CP-NNN: pre-implement [feature-name]`. Snapshot .context/ state, tag current git state. This is the rollback point if implementation goes wrong.

5. **Analyze PRP steps for parallelism**:
   - Read all `[ ]` steps in the PRP
   - Identify which steps are independent (can run in parallel)
   - Identify dependencies (step 3 needs step 1's API types)
   - Group into parallel tracks (e.g., frontend track, backend track, test track)

6. **Decide execution mode**:
   - **3+ independent steps**: Create an Agent Team (proceed to step 7)
   - **< 3 steps or all sequential**: Use a single subagent via the `implementer` agent (simpler, cheaper)

7. **Create Agent Team** (when parallel execution is beneficial):

   **Checkpoint** (trigger: pre-agent-team): Create checkpoint `CP-NNN: pre-team [feature-name]` before spawning teammates. This is the safety net for multi-teammate parallel work.

   Create an agent team to implement the PRP at [PRP path].

   Team structure based on PRP analysis:
   - **Team lead** (you): Coordinate work, manage the shared task list, synthesize results, capture learnings
   - **Spawn teammates** based on the parallel tracks identified. Give each teammate:
     - Their specific PRP steps to own
     - The testing strategy to follow
     - File ownership boundaries (which files each teammate owns - prevent conflicts)
     - Instructions to read `.context/patterns/CODE_PATTERNS.md` before starting
     - Instructions to message other teammates when they create or change interfaces/types/APIs that others depend on

   Example spawn prompt for a teammate:
   ```
   You are an implementation engineer working on [track name].
   Testing strategy: [strategy]
   Your steps from the PRP:
   - Step [N]: [description]
   - Step [M]: [description]
   Files you own: [list]
   Read .context/patterns/CODE_PATTERNS.md before starting.
   Run validation after each step: [command]
   Mark completed steps with [x] in the PRP.
   Message [other teammate] when you finish [interface/type] so they can proceed.
   ```

   Set up the shared task list with dependencies:
   - Create tasks matching PRP steps
   - Set `blockedBy` for dependent steps
   - Teammates self-claim unblocked tasks

8. **Monitor and coordinate**:
   - Watch for teammates reporting completion or problems
   - If a teammate hits an error, intervene or spawn a replacement
   - If teammates need to communicate about API contracts, ensure messages are flowing
   - Use delegate mode (Shift+Tab) to stay in coordination role

9. **When all steps complete**:
   - Verify all PRP steps are marked `[x]`
   - Run full test suite one final time
   - Shut down teammates, clean up team
   - Capture learnings: errors to `.context/errors/`, patterns to `.context/patterns/`, insights to `.context/knowledge/LEARNINGS.md`
   ```
   All steps complete.
   Next: /clear then /validate [PRP path]
   ```

## Resuming
When steps are already marked `[x]`: read PRP, summarize progress, pick up remaining unchecked steps. Spawn a smaller team for just the remaining work.

## Rules
- MUST run safety checks before first step.
- Use Agent Teams when 3+ steps can run in parallel. Use single `implementer` subagent for sequential work.
- Each teammate MUST own specific files - never let two teammates edit the same file.
- Teammates must communicate when creating interfaces/types that others depend on.
- Use the shared task list with `blockedBy` for dependency ordering.
- Use delegate mode (Shift+Tab) so the lead coordinates instead of implementing.
- Capture errors immediately when resolved.
- No scope creep. Note extras in PRP NOTES.md.
- Clean up team (shut down all teammates) before handing off to `/validate`.
- Hand off to `/validate` when done.

## User Input
$ARGUMENTS
