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

   **Checkpoint** (trigger: pre-agent-team): Create checkpoint `CP-NNN: pre-debug-team [symptom]` before spawning investigators. Safety net for parallel hypothesis testing.

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

   The adversarial structure prevents anchoring bias. Sequential investigation tends to commit to the first theory explored. Parallel investigators challenging each other surface the actual root cause faster.

   The lead synthesizes findings, identifies the root cause from the strongest evidence, and applies the fix.

5. **Review the fix**: Present findings and fix to user. Confirm acceptable.
6. **Verify**: Re-run failing command. Run full test suite.

7. **Reflect** (automatic):
   - Capture error pattern to `.context/errors/INDEX.md` with signature, cause, fix, prevention
   - If bug revealed a missing test, note in `.context/knowledge/LEARNINGS.md`
   - If bug exposed a fragile pattern, add to `.context/patterns/ANTI_PATTERNS.md`
   - **Update metrics** in `.context/metrics/HEALTH.md`:
     - Increment "Total errors indexed"
     - Increment "Novel errors" (or "Repeat errors" if root cause matches an existing entry)
     - Recompute "Hit rate"
     - Increment Agent Team or Subagent execution counter based on investigation mode used

8. **Next steps**:
   ```
   Bug fixed and captured to error index.

   Options:
   1. Commit the fix (suggest: fix: [description])
   2. Commit + create PR for the fix
   3. Continue working (don't commit yet)
   4. Create a PRP for a more thorough fix (if this was a band-aid)
   ```
   If option 1 or 2: check branch. If on `main`/`master`, suggest `fix/[bug-name]` branch.

## Rules
- Check error index FIRST.
- Use Agent Team only for complex, multi-cause bugs. Simple bugs don't need the overhead.
- Investigators must actively challenge each other's theories - not just work in isolation.
- Clean up team before committing.
- If bug reveals a deeper architectural issue, recommend `/refactor`.
- Always capture the resolution to `.context/errors/`.

## User Input
$ARGUMENTS
