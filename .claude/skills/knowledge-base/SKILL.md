---
description: Deep knowledge layer - project-specific library quirks, stack recipes, dependency notes. Auto-loaded when working with knowledge files or when implement/debug discovers something worth preserving.
globs:
  - ".context/knowledge/**"
  - "package.json"
  - "requirements*.txt"
  - "pyproject.toml"
  - "Gemfile"
  - "go.mod"
  - "Cargo.toml"
---

# Deep Knowledge Layer

Project-specific technical knowledge that persists across sessions. Three tiers:

## Storage Structure
```
.context/knowledge/
  LEARNINGS.md              Quick insights (2-3 sentences each)
  libraries/                Per-library deep reference
    TEMPLATE.md             Copy for new libraries
    [library-name].md       Quirks, workarounds, patterns
  stack/                    Integration recipes
    TEMPLATE.md             Copy for new recipes
    [recipe-name].md        Multi-tool config patterns
  dependencies/
    PINS.md                 Version pins and upgrade blockers
```

## When to Capture (Hybrid Model)

### Auto-Capture (implement + debug phases)
The implementer and debugger agents write to knowledge automatically when they:
- Discover a library behaves unexpectedly (-> `libraries/[name].md`)
- Find a version-specific bug or incompatibility (-> `dependencies/PINS.md`)
- Resolve a bug caused by tool integration (-> `stack/[recipe].md`)
- Hit any "aha moment" that took > 5 minutes to figure out (-> `LEARNINGS.md`)

### Manual Capture (research + plan phases)
Use `/ce-learn` to manually route knowledge:
- `/ce-learn library quirk: React Query v5 onSuccess removed, use onSettled`
- `/ce-learn stack recipe: Next.js + Prisma + tRPC setup`
- `/ce-learn dependency pin: Tailwind pinned to 3.x, 4.x breaks PostCSS`
- `/ce-learn insight: Our API rate limiting needs per-user, not per-IP`

## How to Read Knowledge

Before implementing or debugging, check relevant knowledge:
1. `LEARNINGS.md` - scan for relevant quick insights
2. `libraries/[name].md` - if working with a specific library
3. `stack/[name].md` - if touching an integration point
4. `dependencies/PINS.md` - before upgrading or adding dependencies

## Promotion Rules
- Quick insight in LEARNINGS.md that grows to 5+ lines -> promote to `libraries/` or `stack/`
- Same library appearing 3+ times in LEARNINGS.md -> create dedicated `libraries/[name].md`
- Copy from TEMPLATE.md when creating new deep reference files

## Knowledge vs Other .context/ Files
| What | Where | Why |
|------|-------|-----|
| Error signatures + fixes | `.context/errors/` | Greppable by exact error text |
| Code conventions | `.context/patterns/` | Style rules, not library-specific |
| Architecture decisions | `.context/decisions/` | "We chose X over Y because..." |
| Library quirks | `.context/knowledge/libraries/` | "X behaves unexpectedly when..." |
| Config recipes | `.context/knowledge/stack/` | "To set up X + Y together, do..." |
| Version constraints | `.context/knowledge/dependencies/` | "Pinned to vX because..." |
| Quick insights | `.context/knowledge/LEARNINGS.md` | Everything else worth remembering |
