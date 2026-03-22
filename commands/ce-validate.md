# /ce-validate - Phase 4: Validate & Capture Learnings

Mandatory regardless of testing strategy. Uses an Agent Team for parallel review when changes are substantial.

## Process

1. **Load PRP** from `$ARGUMENTS` (or find most recent IN_PROGRESS PRP).
2. **Check testing strategy**: PRP field -> CLAUDE.md default -> `implement-then-test`.
3. **Checkpoint** (trigger: phase-boundary): Create checkpoint `CP-NNN: pre-validate [feature-name]`. Snapshot .context/ state, tag current git state.
4. **Run validation checklist** from the PRP (tests, lint, type-check, manual steps).

5. **Create review Agent Team** (for substantial changes - 3+ files or critical features):

   **Checkpoint** (trigger: pre-agent-team): Create checkpoint `CP-NNN: pre-review-team [feature-name]` before spawning review teammates.

   Create an agent team to review the changes from the PRP at [PRP path].

   Spawn these teammates:
   - **Code reviewer**: Review all changes for correctness, pattern compliance, edge cases. Read `.context/patterns/CODE_PATTERNS.md` and `ANTI_PATTERNS.md`. Check against 300-line file limit. Report findings as critical/warning/suggestion with exact file:line references.
   - **Security reviewer**: Run the 6-point security checklist on all changes - input validation, auth, data exposure, injection, dependencies, error handling. Report any findings with severity.
   - **Simplification reviewer**: Look at changes holistically for dead code, duplication, over-abstraction (interfaces with one consumer), unnecessary complexity, and consolidation opportunities. Suggest specific simplifications.

   Each reviewer reports findings independently. The lead synthesizes into a unified review.

   For smaller changes (< 3 files), use the `reviewer` subagent instead of a full team.

6. **Synthesize review**: Combine teammate findings into one report.
7. **Fix critical issues** immediately. Log non-critical as TODOs.
8. **Apply simplifications** from the simplification reviewer. Re-run validation if changes are significant.

9. **Capture learnings** (MANDATORY - never skip):
   - New patterns -> `.context/patterns/CODE_PATTERNS.md`
   - Errors -> `.context/errors/INDEX.md`
   - Recurring findings -> `.context/patterns/ANTI_PATTERNS.md`
   - Architecture changes -> `.context/architecture/`
   - Significant decisions -> `.context/decisions/` (ADR)
   - Simplifications -> `.context/knowledge/LEARNINGS.md`
   - If nothing learned, note clean completion in LEARNINGS.md.

10. **Update PRP status** to COMPLETE. Update FEATURES.md.

11. **Capture feature metrics** (auto - append to `.context/metrics/HEALTH.md`):
    - **Velocity**: Read PRP creation date (from git log or file metadata), today's date = validate date. Count total steps, count `/clear` commands in this feature's history (estimate from checkpoint count). Append row to Feature Velocity table.
    - **Error tracking**: Count errors added to INDEX.md during this feature. Check if any were hits (known fix applied from index) vs novel. Update error counters.
    - **Knowledge growth**: Count entries added to knowledge/ during this feature (diff LEARNINGS.md, libraries/, stack/, PINS.md). Append row to Knowledge Growth table.
    - **Context efficiency**: Count checkpoints created during this feature (from MANIFEST.md). Count clears (estimate from checkpoint gaps). Append row to Context Efficiency table.
    - **Agent effectiveness**: Increment team/subagent counters based on what was used during implement and validate.
    - **Write per-PRP metrics block** at the bottom of the PRP file:
      ```
      ## Metrics
      - Plan date: [YYYY-MM-DD]
      - Validate date: [YYYY-MM-DD]
      - Elapsed: [N days]
      - Steps: [completed/total]
      - Testing strategy: [strategy]
      - Errors encountered: [N] (N novel, N hits)
      - Knowledge captured: [N entries]
      - Checkpoints created: [N]
      - Clears: [estimated N]
      - Execution mode: [Agent Team / Subagent]
      ```

12. **Checkpoint** (trigger: phase-boundary): Create checkpoint `CP-NNN: post-validate [feature-name]`. This captures the fully validated state before commit.

13. **Report**:
    ```
    ## Validation: [Feature]
    **Status**: PASS/FAIL | **Strategy**: [strategy]
    **Tests**: [results] | **Lint**: [results] | **Types**: [results]
    **Code Review**: [summary]
    **Security**: [summary]
    **Simplified**: [what was consolidated/removed]
    **Learnings captured**: [what was added to .context/]
    ```

14. **Commit & PR prompt** (only if PASSED):

    Generate a conventional commit message and ask:
    ```
    Ready to ship. Suggested commit:

      feat: [concise description]

      - [key change 1]
      - [key change 2]

      PRP: .context/features/[NNN]-[name]/PRP.md

    Options:
    1. Commit only
    2. Commit + create PR
    3. Edit the message
    4. Skip (I'll handle it manually)
    ```

    Option 2: Generate PR description from PRP, diff, and review report. Use `gh pr create` or `glab mr create`.

## Rules
- Use Agent Team for review when 3+ files changed or feature is critical. Use `reviewer` subagent for smaller changes.
- Each review teammate focuses on ONE concern (code quality, security, simplification) - no overlap.
- Clean up team before capture/commit steps.
- Always capture learnings. This is the ROI of the system.
- Always ask before committing or creating a PR.
- If fixes are complex, save state and start a new `/ce-implement` cycle.

## User Input
$ARGUMENTS
