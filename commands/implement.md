# /implement - Phase 3: Execute Implementation

Execute the PRP using an Agent Team for parallel step execution.

## Process

1. **Safety checks** (MUST pass before any code is written):
   a. **Clean working tree**: Run `git status`. If uncommitted changes, stop and ask user to commit or stash.
   b. **Tests pass**: Run the project's test command from TECH_STACK.md. If tests fail, stop and suggest: `Tests are failing. Run /debug [failing test or error] to diagnose before implementing.`
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
   - **Important**: Teammates should not write to the same `.context/` file simultaneously. The lead agent consolidates all `.context/` captures after team execution completes.

7. **Monitor and coordinate**:
   - Watch for teammates reporting completion or problems
   - If a teammate hits an error: attempt a quick fix first. If the error is non-obvious or persists, run `/debug [error]` to diagnose systematically before continuing.
   - Ensure API contract communication is flowing between teammates
   - Use delegate mode (Shift+Tab) to stay in coordination role

8. **When all steps complete**:
   - Verify all PRP steps are marked `[x]`
   - Run full test suite one final time
   - Shut down teammates, clean up team
   - **Capture learnings** (verify what agents captured, fill gaps):
     Teammates may have written to `.context/` during execution. Check and complete using formats from `.claude/instructions/CAPTURE-FORMAT.md`:
     - Error signatures -> `.context/errors/INDEX.md`
     - New code patterns -> `.context/patterns/CODE_PATTERNS.md`
     - Insights -> `.context/knowledge/LEARNINGS.md`
     - Library quirks -> `.context/knowledge/libraries/[name].md`
     - Version pins -> `.context/knowledge/dependencies/PINS.md`
     If significant knowledge was captured, suggest `/learn` for complex entries that need routing.
   ```
   All steps complete.
   Next: /validate [PRP path] (run /clear first if context > 50%)
   Proceed? (y/n)
   ```
   If yes: invoke `/validate` with the PRP path as the argument (use the Skill tool with skill="validate"). Remind about `/clear` first if context > 50%. If no: ask the user what they'd like to do instead.

## Resuming
When steps are already marked `[x]`: read PRP, summarize progress, pick up remaining unchecked steps. Spawn a smaller team for just the remaining work.

## Rules
- MUST run safety checks before first step.
- Each teammate MUST own specific files - no overlap.
- No scope creep. Note extras in PRP NOTES.md.
- Clean up team before handing off to `/validate`.
- If implementation goes off the rails (multiple failing steps, cascading errors), consider `/checkpoint rollback CP-NNN` to restore the pre-team state and retry with a revised approach.

## User Input
$ARGUMENTS
