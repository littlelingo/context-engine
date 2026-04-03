#!/bin/bash
# PreToolUse: Warn before committing with unvalidated features
# Intercepts git commit when an IN_PROGRESS PRP exists in FEATURES.md,
# reminding that /validate hasn't run. Uses "ask" so the user can still proceed.
# Matcher: Bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
    exit 0
fi

# Only intercept git commit commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+commit\b'; then
    exit 0
fi

FEATURES_FILE=".context/features/FEATURES.md"

# No features file means no tracked PRPs — nothing to enforce
[ -f "$FEATURES_FILE" ] || exit 0

# Check for any IN_PROGRESS features that haven't been validated
IN_PROGRESS=$(grep -E '\|\s*IN_PROGRESS\s*\|' "$FEATURES_FILE" 2>/dev/null | head -5)

if [ -z "$IN_PROGRESS" ]; then
    exit 0
fi

# Extract feature names for the warning message
FEATURE_NAMES=$(echo "$IN_PROGRESS" | sed 's/.*| *//;s/ *|.*//' | head -3 | tr '\n' ', ' | sed 's/, $//')

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"ask\",\"permissionDecisionReason\":\"VALIDATION SKIPPED: Feature(s) still IN_PROGRESS — /validate has not run. Before committing, ensure: (1) learnings captured to .context/ (patterns, errors, insights, library quirks), (2) metrics row written to .context/metrics/HEALTH.md, (3) FEATURES.md status updated. Proceed only if all three are done.\"}}"
exit 0
