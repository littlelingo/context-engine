# /status - Project Briefing

Synthesize the current state of the project from `.context/`. Useful for onboarding, catching up after a break, or getting the big picture.

This command is read-only. It doesn't modify anything.

## Process

1. **Read project knowledge** (in this order, skip any that don't exist):
   - `.context/architecture/OVERVIEW.md` - what the project is
   - `.context/architecture/TECH_STACK.md` - languages, frameworks, commands
   - `.context/features/FEATURES.md` - what's been built and what's in progress
   - `.context/knowledge/LEARNINGS.md` - recent insights (last 5-10 entries)
   - `.context/errors/INDEX.md` - number of known error patterns
   - `.context/patterns/CODE_PATTERNS.md` - number of documented patterns

2. **Present a briefing** covering: project summary, tech stack, features (completed/in-progress/planned with current step), last 3-5 learnings, knowledge base counts (patterns, errors, ADRs), and next action (resume command or research suggestion).

3. **If `$ARGUMENTS` contains "onboard" or "new"**: Also include key dev commands, top 3 code patterns, top 3 error patterns, and architecture component map.

## Rules
- Read-only. Don't modify any files.
- Keep it concise. This is a briefing, not a book.
- Prioritize actionable info: what's in progress, what was recently learned, what to do next.
- If `.context/` is mostly empty, say so and recommend running `/init`.

## User Input
$ARGUMENTS
