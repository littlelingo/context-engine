#!/bin/bash
# PostToolUse: Auto-format files after edits
# Detects project formatter and runs it on changed files.
# Matcher: Write|Edit|MultiEdit

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

EXT="${FILE_PATH##*.}"
FORMATTED=false

# Try project-level formatters first (check config files exist)
if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f ".prettierrc.yml" ] || [ -f "prettier.config.js" ] || [ -f "prettier.config.mjs" ]; then
    if command -v npx &>/dev/null; then
        npx prettier --write "$FILE_PATH" 2>/dev/null && FORMATTED=true
    fi
fi

if [ "$FORMATTED" = false ] && { [ -f ".eslintrc" ] || [ -f ".eslintrc.json" ] || [ -f ".eslintrc.yml" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; }; then
    case "$EXT" in
        js|jsx|ts|tsx|mjs|cjs)
            if command -v npx &>/dev/null; then
                npx eslint --fix "$FILE_PATH" 2>/dev/null && FORMATTED=true
            fi
            ;;
    esac
fi

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
            if command -v gofmt &>/dev/null; then
                gofmt -w "$FILE_PATH" 2>/dev/null && FORMATTED=true
            fi
            ;;
        rs)
            if command -v rustfmt &>/dev/null; then
                rustfmt "$FILE_PATH" 2>/dev/null && FORMATTED=true
            fi
            ;;
    esac
fi

# No output needed - formatting is a side effect
exit 0
