# /research - Phase 1: Research

No code in this phase. Understand what exists before planning.

## Process

1. **Clarify**: Restate what the user wants. Ask if ambiguous.
2. **MUST delegate**: Use the `researcher` agent to explore the codebase.
3. **Check `.context/`**: Read architecture, patterns, and errors for existing knowledge.
4. **Synthesize**: Produce a summary with current state, gaps, dependencies, risks, open questions.
5. **Save**: Write to `.context/features/[NNN]-[topic]/NOTES.md`:
   - Read FEATURES.md to find the highest existing feature number [NNN]
   - Increment by 1 (do not reuse gaps — e.g., if 001 and 003 exist, next is 004)
   - Verify `.context/features/[NNN]-*` directory doesn't already exist
   - Create the directory and write NOTES.md
6. **Reflect**: Update `.context/` with any new architecture info, patterns, or errors discovered.
7. **Hand off**:
   ```
   Research saved to: .context/features/[NNN]-[topic]/NOTES.md
   Next: /plan .context/features/[NNN]-[topic]/NOTES.md
   Proceed? (y/n)
   ```
   If yes: invoke `/plan` with the notes path as the argument (use the Skill tool with skill="plan"). If no: ask the user what they'd like to do instead.

## Rules
- No code. Research only.
- MUST delegate to `researcher` agent for file exploration. The researcher agent owns the output format.
- Check `.context/` before exploring raw files.
- Monitor context budget per CLAUDE.md thresholds.

## User Input
$ARGUMENTS
