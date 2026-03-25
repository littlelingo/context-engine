# Testing Strategy Reference

Follow the strategy from the PRP `## Testing Strategy:` field, falling back to CLAUDE.md default.

## test-first (Red-Green)
For each PRP step:
1. **RED**: Write a failing test based on the step's "Test coverage:" and "Test file:" path
2. Run tests — confirm the new test fails
3. **GREEN**: Implement the code to make the test pass
4. Run tests — confirm all pass
5. Mark step complete

## implement-then-test (Green-Red-Green)
For each PRP step:
1. **Implement** the code change
2. **Write test** based on the step's "Test coverage:" and "Test file:" path
3. Run tests — if fail, fix implementation until pass
4. Mark step complete

## tests-optional
For each PRP step:
1. Implement the code change
2. Run existing tests to ensure no regressions
3. Mark step complete
