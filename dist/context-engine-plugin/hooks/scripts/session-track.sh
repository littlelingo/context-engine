#!/bin/bash
# UserPromptSubmit: Session tracking for other hooks
# Creates a session marker on first prompt so Stop hook can detect
# whether work was done and learnings need capturing.
# Matcher: (none - fires on all prompts)

# Create session marker on first prompt (if doesn't exist or is old)
PROJECT_HASH=$(git rev-parse --show-toplevel 2>/dev/null | md5 -q 2>/dev/null || git rev-parse --show-toplevel 2>/dev/null | md5sum 2>/dev/null | cut -c1-8 || echo "default")
MARKER="/tmp/.context-engine-session-${PROJECT_HASH}"
if [ ! -f "$MARKER" ] || [ $(find "$MARKER" -mmin +120 2>/dev/null | wc -l) -gt 0 ]; then
    touch "$MARKER"
fi

exit 0
