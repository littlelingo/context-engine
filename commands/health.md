# /health - Framework Effectiveness Metrics

Display framework health dashboard and run deep analysis. Reads from `.context/metrics/HEALTH.md`, git history, and `.context/` state.

## Process

Parse `$ARGUMENTS` to determine the action:

### No arguments: Dashboard

Display a summary of all five metric categories by reading `.context/metrics/HEALTH.md` and computing live stats.

1. **Feature Velocity**
   - Count completed features from FEATURES.md (status COMPLETE)
   - Read the velocity table from HEALTH.md
   - Compute: average elapsed time, average steps per feature, average sessions per feature
   - Trend: is velocity improving? (compare last 3 features vs first 3)

2. **Error Recurrence**
   - Count total errors in `.context/errors/INDEX.md`
   - Read error tracking from HEALTH.md
   - Compute: hit rate (known fixes applied / total bugs investigated)
   - Flag: any errors that recurred 3+ times (need structural fix, not just index entry)

3. **Knowledge Growth**
   - Count files in `knowledge/libraries/` (excluding TEMPLATE.md)
   - Count files in `knowledge/stack/` (excluding TEMPLATE.md)
   - Count entries in `knowledge/dependencies/PINS.md`
   - Count entries in `knowledge/LEARNINGS.md`
   - Count entries in `patterns/CODE_PATTERNS.md` and `ANTI_PATTERNS.md`
   - Read growth table from HEALTH.md for trend

4. **Agent Effectiveness**
   - Read counters from HEALTH.md
   - Compute: team vs subagent ratio, rollback rate, empty run rate
   - Flag: if rollback rate > 20% (checkpoints catching problems = good but frequent = workflow issue)
   - Flag: if empty runs > 0 (implementer not producing output)

5. **Context Efficiency**
   - Read efficiency table from HEALTH.md
   - Compute: average clears per feature, average knowledge files consulted
   - Flag: if average clears > 3 per feature (context pressure - may need to slim CLAUDE.md or split PRPs)

6. **Output dashboard**:
   ```
   ## Context Engine Health Dashboard
   
   ### Feature Velocity
   Features completed: N
   Avg elapsed: X days | Avg steps: N | Avg sessions: N
   Trend: [improving / stable / declining] (last 3 vs first 3)
   
   ### Error Recurrence
   Errors indexed: N | Hit rate: N% (N hits / N investigations)
   Novel: N | Repeat: N
   [Flag repeat errors if any]
   
   ### Knowledge Growth
   Libraries: N files | Stack: N recipes | Pins: N | Learnings: N entries | Patterns: N
   Growth since last feature: +N entries
   
   ### Agent Effectiveness
   Teams: N | Subagents: N | Ratio: N:N
   Rollbacks: N (N full, N soft) | Empty runs: N
   
   ### Context Efficiency
   Avg clears/feature: N | Avg knowledge consulted: N files
   [Flag if context pressure detected]
   
   ### Recommendations
   [List 1-3 actionable recommendations based on the metrics]
   ```

### `velocity`: Deep Velocity Analysis

1. Read all completed PRPs from `.context/features/`
2. For each: count steps, read the metrics block (if present), check git log for dates
3. Plot trend: features are getting faster/slower/stable
4. Identify bottlenecks: which phase takes longest (plan, implement, validate)?

### `errors`: Deep Error Analysis

1. Read `.context/errors/INDEX.md` fully
2. Categorize errors: by type (config, logic, integration, dependency), by frequency
3. Identify patterns: which areas of the codebase produce most errors?
4. Check for stale entries (errors that reference files that no longer exist)

### `knowledge`: Knowledge Audit

1. List all knowledge files with last-modified dates
2. Identify stale knowledge (files not updated in 30+ days)
3. Check LEARNINGS.md for promotion candidates (3+ mentions of same topic)
4. Suggest gaps: libraries used in package.json/requirements.txt without knowledge files

### `agents`: Agent Performance

1. Read HEALTH.md agent counters
2. Cross-reference with checkpoint MANIFEST.md for rollback history
3. Show which commands trigger most rollbacks
4. Show empty run frequency and which features triggered them

### `record [feature-NNN]`: Manually Record Feature Metrics

For features that were completed before metrics system was installed, or to correct auto-captured data.

1. Ask for: plan date, validate date, steps, sessions, clears
2. Append to HEALTH.md velocity and efficiency tables
3. Confirm what was recorded

## Recommendations Engine

Based on metrics, suggest specific improvements:

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

## Rules
- Dashboard is read-only - never modifies files
- Deep analysis modes are read-only
- Only `record` modifies HEALTH.md
- All dates in ISO format (YYYY-MM-DD)
- Percentages rounded to nearest whole number
- Trend requires at least 3 completed features to compute

## User Input
$ARGUMENTS
