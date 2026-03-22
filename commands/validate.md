# /validate - Phase 4: Validate & Capture Learnings

Mandatory regardless of testing strategy. Uses an Agent Team for parallel review when changes are substantial.

## Process

1. **Load PRP** from `$ARGUMENTS` (or find most recent IN_PROGRESS PRP).
2. **Check testing strategy**: Follow testing strategy from PRP field or CLAUDE.md default.
3. **Checkpoint** (trigger: phase-boundary): Create checkpoint `CP-NNN: pre-validate [feature-name]`. Snapshot .context/ state, tag current git state.
4. **Run validation checklist** from the PRP (tests, lint, type-check, manual steps).

5. **Create review Agent Team** (for substantial changes - 3+ files or critical features):

   Create an agent team to review the changes from the PRP at [PRP path].

   Spawn these teammates:
   - **Code reviewer**: Review all changes for correctness, pattern compliance, edge cases per CODE_PATTERNS.md and ANTI_PATTERNS.md. Report as critical/warning/suggestion with file:line references.
   - **Security reviewer**: Run security review per reviewer agent protocol. Report findings with severity.
   - **Simplification reviewer**: Identify dead code, duplication, over-abstraction, and consolidation opportunities. Suggest specific simplifications.

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
    Append per-PRP metrics to HEALTH.md across all 5 categories: velocity (plan date, validate date, elapsed, steps), error tracking (novel vs hits), knowledge growth (entries added), context efficiency (checkpoints, clears), agent effectiveness (team vs subagent).
    Write a `## Metrics` block at the PRP bottom with: plan date, validate date, elapsed, steps, strategy, errors, knowledge entries, checkpoints, clears, execution mode.

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

    Commit + PR? (y / commit-only / skip)
    ```

    If PR: Generate PR description from PRP, diff, and review report. Use `gh pr create` or `glab mr create`.

## Rules
- Always capture learnings - this is the ROI of the system.
- Always ask before committing or creating a PR.
- If fixes are complex, start a new `/implement` cycle.

## User Input
$ARGUMENTS
