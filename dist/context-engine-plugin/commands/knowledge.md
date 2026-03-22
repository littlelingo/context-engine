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
6. Report total knowledge entries and suggest areas that may need attention

### `search [query]`: Search across all knowledge
1. Grep across all `.context/knowledge/` files for the query
2. Also search `.context/errors/INDEX.md` and `.context/patterns/`
3. Return matching entries with file paths and surrounding context
4. Highlight which type of knowledge matched (library, stack, dependency, error, pattern)

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

## Rules
- Read-only by default - only `promote` and `cleanup` modify files
- Search is case-insensitive and searches file contents, not just names
- Template files (TEMPLATE.md) are never included in counts or search results

## User Input
$ARGUMENTS
