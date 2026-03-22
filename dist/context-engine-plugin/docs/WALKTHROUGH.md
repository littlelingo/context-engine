# Context Engine - Full Cycle Walkthrough

A step-by-step guide showing the complete workflow from project setup through feature completion. Uses a sample "user authentication" feature on a Node.js/Express project as the example.

---

## Step 0: Install, Setup & Initialize

### Install the framework

```bash
# From the context-engine repo
./install.sh /path/to/your-project

# Or copy manually
cp -r .claude .context CLAUDE.md CLAUDE.local.md .claudeignore /path/to/your-project/
```

### Start Claude Code and set up the environment

```bash
cd /path/to/your-project
claude
```

First, run:
```
/init
```

Claude asks:
```
How do you want to set up the development environment?
1. Devcontainer (Docker-based isolated environment - recommended for teams)
3. Local (no container - use current machine as-is)
```



### Initialize the project

Then run:
```
/init
```

Claude will:
- Use the `researcher` agent to scan your project
- Auto-detect your tech stack, test commands, lint commands
- Populate `.context/architecture/` with OVERVIEW.md, TECH_STACK.md, DIRECTORY_MAP.md
- Populate `.context/patterns/CODE_PATTERNS.md` with initial conventions
- **Prompt you to choose a default testing strategy**

You'll see something like:
```
What should be the default testing strategy for this project?
1. test-first - TDD, write tests before code
2. implement-then-test - Code first, then tests (recommended default)
3. tests-optional - Defer tests (for prototyping projects)
```

Pick your default. You can override it per-feature later.

```
Context Engine initialized.
Detected: Node.js, Express, Jest | Test: npm test | Lint: npm run lint
Testing strategy: implement-then-test
Run /research [topic] to begin.
```

**Check context**: `/context` - should be around 30-35% after init. If higher, `/clear` and start fresh.

---

## Step 1: Research (`/research`)

Start a new feature. Don't jump into coding.

```
/research user authentication with JWT tokens
```

Claude will:
1. Restate your request and ask clarifying questions if needed
2. **Delegate to the `researcher` agent** (runs in isolated context)
3. Check `.context/` for existing knowledge about auth patterns
4. Synthesize findings into a research summary
5. **Reflect** - update `.context/` with any new architecture/pattern/error discoveries
6. Save to `.context/features/auth/NOTES.md`

You'll see the researcher agent explore your codebase, then Claude presents:

```markdown
# Research: User Authentication with JWT

## Current State
- No existing auth middleware found
- Express routes in `src/routes/` have no protection
- User model exists at `src/models/user.js` but has no password field

## Gap Analysis
- Need password hashing (bcrypt)
- Need JWT generation and verification middleware
- Need protected route wrapper
- Need login/register endpoints

## Dependencies
- All existing routes will need auth middleware applied
- User model needs schema changes

## Risks & Known Issues
- No entries in .context/errors/ for auth-related issues yet

## Open Questions
- Should refresh tokens be implemented now or deferred?
- Where should JWT secret be stored? (.env, config service?)

## Recommended Approach
- Add auth as middleware layer, not embedded in routes
```

**Answer the open questions**, then Claude hands off:

```
Research saved to: .context/features/auth/NOTES.md
Next: /plan .context/features/auth/NOTES.md
```

**Decision point**: Check `/context`. If > 50%, run `/clear` first. If under, continue in the same session.

---

## Step 2: Plan (`/plan`)

```
/plan .context/features/auth/NOTES.md
```

Claude will:
1. Load your research notes + architecture docs + patterns + errors
2. **Delegate to the `planner` agent** to create the PRP
3. Present the draft PRP for review
4. **Prompt you to choose a testing strategy for this plan**:

```
Which testing strategy for this feature?
1. test-first - TDD, tests before code
2. implement-then-test - Code first, then tests
3. tests-optional - Defer tests (spikes/prototypes)
4. Use project default (implement-then-test)
```

Pick your strategy. Then review the PRP:

