#!/bin/bash
# PostToolUse: Monitor context budget via tool call count proxy
# Warns when approaching context thresholds.
# Matcher: Read|Bash

COUNTER="/tmp/.context-engine-tool-count"
MARKER="/tmp/.session-start"

# Reset counter if session is new (session-track.sh creates marker)
if [ -f "$MARKER" ] && [ -f "$COUNTER" ]; then
    if [ "$MARKER" -nt "$COUNTER" ]; then
        echo "0" > "$COUNTER"
    fi
fi

# Increment counter
COUNT=0
if [ -f "$COUNTER" ]; then
    COUNT=$(cat "$COUNTER" 2>/dev/null || echo "0")
fi
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER"

# Warn at thresholds (only once per threshold)
if [ "$COUNT" -eq 80 ]; then
    echo '{"additionalContext":"Context budget WARNING: ~80 tool calls this session. Strongly recommend /clear + /resume before continuing."}'
elif [ "$COUNT" -eq 50 ]; then
    echo '{"additionalContext":"Context budget NOTE: ~50 tool calls this session. Consider wrapping up the current step and preparing to /clear."}'
fi

exit 0
