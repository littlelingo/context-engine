---
name: postgres
description: PostgreSQL patterns - queries, indexing, performance, maintenance. Auto-loaded when working with SQL files, database configs, or Postgres-specific code.
user-invocable: false
---

# PostgreSQL

## Query Patterns
- Always use parameterized queries (never string interpolation for values)
- `EXPLAIN ANALYZE` before optimizing - measure, don't guess
- CTEs (`WITH`) for readability, but know they can be optimization fences
- `RETURNING *` on INSERT/UPDATE to avoid a second SELECT
- `UPSERT` via `ON CONFLICT DO UPDATE` for idempotent writes

## Indexing
- B-tree (default) for equality and range queries
- GIN for full-text search, JSONB containment, array membership
- GiST for geometric/geographic data (PostGIS)
- Partial indexes for queries with common WHERE clauses
- `CREATE INDEX CONCURRENTLY` to avoid table locks on large tables
- Composite indexes: put equality columns first, range columns last

## Performance
- Connection pooling (PgBouncer or built-in pool) - never open/close per query
- `LIMIT` + cursor-based pagination (not OFFSET for large datasets)
- OFFSET scales linearly with page number - use `WHERE id > last_seen`
- Batch operations: `INSERT INTO ... VALUES (batch)` not per-row inserts
- Vacuum regularly (autovacuum should be enabled)

## Schema Design
- Use appropriate types: `timestamptz` (not timestamp), `text` (not varchar), `uuid`
- JSON: `jsonb` for queryable data, `json` for storage-only
- Enums via `CREATE TYPE` for fixed value sets, text + CHECK for flexible ones
- Partitioning for tables exceeding ~100M rows

## Common Pitfalls
- Missing indexes on foreign key columns (slow JOIN, slow DELETE)
- `SELECT *` in production (fetches unneeded columns, breaks on schema change)
- Transactions held open too long (blocks autovacuum, causes bloat)
- Not using `timestamptz` (timezone-unaware timestamps cause bugs)
- Sequences gaps after rollback (expected behavior, not a bug)
