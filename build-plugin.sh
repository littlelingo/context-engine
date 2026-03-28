#!/bin/bash
# build-plugin.sh - Package Context Engine as a Claude Code plugin
# Since the repo follows plugin layout (root-level components), this script
# copies the repo into a clean distributable directory.
#
# Usage: ./build-plugin.sh [output-dir]
# Default output: ./dist/context-engine-plugin/

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="${1:-$SCRIPT_DIR/dist/context-engine-plugin}"
VERSION=$(cat "$SCRIPT_DIR/.claude-plugin/plugin.json" | python3 -c "import sys,json; print(json.load(sys.stdin)['version'])" 2>/dev/null || echo "0.0.0")

echo "Building Context Engine Plugin v$VERSION"
echo "Output: $OUTPUT"
echo ""

# Clean and create output
rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"

# 1. Copy plugin manifest
echo "Copying manifest..."
cp -r "$SCRIPT_DIR/.claude-plugin" "$OUTPUT/.claude-plugin"

# 2. Copy commands
echo "Copying commands..."
cp -r "$SCRIPT_DIR/commands" "$OUTPUT/commands"
COMMAND_COUNT=$(ls "$OUTPUT/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo "  $COMMAND_COUNT commands"

# 3. Copy agents
echo "Copying agents..."
cp -r "$SCRIPT_DIR/agents" "$OUTPUT/agents"
AGENT_COUNT=$(ls "$OUTPUT/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo "  $AGENT_COUNT agents"

# 4. Copy skills
echo "Copying skills..."
cp -r "$SCRIPT_DIR/skills" "$OUTPUT/skills"
SKILL_COUNT=$(find "$OUTPUT/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
echo "  $SKILL_COUNT skills"

# 5. Copy hooks (scripts + hooks.json)
echo "Copying hooks..."
cp -r "$SCRIPT_DIR/hooks" "$OUTPUT/hooks"
chmod +x "$OUTPUT/hooks/scripts/"*.sh 2>/dev/null || true
HOOK_COUNT=$(ls "$OUTPUT/hooks/scripts/"*.sh 2>/dev/null | wc -l | tr -d ' ')
echo "  $HOOK_COUNT hook scripts + hooks.json"

# 6. Copy MCP config
echo "Copying MCP config..."
cp "$SCRIPT_DIR/.mcp.json" "$OUTPUT/.mcp.json"

# 7. Shared instructions (referenced by agents and commands)
echo "Copying shared instructions..."
if [ -d "$SCRIPT_DIR/.claude/instructions" ]; then
    mkdir -p "$OUTPUT/instructions"
    cp "$SCRIPT_DIR/.claude/instructions/"*.md "$OUTPUT/instructions/" 2>/dev/null || true
    INSTRUCTION_COUNT=$(ls "$OUTPUT/instructions/"*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  $INSTRUCTION_COUNT instruction files"
fi

# 8. Context templates (for init to bootstrap into user projects)
echo "Copying context templates..."
mkdir -p "$OUTPUT/context-templates"
cp -r "$SCRIPT_DIR/.context/"* "$OUTPUT/context-templates/" 2>/dev/null || true
TEMPLATE_COUNT=$(find "$OUTPUT/context-templates" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "  $TEMPLATE_COUNT template files"

# 9. Add CLAUDE.md as a catch-all skill
mkdir -p "$OUTPUT/skills/context-engine-rules"
cat > "$OUTPUT/skills/context-engine-rules/SKILL.md" << 'EOF'
---
name: context-engine-rules
description: Context Engine core rules. Always active when the plugin is installed.
---
EOF
cat "$SCRIPT_DIR/CLAUDE.md" >> "$OUTPUT/skills/context-engine-rules/SKILL.md"

# 10. Docs
mkdir -p "$OUTPUT/docs"
cp "$SCRIPT_DIR/README.md" "$OUTPUT/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/"* "$OUTPUT/docs/" 2>/dev/null || true

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
TOTAL=$(find "$OUTPUT" -type f | wc -l | tr -d ' ')
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
