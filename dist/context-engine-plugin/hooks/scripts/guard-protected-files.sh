#!/bin/bash
# PreToolUse: Guard protected files from AI edits
# Blocks writes to sensitive files that should only be edited by humans.
# Matcher: Write|Edit|MultiEdit

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Protected patterns
PROTECTED=(
    ".env"
    ".env.local"
    ".env.production"
    ".git/"
    "package-lock.json"
    "yarn.lock"
    "pnpm-lock.yaml"
    "Gemfile.lock"
    "poetry.lock"
    "go.sum"
    ".claude/settings.json"
    ".claude/settings.local.json"
)

for pattern in "${PROTECTED[@]}"; do
    if [[ "$FILE_PATH" == *"$pattern"* ]]; then
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Protected file: $FILE_PATH - edit manually if needed\"}}"
        exit 0
    fi
done

# Block writes to nested .claude directories (memory must live at root .claude/)
# Only check paths within the project tree (skip external paths like ~/.claude/)
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
NORMALIZED="${FILE_PATH#$GIT_ROOT/}"
NORMALIZED="${NORMALIZED#./}"
if [[ "$NORMALIZED" != /* ]]; then
    if [[ "$NORMALIZED" == *"/.claude/"* ]] || [[ "$NORMALIZED" == *"/.claude" ]]; then
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Nested .claude directory detected: $FILE_PATH — agent memory must be written to .claude/agent-memory/ at the project root, not inside subdirectories.\"}}"
        exit 0
    fi
fi

exit 0
