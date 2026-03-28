#!/bin/bash
# PreToolUse: Guard protected files from AI edits
# Blocks writes to sensitive files that should only be edited by humans.
# Matcher: Write|Edit|MultiEdit

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

# Protected patterns - anchored to prevent false matches
# Each pattern is a regex tested against the path relative to git root
PROTECTED=(
    '(^|/)\.env$'
    '(^|/)\.env\.'
    '(^|/)\.git/'
    '(^|/)package-lock\.json$'
    '(^|/)yarn\.lock$'
    '(^|/)pnpm-lock\.yaml$'
    '(^|/)Gemfile\.lock$'
    '(^|/)poetry\.lock$'
    '(^|/)go\.sum$'
    '(^|/)\.claude/settings\.json$'
    '(^|/)\.claude/settings\.local\.json$'
)

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")

while IFS= read -r FILE_PATH; do
    [ -z "$FILE_PATH" ] && continue

    for pattern in "${PROTECTED[@]}"; do
        if [[ "$FILE_PATH" =~ $pattern ]]; then
            echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Protected file: $FILE_PATH - edit manually if needed\"}}"
            exit 0
        fi
    done

    # Block writes to nested .claude directories (memory must live at root .claude/)
    # Only check paths within the project tree (skip external paths like ~/.claude/)
    NORMALIZED="${FILE_PATH#$GIT_ROOT/}"
    NORMALIZED="${NORMALIZED#./}"
    if [[ "$NORMALIZED" != /* ]]; then
        if [[ "$NORMALIZED" == *"/.claude/"* ]] || [[ "$NORMALIZED" == *"/.claude" ]]; then
            echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Nested .claude directory detected: $FILE_PATH — agent memory must be written to .claude/agent-memory/ at the project root, not inside subdirectories.\"}}"
            exit 0
        fi
    fi
done <<< "$FILE_PATHS"

exit 0
