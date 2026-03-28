# /validate - Phase 4: Validate & Capture Learnings

Mandatory regardless of testing strategy. Uses an Agent Team for parallel review when changes are substantial.

## Process

1. **Load PRP** from `$ARGUMENTS` (or find most recent IN_PROGRESS PRP).
2. **Check testing strategy**: Follow testing strategy from PRP field or CLAUDE.md default.
3. **Checkpoint** (trigger: phase-boundary): Create checkpoint `CP-NNN: pre-validate [feature-name]`. Snapshot .context/ state, tag current git state.
4. **Run validation checklist** from the PRP (tests, lint, type-check, manual steps).

5. **Write partial metrics** (early capture — prevents data loss if context runs out):
   Read the PRP to extract: feature number, feature name, plan date, total step count.
   Append an `IN_PROGRESS` row to `.context/metrics/HEALTH.md` Feature Velocity table:
   `| [NNN] | [name] | [plan date] | IN_PROGRESS | - | [steps] | - | - |`
   This row will be completed in step 12. If context runs out before then, `/health record [feature-NNN]` can finish it manually.

6. **Create review Agent Team** (for substantial changes - 3+ files or critical features):

   Create an agent team to review the changes from the PRP at [PRP path].

   Spawn these teammates:
   - **Code reviewer**: Review all changes for correctness, pattern compliance, edge cases per CODE_PATTERNS.md and ANTI_PATTERNS.md. Report as critical/warning/suggestion with file:line references.
   - **Security reviewer**: Run security review per reviewer agent protocol. Report findings with severity.
   - **Simplification reviewer**: Identify dead code, duplication, over-abstraction, and consolidation opportunities. Suggest specific simplifications.

   Each reviewer reports findings independently. The lead synthesizes into a unified review.

   For smaller changes (< 3 files), use the `reviewer` subagent instead of a full team.

7. **Synthesize review**: Combine teammate findings into one report.
8. **Fix critical issues** immediately. Log non-critical as TODOs.
9. **Apply simplifications** from the simplification reviewer. Re-run validation if changes are significant. If simplifications are too large to apply inline (multi-file restructuring, module extraction), note them and suggest `/refactor [scope]` as a follow-up.

10. **Capture learnings** (MANDATORY - never skip. Use formats from `.claude/instructions/CAPTURE-FORMAT.md`):
   - New patterns -> `.context/patterns/CODE_PATTERNS.md`
   - Errors found -> `.context/errors/INDEX.md` (complex errors also get `.context/errors/detail/ERR-NNN.md`)
   - Recurring findings -> `.context/patterns/ANTI_PATTERNS.md`
   - Architecture changes -> run `/update-arch` if structural changes were significant
   - Significant decisions -> `.context/decisions/ADR-NNN-[title].md` using ADR-000-template.md format
   - Insights -> `.context/knowledge/LEARNINGS.md`
   - If nothing learned, note clean completion in LEARNINGS.md.
   For complex entries (library quirks, stack recipes, dependency pins), use `/learn [type]: [content]` to route correctly.

11. **Update PRP status** to COMPLETE. Update FEATURES.md.

12. **Complete feature metrics** (update the IN_PROGRESS row written in step 5 — YOU write directly to `.context/metrics/HEALTH.md`):

    Gather these values from the PRP and this session:
    - **Velocity**: plan date (from PRP header), validate date (today), elapsed days, step count (total `[x]` steps), session count (estimate from /resume calls or 1)
    - **Error tracking**: count errors added to INDEX.md during this feature, count known-error hits (from /debug steps), compute hit rate
    - **Knowledge growth**: count entries added to LEARNINGS.md, count new library files, stack recipes, dependency pins, patterns since plan date
    - **Agent effectiveness**: execution mode (team or subagent), any rollbacks, any empty implementer runs
    - **Context efficiency**: count /clear and /resume cycles during this feature, count knowledge files consulted

    Then find and update the IN_PROGRESS row for this feature in the Feature Velocity table, and append one row to each remaining HEALTH.md table:
    - **Feature Velocity**: Find the `IN_PROGRESS` row written in step 5 and replace it with the final values: `| [NNN] | [name] | [plan date] | [validate date] | [elapsed] | [steps] | [sessions] | [clears] |`
    - **Error Tracking**: Update the cumulative counters (total indexed, hits, novel, repeats, hit rate %)
    - **Knowledge Growth**: `| [date] | [feature] | [learnings] | [libraries] | [stack] | [pins] | [patterns] |`
    - **Agent Effectiveness**: Increment the appropriate counters
    - **Context Efficiency**: `| [feature] | [clears] | [resumes] | [compactions] | [knowledge consulted] |`

    Also write a `## Metrics` block at the PRP bottom with the raw values for future reference.

13. **Checkpoint** (trigger: phase-boundary): Create checkpoint `CP-NNN: post-validate [feature-name]`. This captures the fully validated state before commit.

14. **Report**:
    ```
    ## Validation: [Feature]
    **Status**: PASS/FAIL | **Strategy**: [strategy]
    **Tests**: [results] | **Lint**: [results] | **Types**: [results]
    **Code Review**: [summary]
    **Security**: [summary]
    **Simplified**: [what was consolidated/removed]
    **Learnings captured**: [what was added to .context/]
    ```

15. **Commit & PR prompt** (only if PASSED):

    Generate a conventional commit message and ask:
    ```
    Ready to ship. Suggested commit:

      feat: [concise description]

      - [key change 1]
      - [key change 2]

      PRP: .context/features/[NNN]-[name]/PRP.md

    Commit + PR? (y / commit-only / skip)
    ```

    If PR: Generate PR description from PRP, diff, and review report. Use `gh pr create` or `glab mr create`.

16. **Branch & worktree cleanup** (only after commit in step 15):

    Detect environment via `git worktree list` and `git branch --show-current`.

    - **On `main`/`master`**: No cleanup needed.

    - **In a worktree** (current directory is a linked worktree, not the first entry in `git worktree list`):

      Worktrees are temporary workspaces — clean up automatically:
      - If a PR was created: remove the worktree (`git worktree remove [path]`). Note the branch will merge via the PR.
      - If no PR (commit-only): rebase onto main, fast-forward merge, delete branch, then remove the worktree. Inform the user what was done.
      - In both cases, instruct the user to `cd` back to the main worktree directory.

    - **On a feature branch** (not a worktree):

      Ask the user:
      ```
      Branch: [branch-name]

      Merge to main? (merge / skip)
        merge — rebase onto main, fast-forward merge, delete branch
        skip  — stay on branch, merge later
      ```
      If a PR was created in step 15, recommend merging via the PR instead and only offer local branch deletion after the PR merges.

## Rules
- Always capture learnings - this is the ROI of the system.
- Always ask before committing or creating a PR.
- If validation tests fail with a non-obvious cause, run `/debug [failing test or error]` to diagnose before attempting manual fixes.
- If fixes are complex, start a new `/implement` cycle.
- If validation reveals the implementation is fundamentally broken, consider `/checkpoint rollback CP-NNN` to restore the last known-good state before retrying.

## User Input
$ARGUMENTS
