# /implement - Phase 3: Execute Implementation

Execute the PRP using an Agent Team for parallel step execution.

## Process

1. **Safety checks**: Follow `.claude/instructions/SAFETY-CHECKS.md`
   If on main/master, create feature branch from the PRP name.
   If resuming (steps already marked `[x]`), skip safety checks.
   **Before branching or entering a worktree**: verify the PRP and NOTES.md are committed. If uncommitted `.context/features/` files exist, stage and commit them automatically (`docs: plan [feature-name]`) — no user prompt needed for framework artifacts. Uncommitted artifacts will not carry over to new branches or worktrees.

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

   **Checkpoint** (trigger: pre-agent-team): Create checkpoint `CP-NNN: pre-team [feature-name]` unless no steps have been completed since the last checkpoint.

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
   - **Capture learnings** (MANDATORY — use formats from `.claude/instructions/CAPTURE-FORMAT.md`):
     Teammates may have written to `.context/` during execution. Verify what agents captured, fill gaps:
     - Error signatures -> `.context/errors/INDEX.md`
     - **Error index hits**: If any errors encountered during implementation matched entries in `.context/errors/INDEX.md`, increment "Error index hits" and recompute "Hit rate" in `.context/metrics/HEALTH.md`
     - New code patterns -> `.context/patterns/CODE_PATTERNS.md`
     - Insights -> `.context/knowledge/LEARNINGS.md`
     - **Library quirks**: For any library where you spent significant debugging time or discovered non-obvious behavior, create/update `.context/knowledge/libraries/[name].md` using the TEMPLATE.md format. Do not skip this — agent memory is per-session, the shared knowledge base persists.
     - **Stack recipes**: If you wired up a non-trivial integration (e.g., async DB + test setup, build tool config), create/update `.context/knowledge/stack/[name].md`
     - Version pins -> `.context/knowledge/dependencies/PINS.md`
     If significant knowledge was captured, suggest `/learn` for complex entries that need routing.
   ```
   All steps complete.

   Next step options:
     1. /validate [PRP path]  (recommended — full review + tests + learnings + metrics)
     2. commit                (skip review/tests — still captures learnings + metrics first)
     3. pause                 (checkpoint and stop — resume later)

   Choose (1/2/3):
   ```
   - **Option 1** (validate): Invoke `/validate` with the PRP path as the argument (use the Skill tool with skill="validate"). Remind about `/clear` first if context > 50%.
   - **Option 2** (commit without validation): Before committing, you MUST still run the following — these are not optional:
     1. **Capture learnings** (same as step 8 above) — errors, patterns, insights, library quirks, stack recipes, version pins to `.context/`.
     2. **Write metrics** — append a row to `.context/metrics/HEALTH.md` Feature Velocity table with available data (mark review columns as `SKIPPED`). Update FEATURES.md status to `COMPLETE (unvalidated)`.
     3. **Then** generate a conventional commit message and prompt for commit + PR (same as `/validate` step 15).
     The `require-validation` hook will fire on commit as a final reminder — the user can approve to proceed.
   - **Option 3** (pause): Create checkpoint `CP-NNN: paused [feature-name]`, leave status as IN_PROGRESS, and stop. The user can resume later with `/implement [PRP path]`.

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
