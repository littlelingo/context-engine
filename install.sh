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
    echo "Installs .claude/ (agents, commands, skills, hooks), .context/, CLAUDE.md, .claudeignore, and docs."
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

echo "Agents (.claude/agents/)..."
safe_copy_dir "$SCRIPT_DIR/.claude/agents" "$TARGET/.claude/agents"

echo "Commands (.claude/commands/)..."
safe_copy_dir "$SCRIPT_DIR/.claude/commands" "$TARGET/.claude/commands"

echo "Skills (.claude/skills/)..."
safe_copy_dir "$SCRIPT_DIR/.claude/skills" "$TARGET/.claude/skills"

echo "Hooks (.claude/hooks/)..."
safe_copy_dir "$SCRIPT_DIR/.claude/hooks" "$TARGET/.claude/hooks"
# Ensure hooks are executable
chmod +x "$TARGET/.claude/hooks/"*.sh 2>/dev/null || true

echo "Settings (.claude/settings.json)..."
safe_copy "$SCRIPT_DIR/.claude/settings.json" "$TARGET/.claude/settings.json"

# --- Context templates ---

echo "Context templates (.context/)..."
safe_copy_dir "$SCRIPT_DIR/.context" "$TARGET/.context"

# --- Root files ---

echo "Root config files..."
safe_copy "$SCRIPT_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
safe_copy "$SCRIPT_DIR/CLAUDE.local.md" "$TARGET/CLAUDE.local.md"
safe_copy "$SCRIPT_DIR/.claudeignore" "$TARGET/.claudeignore"
safe_copy "$SCRIPT_DIR/README.md" "$TARGET/CONTEXT-ENGINE.md"

# --- Documentation ---

echo "Documentation (docs/)..."
safe_copy "$SCRIPT_DIR/docs/WALKTHROUGH.md" "$TARGET/docs/WALKTHROUGH.md"
safe_copy "$SCRIPT_DIR/docs/CHEATSHEET.md" "$TARGET/docs/CHEATSHEET.md"


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
    cp "$SCRIPT_DIR/.gitignore" "$TARGET/.gitignore"
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
echo "  3. /ce-init"
echo ""
echo -e "${BOLD}Commands:${NC}"
echo "  /ce-research     Explore codebase (Phase 1)"
echo "  /ce-plan         Create implementation plan (Phase 2)"
echo "  /ce-plan-quick   Quick plan for small tasks"
echo "  /ce-implement    Execute plan step-by-step (Phase 3)"
echo "  /ce-validate     Review, simplify, capture learnings (Phase 4)"
echo "  /ce-debug        Diagnose and fix bugs"
echo "  /ce-refactor     Restructure existing code"
echo "  /ce-status       Project briefing"
echo "  /ce-resume       Resume after /clear"
echo "  /ce-learn        Capture error, pattern, decision, or insight"
echo "  /ce-update-arch  Refresh architecture docs"
echo ""
echo -e "${BOLD}Docs:${NC}"
echo "  docs/WALKTHROUGH.md  Full cycle walkthrough with examples"
echo "  docs/CHEATSHEET.md   Quick reference card"
echo "  CONTEXT-ENGINE.md    Framework README"
