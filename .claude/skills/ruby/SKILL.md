---
description: Ruby and Rails patterns - models, controllers, services, testing. Auto-loaded when working with Ruby files, Gemfiles, or Rails directories.
globs:
  - "**/*.rb"
  - "**/*.erb"
  - "**/*.haml"
  - "Gemfile"
  - "Gemfile.lock"
  - "Rakefile"
  - "config.ru"
  - "**/config/**/*.rb"
  - "**/app/**/*.rb"
  - "**/spec/**/*_spec.rb"
  - "**/test/**/*_test.rb"
---

# Ruby & Rails

## Rails Conventions
- Fat models, skinny controllers
- Service objects for business logic that spans multiple models
- Concerns for shared model/controller behavior (use sparingly)
- Strong parameters in controllers for mass assignment protection
- Scopes for reusable query logic in models

## Project Structure (Rails)
```
app/
  controllers/   HTTP handling only
  models/        ActiveRecord models + validations
  services/      Business logic (POROs)
  serializers/   JSON response shaping
  jobs/          Background jobs (Sidekiq/ActiveJob)
  mailers/       Email templates and delivery
```

## Testing
- RSpec preferred: `describe`, `context`, `it` blocks
- FactoryBot for test data (not fixtures for complex scenarios)
- Request specs for API endpoints (not controller specs)
- `let` for lazy-loaded test data, `let!` when eager loading needed
- `shared_examples` for common behavior across models

## ActiveRecord
- Use scopes for reusable queries: `scope :active, -> { where(active: true) }`
- `find_each` for batch processing (not `each` on large datasets)
- `includes` to prevent N+1 (use Bullet gem to detect)
- Transactions for multi-record operations that must succeed together
- Enum with prefix: `enum :status, { active: 0, archived: 1 }, prefix: true`

## Ruby Style
- Two-space indentation
- Snake_case for methods and variables, CamelCase for classes
- Guard clauses for early returns: `return unless valid?`
- Frozen string literals: `# frozen_string_literal: true` at top of files
- Prefer `each_with_object` over `inject` for building collections

## Common Pitfalls
- N+1 queries (use Bullet gem + `includes`)
- Callbacks creating hidden side effects (prefer explicit service calls)
- Long-running tasks in request cycle (use background jobs)
- Not indexing foreign keys in migrations
