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

# Check if debug/fix activity occurred without error index capture
DEBUG_ACTIVITY=$(git diff HEAD --name-only 2>/dev/null | grep -iE 'fix/|debug|\.test\.' | head -1)
# Check for new error files OR updates to INDEX.md (which includes known-error hit counter increments)
ERROR_CAPTURED=$(find .context/errors/ -name "*.md" -newer /tmp/.session-start 2>/dev/null | grep -v TEMPLATE | head -1)
INDEX_UPDATED=$(git diff HEAD -- .context/errors/INDEX.md 2>/dev/null | head -1)

if [ -n "$DEBUG_ACTIVITY" ] && [ -z "$ERROR_CAPTURED" ] && [ -z "$INDEX_UPDATED" ]; then
    echo "{\"additionalContext\":\"ERROR CAPTURE GAP: Debug/fix activity detected but no errors captured to .context/errors/INDEX.md. If you encountered and resolved an error, capture it with /learn error: [description] so future sessions can find it by signature.\"}"
fi

exit 0
