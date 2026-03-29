---
name: database-migrations
description: Database migration patterns and ORM conventions. Auto-loaded when working with schema changes, migrations, models, or SQL files.
user-invocable: false
---

# Database Migrations

## Safety Rules
- NEVER run destructive migrations without explicit user approval
- Always create a rollback plan before applying migrations
- Test migrations on a copy of production data when possible
- Migrations must be idempotent - safe to run multiple times

## Migration Checklist
1. Write migration with both `up` and `down` (rollback)
2. Test up migration on empty database
3. Test down migration (verify rollback works)
4. Test up migration on database with existing data
5. Check for data loss - does the migration destroy existing data?
6. Add appropriate indexes for new columns used in WHERE/JOIN
7. Consider table locks on large tables - use concurrent index creation

## Naming
- Timestamp prefix: `20260321_add_user_roles.sql`
- Descriptive: what the migration does, not the ticket number
- One logical change per migration file

## Schema Design
- Always include `created_at` and `updated_at` timestamps
- Use UUIDs or ULIDs for public-facing IDs, sequential integers for internal
- Add NOT NULL constraints by default, allow NULL only when semantically correct
- Foreign keys with appropriate ON DELETE behavior (CASCADE, SET NULL, RESTRICT)

## Common Pitfalls
- Adding NOT NULL column without default to table with existing rows
- Dropping columns that are still referenced in application code
- Running migrations that lock large tables during peak traffic
- Forgetting to update ORM models after schema changes
