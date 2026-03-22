#!/bin/bash
# PreCompact: Preserve critical context before compaction
# Injects reminders about active PRP, current feature, and .context/ state
# so the agent retains project awareness after context is compressed.
# Matcher: (none - fires on all compaction events)

# Find active PRP (IN_PROGRESS status)
ACTIVE_PRP=""
ACTIVE_FEATURE=""
if [ -d ".context/features" ]; then
    ACTIVE_PRP=$(grep -rl "Status: IN_PROGRESS" .context/features/*/PRP.md 2>/dev/null | head -1)
    if [ -n "$ACTIVE_PRP" ]; then
        ACTIVE_FEATURE=$(basename "$(dirname "$ACTIVE_PRP")")
    fi
fi

# Find current branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# Find testing strategy
STRATEGY=$(grep -oP 'Testing Strategy:\s*\K\S+' "$ACTIVE_PRP" 2>/dev/null || grep -oP '\*\*Default\*\*:\s*`\K[^`]+' CLAUDE.md 2>/dev/null || echo "implement-then-test")

# Build the context injection
CONTEXT="CONTEXT PRESERVED BEFORE COMPACTION:"
CONTEXT="$CONTEXT\n- Branch: $BRANCH"

if [ -n "$ACTIVE_PRP" ]; then
    # Read the PRP steps to show progress
    TOTAL=$(grep -c '^\s*[0-9]*\.\s*\[' "$ACTIVE_PRP" 2>/dev/null || echo "0")
    DONE=$(grep -c '^\s*[0-9]*\.\s*\[x\]' "$ACTIVE_PRP" 2>/dev/null || echo "0")
    CONTEXT="$CONTEXT\n- Active PRP: $ACTIVE_PRP ($DONE/$TOTAL steps complete)"
    CONTEXT="$CONTEXT\n- Feature: $ACTIVE_FEATURE"
    CONTEXT="$CONTEXT\n- Testing strategy: $STRATEGY"
    CONTEXT="$CONTEXT\n- To resume: /implement $ACTIVE_PRP"
else
    CONTEXT="$CONTEXT\n- No active PRP found"
    CONTEXT="$CONTEXT\n- To check status: /status"
fi

CONTEXT="$CONTEXT\n- Project knowledge: .context/ (architecture, patterns, errors, learnings)"
CONTEXT="$CONTEXT\n- Recent learnings: .context/knowledge/LEARNINGS.md"
CONTEXT="$CONTEXT\n- Known errors: .context/errors/INDEX.md"

# Return as additionalContext so it survives compaction
printf '{"additionalContext":"%s"}' "$(echo -e "$CONTEXT" | sed 's/"/\\"/g' | tr '\n' ' ')"
