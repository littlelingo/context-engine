# /cancel - Cancel an In-Progress or Approved Feature

Mark a feature as CANCELLED, capture learnings from partial work, and optionally clean up branches and checkpoints.

## Process

Parse `$ARGUMENTS` to find the target feature:

- No arguments: find the most recent IN_PROGRESS or APPROVED feature in `.context/features/FEATURES.md`
- `feature-NNN` or a PRP path: use that specific feature

### 1. Find Target PRP

Read `.context/features/FEATURES.md`. If no IN_PROGRESS or APPROVED feature exists (and no argument was given), report:

```
No active features to cancel.
```

Stop. Otherwise, resolve the PRP path and read it.

### 2. Assess and Show What Will Be Cancelled

Display:

```
Cancel: [feature-name] ([feature-NNN])
Status: [current status]
Progress: [N/M steps complete]
Branch: [branch name or "none detected"]
Uncommitted changes: [yes/no — check via git status]
Checkpoints: [list CP-NNN labels, or "none"]
```

If uncommitted changes exist, warn:

```
Warning: there are uncommitted changes on this branch. These will remain on the branch unless deleted.
```

### 3. Confirm

Ask:

```
Cancel [feature-name]? This will mark it CANCELLED in FEATURES.md. (y/n)
```

If the answer is not `y` or `yes`, report "Cancellation aborted." and stop.

### 4. Update Status

- Set `status: CANCELLED` in the PRP file (update the status field, do not delete the file).
- Update the feature row in `.context/features/FEATURES.md` to `CANCELLED`.

### 5. Capture Learnings (MANDATORY)

Ask:

```
Any learnings from this work worth capturing before closing?
(Partial work often reveals valuable insights — what did you learn?)
```

Capture whatever the user shares using the formats in `.claude/instructions/CAPTURE-FORMAT.md`. If nothing is offered, write a brief note in `.context/knowledge/LEARNINGS.md` acknowledging the cancellation and any observable reason (e.g., approach changed, requirements shifted).

### 6. Branch Cleanup (Optional)

If a feature branch was detected, ask:

```
Branch [branch-name] still exists. Delete it or keep it?
  delete — git branch -d [branch-name]
  keep   — leave the branch as-is
```

Only delete if the user explicitly chooses `delete`.

### 7. Checkpoint Cleanup (Optional)

If checkpoints exist for this feature, ask:

```
Checkpoints found: [CP-NNN list]. Clean them up via /checkpoint clean?
  yes — run /checkpoint clean
  no  — leave checkpoints as-is
```

### 8. Record Metrics (MANDATORY)

Append a row to `.context/metrics/HEALTH.md` Feature Velocity table to make the cancellation visible:
`| [NNN] | [name] | [plan date] | CANCELLED | [elapsed days] | [completed steps]/[total steps] | - | - |`

Update Knowledge Growth table if any learnings were captured in step 5.
Set the `Metrics` column in FEATURES.md to `AUTO` for this feature.

This ensures cancelled features are tracked — partial work still consumes effort and produces insights.

### 9. Report

```
## Cancelled: [feature-name]
**PRP**: [path] — status set to CANCELLED
**FEATURES.md**: updated
**Learnings captured**: [what was written, or "none"]
**Branch**: [deleted / kept / not applicable]
**Checkpoints**: [cleaned / kept / not applicable]
```

## Rules

- Always confirm before cancelling — never cancel silently.
- Always offer a learnings prompt — partial work is still information.
- Never delete the PRP file — CANCELLED status preserves decision history.
- Branch deletion requires explicit user choice — default is to keep.
- If the feature was APPROVED but never started (0 steps complete), learnings are optional but still prompted.

## User Input
$ARGUMENTS
