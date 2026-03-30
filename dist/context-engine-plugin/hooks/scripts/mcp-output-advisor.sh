#!/bin/bash
# PostToolUse: Advise context compression after MCP tool calls
# MCP tools often return large output. This hook injects a reminder
# to summarize findings rather than carrying raw output forward.
# Matcher: mcp__.*

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")

# Only fire for MCP tools (safety check beyond matcher)
case "$TOOL_NAME" in
    mcp__*) ;;
    *) exit 0 ;;
esac

# Categorize by output size risk
# HIGH: tools that return full DOM trees, screenshots, network dumps, audit reports
# MEDIUM: tools that return query results, lists, evaluations
# LOW: tools that perform actions with minimal output (clicks, navigation, fills)
RISK="LOW"

case "$TOOL_NAME" in
    *take_screenshot*|*take_snapshot*|*take_memory_snapshot*)
        RISK="HIGH" ;;
    *list_network_requests*|*lighthouse_audit*|*performance_stop_trace*|*performance_analyze*)
        RISK="HIGH" ;;
    *query*|*get_network_request*|*get_console_message*|*evaluate_script*|*evaluate*)
        RISK="MEDIUM" ;;
    *list_console_messages*|*list_pages*|*get_task*|*get_tasks*)
        RISK="MEDIUM" ;;
    *resolve*|*sequentialthinking*)
        RISK="MEDIUM" ;;
esac

if [ "$RISK" = "HIGH" ]; then
    echo '{"additionalContext":"CONTEXT MODE: This MCP tool likely returned large output. Extract ONLY the specific data points you need (selectors, values, errors) and discard the raw output mentally. Do not reference or repeat the full output in your next response."}'
elif [ "$RISK" = "MEDIUM" ]; then
    echo '{"additionalContext":"CONTEXT MODE: Summarize the MCP result in 3-5 key findings. Do not carry raw output forward."}'
fi

exit 0
