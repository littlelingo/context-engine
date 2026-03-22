#!/bin/bash
# Context Engine Installer
# Usage: ./install.sh [target-directory]
# Installs the context engineering framework into an existing project.

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

TARGET="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COUNT_FILE=$(mktemp)
echo "0 0" > "$COUNT_FILE"
trap "rm -f '$COUNT_FILE'" EXIT

# Help
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Context Engine Installer"
    echo ""
    echo "Usage: ./install.sh [target-directory]"
    echo ""
    echo "  target-directory  Path to your project (default: current directory)"
    echo ""
    echo "Installs commands, agents, skills, hooks into .claude/ and sets up .context/ templates."
    echo "Existing files are never overwritten - review manually if needed."
    exit 0
fi

# Validate target
if [ ! -d "$TARGET" ]; then
    echo -e "${RED}Error${NC}: Target directory '$TARGET' does not exist."
    exit 1
fi

# Resolve to absolute path for clear output
TARGET="$(cd "$TARGET" && pwd)"

# Increment counter (works across subshells via temp file)
inc_installed() { read i s < "$COUNT_FILE"; echo "$((i+1)) $s" > "$COUNT_FILE"; }
inc_skipped()   { read i s < "$COUNT_FILE"; echo "$i $((s+1))" > "$COUNT_FILE"; }

# Copy a single file without overwriting
safe_copy() {
    local src="$1" dest="$2"
    if [ -f "$dest" ]; then
        echo -e "  ${YELLOW}EXISTS${NC}: $dest (skipped)"
        inc_skipped
        return
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo -e "  ${GREEN}CREATED${NC}: $dest"
    inc_installed
}

# Copy all files in a directory tree (including dotfiles like .gitkeep)
safe_copy_dir() {
    local src_dir="$1" dest_dir="$2"
    find "$src_dir" -type f -not -name ".DS_Store" | while read -r file; do
        local rel_path="${file#$src_dir/}"
        safe_copy "$file" "$dest_dir/$rel_path"
    done
}

echo -e "${BOLD}Context Engine${NC} - Installing to: $TARGET"
echo ""

# --- Core framework ---
# Source is root-level (plugin layout), target gets .claude/ structure

echo "Agents (.claude/agents/)..."
safe_copy_dir "$SCRIPT_DIR/agents" "$TARGET/.claude/agents"

echo "Commands (.claude/commands/)..."
safe_copy_dir "$SCRIPT_DIR/commands" "$TARGET/.claude/commands"

echo "Skills (.claude/skills/)..."
safe_copy_dir "$SCRIPT_DIR/skills" "$TARGET/.claude/skills"

echo "Hooks (.claude/hooks/)..."
safe_copy_dir "$SCRIPT_DIR/hooks/scripts" "$TARGET/.claude/hooks"
# Ensure hooks are executable
chmod +x "$TARGET/.claude/hooks/"*.sh 2>/dev/null || true

echo "Settings (.claude/settings.json)..."
# Generate clean settings for target (no dev-specific statusLine/mcpServers)
if [ ! -f "$TARGET/.claude/settings.json" ]; then
    mkdir -p "$TARGET/.claude"
    cat > "$TARGET/.claude/settings.json" << 'SETTINGS_EOF'
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
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/guard-protected-files.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/block-destructive.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/auto-format.sh"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/preserve-context.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/capture-learnings.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/verify-agent-output.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/session-track.sh"
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
    echo -e "  ${GREEN}CREATED${NC}: $TARGET/.claude/settings.json"
    inc_installed
else
    echo -e "  ${YELLOW}EXISTS${NC}: $TARGET/.claude/settings.json (skipped)"
    inc_skipped
fi

# --- Context templates ---

echo "Context templates (.context/)..."
safe_copy_dir "$SCRIPT_DIR/.context" "$TARGET/.context"

# --- Root files ---

echo "Root config files..."
safe_copy "$SCRIPT_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
if [ -f "$SCRIPT_DIR/.claudeignore" ]; then
    safe_copy "$SCRIPT_DIR/.claudeignore" "$TARGET/.claudeignore"
fi
if [ -f "$SCRIPT_DIR/README.md" ]; then
    safe_copy "$SCRIPT_DIR/README.md" "$TARGET/CONTEXT-ENGINE.md"
fi

# --- Documentation ---

echo "Documentation (docs/)..."
if [ -f "$SCRIPT_DIR/docs/WALKTHROUGH.md" ]; then
    safe_copy "$SCRIPT_DIR/docs/WALKTHROUGH.md" "$TARGET/docs/WALKTHROUGH.md"
fi
if [ -f "$SCRIPT_DIR/docs/CHEATSHEET.md" ]; then
    safe_copy "$SCRIPT_DIR/docs/CHEATSHEET.md" "$TARGET/docs/CHEATSHEET.md"
fi

# --- .gitignore ---

echo ".gitignore..."
GITIGNORE_ENTRIES=("CLAUDE.local.md" ".claude/settings.local.json" ".DS_Store" "Thumbs.db")
if [ -f "$TARGET/.gitignore" ]; then
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if ! grep -qF "$entry" "$TARGET/.gitignore" 2>/dev/null; then
            echo "$entry" >> "$TARGET/.gitignore"
            echo -e "  ${GREEN}ADDED${NC}: '$entry' to .gitignore"
        fi
    done
else
    printf '%s\n' "${GITIGNORE_ENTRIES[@]}" > "$TARGET/.gitignore"
    echo -e "  ${GREEN}CREATED${NC}: .gitignore"
    inc_installed
fi

# --- Summary ---

read INSTALLED SKIPPED < "$COUNT_FILE"
echo ""
echo "-------------------------------------------"
echo -e "${GREEN}Installed${NC}: $INSTALLED files"
if [ "$SKIPPED" -gt 0 ]; then
    echo -e "${YELLOW}Skipped${NC}: $SKIPPED files (already existed)"
fi
echo "-------------------------------------------"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. cd $TARGET"
echo "  2. claude"
echo "  3. /init"
echo ""
echo -e "${BOLD}Commands:${NC}"
echo "  /research     Explore codebase (Phase 1)"
echo "  /plan         Create implementation plan (Phase 2)"
echo "  /plan-quick   Quick plan for small tasks"
echo "  /implement    Execute plan step-by-step (Phase 3)"
echo "  /validate     Review, simplify, capture learnings (Phase 4)"
echo "  /debug        Diagnose and fix bugs"
echo "  /refactor     Restructure existing code"
echo "  /status       Project briefing"
echo "  /resume       Resume after /clear"
echo "  /learn        Capture error, pattern, decision, or insight"
echo "  /update-arch  Refresh architecture docs"
echo ""
echo -e "${BOLD}Docs:${NC}"
echo "  docs/WALKTHROUGH.md  Full cycle walkthrough with examples"
echo "  docs/CHEATSHEET.md   Quick reference card"
echo "  CONTEXT-ENGINE.md    Framework README"
