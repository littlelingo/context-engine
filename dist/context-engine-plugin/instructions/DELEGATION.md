# Command → Agent Delegation Pattern

When delegating to an agent:
1. **Share the task** — pass the PRP path or request, not a full context summary
2. **Agent reads `.context/` independently** — don't duplicate architecture/pattern content in the prompt
3. **Agent follows its own instructions** — don't repeat agent rules in the command
4. **Hand off with explicit next command** — always end with the exact next `/command`, then prompt `Proceed? (y/n)`. If yes, execute it. If no, ask the user what to do instead.
5. **Monitor context budget** — if > 40%, prefer single subagent over Agent Team
6. **MCP-heavy tasks** — when a task needs 3+ MCP tool calls, delegate to `mcp-researcher` agent. Raw MCP output stays in the subagent's context, only the summary enters yours.
