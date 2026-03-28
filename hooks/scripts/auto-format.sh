#!/bin/bash
# PostToolUse: Auto-format files after edits
# Detects project formatter and runs it on changed files.
# Matcher: Write|Edit|MultiEdit
#
# Optimizations:
# - Early exit for non-source files (.md, .json, .context/, .claude/, dist/)
# - Cached formatter detection (5-min TTL)
# - Skip during Agent Team execution (format at team completion)

INPUT=$(cat)

# Extract file paths — handles both Edit (single file_path) and MultiEdit (edits[] array)
FILE_PATHS=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
ti = d.get('tool_input', {})
paths = []
fp = ti.get('file_path') or ti.get('filePath')
if fp:
    paths.append(fp)
for edit in ti.get('edits', []):
    p = edit.get('file_path') or edit.get('filePath')
    if p:
        paths.append(p)
print('\n'.join(paths))
" 2>/dev/null)

if [ -z "$FILE_PATHS" ]; then
    exit 0
fi

CACHE="/tmp/.context-engine-formatter-cache"
CACHE_TTL=300  # 5 minutes

# Check formatter cache (avoids re-detecting on every edit)
use_cached_formatter() {
    if [ -f "$CACHE" ] && [ $(($(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || stat -c %Y "$CACHE" 2>/dev/null || echo 0))) -lt $CACHE_TTL ]; then
        cat "$CACHE"
        return 0
    fi
    return 1
}

detect_formatter() {
    if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f ".prettierrc.yml" ] || [ -f "prettier.config.js" ] || [ -f "prettier.config.mjs" ]; then
        echo "prettier"
    elif [ -f ".eslintrc" ] || [ -f ".eslintrc.json" ] || [ -f ".eslintrc.yml" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; then
        echo "eslint"
    else
        echo "language"
    fi
}

FORMATTER=$(use_cached_formatter || { F=$(detect_formatter); echo "$F" > "$CACHE"; echo "$F"; })

format_file() {
    local FILE_PATH="$1"

    [ ! -f "$FILE_PATH" ] && return

    # Skip non-source files and framework directories
    case "$FILE_PATH" in
        *.md|*.json|*.yaml|*.yml|*.toml|*.lock|*.csv)
            return ;;
        *.context/*|*.claude/*|*/dist/*|*/node_modules/*|*/.git/*)
            return ;;
        .context/*|.claude/*|dist/*)
            return ;;
    esac

    local EXT="${FILE_PATH##*.}"
    local FORMATTED=false

    case "$FORMATTER" in
        prettier)
            if command -v npx &>/dev/null; then
                npx prettier --write "$FILE_PATH" 2>/dev/null && FORMATTED=true
            fi
            ;;
        eslint)
            case "$EXT" in
                js|jsx|ts|tsx|mjs|cjs)
                    if command -v npx &>/dev/null; then
                        npx eslint --fix "$FILE_PATH" 2>/dev/null && FORMATTED=true
                    fi
                    ;;
            esac
            ;;
    esac

    # Language-specific fallbacks
    if [ "$FORMATTED" = false ]; then
        case "$EXT" in
            py)
                if command -v ruff &>/dev/null; then
                    ruff format "$FILE_PATH" 2>/dev/null && FORMATTED=true
                elif command -v black &>/dev/null; then
                    black -q "$FILE_PATH" 2>/dev/null && FORMATTED=true
                fi
                ;;
            go)
                command -v gofmt &>/dev/null && gofmt -w "$FILE_PATH" 2>/dev/null && FORMATTED=true
                ;;
            rs)
                command -v rustfmt &>/dev/null && rustfmt "$FILE_PATH" 2>/dev/null && FORMATTED=true
                ;;
        esac
    fi
}

while IFS= read -r FILE_PATH; do
    [ -z "$FILE_PATH" ] && continue
    format_file "$FILE_PATH"
done <<< "$FILE_PATHS"

exit 0
