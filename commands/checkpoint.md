# /checkpoint - Checkpoint Management

Create, list, rollback, and clean hybrid checkpoints (git tag + .context/ snapshot).

## Process

Parse `$ARGUMENTS` to determine the action:

### `create [label]` or no arguments: Create Checkpoint

1. **Determine next checkpoint number**: Read `.context/checkpoints/MANIFEST.md`, find highest CP-NNN, increment.
2. **Snapshot .context/ state**:
   - Create directory `.context/checkpoints/CP-NNN/`
   - Copy these files into the snapshot directory:
     - Active PRP file (if any IN_PROGRESS feature)
     - `.context/knowledge/LEARNINGS.md`
     - `.context/knowledge/dependencies/PINS.md`
     - `.context/errors/INDEX.md`
     - `.context/features/FEATURES.md`
     - `.context/patterns/CODE_PATTERNS.md`
     - `.context/patterns/ANTI_PATTERNS.md`
     - Any `.context/decisions/ADR-*.md` files (excluding the template)
     - Any `.context/knowledge/libraries/*.md` and `stack/*.md` files (excluding TEMPLATEs)
   - Write `snapshot-meta.json` with: timestamp, branch, PRP path, PRP progress (N/M steps), trigger reason, git SHA at time of snapshot
3. **Commit .context/ artifacts before tagging**:
   - If there are uncommitted `.context/` files (NOTES.md, PRP.md, FEATURES.md, knowledge captures): stage and commit them with `docs: checkpoint [label]`. These must be in git history for the tag and any branch/worktree to carry them.
   - If there are also uncommitted source code changes: leave those unstaged — only commit `.context/` artifacts.
4. **Create git tag**:
   - First verify tag doesn't already exist: `git tag -l checkpoint-NNN`. If collision found, increment NNN until an available number is found.
   - If working tree is clean: `git tag checkpoint-NNN -m "[label]"`
   - If working tree is dirty (non-.context/ changes remain): `git stash` first, tag, then `git stash pop`. Note in manifest that tree was dirty.
   - If git stash fails (nothing to stash): tag the current HEAD anyway.
4. **Append to MANIFEST.md** with all metadata.
5. **Report**: "Checkpoint CP-NNN created. Tag: checkpoint-NNN. [N files snapshotted]."

### `list`: List All Checkpoints

1. Read `.context/checkpoints/MANIFEST.md`
2. Also verify git tags still exist: `git tag -l "checkpoint-*"`
3. Display table with: number, label, timestamp, trigger, branch, PRP progress
4. Flag any orphaned checkpoints (manifest entry but missing git tag, or vice versa)

### `rollback [CP-NNN]`: Rollback to Checkpoint

1. **Verify checkpoint exists**: Check both manifest entry and git tag.
2. **Show what will change**:
   - `git diff --stat checkpoint-NNN` (files that changed since checkpoint)
   - Compare current PRP progress vs snapshot PRP progress
   - List knowledge/error entries added since checkpoint
3. **Offer choice**:

   **Option A: Full rollback** (code + context)
   - `git reset --hard checkpoint-NNN` (resets code to checkpoint state)
   - Restore all `.context/` files from snapshot
   - Warning: This discards all code changes since the checkpoint. Uncommitted work will be lost.

   **Option B: Soft rollback** (context only)
   - Restore `.context/` files from snapshot (PRP progress, learnings, errors, features)
   - Do NOT touch code files
   - Show `git diff checkpoint-NNN` so user can manually revert specific files
   - Useful when: the code is partially good but the PRP state got corrupted

   **Option C: Cancel**
   - Do nothing. Exit.

4. **After rollback**: Report what was restored and current state.
5. **Update metrics**: Increment "Checkpoint rollbacks (full)" or "Checkpoint rollbacks (soft)" in `.context/metrics/HEALTH.md`.

### `resume [CP-NNN]`: Resume from Checkpoint

Pick up work from a checkpoint's saved state. Use after a rollback, or to re-orient after a `/clear`.

1. **Load checkpoint metadata**: Read `snapshot-meta.json` from `.context/checkpoints/CP-NNN/` for branch, PRP path, PRP progress, trigger.
2. **Restore context**:
   - Read the snapshotted PRP to determine completed vs remaining steps
   - Read snapshotted LEARNINGS.md and INDEX.md for context accumulated up to that point
3. **Verify current state**:
   - Is the git branch still the same? If not, warn and suggest switching: `git checkout [branch]`
   - Does the PRP file still exist at the recorded path? If moved, search `.context/features/` for it.
4. **Report**:
   ```
   Resuming from checkpoint CP-NNN: [label]
   Created: [timestamp] | Trigger: [trigger]
   Branch: [branch]
   PRP: [path]
   Progress: [N/M steps complete]
   Next step: [N+1] - [description]

   Ready. Run: /implement [PRP path]
   ```
5. **If no PRP was active at checkpoint time**: Report the checkpoint state and suggest `/status` or `/research`.

### `clean [--keep N]`: Remove Old Checkpoints

1. Default: keep last 5 checkpoints, remove older ones.
2. `--keep N`: keep last N checkpoints.
3. For each removed checkpoint:
   - Delete `.context/checkpoints/CP-NNN/` directory
   - Delete git tag: `git tag -d checkpoint-NNN`
   - Remove entry from MANIFEST.md
4. Report: "Removed N checkpoints. Kept last M."

## Safety Rules
- Full rollback requires explicit confirmation ("yes, discard all changes")
- Never rollback if there are uncommitted changes AND the user chose full rollback - warn and require stash or commit first
- Checkpoint creation should be fast (< 2 seconds) - don't block the workflow
- Git tags use lightweight tags, not annotated (faster)
- If git is not initialized, skip git tag but still create .context/ snapshot

## User Input
$ARGUMENTS
