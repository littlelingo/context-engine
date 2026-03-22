# /research - Phase 1: Research

No code in this phase. Understand what exists before planning.

## Process

1. **Clarify**: Restate what the user wants. Ask if ambiguous.
2. **MUST delegate**: Use the `researcher` agent to explore the codebase.
3. **Check `.context/`**: Read architecture, patterns, and errors for existing knowledge.
4. **Synthesize**: Produce a summary with current state, gaps, dependencies, risks, open questions.
5. **Save**: Write to `.context/features/[topic]/NOTES.md`
6. **Reflect**: Update `.context/` with any new architecture info, patterns, or errors discovered.
7. **Hand off**:
   ```
   Research saved to: .context/features/[topic]/NOTES.md
   Next: /plan .context/features/[topic]/NOTES.md
   ```

## Research Summary Format
```markdown
# Research: [Topic]
## Date: [today]
## Current State
[How things work now - reference specific files]
## Gap Analysis
[What needs to change]
## Dependencies
[Other components affected]
## Risks & Known Issues
[From .context/errors/ and patterns]
## Open Questions
[Decisions needed from user]
## Recommended Approach
[High-level suggestion - NOT a full plan]
```

## Rules
- No code. Research only.
- MUST delegate to `researcher` agent for file exploration.
- Check `.context/` before exploring raw files.
- If context > 50%, save notes and recommend `/clear` before planning.

## User Input
$ARGUMENTS
