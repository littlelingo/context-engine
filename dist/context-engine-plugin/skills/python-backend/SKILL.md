---
description: Python backend patterns - FastAPI, Django, Flask, project structure, async. Auto-loaded when working with Python backend files.
globs:
  - "**/views/**/*.py"
  - "**/routers/**/*.py"
  - "**/endpoints/**/*.py"
  - "**/services/**/*.py"
  - "**/schemas/**/*.py"
  - "**/serializers/**/*.py"
  - "manage.py"
  - "app.py"
  - "main.py"
  - "wsgi.py"
  - "asgi.py"
  - "pyproject.toml"
  - "requirements*.txt"
---

# Python Backend

## FastAPI
- Pydantic models for all request/response schemas (never raw dicts)
- Dependency injection for DB sessions, auth, config
- Background tasks for non-blocking operations (email, notifications)
- `async def` for I/O-bound endpoints, regular `def` for CPU-bound
- Router organization: one router per domain (users, auth, billing)

## Django
- Fat models, thin views - business logic in models/managers
- Custom managers for complex querysets
- Signals sparingly - explicit method calls are easier to debug
- `select_related`/`prefetch_related` to prevent N+1 queries
- Django REST Framework serializers for API responses

## Flask
- Application factory pattern (`create_app()`)
- Blueprints for route organization
- Flask-SQLAlchemy with proper session management
- Error handlers at blueprint and app level

## Project Structure
```
app/
  api/           Route definitions
  models/        Database models/schemas
  services/      Business logic (no HTTP concerns)
  repositories/  Data access layer
  schemas/       Pydantic/serializer models
  utils/         Shared utilities
  config.py      Settings from environment
tests/           Mirror app/ structure
```

## Best Practices
- Type hints on all function signatures
- Ruff for linting + formatting (replaces flake8, isort, black)
- pytest with fixtures for testing, not unittest
- Alembic for migrations (FastAPI), Django migrations for Django
- Structured logging (structlog or python-json-logger), not print()
- Environment config via pydantic-settings or django-environ

## Common Pitfalls
- Circular imports between models and services - use dependency injection
- N+1 queries - always check query count in tests
- Missing `async` on I/O endpoints (blocks the event loop)
- Bare `except:` catching everything including KeyboardInterrupt
