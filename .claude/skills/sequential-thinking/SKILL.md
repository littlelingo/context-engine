---
description: Sequential thinking for structured problem decomposition. Use for complex planning, debugging, and architectural decisions where step-by-step reasoning with revision and branching helps.
globs:
  - ".context/features/*/PRP.md"
  - ".context/decisions/ADR-*.md"
  - ".context/errors/**"
---

# Sequential Thinking MCP

Structured step-by-step reasoning with revision and branching support. Use this when a problem is too complex to solve in one pass - it breaks thinking into trackable steps where you can revise earlier conclusions as understanding deepens.

## When to Use
- **Complex feature planning** (`/ce-plan`): Decompose requirements into implementation steps
- **Debugging** (`/ce-debug`): Systematic hypothesis testing, revise when evidence contradicts
- **Architecture decisions** (ADRs): Evaluate tradeoffs step-by-step with branching alternatives
- **Refactoring scope analysis**: Map dependencies before restructuring

## When NOT to Use
- Simple single-file changes or bug fixes
- Tasks where the solution is already clear
- Quick questions or lookups

## Workflow
1. Frame the problem as a sequential thinking task
2. Call `mcp__sequential-thinking__sequentialthinking` with initial thought
3. Each step: provide `thought`, `thoughtNumber`, `totalThoughts`, `nextThoughtNeeded`
4. Revise earlier steps if new evidence contradicts them (`isRevision: true`)
5. Branch into alternative paths when multiple approaches are viable (`branchFromThought`, `branchId`)
6. Synthesize conclusions from the thinking chain

## Tool Interface
```
mcp__sequential-thinking__sequentialthinking({
  thought: "Step 1: Analyze the current auth flow...",
  nextThoughtNeeded: true,
  thoughtNumber: 1,
  totalThoughts: 5,
  // Optional revision/branching:
  isRevision: false,
  revisesThought: null,
  branchFromThought: null,
  branchId: null
})
```

## Integration with Context Engine
- During `/ce-plan`: Use sequential thinking to decompose the feature, then write the PRP
- During `/ce-debug`: Use sequential thinking for hypothesis-evidence-revision cycles
- During ADR creation: Use branching to explore alternative architectures side-by-side
- Capture final synthesis in `.context/` (the thinking chain is ephemeral)

## MCP Configuration
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```
