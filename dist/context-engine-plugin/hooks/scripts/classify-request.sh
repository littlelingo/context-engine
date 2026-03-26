#!/bin/bash
# UserPromptSubmit: Classify request complexity to optimize context loading
# Injects hints for minimal tasks (skip teams) and heavy tasks (check budget).
# Matcher: (none - fires on all prompts)

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.user_prompt // empty' 2>/dev/null)

if [ -z "$PROMPT" ]; then
    exit 0
fi

PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Minimal task detection: simple edits that don't need agent delegation
if echo "$PROMPT_LOWER" | grep -qE '(typo|rename|fix import|update version|change string|s]imple fix|one.?line|single line|quick fix)'; then
    echo '{"additionalContext":"Task complexity: MINIMAL. Prefer direct edit over agent delegation. Skip Agent Teams."}'
    exit 0
fi

# Heavy task detection: complex operations that consume significant context
if echo "$PROMPT_LOWER" | grep -qE '(/debug|/refactor|/adapt|/validate|/implement|agent.?team|parallel tracks|complex bug|full audit)'; then
    echo '{"additionalContext":"Task complexity: HEAVY. Check context budget before spawning Agent Teams. If context > 40%, prefer single subagent."}'
    exit 0
fi

# Standard: no special hint needed
exit 0
