---
description: MCP server integration catalog and configuration reference. Auto-loaded when working with MCP configs. Lists all available and recommended MCP servers with install commands.
globs:
  - ".mcp.json"
  - "**/.mcp.json"
  - "**/mcp/**"
---

# MCP Server Catalog

Check `.mcp.json` and `.claude/settings.json` for currently configured servers.
Skills with dedicated SKILL.md: `context7-docs`, `sequential-thinking`, `puppeteer`, `postgres-mcp`, `google-workspace`

## Recommended MCP Servers

### Documentation & Research
| Server | Package | Purpose |
|--------|---------|---------|
| **Context7** | `npx -y @context7/mcp@latest` | Library docs lookup (prevents hallucinated APIs) |
| **Exa** | `npx -y exa-mcp-server` | AI-powered web search (needs EXA_API_KEY) |

### Reasoning & Thinking
| Server | Package | Purpose |
|--------|---------|---------|
| **Sequential Thinking** | `npx -y @modelcontextprotocol/server-sequential-thinking` | Structured problem decomposition with revision/branching |

### Browser Automation
| Server | Package | Purpose |
|--------|---------|---------|
| **Puppeteer** | `npx -y @modelcontextprotocol/server-puppeteer` | Navigate, click, fill, screenshot |
| **Chrome DevTools** | `npx -y chrome-devtools-mcp@latest` | Console, DOM inspection, debugging |
| **Playwright** | `npx -y @anthropic/mcp-playwright` | Cross-browser automation and testing |
| **Browserbase** | `npx -y @browserbasehq/mcp` | Cloud browser for scraping |

### Databases
| Server | Package | Purpose |
|--------|---------|---------|
| **PostgreSQL (official)** | `npx -y @modelcontextprotocol/server-postgres URL` | Read-only queries, schema inspection |
| **PostgreSQL (enhanced)** | `npx -y @henkey/postgres-mcp-server --connection-string URL` | Read-write, 18 tools, EXPLAIN, indexes |
| **PostgreSQL (env-based)** | `npx -y mcp-postgres-server` | Config via PG_HOST/PG_USER env vars |
| **Supabase** | `npx -y supabase-mcp` | Supabase project management |
| **Neon** | `npx -y @neondatabase/mcp-server-neon` | Neon serverless Postgres |
| **Redis** | `npx -y redis-mcp` | Redis operations, key inspection |

### Google Workspace
| Server | Package | Purpose |
|--------|---------|---------|
| **Docs+Sheets+Drive** | `npx -y @a-bonus/google-docs-mcp` | All-in-one Google Workspace (OAuth) |
| **Drive+Docs+Sheets+Calendar** | `npx -y @piotr-agier/google-drive-mcp` | Extended with Calendar support |
| **Sheets only** | `npx -y mcp-gsheets@latest` | Lightweight, service account auth |

### Project Management & Communication
| Server | Package | Purpose |
|--------|---------|---------|
| **Linear** | `npx -y linear-mcp` | Issue tracking (needs LINEAR_API_KEY) |
| **Notion** | `npx -y @anthropic/mcp-notion` | Workspace docs, databases |
| **Slack** | `npx -y @anthropic/mcp-slack` | Messages, search, notifications |

### Code & DevOps
| Server | Package | Purpose |
|--------|---------|---------|
| **GitHub** | `npx -y @anthropic/mcp-github` | Issues, PRs, repos, actions |
| **GitLab** | `npx -y gitlab-mcp` | MRs, issues, pipelines |
| **Sentry** | `npx -y @sentry/mcp-server` | Error monitoring |
| **Docker** | `npx -y docker-mcp` | Container management |

### Design & Content
| Server | Package | Purpose |
|--------|---------|---------|
| **Figma** | `npx -y figma-mcp` | Design inspection (needs FIGMA_TOKEN) |

### Memory & Knowledge
| Server | Package | Purpose |
|--------|---------|---------|
| **Memory** | `npx -y @anthropic/mcp-memory` | Persistent knowledge graph |

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

Or via Claude Code CLI:
```bash
claude mcp add-json "server-name" '{"command":"npx","args":["-y","package-name"]}'
```

## MCP + Skills Pattern
Wrap MCP tools in skills for context-efficient usage:
- Skill defines WHEN and HOW to use the MCP tools
- MCP server handles the actual operation
- Only results enter the context window
- See `context7-docs`, `sequential-thinking`, `puppeteer`, `postgres-mcp`, `google-workspace` skills
