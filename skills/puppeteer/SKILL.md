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

## Best Practices
- Wait for navigation/network idle before screenshots
- Use specific CSS selectors, not fragile XPath
- Set viewport dimensions for consistent screenshots
- Clean up: don't leave browser processes running

For available tools, MCP configuration, and workflow examples, read `REFERENCE.md` in this directory.
