# /resume - Resume After Context Clear

Reload relevant context efficiently after `/clear` or new chat.

## Process

1. **Find active work**: Read `.context/features/FEATURES.md` for any feature with status APPROVED or IN_PROGRESS (most recent first). This is faster than scanning PRP files.

2. **Detect missing captures** (recovery from crash/abandoned session):
   Check if code was committed since the last `.context/` update:
   - Compare the most recent commit touching non-`.context/` files (`git log -1 --format=%ci -- . ':!.context/'`) with the most recent commit touching `.context/` files (`git log -1 --format=%ci -- .context/`).
   - If code commits are newer than `.context/` commits (or no `.context/` commits exist), warn:
     ```
     ⚠ CAPTURE GAP: Code changes committed without .context/ updates.
     Recent code commits: [list last 3 non-.context/ commits]
     Last .context/ update: [date or "none found"]

     Recommend capturing learnings before continuing:
       /learn — route insights to the right files
     Continue without capturing? (y/n)
     ```
   - If the user chooses to capture, assist with learnings before loading PRP state.
   - Also check: if an IN_PROGRESS feature exists in FEATURES.md but HEALTH.md has no row for that feature number, flag it: `METRICS GAP: Feature [NNN] is IN_PROGRESS but has no HEALTH.md entry. /validate or /health record will fix this.`

3. **Check checkpoints**: Read `.context/checkpoints/MANIFEST.md` for the most recent checkpoint. If a checkpoint is newer than the PRP's last `[x]` step, note it — the checkpoint may represent a more recent known-good state.
4. **Load**: Read the PRP (check completed vs remaining steps), skim `OVERVIEW.md` and `INDEX.md`.
5. **Report**:
   ```
   Resuming: [Feature]
   PRP: [path]
   Completed: Steps 1-N of M
   Next: Step N+1 - [description]
   Last checkpoint: CP-NNN ([label], [timestamp])
   Ready. Run: /[next-phase-command] [resolved-PRP-path]
   ```
   If the most recent checkpoint is from a rollback or pre-team trigger, highlight it — the user may want to `/checkpoint resume CP-NNN` instead.
6. **If no active PRP**: Show recent research notes, list available checkpoints, and offer options.

## Rules
- Fast and lightweight - don't re-read implementation files, just PRP status.
- If `$ARGUMENTS` specifies a feature, jump directly to it.
- If `$ARGUMENTS` specifies a checkpoint (e.g., `CP-NNN`), delegate to `/checkpoint resume CP-NNN`.
- Maximize remaining context for the next phase.

## User Input
$ARGUMENTS
