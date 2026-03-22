---
name: context-engine project structure
description: Full file structure, symlinks, and key paths for the context-engine plugin repo
type: project
---

Context Engine is both a runnable dev project and a distributable Claude Code plugin.

Root layout:
- agents/       (5 agents: researcher, planner, implementer, reviewer, debugger)
- commands/     (15 commands: ce-init, ce-research, ce-plan, ce-plan-quick, ce-implement, ce-validate, ce-debug, ce-refactor, ce-status, ce-resume, ce-learn, ce-knowledge, ce-checkpoint, ce-health, ce-update-arch)
- skills/       (19 skills - all have SKILL.md frontmatter)
- hooks/scripts/ (7 scripts: guard-protected-files.sh, block-destructive.sh, auto-format.sh, preserve-context.sh, capture-learnings.sh, session-track.sh, verify-agent-output.sh)
- hooks/hooks.json  (plugin-time hook config using ${CLAUDE_PLUGIN_ROOT}/ paths)
- .claude/      (dev-time config with symlinks to root-level dirs)
  - settings.json  (identical to root settings.json + statusLine + mcpServers + hooks with relative paths)
  - agents -> ../agents
  - commands -> ../commands
  - skills -> ../skills
  - hooks -> ../hooks/scripts
  - agent-memory/researcher/  (researcher role memory dir, currently empty)
- .claude-plugin/plugin.json   (name, version, description, author, license, keywords)
- .claude-plugin/marketplace.json  (full marketplace listing with strict:true)
- .mcp.json     (chrome-devtools only)
- settings.json (root - permissions + env only, no hooks/statusLine/mcpServers)
- CLAUDE.md     (plugin-facing: references skills/ commands/ hooks/ paths, not .claude/)
- install.sh    (copies root dirs -> .claude/ in target project)
- build-plugin.sh  (packages for dist/)

Why: The repo serves double duty - it IS the dev project and the plugin source.
symlinks in .claude/ allow Claude Code to find agents/commands/skills/hooks during dev sessions.
How to apply: When searching for file paths, agents/commands/skills live at root level. .claude/ is just a symlink layer for dev.
