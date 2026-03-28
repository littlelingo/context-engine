#!/bin/bash
# Stop: Verify learnings were captured before session ends
# Checks if .context/ was updated during this session.
# If no updates detected and work was done, reminds to capture.
# Matcher: (none - fires on all stop events)

# Check if any .context/ files were modified in the last 30 minutes
RECENT_UPDATES=$(find .context/ -name "*.md" -newer /tmp/.session-start 2>/dev/null | head -5)

# Check if code files were modified (indicates work was done)
CODE_CHANGES=$(git diff HEAD --name-only 2>/dev/null | grep -v '.context/' | head -1)

if [ -n "$CODE_CHANGES" ] && [ -z "$RECENT_UPDATES" ]; then
    # Work was done but no learnings captured
    echo "{\"additionalContext\":\"REMINDER: Code changes detected but no .context/ updates found. Consider capturing learnings before ending: patterns to .context/patterns/, errors to .context/errors/INDEX.md, insights to .context/knowledge/LEARNINGS.md. Run /learn if needed.\"}"
fi

exit 0
