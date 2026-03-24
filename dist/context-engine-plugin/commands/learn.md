# /learn - Capture Knowledge

Capture a learning from the current session. Routes to the correct file based on type.

## Process

1. **Determine type** from `$ARGUMENTS` or conversation context:

   **Error patterns** -> `.context/errors/INDEX.md` + `.context/errors/detail/ERR-NNN.md`
   **Code patterns** -> `.context/patterns/CODE_PATTERNS.md`
   **Anti-patterns** -> `.context/patterns/ANTI_PATTERNS.md`
   **Architecture decisions** -> `.context/decisions/ADR-NNN-title.md`
   **Library quirks/workarounds** -> `.context/knowledge/libraries/[library-name].md`
   **Stack config recipes** -> `.context/knowledge/stack/[recipe-name].md`
   **Dependency version pins** -> `.context/knowledge/dependencies/PINS.md`
   **General insights** -> `.context/knowledge/LEARNINGS.md`

2. **For deep knowledge files** (libraries/, stack/):
   - Check if a file already exists for this library/recipe
   - If yes: append to the appropriate section
   - If no: copy the TEMPLATE.md, rename it, fill in the entry

3. **Check for duplicates** in the target file.

4. **Write the entry** with appropriate format:
   - Errors: `### ERR-NNN: [desc]` with Signature (greppable text from logs), Cause, Fix, Prevention
   - Patterns: `### [Name]` with context, example, rationale
   - Decisions: ADR format (context, decision, consequences)
   - Library quirks: Under `## Quirks & Gotchas` or `## Workarounds`
   - Stack recipes: Full recipe with config, order of operations, common failures
   - Dependency pins: `### [package]` with version, reason, blocker
   - General: `### [Date] - [Topic]` with 2-3 sentence insight

5. **Promotion check**: If LEARNINGS.md has 3+ entries about the same library or integration, suggest promoting to a dedicated deep reference file.

6. **Confirm** what was captured and where.

## Routing Hints

Prefix-based routing (optional - helps with explicit categorization):
- `/learn library quirk: ...` -> libraries/
- `/learn stack recipe: ...` -> stack/
- `/learn dependency pin: ...` -> dependencies/PINS.md
- `/learn error: ...` -> errors/
- `/learn pattern: ...` -> patterns/
- `/learn decision: ...` -> decisions/
- `/learn insight: ...` -> LEARNINGS.md

Without prefix: infer from content (library name mentioned -> libraries/, version mentioned -> dependencies/, config/setup -> stack/, error/fix -> errors/).

## Rules
- Keep entries concise - future sessions will read these
- Always include *why*, not just what
- Library files: include the version where behavior was observed
- Stack recipes: include the exact config that works (not just description)
- Error signatures must be greppable - exact text from logs/terminal
- Number errors (ERR-NNN) and decisions (ADR-NNN) sequentially and globally — read INDEX.md or decisions/ to find the highest existing number and increment. Avoid collisions across sessions.
- Use kebab-case for filenames: `react-query.md`, `nextjs-prisma-trpc.md`

## User Input
$ARGUMENTS
