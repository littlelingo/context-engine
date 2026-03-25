# PostgreSQL MCP - Detailed Configuration

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
