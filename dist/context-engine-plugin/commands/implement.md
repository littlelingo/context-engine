# /implement - Phase 3: Execute Implementation

Execute the PRP using an Agent Team for parallel step execution.

## Process

1. **Safety checks** (MUST pass before any code is written):
   a. **Clean working tree**: Run `git status`. If uncommitted changes, stop and ask user to commit or stash.
   b. **Tests pass**: Run the project's test command from TECH_STACK.md. If tests fail, stop.
   c. **Correct branch**: If on `main`/`master`, derive branch name from PRP (`feat/`, `fix/`, `refactor/`), ask user to confirm, create it.
   If resuming (steps already marked `[x]`), skip safety checks.

2. **Load PRP** from `$ARGUMENTS` (or find most recent APPROVED/IN_PROGRESS PRP). Set status to IN_PROGRESS. Update FEATURES.md.

3. **Determine testing strategy**: Follow testing strategy from PRP field or CLAUDE.md default.

4. **Analyze PRP steps for parallelism**:
   - Read all `[ ]` steps in the PRP
   - Identify which steps are independent (can run in parallel)
   - Identify dependencies (step 3 needs step 1's API types)
   - Group into parallel tracks (e.g., frontend track, backend track, test track)

5. **Decide execution mode**:
   - **3+ independent steps**: Create an Agent Team (proceed to step 6)
   - **< 3 steps or all sequential**: Use a single subagent via the `implementer` agent (simpler, cheaper)

6. **Create Agent Team** (when parallel execution is beneficial):

   **Checkpoint** (trigger: pre-agent-team): Create checkpoint `CP-NNN: pre-team [feature-name]` ONLY if steps were completed since the last checkpoint.

   Create an agent team to implement the PRP at [PRP path].

   Team structure:
   - **Team lead** (you): Coordinate work, manage shared task list, synthesize results, capture learnings
   - **Spawn teammates** per parallel track. Each teammate receives: their PRP steps, testing strategy, owned files, CODE_PATTERNS.md instruction, and inter-teammate communication instructions
   - Set up shared task list with `blockedBy` dependencies; teammates self-claim unblocked tasks

7. **Monitor and coordinate**:
   - Watch for teammates reporting completion or problems
   - If a teammate hits an error, intervene or spawn a replacement
   - Ensure API contract communication is flowing between teammates
   - Use delegate mode (Shift+Tab) to stay in coordination role

8. **When all steps complete**:
   - Verify all PRP steps are marked `[x]`
   - Run full test suite one final time
   - Shut down teammates, clean up team
   - Capture learnings: errors to `.context/errors/`, patterns to `.context/patterns/`, insights to `.context/knowledge/LEARNINGS.md`
   ```
   All steps complete.
   Next: /validate [PRP path] (run /clear first if context > 50%)
   ```

## Resuming
When steps are already marked `[x]`: read PRP, summarize progress, pick up remaining unchecked steps. Spawn a smaller team for just the remaining work.

## Rules
- MUST run safety checks before first step.
- Each teammate MUST own specific files - no overlap.
- No scope creep. Note extras in PRP NOTES.md.
- Clean up team before handing off to `/validate`.

## User Input
$ARGUMENTS
