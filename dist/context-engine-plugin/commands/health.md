# /health - Framework Effectiveness Metrics

Display framework health dashboard and run deep analysis. Reads from `.context/metrics/HEALTH.md`, git history, and `.context/` state.

## Process

Parse `$ARGUMENTS` to determine the action:

### No arguments: Dashboard

Display a summary of all five metric categories by reading `.context/metrics/HEALTH.md` and computing live stats. If no features have been completed yet, show baseline zeros and note that trends appear after 3+ completed features.

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
- **Promotion candidates**: Identify errors with 3+ similar signatures or in the same file/component area. Suggest promotion to ANTI_PATTERNS.md with a draft entry (Don't/Do/Why format).

### `knowledge`: Knowledge Audit
List files with last-modified dates, flag stale entries (30+ days), find promotion candidates, identify gaps vs package.json/requirements.txt.

### `agents`: Agent Performance
Show team vs subagent usage, rollback history by command, empty run frequency.

### `record [feature-NNN]`: Record Feature Metrics

For features that completed without formal `/validate` metrics capture. Extracts what it can from git and `.context/`, prompts only for unknowable values.

1. **Locate feature**: Find the PRP at `.context/features/[NNN]-*/PRP.md`. If no PRP exists, note this as a pre-framework feature and work from git history alone.

2. **Extract from git history** (automated):
   - Plan date: earliest commit touching `.context/features/[NNN]-*/` or feature branch creation
   - Complete date: commit that set PRP status to COMPLETE, or last commit on feature branch, or merge commit
   - Elapsed days: difference between plan and complete dates
   - Step count: count `[x]` items in PRP (if PRP exists), otherwise estimate from commit count

3. **Extract from .context/ state** (automated):
   - Error tracking: count errors in INDEX.md added between plan and complete dates (via `git log -p`)
   - Knowledge growth: count LEARNINGS.md entries, library files, stack recipes, pins, patterns added between those dates
   - If date range is unavailable, count current totals and note them as cumulative snapshots

4. **Prompt for unknowable values** (ask user):
   - Sessions count (how many Claude sessions, including /clear+/resume cycles)
   - Context clears count
   - Whether Agent Team or subagent was used
   - Any checkpoint rollbacks
   - Allow user to override any auto-extracted value

5. **Confirm**: Present all extracted + prompted values in a summary table. Ask user to confirm or adjust before writing.

6. **Write to HEALTH.md**: Append/update rows in all 5 tables. Mark `[M]` suffix on feature name in the Velocity table to distinguish manual captures from auto-captured metrics.

7. **Update FEATURES.md**: If the feature is not in FEATURES.md, add it with status `COMPLETE`. Set the `Metrics` column to `MANUAL`.

### `backfill`: Retroactive Metrics Capture

Scan git history for features that lack metrics entries. Batch-process them.

1. **Scan for features**:
   - List all directories in `.context/features/` matching `[NNN]-*` pattern
   - Scan `git log --oneline` for conventional `feat:` commits that may represent features not tracked through the PRP system
   - Cross-reference with FEATURES.md and HEALTH.md Feature Velocity table

2. **Build feature inventory**: For each discovered feature, show:
   ```
   Found N features without metrics:
   | # | Feature | Source | Has PRP | In FEATURES.md | In HEALTH.md |
   |---|---------|--------|---------|-----------------|--------------|
   ```

3. **Triage**: Ask user which to process:
   - `all` — process every untracked feature
   - Specific numbers — process selected features
   - `skip [NNN]` — exclude specific features (e.g., chore commits not worth tracking)

4. **Batch process**: For each selected feature, run the `record` workflow above. Between features, show a running tally and ask whether to continue.

5. **Summary report**:
   ```
   Backfill complete:
   - Features added to FEATURES.md: N
   - Features with metrics recorded: N
   - Features skipped: N
   ```

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
