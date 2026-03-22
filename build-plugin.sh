#!/bin/bash
# build-plugin.sh - Package Context Engine as a Claude Code plugin
# Transforms project structure (.claude/) into plugin structure (root-level components)
#
# Usage: ./build-plugin.sh [output-dir]
# Default output: ./dist/context-engine-plugin/

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="${1:-$SCRIPT_DIR/dist/context-engine-plugin}"
VERSION="0.0.1"

echo "Building Context Engine Plugin v$VERSION"
echo "Output: $OUTPUT"
echo ""

# Clean and create output
rm -rf "$OUTPUT"
mkdir -p "$OUTPUT/.claude-plugin"
mkdir -p "$OUTPUT/commands"
mkdir -p "$OUTPUT/agents"
mkdir -p "$OUTPUT/skills"
mkdir -p "$OUTPUT/hooks/scripts"
mkdir -p "$OUTPUT/context-templates"
mkdir -p "$OUTPUT/docs"

# 1. Plugin manifest
cat > "$OUTPUT/.claude-plugin/plugin.json" << 'MANIFEST'
{
  "name": "context-engine",
  "version": "0.0.1",
  "description": "Agentic orchestration framework for Claude Code. Agent Teams, subagents, progressive-disclosure skills, hooks, checkpoints, knowledge layer, and metrics.",
  "author": {
    "name": "Context Engine",
    "url": "https://github.com/context-engine/context-engine"
  },
  "license": "MIT",
  "keywords": [
    "context-engineering",
    "agent-teams",
    "orchestration",
    "skills",
    "hooks",
    "knowledge-management",
    "checkpoints",
    "metrics"
  ],
  "skills": "./skills/",
  "commands": "./commands/",
  "agents": "./agents/",
  "mcpServers": "./.mcp.json"
}
MANIFEST

# 2. Copy commands (strip ce- prefix for plugin namespacing)
# Plugin commands become /context-engine:init, /context-engine:plan, etc.
echo "Copying commands..."
COMMAND_COUNT=0
for cmd in "$SCRIPT_DIR/.claude/commands/"*.md; do
    name=$(basename "$cmd")
    cp "$cmd" "$OUTPUT/commands/$name"
    COMMAND_COUNT=$((COMMAND_COUNT + 1))
done
echo "  $COMMAND_COUNT commands"

# 3. Copy agents
echo "Copying agents..."
AGENT_COUNT=0
for agent in "$SCRIPT_DIR/.claude/agents/"*.md; do
    cp "$agent" "$OUTPUT/agents/"
    AGENT_COUNT=$((AGENT_COUNT + 1))
done
echo "  $AGENT_COUNT agents"

# 4. Copy skills
echo "Copying skills..."
SKILL_COUNT=0
for skill_dir in "$SCRIPT_DIR/.claude/skills/"*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$OUTPUT/skills/$skill_name"
    cp -r "$skill_dir"* "$OUTPUT/skills/$skill_name/" 2>/dev/null || true
    SKILL_COUNT=$((SKILL_COUNT + 1))
done
echo "  $SKILL_COUNT skills"

# 5. Build hooks/hooks.json from settings.json hooks config
echo "Building hooks..."
python3 -c "
import json, os

settings = json.load(open('$SCRIPT_DIR/.claude/settings.json'))
hooks = settings.get('hooks', {})

# Rewrite script paths to use \${CLAUDE_PLUGIN_ROOT}
for event, matchers in hooks.items():
    for matcher in matchers:
        for hook in matcher.get('hooks', []):
            if hook.get('type') == 'command':
                cmd = hook['command']
                cmd = cmd.replace('.claude/hooks/', '\${CLAUDE_PLUGIN_ROOT}/hooks/scripts/')
                hook['command'] = cmd

json.dump({'hooks': hooks}, open('$OUTPUT/hooks/hooks.json', 'w'), indent=2)
print('  hooks.json generated')
"

# Copy hook scripts
for script in "$SCRIPT_DIR/.claude/hooks/"*.sh; do
    cp "$script" "$OUTPUT/hooks/scripts/"
done
chmod +x "$OUTPUT/hooks/scripts/"*.sh 2>/dev/null || true
HOOK_COUNT=$(ls "$OUTPUT/hooks/scripts/"*.sh 2>/dev/null | wc -l)
echo "  $HOOK_COUNT hook scripts"

# 6. MCP server config (extracted from settings.json)
echo "Building MCP config..."
python3 -c "
import json
settings = json.load(open('$SCRIPT_DIR/.claude/settings.json'))
mcp = settings.get('mcpServers', {})
json.dump({'mcpServers': mcp}, open('$OUTPUT/.mcp.json', 'w'), indent=2)
print('  .mcp.json generated')
"

# 7. Context templates (for ce-init to bootstrap into user projects)
echo "Copying context templates..."
cp -r "$SCRIPT_DIR/.context/"* "$OUTPUT/context-templates/" 2>/dev/null || true
TEMPLATE_COUNT=$(find "$OUTPUT/context-templates" -type f | wc -l)
echo "  $TEMPLATE_COUNT template files"

# 8. Docs
cp "$SCRIPT_DIR/README.md" "$OUTPUT/" 2>/dev/null || true
cp "$SCRIPT_DIR/CONTEXT-ENGINE.md" "$OUTPUT/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/"* "$OUTPUT/docs/" 2>/dev/null || true

# 9. CLAUDE.md as a skill (so it loads in context when plugin is active)
mkdir -p "$OUTPUT/skills/context-engine-rules"
cat > "$OUTPUT/skills/context-engine-rules/SKILL.md" << 'EOF'
---
description: Context Engine core rules. Always active when the plugin is installed.
globs:
  - "**/*"
---
EOF
cat "$SCRIPT_DIR/CLAUDE.md" >> "$OUTPUT/skills/context-engine-rules/SKILL.md"

# 10. Settings template (permissions, env vars for agent teams)
cat > "$OUTPUT/settings.json" << 'SETTINGS'
{
  "permissions": {
    "allow": [
      "Read(**)",
      "Glob(**)",
      "Grep(**)",
      "Bash(find:*)",
      "Bash(wc:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(cat:*)",
      "Bash(git:diff*)",
      "Bash(git:log*)",
      "Bash(git:status*)"
    ]
  },
  "env": {
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "0",
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
SETTINGS

# 11. License
cat > "$OUTPUT/LICENSE" << 'LICENSE'
MIT License

Copyright (c) 2026 Context Engine Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE

# Summary
TOTAL=$(find "$OUTPUT" -type f | wc -l)
echo ""
echo "=== Context Engine Plugin v$VERSION ==="
echo "Commands:  $COMMAND_COUNT"
echo "Agents:    $AGENT_COUNT"
echo "Skills:    $SKILL_COUNT + 1 (rules)"
echo "Hooks:     $HOOK_COUNT scripts + hooks.json"
echo "Templates: $TEMPLATE_COUNT context templates"
echo "Total:     $TOTAL files"
echo ""
echo "Install locally:  claude plugin add --path $OUTPUT"
echo "Validate:         claude plugin validate $OUTPUT"
echo ""
echo "To publish to a marketplace, create a marketplace.json"
echo "and push to a git repository. See docs/PLUGIN.md."
