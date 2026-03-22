# /ce-checkpoint - Checkpoint Management

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
   - Write `snapshot-meta.json` with: timestamp, branch, PRP path, PRP progress (N/M steps), trigger reason, git SHA at time of snapshot
3. **Create git tag**:
   - If working tree is clean: `git tag ce-checkpoint-NNN -m "[label]"`
   - If working tree is dirty: `git stash` first, tag, then `git stash pop`. Note in manifest that tree was dirty.
   - If git stash fails (nothing to stash): tag the current HEAD anyway.
4. **Append to MANIFEST.md** with all metadata.
5. **Report**: "Checkpoint CP-NNN created. Tag: ce-checkpoint-NNN. [N files snapshotted]."

### `list`: List All Checkpoints

1. Read `.context/checkpoints/MANIFEST.md`
2. Also verify git tags still exist: `git tag -l "ce-checkpoint-*"`
3. Display table with: number, label, timestamp, trigger, branch, PRP progress
4. Flag any orphaned checkpoints (manifest entry but missing git tag, or vice versa)

### `rollback [CP-NNN]`: Rollback to Checkpoint

1. **Verify checkpoint exists**: Check both manifest entry and git tag.
2. **Show what will change**:
   - `git diff --stat ce-checkpoint-NNN` (files that changed since checkpoint)
   - Compare current PRP progress vs snapshot PRP progress
   - List knowledge/error entries added since checkpoint
3. **Offer choice**:

   **Option A: Full rollback** (code + context)
   - `git reset --hard ce-checkpoint-NNN` (resets code to checkpoint state)
   - Restore all `.context/` files from snapshot
   - Warning: This discards all code changes since the checkpoint. Uncommitted work will be lost.

   **Option B: Soft rollback** (context only)
   - Restore `.context/` files from snapshot (PRP progress, learnings, errors, features)
   - Do NOT touch code files
   - Show `git diff ce-checkpoint-NNN` so user can manually revert specific files
   - Useful when: the code is partially good but the PRP state got corrupted

   **Option C: Cancel**
   - Do nothing. Exit.

4. **After rollback**: Report what was restored and current state.
5. **Update metrics**: Increment "Checkpoint rollbacks (full)" or "Checkpoint rollbacks (soft)" in `.context/metrics/HEALTH.md`.

### `clean [--keep N]`: Remove Old Checkpoints

1. Default: keep last 5 checkpoints, remove older ones.
2. `--keep N`: keep last N checkpoints.
3. For each removed checkpoint:
   - Delete `.context/checkpoints/CP-NNN/` directory
   - Delete git tag: `git tag -d ce-checkpoint-NNN`
   - Remove entry from MANIFEST.md
4. Report: "Removed N checkpoints. Kept last M."

## Snapshot Contents

Each `.context/checkpoints/CP-NNN/` contains:
```
snapshot-meta.json       Timestamp, branch, SHA, PRP path, progress, trigger
PRP.md                   Copy of active PRP (if any)
LEARNINGS.md             Copy of knowledge/LEARNINGS.md
PINS.md                  Copy of knowledge/dependencies/PINS.md
INDEX.md                 Copy of errors/INDEX.md
FEATURES.md              Copy of features/FEATURES.md
```

Only files that exist are copied. Missing files are noted in snapshot-meta.json.

## Safety Rules
- Full rollback requires explicit confirmation ("yes, discard all changes")
- Never rollback if there are uncommitted changes AND the user chose full rollback - warn and require stash or commit first
- Checkpoint creation should be fast (< 2 seconds) - don't block the workflow
- Git tags use lightweight tags, not annotated (faster)
- If git is not initialized, skip git tag but still create .context/ snapshot

## User Input
$ARGUMENTS
