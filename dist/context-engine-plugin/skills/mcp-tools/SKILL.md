---
name: mcp-tools
description: MCP server integration catalog and configuration reference. Auto-loaded when working with MCP configs. Lists all available and recommended MCP servers with install commands.
user-invocable: false
---

# MCP Server Catalog

Check `.mcp.json` for currently configured MCP servers.
Skills with dedicated SKILL.md: `context7-docs`, `sequential-thinking`, `puppeteer`, `postgres-mcp`, `google-workspace`

## Adding an MCP Server
Add to `.mcp.json` (project-level) or `~/.mcp.json` (global):
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name@latest"],
      "env": {
        "API_KEY": "your-key-here"
      }
    }
  }
}
```

Or via CLI: `claude mcp add-json "server-name" '{"command":"npx","args":["-y","package-name"]}'`

## MCP + Skills Pattern
Wrap MCP tools in skills for context-efficient usage:
- Skill defines WHEN and HOW to use the MCP tools
- MCP server handles the actual operation
- Only results enter the context window

For the full server catalog with all packages and categories, read `REFERENCE.md` in this directory.
