# /knowledge - Browse & Manage Knowledge Base

Search, browse, and maintain the deep knowledge layer.

## Process

Parse `$ARGUMENTS` to determine the action:

### No arguments: Overview
1. Count entries in each knowledge area
2. List library files in `.context/knowledge/libraries/` (excluding TEMPLATE.md)
3. List stack recipe files in `.context/knowledge/stack/` (excluding TEMPLATE.md)
4. Count dependency pins in `.context/knowledge/dependencies/PINS.md`
5. Count quick insights in `.context/knowledge/LEARNINGS.md`
6. Count ADR files in `.context/decisions/` (excluding any TEMPLATE.md)
7. Count files in `.context/architecture/`
8. Report total knowledge entries and suggest areas that may need attention

### `search [query]`: Search across all knowledge
Search across all `.context/` knowledge sources:
- `.context/knowledge/` — learnings, libraries, stack recipes, dependency pins
- `.context/errors/` — error index and detail files
- `.context/patterns/` — code patterns and anti-patterns
- `.context/decisions/` — architecture decision records
- `.context/architecture/` — system overview, tech stack, directory map

1. Grep case-insensitively across all sources listed above for the query
2. Return matching entries with file paths and surrounding context
3. Highlight which type of knowledge matched (library, stack, dependency, error, pattern, decision, architecture)

### `library [name]`: Show library knowledge
1. Look for `.context/knowledge/libraries/[name].md`
2. If found: display contents
3. If not found: check LEARNINGS.md for mentions, suggest creating a dedicated file

### `recipe [name]`: Show stack recipe
1. Look for `.context/knowledge/stack/[name].md`
2. If found: display contents
3. If not found: suggest creating from template

### `pins`: Show all dependency pins
1. Display `.context/knowledge/dependencies/PINS.md`

### `promote [library-or-topic]`: Promote from LEARNINGS.md to deep reference
1. Find all entries in LEARNINGS.md mentioning the topic
2. Create a new file from TEMPLATE.md in the appropriate subdirectory
3. Move the entries from LEARNINGS.md into the new file
4. Add a cross-reference note in LEARNINGS.md pointing to the new file

### `cleanup`: Maintenance
1. Find duplicate entries across knowledge files
2. Flag LEARNINGS.md entries that should be promoted (3+ mentions of same library)
3. Check for empty or stale knowledge files
4. Report recommendations
5. Scan `.context/features/` for subdirectories containing a PRP with status COMPLETE or CANCELLED
   - For each candidate, check the PRP file for a completion date; fall back to `git log --follow` on the directory to find the last-modified date
   - If the feature has been COMPLETE or CANCELLED for more than 30 days, suggest archiving it
   - **Never suggest archiving IN_PROGRESS or APPROVED features**
   - Confirm with the user before archiving each feature
   - Archive: append a summary entry to `.context/features/ARCHIVE.md` (feature number, name, status, completion date, key files changed, one-line summary from PRP), then delete the feature directory
   - If `.context/features/ARCHIVE.md` does not exist, create it with a `# Feature Archive` header before appending

## Rules
- Read-only by default - only `promote` and `cleanup` modify files
- Search is case-insensitive and searches file contents, not just names
- Template files (TEMPLATE.md) are never included in counts or search results

## User Input
$ARGUMENTS
