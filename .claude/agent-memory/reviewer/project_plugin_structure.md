---
name: plugin-structure-findings
description: Plugin audit findings - fragile areas, known issues, and structural facts about context-engine as a Claude Code plugin
type: project
---

Plugin layout is root-level (commands/, agents/, skills/, hooks/) with `.claude-plugin/plugin.json` as manifest.
`.claude/` contains symlinks to root-level components for local dev (hooks symlinks to hooks/scripts).

**Known fragile area: deployment-cicd SKILL.md**
File: `skills/deployment-cicd/SKILL.md`
The frontmatter has orphaned YAML list items (`- "vercel.json"`, `- "netlify.toml"`) that were left behind after a `globs:` key was removed. YAML parses them silently into the description string, producing a corrupted description. This is a latent issue - not a hard failure but semantically wrong.

**Why:** globs: is not a supported SKILL.md field (confirmed in spec). The list items were remnants.
**How to apply:** When reviewing skill frontmatter, watch for orphaned list items under description.

**install.sh is a traditional installer, not a plugin**: It intentionally copies to `.claude/` in the target project. The `.claude/hooks/` paths in the generated settings.json are correct for that installer's use case.

**marketplace.json location**: Lives at `.claude-plugin/marketplace.json`, NOT at root. Audit spec refers to it at root but it's correctly in the plugin manifest directory.

**build-plugin.sh step numbering**: Step 10 is missing (jumps from 9 to 11). Cosmetic only, no functional impact.

**Counts verified (as of 2026-03-22)**:
- Commands: 15
- Agents: 5
- Skills: 19 (CLAUDE.md and context-system SKILL.md both say 19 - CORRECT)
- Hook scripts: 7
