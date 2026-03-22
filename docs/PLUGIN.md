# Plugin Distribution Guide

Context Engine can be installed two ways: as a project-level framework (install.sh) or as a Claude Code plugin (marketplace).

## Method 1: Project-Level Install (Recommended for Teams)

Copies files directly into your project's `.claude/` and `.context/` directories. Best when you want the framework committed to your repo so every team member gets it automatically.

```bash
# Clone and install
git clone https://github.com/context-engine/context-engine.git
cd context-engine
./install.sh /path/to/your/project

# Or one-liner
curl -sL https://raw.githubusercontent.com/context-engine/context-engine/main/install.sh | bash -s /path/to/your/project
```

**Pros**: Framework is in your repo, no external dependency, works offline, team members get it via git pull.
**Cons**: Manual updates (re-run install.sh), files are in your repo's git history.

## Method 2: Plugin Install (Recommended for Personal Use)

Install as a Claude Code plugin via the marketplace. Best for personal productivity - the plugin loads automatically in every project without cluttering your repo.

### From Marketplace

```bash
# Add the marketplace (one-time)
/plugin marketplace add context-engine/context-engine

# Install the plugin
/plugin install context-engine@context-engine
```

### From Local Build

```bash
# Build the plugin
./build-plugin.sh

# Install locally
claude plugin add --path ./dist/context-engine-plugin

# Validate
claude plugin validate ./dist/context-engine-plugin
```

**Pros**: Auto-updates via marketplace, no files in your repo, available in all projects.
**Cons**: Requires marketplace setup, commands are namespaced (`/context-engine:plan`), `.context/` still needs to be in your project.

## Plugin Architecture

The build script (`build-plugin.sh`) transforms the project structure into plugin format:

```
Project Structure (.claude/)          Plugin Structure (root-level)
─────────────────────────            ─────────────────────────────
.claude/                             context-engine-plugin/
  agents/                            ├── .claude-plugin/
    researcher.md         ──────>    │   └── plugin.json
    planner.md                       ├── agents/
    ...                              │   ├── researcher.md
  commands/                          │   └── ...
    init.md            ──────>    ├── commands/
    plan.md                       │   ├── init.md
    ...                              │   └── ...
  skills/                            ├── skills/
    context-system/       ──────>    │   ├── context-system/
    react-frontend/                  │   ├── react-frontend/
    ...                              │   ├── context-engine-rules/  (CLAUDE.md as skill)
  hooks/                             │   └── ...
    auto-format.sh        ──────>    ├── hooks/
    ...                              │   ├── hooks.json  (extracted from settings.json)
  settings.json           ──────>    │   └── scripts/
                                     │       ├── auto-format.sh
.context/                            │       └── ...
  architecture/           ──────>    ├── context-templates/  (for init)
  patterns/                          │   ├── architecture/
  errors/                            │   ├── patterns/
  ...                                │   └── ...
                                     ├── .mcp.json  (extracted from settings.json)
                                     ├── settings.json  (permissions + env)
                                     ├── marketplace.json
                                     └── LICENSE
```

Key differences:
- **Hooks**: `settings.json` hooks section becomes `hooks/hooks.json`. Script paths use `${CLAUDE_PLUGIN_ROOT}`.
- **CLAUDE.md**: Becomes a skill (`context-engine-rules/SKILL.md`) with `globs: ["**/*"]` so it always loads.
- **MCP servers**: Extracted from `settings.json` into `.mcp.json` at plugin root.
- **.context/ templates**: Moved to `context-templates/` - the `init` command copies them into the user's project.
- **Commands**: Namespaced as `/context-engine:plan`, `/context-engine:implement`, etc.

## Publishing to a Marketplace

### Self-Hosted (Git Repository)

1. Build the plugin: `./build-plugin.sh`
2. Commit `dist/` and `marketplace.json` to your repo
3. Users add: `/plugin marketplace add your-org/context-engine`
4. Users install: `/plugin install context-engine@context-engine`

### Version Updates

1. Update version in `build-plugin.sh` (the `VERSION` variable)
2. Rebuild: `./build-plugin.sh`
3. Commit and push
4. Users get updates automatically on next session

## Bootstrapping .context/ in Plugin Mode

When installed as a plugin, the `.context/` directory doesn't come with the plugin (it's project-specific). Run `/context-engine:init` in any project to bootstrap:

```
/context-engine:init
```

This copies the context templates from the plugin's `context-templates/` into the project's `.context/` directory, detects the stack, and populates architecture docs.
