# /resume - Resume After Context Clear

Reload relevant context efficiently after `/clear` or new chat.

## Process

1. **Find active work**: Read `.context/features/FEATURES.md` for any feature with status APPROVED or IN_PROGRESS (most recent first). This is faster than scanning PRP files.
2. **Load**: Read the PRP (check completed vs remaining steps), skim `OVERVIEW.md` and `INDEX.md`.
3. **Report**:
   ```
   Resuming: [Feature]
   PRP: [path]
   Completed: Steps 1-N of M
   Next: Step N+1 - [description]
   Ready. Run: /[next-phase-command] [resolved-PRP-path]
   ```
4. **If no active PRP**: Show recent research notes and offer options.

## Rules
- Fast and lightweight - don't re-read implementation files, just PRP status.
- If `$ARGUMENTS` specifies a feature, jump directly to it.
- Maximize remaining context for the next phase.

## User Input
$ARGUMENTS
