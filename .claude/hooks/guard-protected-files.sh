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

exit 0
