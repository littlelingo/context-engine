# Health Recommendations Engine

Signal→recommendation lookup for `/health` dashboard.

| Signal | Recommendation |
|--------|---------------|
| Avg clears > 3/feature | Split large PRPs, slim CLAUDE.md, use more /clear+resume |
| Hit rate < 30% | Improve error capture - add more detail to INDEX.md entries |
| Hit rate > 70% | Error index working well - consider promoting common fixes to patterns |
| Repeat errors > 0 | Structural fix needed, not just index entry. Add to ANTI_PATTERNS.md |
| Empty runs > 0 | Review implementer agent prompts, check PRP step clarity |
| Rollback rate > 20% | Good that checkpoints catch problems, but investigate root causes |
| Knowledge growth stagnant | Review auto-capture - are implement/debug writing to knowledge? |
| Velocity declining | Check for scope creep, PRP complexity, or context pressure |