```markdown
# PRP: User Authentication with JWT

## Status: PLANNING
## Created: 2026-03-17
## Complexity: MEDIUM
## Testing Strategy: implement-then-test

## 1. Overview
Add JWT-based authentication to the Express API. Users can register and
login. Protected routes require a valid token.

## 2. Requirements
### Must Have
- [ ] User registration with hashed passwords
- [ ] Login endpoint returning JWT
- [ ] Auth middleware for protected routes
- [ ] Token expiration handling

### Out of Scope
- Refresh tokens (deferred to separate PRP)
- OAuth/social login

## 3. Technical Approach
...

## 4. Implementation Steps
1. [ ] **Add dependencies** - `package.json`
   - Add bcrypt, jsonwebtoken
   - Test coverage: verify packages install correctly
2. [ ] **Update user model** - `src/models/user.js`
   - Add password field with bcrypt pre-save hook
   - Test coverage: password hashing on save, no plaintext storage
3. [ ] **Create auth middleware** - `src/middleware/auth.js`
   - JWT verification, attach user to req
   - Test coverage: valid token, expired token, missing token, malformed token
4. [ ] **Create auth routes** - `src/routes/auth.js`
   - POST /register, POST /login
   - Test coverage: successful registration, duplicate email, successful login, wrong password
5. [ ] **Apply middleware to existing routes** - `src/routes/*.js`
   - Test coverage: protected routes reject unauthenticated requests

## 5. Validation Checklist
- [ ] Tests pass: `npm test`
- [ ] Lint clean: `npm run lint`
- [ ] Manual: register user, login, access protected route, verify expired token rejected
```

Iterate if needed ("add rate limiting to the login route", "split step 3 into two steps"). When satisfied, approve.

Claude saves the PRP, updates FEATURES.md, reflects on any new patterns/decisions, then hands off:

```
PRP saved to: .context/features/001-user-auth/PRP.md
Testing strategy: implement-then-test

Next: /clear then /implement .context/features/001-user-auth/PRP.md
```

**Run `/clear` now.** Implementation needs maximum context.

---

## Step 3: Implement (`/implement`)

```
/implement .context/features/001-user-auth/PRP.md
```

Claude will:
1. Load the PRP, set status to IN_PROGRESS, update FEATURES.md
2. Read the testing strategy from the PRP header (`implement-then-test`)
3. Find the first unchecked step
4. **Delegate to the `implementer` agent** for that step

The implementer runs step 1 (add dependencies), marks it `[x]`, returns a report:

```
## Implementation Report
### Testing Strategy: implement-then-test
### Step 1: Add dependencies
**Status**: COMPLETE
**Files Changed**: package.json - added bcrypt, jsonwebtoken
**Tests**: N/A (dependency install)
**Issues**: None
### Next Step: Step 2 - Update user model
```

Claude presents this and pauses. You review, then say "continue" or "proceed to step 2."

This repeats for each step. After every 2-3 steps, Claude checks context:
- If < 55%: keeps going
- If > 55%: saves progress (PRP checkmarks updated) and recommends:

```
Context at 58%. Progress saved (steps 1-3 complete).
Next: /clear then /implement .context/features/001-user-auth/PRP.md
```

**Run `/clear`, then the same command.** Claude reads the PRP, sees steps 1-3 are `[x]`, picks up at step 4.

After each step, Claude reflects and writes any errors/patterns/insights to `.context/`.

When all steps complete:

```
All implementation steps complete.
Next: /clear then /validate .context/features/001-user-auth/PRP.md
```

---

## Step 4: Validate (`/validate`)

```
/validate .context/features/001-user-auth/PRP.md
```

Claude will run through 11 steps:

1. **Load PRP**
2. **Check testing strategy** (implement-then-test - tests must exist)
3. **Run validation checklist**: `npm test`, `npm run lint`, manual checks
4. **Delegate to `reviewer` agent** - code review with security checklist
5. **Fix critical issues** from the review
6. **Simplification pass** - look at the full diff for dead code, duplication, over-abstraction, unnecessary complexity
7. **Capture learnings** - errors, patterns, anti-patterns, architecture changes, decisions, insights
8. **Update PRP status** to COMPLETE
9. **Update FEATURES.md** to COMPLETE
10. **Report**:

```
## Validation: User Authentication with JWT
**Status**: PASS | **Strategy**: implement-then-test
**Tests**: 14 passed, 0 failed | **Lint**: Clean | **Types**: N/A
**Review**: No critical issues. 1 warning (missing rate limiting on login - logged as TODO).
**Security**: Input validation present. Passwords hashed. JWT secret from env. No PII in tokens.
**Simplified**: Consolidated duplicate error response formatting in auth routes into shared helper.
**Learnings captured**:
  - Pattern: Express middleware auth pattern added to CODE_PATTERNS.md
  - Error: bcrypt salt rounds must be >= 10 added to errors/INDEX.md
  - Learning: JWT expiry of 15min with refresh is better than long-lived tokens
```

11. **Commit & PR prompt** - Claude asks how you want to ship:

```
Ready to ship. Suggested commit message:

  feat: add JWT authentication with register/login endpoints

  - Add user registration with bcrypt password hashing
  - Add login endpoint returning signed JWT tokens
  - Add auth middleware for protected routes
  - Consolidate error response formatting into shared helper

  PRP: .context/features/001-user-auth/PRP.md

Options:
1. Commit only
2. Commit + create PR
3. Edit the message (tell me what to change)
4. Skip (I'll handle it manually)
```

If you pick 1, Claude commits. If you pick 2, Claude commits and then generates a PR description from the PRP, the diff, and the validation report - including the changes summary, testing results, security review findings, and any notes. It presents the PR description for your review, then runs `gh pr create` or `glab mr create` if the CLI is available. If you pick 3, you tell it what to adjust and it revises. If you pick 4, it shows everything for manual copy.

---

## Between Features

Before starting the next feature, your `.context/` has grown:
- `FEATURES.md` shows auth is COMPLETE
- `CODE_PATTERNS.md` has the Express middleware auth pattern
- `errors/INDEX.md` has the bcrypt salt rounds issue
- `LEARNINGS.md` has the JWT expiry insight
- The `researcher` agent remembers the auth file locations
- The `implementer` agent remembers the bcrypt quirk
- The `reviewer` agent knows to check for rate limiting

The next feature starts smarter than the last one.

---

## Quick Path: Small Tasks

For bug fixes or minor changes, skip the full cycle:

```
/plan-quick fix the 500 error on /api/users when email is missing
```

Claude scans relevant files, checks error index, proposes a quick plan with testing strategy confirmation, implements, reflects, done. One context window, no `/clear` needed.

---

## Parallel Work

Working on two features at once:

```bash
git worktree add ../project-notifications feature/notifications
git worktree add ../project-search feature/search

# Terminal 1
cd ../project-notifications && claude
/research push notifications

# Terminal 2
cd ../project-search && claude
/research full-text search
```

Each session has isolated context. Both share `.context/` via git.

---

## Resuming After a Break

Come back to a project after lunch, next day, whatever:

```bash
claude
/resume
```

Claude reads FEATURES.md, finds IN_PROGRESS features, shows where you left off:

```
Resuming: User Authentication with JWT
PRP: .context/features/001-user-auth/PRP.md
Completed: Steps 1-3 of 5
Next: Step 4 - Create auth routes
Ready: /implement .context/features/001-user-auth/PRP.md
```

---

## Manual Knowledge Capture

Outside the normal workflow, capture something useful:

```
/learn we decided to use Redis for session storage because the app
will run on multiple servers and in-memory sessions won't work
```

Claude determines this is a technical decision and creates an ADR in `.context/decisions/`.

```
/learn the Stripe webhook endpoint must use raw body parsing,
not JSON - Express's json() middleware breaks signature verification
```

Claude captures this as an error pattern in `.context/errors/INDEX.md`.
