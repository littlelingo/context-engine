#!/bin/bash
# Stop: Verify metrics were recorded for completed features
# Checks if a feature was marked COMPLETE in this session but lacks metrics in HEALTH.md.
# Matcher: (none - fires on all stop events)

FEATURES_FILE=".context/features/FEATURES.md"
HEALTH_FILE=".context/metrics/HEALTH.md"

# Only check if FEATURES.md exists
[ -f "$FEATURES_FILE" ] || exit 0

# Check if a feature was marked COMPLETE in the current session (via uncommitted changes)
COMPLETED_FEATURES=$(git diff HEAD -- "$FEATURES_FILE" 2>/dev/null | grep "^+" | grep -E "\| COMPLETE( \(unvalidated\))? \|" | grep -oE "\| [0-9]+ \|" | tr -d "| ")

if [ -z "$COMPLETED_FEATURES" ]; then
    # No features marked COMPLETE this session - check for untracked feature directories
    FEATURE_DIRS=$(find .context/features/ -mindepth 1 -maxdepth 1 -type d -name "[0-9]*" 2>/dev/null | wc -l | tr -d ' ')
    TRACKED_COUNT=$(grep -cE "^\| [0-9]+" "$FEATURES_FILE" 2>/dev/null || echo "0")

    if [ "$FEATURE_DIRS" -gt 0 ] && [ "$TRACKED_COUNT" -eq 0 ]; then
        echo "{\"additionalContext\":\"METRICS GAP: Found $FEATURE_DIRS feature directories in .context/features/ but none are listed in FEATURES.md. Run /health backfill to populate feature tracking and capture metrics.\"}"
    fi
    exit 0
fi

# For each completed feature, check if metrics exist in HEALTH.md
MISSING=""
for FEAT_NUM in $COMPLETED_FEATURES; do
    # Check if a completed metrics row exists (not just a partial IN_PROGRESS row from validate step 5)
    if ! grep -qE "^\| $FEAT_NUM " "$HEALTH_FILE" 2>/dev/null; then
        MISSING="$MISSING $FEAT_NUM"
    elif grep -qE "^\| $FEAT_NUM .*IN_PROGRESS" "$HEALTH_FILE" 2>/dev/null; then
        MISSING="$MISSING $FEAT_NUM(partial)"
    fi
done

if [ -n "$MISSING" ]; then
    MISSING=$(echo "$MISSING" | xargs)
    echo "{\"additionalContext\":\"METRICS INCOMPLETE: Feature(s) $MISSING marked COMPLETE but metrics missing or partial in HEALTH.md. Run /health record [feature-NNN] to complete metrics, or ensure /validate step 12 writes to HEALTH.md. Entries marked (partial) have an IN_PROGRESS row from validate step 5 that was never finalized.\"}"
fi

exit 0
