# Framework Health Metrics

Persistent metrics tracking Context Engine effectiveness over time.
Auto-updated after every `/validate`. Manual deep analysis via `/health`.

## Feature Velocity

<!-- Auto-appended after each feature completes validation -->
<!-- Format: | [NNN] | [name] | [plan date] | [validate date] | [elapsed] | [steps] | [sessions] | [clears] | -->

| Feature | Name | Plan Date | Validate Date | Elapsed | Steps | Sessions | Clears |
|---------|------|-----------|---------------|---------|-------|----------|--------|

## Error Tracking

<!-- Auto-updated by ce-validate and ce-debug -->

| Metric | Value |
|--------|-------|
| Total errors indexed | 0 |
| Error index hits (known fix applied) | 0 |
| Novel errors (new to index) | 0 |
| Repeat errors (same root cause recurred) | 0 |
| Hit rate | 0% |

## Knowledge Growth

<!-- Snapshot taken after each feature validation -->
<!-- Format: | [date] | [feature] | [learnings] | [libraries] | [stack] | [pins] | [patterns] | -->

| Date | Feature | Learnings | Libraries | Stack Recipes | Dep Pins | Patterns |
|------|---------|-----------|-----------|---------------|----------|----------|

## Agent Effectiveness

<!-- Cumulative counters -->

| Metric | Count |
|--------|-------|
| Agent Team executions | 0 |
| Subagent executions | 0 |
| Checkpoint rollbacks (full) | 0 |
| Checkpoint rollbacks (soft) | 0 |
| Implementer empty runs flagged | 0 |
| Debug cycles per bug (avg) | 0 |

## Context Efficiency

<!-- Snapshot per feature -->
<!-- Format: | [feature] | [clears] | [resumes] | [compactions] | [knowledge files consulted] | -->

| Feature | Clears | Resumes | Compactions | Knowledge Consulted |
|---------|--------|---------|-------------|---------------------|
