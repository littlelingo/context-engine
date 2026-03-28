#!/bin/bash
# PreToolUse: Block destructive bash commands
# Prevents rm -rf, DROP TABLE, truncate, and other dangerous operations.
# Matcher: Bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
    exit 0
fi

# Destructive patterns (case-insensitive check for SQL)
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|--force\s+)(/|~|\.\.)'; then
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Blocked: destructive rm targeting root, home, or parent directory\"}}"
    exit 0
fi

if echo "$COMMAND" | grep -qiE 'DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE|DELETE\s+FROM\s+\S+\s*;?\s*$'; then
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"ask\",\"permissionDecisionReason\":\"Destructive database operation detected. Please confirm.\"}}"
    exit 0
fi

if echo "$COMMAND" | grep -qE '>\s*/dev/sd|mkfs\.|dd\s+if=.*of=/dev'; then
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Blocked: disk-level destructive operation\"}}"
    exit 0
fi

# Block mkdir creating .claude directories from a subdirectory (memory must live at project root)
# Pattern requires .claude to be followed by end-of-string, a slash, or whitespace — prevents
# false positives on names like .claude-backup or .claude-old.
if echo "$COMMAND" | grep -qE 'mkdir\s.*\.claude(/|\s|$)'; then
    GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
    if [[ "$PWD" != "$GIT_ROOT" ]]; then
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Blocked: mkdir .claude from subdirectory ($PWD). Agent memory must be created at the project root ($GIT_ROOT/.claude/agent-memory/).\"}}"
        exit 0
    fi
fi

# Git force-push guard
# Match any git push with a force flag (-f, --force, --force-with-lease).
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(-f\b|--force\b|--force-with-lease\b)|(git\s+push\s+(-f\b|--force\b|--force-with-lease\b))'; then
    # Check whether main or master is the explicit target.
    # Matches patterns like: git push -f origin main
    #                         git push --force origin master
    #                         git push --force-with-lease origin main
    if echo "$COMMAND" | grep -qE 'git\s+push\s+.*\s(main|master)(\s|$)'; then
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Blocked: force push to main/master is not allowed. Use a feature branch and open a PR instead.\"}}"
        exit 0
    else
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"ask\",\"permissionDecisionReason\":\"Force push detected on a non-main branch. This rewrites remote history — confirm only if you intended this (e.g., amending a feature branch).\"}}"
        exit 0
    fi
fi

exit 0
