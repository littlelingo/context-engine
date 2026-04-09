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

### `promote [library-or-topic]`: Promote from LEARNINGS.md to deep reference (manual)
1. Find all entries in LEARNINGS.md mentioning the topic
2. Create a new file from TEMPLATE.md in the appropriate subdirectory
3. Move the entries from LEARNINGS.md into the new file
4. Add a cross-reference note in LEARNINGS.md pointing to the new file

### `promote auto`: Auto-promote LEARNINGS entries to deep knowledge

Scan `.context/knowledge/LEARNINGS.md` for promotable entries and route them to the correct deep-knowledge file. This is the **promotion pipeline** that closes the loop between auto-capture (which dumps to LEARNINGS) and the deep knowledge layer (`libraries/`, `stack/`, `dependencies/PINS.md`, `patterns/CODE_PATTERNS.md`, `patterns/ANTI_PATTERNS.md`).

Designed to be invoked by `/validate` step 10 (auto) and manually after large batches of learnings accumulate.

**Process:**

1. **Read LEARNINGS.md** and split it into individual entries (each `## ` heading is one entry).

2. **Classify each entry** by content signal:
   - **Library quirk** → `knowledge/libraries/[name].md`. Signal: entry mentions a specific library/package by name (Pydantic, SQLAlchemy, React Query, requests, axios, etc.) AND describes non-obvious behavior, a workaround, a gotcha, or version-specific behavior.
   - **Stack recipe** → `knowledge/stack/[recipe-name].md`. Signal: entry describes a multi-component integration setup (async DB + test fixture, build tool wiring, deploy pipeline, auth flow). Cross-cutting between 2+ tools.
   - **Dependency pin** → `knowledge/dependencies/PINS.md`. Signal: entry mentions a specific version, an upgrade blocker, or "we can't go past vX.Y because…".
   - **Code pattern** → `patterns/CODE_PATTERNS.md`. Signal: entry establishes a positive convention this project should follow ("we always do X").
   - **Anti-pattern** → `patterns/ANTI_PATTERNS.md`. Signal: entry describes a mistake or footgun ("don't do X because Y broke when we did").
   - **Keep in LEARNINGS** → no clear signal, or the entry is a one-off observation that doesn't fit the deep buckets. Leave alone.

3. **For each promotable entry**, choose ONE of:
   - **Move**: append to the target deep file, replace the LEARNINGS entry with a 1-line pointer (`> Promoted to: knowledge/libraries/pydantic.md`). Use this for entries that are clearly out of place in LEARNINGS.
   - **Mirror**: append to the target deep file, leave the LEARNINGS entry intact (no pointer). Use this for entries that are valuable in both places — e.g., a recent insight worth keeping in the chronological feed AND in the persistent library reference.
   - Default to **Move** for clear library/stack/dependency content. Default to **Mirror** for patterns/anti-patterns (they're often discovered during the same session and useful in both views).

4. **For new deep-knowledge files**, use the appropriate template:
   - `knowledge/libraries/[name].md` → start from `knowledge/libraries/TEMPLATE.md`, fill in the library name and version, then append the promoted content under "Quirks & Gotchas" or "Workarounds".
   - `knowledge/stack/[name].md` → start from `knowledge/stack/TEMPLATE.md`, fill in components, append under appropriate sections.
   - `knowledge/dependencies/PINS.md` → append a new entry block to the existing file using the format in the file's header comment.

5. **For existing deep-knowledge files**, append to the most appropriate section. Do NOT overwrite existing content.

6. **Report**:
   ```
   Knowledge promotion summary:
     LEARNINGS entries scanned: [N]
     Promoted to libraries/:    [list with file names]
     Promoted to stack/:        [list with file names]
     Promoted to PINS.md:       [count]
     Promoted to CODE_PATTERNS: [count]
     Promoted to ANTI_PATTERNS: [count]
     Kept in LEARNINGS:         [N]
   ```

**Safety rules:**
- Never delete a LEARNINGS entry without leaving a pointer (Move) or keeping the original (Mirror).
- Never overwrite an existing deep-knowledge file's content — always append.
- Skip any entry whose classification is ambiguous. Bias toward leaving things in LEARNINGS rather than misrouting.
- Skip any entry that already contains a `> Promoted to:` pointer (idempotent — safe to re-run).
- Show a summary before writing if more than 5 entries will be promoted; ask for confirmation when invoked manually. When invoked automatically by `/validate`, proceed without confirmation but report the summary.

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
