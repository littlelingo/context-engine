---
description: PostgreSQL database operations via MCP - schema inspection, live queries, EXPLAIN analysis. Use when you need to inspect the actual database state, verify migrations, or analyze query performance.
globs:
  - "**/*.sql"
  - "**/migrations/**"
  - "**/db/**"
  - "**/database/**"
  - "**/schema/**"
  - "**/*repository*"
  - "**/*dao*"
---

# PostgreSQL MCP - Live Database Access

Query and inspect your PostgreSQL database directly from Claude Code. Use this to verify schema state, test queries, and analyze performance before writing code.

## When to Use
- **Before writing migrations**: Inspect current schema to confirm starting state
- **After running migrations**: Verify the migration applied correctly
- **Query development**: Test queries against real data before committing
- **Performance analysis**: Run `EXPLAIN ANALYZE` on queries you're writing
- **Debugging data issues**: Inspect actual data to understand bugs
- **Schema discovery**: Understand unfamiliar databases

## Available Tools (Official Server)
| Tool | Purpose |
|------|---------|
| `query` | Execute read-only SQL queries |
| `list_tables` | List all tables in database |
| `describe_table` | Get column info for a table |

## Available Tools (@henkey Enhanced Server)
| Tool | Purpose |
|------|---------|
| `pg_schema` | Manage tables, columns, ENUMs, constraints |
| `pg_query` | Execute read-only queries with EXPLAIN |
| `pg_index` | Create, analyze, optimize indexes |
| `pg_permissions` | Manage users and grants |
| `pg_functions` | Manage stored functions |
| `pg_data` | Insert, update, delete, upsert data |

## Workflow: Pre-Migration Verification
```
1. List current tables to understand state
2. Describe the table you're about to modify
3. Write the migration
4. Apply the migration
5. Describe the table again to verify
6. Run a test query to confirm data integrity
```

## Workflow: Query Optimization
```
1. Write the query
2. Run with EXPLAIN ANALYZE to see the plan
3. Identify sequential scans on large tables
4. Add appropriate indexes
5. Re-run EXPLAIN ANALYZE to verify improvement
```

## Safety Rules
- Default server is READ-ONLY - it cannot modify data
- Enhanced server (@henkey) allows writes - use with caution
- Never store connection strings in committed files
- Use environment variables for credentials
- Test destructive operations in dev/staging first

## MCP Configuration

**Official (read-only, recommended for safety):**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://user:password@localhost:5432/mydb"
      ]
    }
  }
}
```

**Enhanced (read-write, more tools):**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@henkey/postgres-mcp-server",
        "--connection-string",
        "postgresql://user:password@localhost:5432/mydb"
      ]
    }
  }
}
```

**Alternative (env-based config):**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "mcp-postgres-server"],
      "env": {
        "PG_HOST": "localhost",
        "PG_PORT": "5432",
        "PG_USER": "your_user",
        "PG_PASSWORD": "your_password",
        "PG_DATABASE": "your_database"
      }
    }
  }
}
```
