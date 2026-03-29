---
name: context7-docs
description: Library documentation lookup via Context7 MCP. Use when you need current docs for any library, framework, or API. Prevents hallucinated APIs by fetching real documentation.
---

# Context7 Documentation Lookup

When you need documentation for a library, framework, or API - fetch it instead of relying on training data. This prevents hallucinated function signatures and outdated API patterns.

## When to Use
- Implementing with a library you're not 100% sure about
- User asks to use a specific library version
- You're about to write code using an API and want to verify it exists
- Error suggests an API has changed since your training data

## Workflow
1. **Resolve library ID**: Use `mcp__context7__resolve-library-id` with the library name
2. **Fetch docs**: Use `mcp__context7__get-library-docs` with the resolved ID
3. **Apply**: Use the fetched documentation to write correct code

## Example
```
# Step 1: Resolve
mcp__context7__resolve-library-id("fastapi")

# Step 2: Fetch relevant docs
mcp__context7__get-library-docs(library_id="...", topic="dependency injection")

# Step 3: Write code using real API signatures
```

## Rules
- Fetch docs BEFORE writing code for unfamiliar APIs
- Don't fetch docs for standard library or well-known stable APIs
- Keep fetched content focused (specify topic) to minimize context usage
- If Context7 is unavailable, note the uncertainty in your response

## MCP Configuration
Add to `.mcp.json` or `settings.json` if not already configured:
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@context7/mcp@latest"]
    }
  }
}
```
