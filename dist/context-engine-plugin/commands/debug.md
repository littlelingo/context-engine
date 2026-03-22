# /debug - Diagnose and Fix a Bug

Something is broken. Uses parallel hypothesis testing via Agent Team for complex bugs, or single `debugger` subagent for simple ones.

## Process

1. **Understand the problem**: Get the error message, failing test, or symptom from `$ARGUMENTS`.
2. **Check known errors**: Read `.context/errors/INDEX.md` for matching signatures.
   - If found: present the known fix. Ask if user wants to apply it. **Update metrics**: increment "Error index hits" in `.context/metrics/HEALTH.md`.
   - If not found: proceed to investigation. This will be a "Novel error" for metrics.

3. **Decide investigation mode**:
   - **Simple bug** (clear error, obvious location - typo, missing import, wrong arg): Fix directly without delegation.
   - **Moderate bug** (single hypothesis path): Delegate to `debugger` subagent.
   - **Complex bug** (multiple possible causes, hard to reproduce, cross-cutting): Create an Agent Team for parallel hypothesis testing.

4. **Agent Team for complex bugs**:

   **Checkpoint**: Create checkpoint `CP-NNN: pre-debug-team [symptom]` ONLY if work was done since the last checkpoint.

   Create an agent team to investigate and fix the bug: [error/symptom].

   Spawn 2-3 hypothesis investigators:
   - **Investigator 1**: Hypothesis - [most likely cause based on error]. Reproduce the bug, trace the code path, test this theory. Try to DISPROVE the other investigators' theories.
   - **Investigator 2**: Hypothesis - [second most likely cause]. Same approach - reproduce, trace, test. Actively challenge Investigator 1's findings.
   - **Investigator 3** (if warranted): Hypothesis - [edge case or environmental cause]. Check configuration, dependencies, race conditions.

   Each investigator:
   - Reads `.context/errors/INDEX.md` for related past issues
   - Reproduces the bug independently
   - Tests their specific hypothesis
   - Messages other investigators when they find evidence for or against a theory
   - Reports back with: hypothesis tested, evidence found, confidence level

   The lead synthesizes findings, identifies the root cause from the strongest evidence, and applies the fix.

5. **Review the fix**: Present findings and fix to user. Confirm acceptable.
6. **Verify**: Re-run failing command. Run full test suite.

7. **Reflect**: Capture error to `.context/errors/INDEX.md` (signature, cause, fix, prevention). Note missing tests in LEARNINGS.md, fragile patterns in ANTI_PATTERNS.md. Update HEALTH.md metrics (error counters, hit rate, agent execution mode).

8. **Next steps**:
   ```
   Bug fixed and captured to error index.
   Commit + PR? (y / commit-only / continue / /research [topic] for deeper fix)
   ```
   If committing: check branch. If on `main`/`master`, suggest `fix/[bug-name]` branch.

## Rules
- Check error index FIRST.
- Investigators must actively challenge each other's theories.
- Always capture the resolution to `.context/errors/`.
- If bug reveals a deeper architectural issue, recommend `/refactor`.

## User Input
$ARGUMENTS
