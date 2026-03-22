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

6. **Output dashboard** with all 5 categories as a compact summary table, plus 1-3 actionable recommendations from the Recommendations Engine.

### `velocity`: Deep Velocity Analysis
Read all completed PRPs, compute per-feature timing, identify bottleneck phases (plan/implement/validate), show trend.

### `errors`: Deep Error Analysis
Categorize errors by type and frequency, identify hotspot areas, flag stale entries referencing deleted files.

### `knowledge`: Knowledge Audit
List files with last-modified dates, flag stale entries (30+ days), find promotion candidates, identify gaps vs package.json/requirements.txt.

### `agents`: Agent Performance
Show team vs subagent usage, rollback history by command, empty run frequency.

### `record [feature-NNN]`: Manually Record Feature Metrics
For features completed before metrics system. Ask for: plan date, validate date, steps, sessions, clears. Append to HEALTH.md.

## Recommendations Engine

Read `.context/metrics/RECOMMENDATIONS.md` for the signal→recommendation lookup table. Generate 1-3 actionable recommendations based on current metrics.

## Rules
- Dashboard is read-only - never modifies files
- Deep analysis modes are read-only
- Only `record` modifies HEALTH.md
- All dates in ISO format (YYYY-MM-DD)
- Percentages rounded to nearest whole number
- Trend requires at least 3 completed features to compute

## User Input
$ARGUMENTS
