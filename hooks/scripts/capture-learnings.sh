#!/bin/bash
# Stop: Verify learnings were captured AND properly routed before session ends
# Detects multiple capture/promotion gaps and emits a single combined reminder.
# Matcher: (none - fires on all stop events)

REMINDERS=""

# Skip entirely if no .context/ exists
[ ! -d .context ] && exit 0

# --- Gather signals ---
RECENT_UPDATES=$(find .context/ -name "*.md" -newer /tmp/.session-start 2>/dev/null | head -10)
CODE_CHANGES=$(git diff HEAD --name-only 2>/dev/null | grep -v '.context/' | head -1)
DEBUG_ACTIVITY=$(git diff HEAD --name-only 2>/dev/null | grep -iE 'fix/|debug|\.test\.' | head -1)
ERROR_CAPTURED=$(find .context/errors/ -name "*.md" -newer /tmp/.session-start 2>/dev/null | grep -v TEMPLATE | head -1)
INDEX_DIFF=$(git diff HEAD -- .context/errors/INDEX.md 2>/dev/null | head -1)
LEARNINGS_DIFF=$(git diff HEAD -- .context/knowledge/LEARNINGS.md 2>/dev/null)
LEARNINGS_GREW=$(echo "$LEARNINGS_DIFF" | grep -c '^+' || echo 0)
DEEP_KNOWLEDGE_TOUCHED=$(find .context/knowledge/libraries .context/knowledge/stack .context/knowledge/dependencies -name '*.md' -newer /tmp/.session-start 2>/dev/null | grep -v TEMPLATE | head -1)
MANIFEST_DIFF=$(git diff HEAD -- .context/checkpoints/MANIFEST.md 2>/dev/null | head -1)
FEATURE_TOUCHED=$(git diff HEAD --name-only 2>/dev/null | grep -E '^\.context/features/' | head -1)

# --- Check 1: Code changes without ANY .context capture ---
if [ -n "$CODE_CHANGES" ] && [ -z "$RECENT_UPDATES" ]; then
    REMINDERS="$REMINDERS\n[CAPTURE GAP] Code changes detected but no .context/ updates. Capture learnings before ending: patterns→.context/patterns/, errors→.context/errors/INDEX.md, insights→.context/knowledge/LEARNINGS.md. Run /learn if needed."
fi

# --- Check 2: Debug/fix activity without error capture ---
if [ -n "$DEBUG_ACTIVITY" ] && [ -z "$ERROR_CAPTURED" ] && [ -z "$INDEX_DIFF" ]; then
    REMINDERS="$REMINDERS\n[ERROR CAPTURE GAP] Debug/fix activity detected but no errors captured to .context/errors/INDEX.md. Capture with /learn error: [description] so future sessions find it by signature."
fi

# --- Check 3: LEARNINGS grew but no promotion to deep knowledge attempted ---
# When LEARNINGS.md gains substantive content but libraries/stack/PINS are untouched,
# the promotion pipeline was skipped — this was the #1 root cause of empty knowledge dirs.
if [ "$LEARNINGS_GREW" -gt 5 ] && [ -z "$DEEP_KNOWLEDGE_TOUCHED" ]; then
    # Quick heuristic: did the new LEARNINGS content mention library-like names?
    NEW_LEARNINGS_CONTENT=$(echo "$LEARNINGS_DIFF" | grep '^+' | grep -v '^+++')
    if echo "$NEW_LEARNINGS_CONTENT" | grep -qiE '\b(pydantic|sqlalchemy|react|fastapi|django|express|axios|requests|prisma|next|vue|svelte|tailwind|jest|pytest|vitest|playwright|cypress|redis|postgres|mongodb)\b'; then
        REMINDERS="$REMINDERS\n[PROMOTION GAP] LEARNINGS.md grew with library-related content but no .context/knowledge/libraries|stack|dependencies file was touched. Run /knowledge promote auto to route entries to the deep knowledge layer — this prevents libraries/ and stack/ from staying empty across features."
    fi
fi

# --- Check 4: Feature work happened but no checkpoint was created ---
# Phase boundary commands (planner/implement/validate) should append to MANIFEST.md.
# If a feature dir was touched but MANIFEST.md is unchanged, a checkpoint was skipped.
if [ -n "$FEATURE_TOUCHED" ] && [ -z "$MANIFEST_DIFF" ]; then
    REMINDERS="$REMINDERS\n[CHECKPOINT GAP] Feature work detected (.context/features/ modified) but checkpoints/MANIFEST.md was not updated. Phase commands should run \${CLAUDE_PLUGIN_ROOT}/hooks/scripts/checkpoint-create.sh — never narrate the steps. Run it now if you're at a phase boundary."
fi

# --- Emit single combined reminder if any gaps found ---
if [ -n "$REMINDERS" ]; then
    if command -v jq &>/dev/null; then
        printf '%s' "{\"additionalContext\":$(printf 'Context Engine session-end checks:%s' "$REMINDERS" | jq -sRr '.')}"
    else
        ESCAPED=$(printf 'Context Engine session-end checks:%s' "$REMINDERS" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')
        printf '{"additionalContext":"%s"}' "$ESCAPED"
    fi
fi

exit 0
