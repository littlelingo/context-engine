#!/bin/bash
# init-templates.sh - Deterministically copy bundled context templates into a target project
#
# Used by /init and /init repair to seed (or repair) `.context/` from the canonical
# templates that ship with the plugin. This is a SHELL script (not LLM prose) because
# template copying must be reliable — past versions of /init relied on the LLM agent
# remembering to "copy templates" and produced 0-byte files in real projects.
#
# Usage:
#   init-templates.sh seed   [target-dir]   # Copy templates only where target file is missing or 0 bytes
#   init-templates.sh repair [target-dir]   # Same as seed (alias) — never overwrites non-empty files
#   init-templates.sh verify [target-dir]   # Report missing/empty template-managed files; exit 1 if any
#   init-templates.sh force  [target-dir]   # Overwrite ALL template-managed files (DANGEROUS — confirms first)
#
# target-dir defaults to current working directory. Templates are copied into `<target-dir>/.context/`.
#
# Source resolution order for templates:
#   1. $CONTEXT_ENGINE_TEMPLATES (explicit override)
#   2. $CLAUDE_PLUGIN_ROOT/context-templates (when invoked from a plugin install)
#   3. $(dirname $0)/../../context-templates (when invoked from a dev checkout)
#
# Exit codes:
#   0 = success (or verify found everything)
#   1 = verify found gaps, or copy failed
#   2 = source templates not found
#   3 = bad arguments

set -e

ACTION="${1:-seed}"
TARGET="${2:-$PWD}"
CONTEXT_DIR="$TARGET/.context"

# --- Resolve source templates ---
if [ -n "$CONTEXT_ENGINE_TEMPLATES" ] && [ -d "$CONTEXT_ENGINE_TEMPLATES" ]; then
    SRC="$CONTEXT_ENGINE_TEMPLATES"
elif [ -n "$CLAUDE_PLUGIN_ROOT" ] && [ -d "$CLAUDE_PLUGIN_ROOT/context-templates" ]; then
    SRC="$CLAUDE_PLUGIN_ROOT/context-templates"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    if [ -d "$SCRIPT_DIR/../../context-templates" ]; then
        SRC="$(cd "$SCRIPT_DIR/../../context-templates" && pwd)"
    fi
fi

if [ -z "$SRC" ] || [ ! -d "$SRC" ]; then
    echo "ERROR: Could not locate context-templates source directory." >&2
    echo "  Tried: \$CONTEXT_ENGINE_TEMPLATES, \$CLAUDE_PLUGIN_ROOT/context-templates, ../../context-templates" >&2
    exit 2
fi

# --- Canonical list of template-managed files (relative to .context/) ---
# These are the files /init must guarantee exist with non-zero content after running.
# Files that grow via auto-capture (LEARNINGS, INDEX, HEALTH) are seeded with their headers
# and then appended to by commands. Files that are pure stubs (TEMPLATE.md, ADR-000-template.md)
# are seeded once and never modified — they serve as format references.
TEMPLATE_FILES=(
    "architecture/OVERVIEW.md"
    "architecture/TECH_STACK.md"
    "architecture/DIRECTORY_MAP.md"
    "patterns/CODE_PATTERNS.md"
    "patterns/ANTI_PATTERNS.md"
    "decisions/ADR-000-template.md"
    "errors/INDEX.md"
    "errors/detail/TEMPLATE.md"
    "features/FEATURES.md"
    "knowledge/LEARNINGS.md"
    "knowledge/libraries/TEMPLATE.md"
    "knowledge/stack/TEMPLATE.md"
    "knowledge/dependencies/PINS.md"
    "checkpoints/MANIFEST.md"
    "metrics/HEALTH.md"
    "metrics/RECOMMENDATIONS.md"
    "templates/PRP-TEMPLATE.md"
    "templates/NOTES-TEMPLATE.md"
)

# Files that should exist as empty placeholders (.gitkeep)
GITKEEP_DIRS=(
    "errors/detail"
    "features"
)

# --- Helpers ---
file_is_empty_or_missing() {
    local path="$1"
    [ ! -f "$path" ] || [ ! -s "$path" ]
}

# Verify a source file exists in the bundled templates; warn if not
src_exists() {
    [ -f "$SRC/$1" ]
}

# --- Actions ---
do_seed() {
    local force="${1:-no}"
    local copied=0
    local skipped=0
    local missing_src=0

    mkdir -p "$CONTEXT_DIR"

    for rel in "${TEMPLATE_FILES[@]}"; do
        local dst="$CONTEXT_DIR/$rel"
        local src="$SRC/$rel"

        if ! src_exists "$rel"; then
            echo "  WARN: source missing: $rel" >&2
            missing_src=$((missing_src + 1))
            continue
        fi

        mkdir -p "$(dirname "$dst")"

        if [ "$force" = "yes" ] || file_is_empty_or_missing "$dst"; then
            cp "$src" "$dst"
            copied=$((copied + 1))
        else
            skipped=$((skipped + 1))
        fi
    done

    for d in "${GITKEEP_DIRS[@]}"; do
        mkdir -p "$CONTEXT_DIR/$d"
        [ -f "$CONTEXT_DIR/$d/.gitkeep" ] || touch "$CONTEXT_DIR/$d/.gitkeep"
    done

    echo "Templates: $copied copied, $skipped already populated (preserved), $missing_src source-missing"
    [ "$missing_src" -gt 0 ] && return 1
    return 0
}

do_verify() {
    local missing=0
    local empty=0
    local ok=0
    local report=""

    for rel in "${TEMPLATE_FILES[@]}"; do
        local dst="$CONTEXT_DIR/$rel"
        if [ ! -f "$dst" ]; then
            report="$report\n  MISSING: $rel"
            missing=$((missing + 1))
        elif [ ! -s "$dst" ]; then
            report="$report\n  EMPTY:   $rel"
            empty=$((empty + 1))
        else
            ok=$((ok + 1))
        fi
    done

    echo "Context template verification:"
    echo "  Source: $SRC"
    echo "  Target: $CONTEXT_DIR"
    echo "  OK: $ok | MISSING: $missing | EMPTY: $empty"
    if [ "$missing" -gt 0 ] || [ "$empty" -gt 0 ]; then
        echo -e "$report"
        echo ""
        echo "To repair: init-templates.sh repair [target-dir]"
        return 1
    fi
    return 0
}

case "$ACTION" in
    seed|repair)
        do_seed no
        ;;
    force)
        echo "WARNING: 'force' will overwrite existing template-managed files."
        echo "This includes architecture/*.md, patterns/*.md, etc."
        echo "Files that have grown beyond their stub state WILL BE LOST."
        echo ""
        read -p "Type 'yes' to confirm: " confirm
        if [ "$confirm" != "yes" ]; then
            echo "Aborted."
            exit 0
        fi
        do_seed yes
        ;;
    verify)
        do_verify
        ;;
    *)
        echo "Usage: $0 {seed|repair|verify|force} [target-dir]" >&2
        exit 3
        ;;
esac
