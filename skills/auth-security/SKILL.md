---
description: Authentication and security patterns - JWT, OAuth, sessions, RBAC, input validation. Auto-loaded when working with auth, middleware, or security files.
---

# Authentication & Security

## Token Handling
- Store JWTs in httpOnly cookies (not localStorage) for web apps
- Short-lived access tokens (15min), longer refresh tokens (7d)
- Always validate token signature AND expiration AND issuer
- Revocation: maintain a blocklist or use short-lived tokens

## Password Security
- bcrypt or argon2 for hashing (NEVER MD5/SHA for passwords)
- Minimum 12 characters, check against breach databases
- Rate-limit login attempts (5 per minute per IP)
- Generic error messages: "Invalid credentials" (don't reveal which field)

## Input Validation
- Validate at the boundary (API entry point), not deep in business logic
- Whitelist valid patterns, don't blacklist bad ones
- Sanitize for the output context (HTML escape for web, parameterize for SQL)
- File uploads: validate MIME type, size, and scan for malware

## Authorization
- Check permissions on every request, not just the first
- Default deny - explicitly grant access, never implicitly allow
- Server-side authorization always (client-side is for UX only)
- Log all authorization failures for security monitoring

## Secrets
- Never commit secrets to git (use .env + .gitignore)
- Use environment variables or secret managers (Vault, AWS SSM)
- Rotate secrets regularly, especially after team member departures
- Different secrets per environment (dev, staging, production)

## OWASP Top 10 Quick Check
- SQL Injection: parameterized queries always
- XSS: escape output, use CSP headers
- CSRF: anti-CSRF tokens for state-changing requests
- Broken auth: session fixation, credential stuffing protection
- SSRF: validate and restrict outbound URLs
