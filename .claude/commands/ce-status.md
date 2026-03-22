# /ce-status - Project Briefing

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

2. **Present a briefing**:
   ```
   ## Project Status

   **What this is**: [1-2 sentence summary from OVERVIEW.md]
   **Tech stack**: [key technologies from TECH_STACK.md]

   ### Features
   **Completed**: [N features]
   [list completed features from FEATURES.md]

   **In Progress**: [N features]
   [list in-progress features with current step]

   **Planned**: [N features]
   [list planned/approved features not yet started]

   ### Recent Activity
   [Last 3-5 learnings from LEARNINGS.md, most recent first]

   ### Knowledge Base
   - [N] code patterns documented
   - [N] anti-patterns documented
   - [N] known error patterns captured
   - [N] architecture decision records

   ### Quick Start
   [If there's an IN_PROGRESS feature]:
     Resume: /ce-implement [PRP path]
   [If not]:
     Start: /ce-research [next topic]
   ```

3. **If `$ARGUMENTS` contains "onboard" or "new"**: Also include:
   - Key dev commands from TECH_STACK.md (test, lint, build)
   - Top 3 most important code patterns
   - Top 3 most common error patterns
   - Architecture component map

## Rules
- Read-only. Don't modify any files.
- Keep it concise. This is a briefing, not a book.
- Prioritize actionable info: what's in progress, what was recently learned, what to do next.
- If `.context/` is mostly empty, say so and recommend running `/ce-init`.

## User Input
$ARGUMENTS
