# /research - Phase 1: Research

No code in this phase. Understand what exists before planning.

## Process

1. **Clarify**: Restate what the user wants. Ask if ambiguous.
2. **Verify context engine baseline**: Run `${CLAUDE_PLUGIN_ROOT}/hooks/scripts/init-templates.sh verify .` and check that `.context/architecture/OVERVIEW.md`, `TECH_STACK.md`, `DIRECTORY_MAP.md`, and `patterns/CODE_PATTERNS.md` are not just stubs (file exists, > 25 lines, mentions the actual project — not just headings and HTML comments). If any are thin or stub-only, the engine has not been properly bootstrapped against this codebase. Run `/adapt populate` automatically to back-fill them before continuing — research conclusions are only as good as the architecture context they're built on. If `init-templates.sh verify` fails with MISSING/EMPTY files, run `/init repair` first.
3. **MUST delegate**: Use the `researcher` agent to explore the codebase. Follow `.claude/instructions/DELEGATION.md` delegation pattern.
4. **Check `.context/`**: Read architecture docs, patterns, and **explicitly check `.context/errors/INDEX.md`** for known errors related to this feature area (matching libraries, file paths, or patterns). Known errors should inform the research summary's risks and potential issues.
5. **Synthesize**: Produce a summary with current state, gaps, dependencies, risks, open questions.
6. **Save**: Write to `.context/features/[NNN]-[topic]/NOTES.md`:
   - Read FEATURES.md to find the highest existing feature number [NNN]
   - Increment by 1 (do not reuse gaps — e.g., if 001 and 003 exist, next is 004)
   - Verify `.context/features/[NNN]-*` directory doesn't already exist
   - Create the directory and write NOTES.md
7. **Reflect**: Update `.context/` with any new architecture info, patterns, or errors discovered. Use formats from `.claude/instructions/CAPTURE-FORMAT.md` when writing to `.context/`.
8. **Commit research artifacts** (automatic — no user prompt): Stage and commit all `.context/` changes (NOTES.md, FEATURES.md, any reflection updates) with `docs: research [topic]`. These are framework bookkeeping, not user code — commit silently so artifacts survive branch creation, worktree spawns, and checkpoints.
9. **Hand off**:
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
