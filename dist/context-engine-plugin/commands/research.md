# /research - Phase 1: Research

No code in this phase. Understand what exists before planning.

## Process

1. **Clarify**: Restate what the user wants. Ask if ambiguous.
2. **MUST delegate**: Use the `researcher` agent to explore the codebase. Follow `.claude/instructions/DELEGATION.md` delegation pattern.
3. **Check `.context/`**: Read architecture docs, patterns, and **explicitly check `.context/errors/INDEX.md`** for known errors related to this feature area (matching libraries, file paths, or patterns). Known errors should inform the research summary's risks and potential issues.
4. **Synthesize**: Produce a summary with current state, gaps, dependencies, risks, open questions.
5. **Save**: Write to `.context/features/[NNN]-[topic]/NOTES.md`:
   - Read FEATURES.md to find the highest existing feature number [NNN]
   - Increment by 1 (do not reuse gaps — e.g., if 001 and 003 exist, next is 004)
   - Verify `.context/features/[NNN]-*` directory doesn't already exist
   - Create the directory and write NOTES.md
6. **Reflect**: Update `.context/` with any new architecture info, patterns, or errors discovered. Use formats from `.claude/instructions/CAPTURE-FORMAT.md` when writing to `.context/`.
7. **Commit research artifacts** (automatic — no user prompt): Stage and commit all `.context/` changes (NOTES.md, FEATURES.md, any reflection updates) with `docs: research [topic]`. These are framework bookkeeping, not user code — commit silently so artifacts survive branch creation, worktree spawns, and checkpoints.
8. **Hand off**:
   ```
   Research saved to: .context/features/[NNN]-[topic]/NOTES.md
   Next: /planner .context/features/[NNN]-[topic]/NOTES.md
   Proceed? (y/n)
   ```
   If yes: invoke `/planner` with the notes path as the argument (use the Skill tool with skill="planner"). If no: ask the user what they'd like to do instead.

## Rules
- No code. Research only.
- MUST delegate to `researcher` agent for file exploration. The researcher agent owns the output format.
- Check `.context/` before exploring raw files.
- Monitor context budget per CLAUDE.md thresholds.

## User Input
$ARGUMENTS
