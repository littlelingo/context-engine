# Pre-Execution Safety Checks

Before modifying project source code:
1. **Clean working tree** — if dirty (uncommitted changes), stop and ask the user to commit or stash
2. **Tests pass** — run test suite; if failing, stop and suggest `/debug`
3. **Correct branch** — if on main/master, create an appropriate feature/refactor branch first
