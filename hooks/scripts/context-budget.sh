#!/bin/bash
# PostToolUse: Monitor context budget via weighted tool call count proxy
# Warns when approaching context thresholds.
# Matcher: Read|Bash
# Note: Matcher should ideally also include Grep|Glob — weights are defined below
# for those tools so the logic is ready when the matcher is expanded in hooks.json.

# Weighting rationale: tools that produce large output consume proportionally more
# context tokens. A full file read can return thousands of lines; a Bash call
# typically returns a short status or diff; Grep/Glob return path lists.
#   Read=3  (full file contents, can be very large)
#   Bash=2  (command output, moderate size)
#   Grep=2  (matching lines with context, moderate size)
#   Glob=1  (file path list only, smallest footprint)

PROJECT_HASH=$(git rev-parse --show-toplevel 2>/dev/null | md5 -q 2>/dev/null || git rev-parse --show-toplevel 2>/dev/null | md5sum 2>/dev/null | cut -c1-8 || echo "default")
COUNTER="/tmp/.context-engine-tool-count-${PROJECT_HASH}"
MARKER="/tmp/.context-engine-session-${PROJECT_HASH}"

# Reset counter if session is new (session-track.sh creates marker)
if [ -f "$MARKER" ] && [ -f "$COUNTER" ]; then
    if [ "$MARKER" -nt "$COUNTER" ]; then
        echo "0" > "$COUNTER"
    fi
fi

# Read tool name from stdin (PostToolUse receives JSON: {"tool_name": "...", ...})
TOOL_NAME=$(cat /dev/stdin | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")

# Assign weight based on tool name
case "$TOOL_NAME" in
    Read)   WEIGHT=3 ;;
    Bash)   WEIGHT=2 ;;
    Grep)   WEIGHT=2 ;;
    Glob)   WEIGHT=1 ;;
    *)      WEIGHT=1 ;;
esac

# Add weighted units to counter
COUNT=0
if [ -f "$COUNTER" ]; then
    COUNT=$(cat "$COUNTER" 2>/dev/null || echo "0")
fi
COUNT=$((COUNT + WEIGHT))
echo "$COUNT" > "$COUNTER"

# Warn at thresholds (only once per threshold, in weighted units)
if [ "$COUNT" -ge 80 ] && [ "$((COUNT - WEIGHT))" -lt 80 ]; then
    echo '{"additionalContext":"Context budget WARNING: ~80 weighted units this session. Strongly recommend /clear + /resume before continuing."}'
elif [ "$COUNT" -ge 50 ] && [ "$((COUNT - WEIGHT))" -lt 50 ]; then
    echo '{"additionalContext":"Context budget NOTE: ~50 weighted units this session. Consider wrapping up the current step and preparing to /clear."}'
fi

exit 0
