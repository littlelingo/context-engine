---
description: Redis patterns - caching, sessions, queues, pub/sub, rate limiting. Auto-loaded when working with cache, Redis, or queue-related files.
---

# Redis

## Caching Patterns
- Cache-aside: app checks cache, falls back to DB, writes to cache
- TTL on every key (no orphaned data) - start with 5min, tune from metrics
- Cache invalidation: delete on write (simplest), or pub/sub for distributed
- Key naming: `{service}:{entity}:{id}` (e.g., `app:user:123`)
- Avoid caching sensitive data (PII, tokens) unless encrypted

## Session Storage
- `SET session:{id} {data} EX 1800` (30min TTL)
- Extend TTL on each access (sliding window)
- Store minimal data - user ID and role, not full profile

## Job Queues
- Redis Streams or Bull/BullMQ for reliable queues
- Dead letter queue for failed jobs (don't lose work)
- Idempotent job handlers (safe to retry)
- Concurrency limits to prevent thundering herd

## Rate Limiting
- Sliding window: `INCR` + `EXPIRE` for simple per-minute limits
- Token bucket for burst-friendly rate limiting
- Key per user/IP: `ratelimit:{endpoint}:{user_id}`

## Pub/Sub
- For real-time notifications, not reliable delivery (messages lost if no subscriber)
- Use Streams for reliable pub/sub (consumer groups with acknowledgment)
- Channel naming: `{domain}.{event}` (e.g., `orders.created`)

## Operational
- `MAXMEMORY` policy: `allkeys-lru` for pure cache, `noeviction` for queues
- Monitor with `INFO` command, `SLOWLOG` for performance
- Persistence: RDB snapshots for cache, AOF for queues/sessions
- Cluster mode for scaling beyond single instance memory

## Common Pitfalls
- No TTL on keys (memory grows unbounded until OOM)
- Using Redis as primary database (it's a cache/store, not a DB)
- Blocking operations (`KEYS *`) in production (use `SCAN` instead)
- Hot keys (one key receiving massive traffic) - shard or replicate
