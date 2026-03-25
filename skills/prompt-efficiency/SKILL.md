---
description: Context budget and token efficiency rules. Auto-loaded to minimize prompt overhead across all interactions.
---

# Prompt Efficiency

## Delegation Rules
- Pass only the **task + relevant file paths** to subagents — not full context summaries
- Agent reads `.context/` independently — don't duplicate its content in the delegation prompt
- Each Agent Team teammate gets only **their file scope**, not the full PRP

## Context Loading Rules
- Read only the **section needed** from `.context/` files, not the full file
- Skills with a `REFERENCE.md` file: load only `SKILL.md` (Tier 1) by default; read `REFERENCE.md` only when editing MCP configs or the user explicitly asks for setup details
- Shared instructions in `.claude/instructions/` are **referenced, not inlined** — agents and commands point to them instead of duplicating content

## Context Budget Thresholds
- **< 40%**: Full Agent Teams allowed
- **40-50%**: Prefer single subagent over Agent Team
- **> 50%**: Save state, prepare to `/clear` + `/resume`
- **> 60%**: Stop. `/clear`. `/resume`.

## Anti-Patterns (Token Waste)
- Repeating agent instructions in command prompts (agents have their own instructions)
- Loading full MCP config blocks when only querying data
- Summarizing `.context/` docs in delegation prompts (agent reads them directly)
- Spawning Agent Teams for < 3 independent steps
