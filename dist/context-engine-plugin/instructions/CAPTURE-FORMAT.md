# .context/ Capture Formats

## Error Signatures → `.context/errors/INDEX.md`
```
### ERR-NNN: [short description]
**Signature**: [greppable error text]
**Cause**: [root cause]
**Fix**: [what resolved it]
**Prevention**: [how to avoid in future]
```
For complex errors, also write `.context/errors/detail/ERR-NNN.md` with full analysis.

## Learnings → `.context/knowledge/LEARNINGS.md`
```
### [Date] - [Topic]
[2-3 sentence insight]
```

## Patterns → `.context/patterns/CODE_PATTERNS.md`
```
### [Pattern Name]
**Context**: [when this applies]
**Example**: [code or reference]
**Rationale**: [why this pattern]
```

## Anti-Patterns → `.context/patterns/ANTI_PATTERNS.md`
```
### [Name]
**Don't**: [what to avoid]
**Do**: [what to do instead]
**Why**: [consequence of the anti-pattern]
```

## Library Quirks → `.context/knowledge/libraries/[name].md`
Create from `TEMPLATE.md` if new. Use kebab-case filenames.

## Version Pins → `.context/knowledge/dependencies/PINS.md`
```
### [package-name]
**Version**: [pinned version]
**Reason**: [why pinned]
**Blocker**: [what breaks if upgraded]
```
