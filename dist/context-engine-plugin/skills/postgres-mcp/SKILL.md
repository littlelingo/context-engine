---
name: postgres-mcp
description: PostgreSQL database operations via MCP - schema inspection, live queries, EXPLAIN analysis. Use when you need to inspect the actual database state, verify migrations, or analyze query performance.
---

# PostgreSQL MCP - Live Database Access

Query and inspect your PostgreSQL database directly from Claude Code.

## When to Use
- **Before writing migrations**: Inspect current schema to confirm starting state
- **After running migrations**: Verify the migration applied correctly
- **Query development**: Test queries against real data before committing
- **Performance analysis**: Run `EXPLAIN ANALYZE` on queries you're writing
- **Debugging data issues**: Inspect actual data to understand bugs

## Workflow: Pre-Migration Verification
1. List current tables to understand state
2. Describe the table you're about to modify
3. Write and apply the migration
4. Describe the table again to verify
5. Run a test query to confirm data integrity

## Workflow: Query Optimization
1. Write the query
2. Run with EXPLAIN ANALYZE to see the plan
3. Identify sequential scans on large tables
4. Add appropriate indexes
5. Re-run EXPLAIN ANALYZE to verify improvement

## Safety Rules
- Default server is READ-ONLY - it cannot modify data
- Enhanced server (@henkey) allows writes - use with caution
- Never store connection strings in committed files
- Use environment variables for credentials

For available tools and MCP configuration options, read `REFERENCE.md` in this directory.
