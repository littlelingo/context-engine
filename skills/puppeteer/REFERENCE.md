# Puppeteer MCP - Detailed Configuration

## Available Tools
| Tool | Purpose |
|------|---------|
| `puppeteer_navigate` | Navigate to a URL |
| `puppeteer_screenshot` | Capture full-page or element screenshot |
| `puppeteer_click` | Click elements by CSS selector |
| `puppeteer_fill` | Fill form inputs by CSS selector |
| `puppeteer_select` | Select dropdown options |
| `puppeteer_hover` | Hover over elements |
| `puppeteer_evaluate` | Execute JavaScript in page context |

## MCP Configuration

**Headless (default):**
```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

**Headed (visible browser window):**
```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
      "env": {
        "PUPPETEER_LAUNCH_OPTIONS": "{\"headless\": false}",
        "ALLOW_DANGEROUS": "true"
      }
    }
  }
}
```

## Workflow: Visual Verification
```
1. puppeteer_navigate({ url: "http://localhost:3000/login" })
2. puppeteer_screenshot({ name: "login-page" })
3. puppeteer_fill({ selector: "#email", value: "test@example.com" })
4. puppeteer_fill({ selector: "#password", value: "password123" })
5. puppeteer_click({ selector: "button[type=submit]" })
6. puppeteer_screenshot({ name: "after-login" })
```

## Workflow: Data Extraction
```
1. puppeteer_navigate({ url: "https://target-site.com/data" })
2. puppeteer_evaluate({ script: "document.querySelectorAll('.item').length" })
3. puppeteer_evaluate({ script: "JSON.stringify([...document.querySelectorAll('.item')].map(e => e.textContent))" })
```
