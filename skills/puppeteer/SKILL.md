---
description: Browser automation via Puppeteer MCP - navigation, screenshots, form filling, testing. Auto-loaded when working with browser tests, E2E tests, or scraping-related files.
---

# Puppeteer MCP - Browser Automation

Control a headless (or headed) Chrome browser for testing, scraping, and visual verification.

## When to Use
- **E2E testing**: Verify user flows end-to-end in a real browser
- **Visual regression**: Screenshot pages and compare against baselines
- **Form testing**: Fill and submit forms, verify validation behavior
- **Scraping**: Extract data from pages that require JavaScript rendering
- **Debug UI issues**: Screenshot specific states to inspect layout/styling

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

## Best Practices
- Wait for navigation/network idle before screenshots
- Use specific CSS selectors, not fragile XPath
- Set viewport dimensions for consistent screenshots
- Clean up: don't leave browser processes running
- For headed mode (see the browser), set `PUPPETEER_LAUNCH_OPTIONS`

## MCP Configuration
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

For headed mode (visible browser window):
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
