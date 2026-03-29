---
name: node-backend
description: Node.js backend patterns - Express, Fastapi, NestJS, middleware, async. Auto-loaded when working with server.ts/js, app.ts/js, routes/, middleware/, or Node.js backend directories.
user-invocable: false
---

# Node.js Backend

## Project Structure
- `src/routes/` or `src/controllers/` — route handlers grouped by domain
- `src/middleware/` — auth, validation, error handling, logging
- `src/services/` — business logic (not in route handlers)
- `src/models/` or `src/schemas/` — data shapes and validation
- `src/utils/` — shared helpers (keep thin)

## Express Patterns
- Use `Router()` for route grouping — never define routes on the app directly
- Error middleware must have 4 params: `(err, req, res, next)` — Express uses arity to detect it
- Use `express.json()` with a size limit: `express.json({ limit: '1mb' })`
- Never use `app.use(cors())` without origin configuration in production
- Return early from middleware on failure — don't fall through to next handler

## Fastify Patterns
- Use schema-based validation (built-in JSON Schema) over middleware validation
- Register plugins with `fastify.register()` for encapsulation
- Use `fastify.decorateRequest()` for request-scoped data (not `req.custom`)
- Prefer `reply.send()` over `return` for explicit response control

## Async & Error Handling
- Always `try/catch` around `await` in route handlers, or use an async wrapper
- Never swallow errors — log and re-throw or return appropriate HTTP status
- Use `process.on('unhandledRejection')` and `process.on('uncaughtException')` — log and exit
- Graceful shutdown: listen for `SIGTERM`/`SIGINT`, close server, drain connections, then exit
- Avoid `setTimeout`/`setInterval` for scheduling — use a job queue (BullMQ, Agenda)

## Middleware
- Order matters: logging → auth → validation → handler → error handler
- Keep middleware single-purpose — don't mix auth and logging in one function
- Use `next(error)` to pass errors to the error handler, never `throw` in middleware
- Rate limiting belongs in middleware or reverse proxy, not in route handlers

## Database Access
- Use connection pooling (pg Pool, Prisma connection pool, Knex pool)
- Never build SQL with string interpolation — use parameterized queries or ORM
- Close database connections on graceful shutdown
- Use transactions for multi-step writes

## Environment & Config
- Load env vars once at startup, validate with zod/joi, export typed config object
- Never access `process.env` directly in business logic — use the config module
- Use `dotenv` only in development — production should inject env vars directly

## Common Pitfalls
- `express.json()` must come before routes — middleware order is declaration order
- Forgetting `return` after `res.send()` causes "headers already sent" errors
- `req.params` values are always strings — parse to numbers explicitly
- Memory leaks from event listeners — always `removeListener` in cleanup
- Blocking the event loop with synchronous operations (crypto, fs) — use async variants
