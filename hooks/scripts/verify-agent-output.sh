#!/bin/bash
# SubagentStop: Verify subagent/teammate output quality
# Checks that the agent actually produced deliverables (not just a summary).
# Matcher: (none - fires on all subagent completions)

INPUT=$(cat)
AGENT_NAME=$(echo "$INPUT" | jq -r '.agent_name // .subagent_name // "unknown"')

# Check if the subagent made any file changes
CHANGES=$(git diff --name-only 2>/dev/null | wc -l)

# Check if PRP steps were marked complete (for implementer)
PRP_UPDATES=$(git diff --name-only 2>/dev/null | grep "PRP.md" | head -1)

# If implementer/reviewer agent ran but no files changed, flag it
if echo "$AGENT_NAME" | grep -qi "implement"; then
    if [ "$CHANGES" -eq 0 ]; then
        echo "{\"additionalContext\":\"WARNING: Implementer agent completed but no file changes detected. Verify the step was actually implemented, not just planned.\"}"
    fi
fi

exit 0
