---
name: chrome-devtools
description: Chrome DevTools debugging and browser automation via MCP. Auto-loaded when working with browser debugging, performance analysis, or web inspection tasks.
---

# Chrome DevTools MCP

Browser debugging, performance profiling, and page inspection via the Chrome DevTools Protocol.

## When to Use
- Debugging rendered web pages (layout, styles, DOM)
- Performance analysis (LCP, memory leaks, network waterfall)
- Accessibility auditing (contrast, ARIA, focus states)
- Inspecting live network requests and console output
- Taking screenshots of rendered pages
- Automating browser interactions for testing

## When NOT to Use
- Headless browser scripting (use Puppeteer instead)
- Unit/integration testing (use test framework directly)
- Static code analysis (use linter/type checker)

## Workflow
1. Ensure Chrome/Chromium is running with remote debugging enabled
2. Use `list_pages` to find available targets
3. `select_page` or `navigate_page` to target the right page
4. Use inspection tools: `take_snapshot` (DOM), `take_screenshot`, `evaluate_script`
5. For performance: `performance_start_trace` → reproduce issue → `performance_stop_trace` → `performance_analyze_insight`
6. For accessibility: `lighthouse_audit` or manual DOM inspection

## Key Tools
- **Navigation**: `navigate_page`, `list_pages`, `select_page`, `new_page`, `close_page`
- **Inspection**: `take_snapshot`, `take_screenshot`, `evaluate_script`
- **Interaction**: `click`, `fill`, `type_text`, `press_key`, `hover`, `drag`
- **Performance**: `performance_start_trace`, `performance_stop_trace`, `performance_analyze_insight`
- **Network**: `list_network_requests`, `get_network_request`
- **Console**: `list_console_messages`, `get_console_message`
- **Advanced**: `lighthouse_audit`, `take_memory_snapshot`, `emulate`

## Rules
- Always `list_pages` first to verify a debuggable target exists
- Use `take_snapshot` (DOM tree) over `take_screenshot` when text content matters — DOM text is far smaller than base64 images
- For performance issues, capture a trace rather than guessing — `performance_analyze_insight` provides data-driven answers
- Network inspection via `list_network_requests` is more reliable than console.log for API debugging
- Use URL filters on `list_network_requests` rather than fetching all requests — filter to the domain or path you care about
- For console messages, use `get_console_message` for specific entries rather than `list_console_messages` for the full log
- Multi-step browser sequences (navigate + interact + inspect) should be delegated to a subagent to keep raw DOM/screenshot output out of lead agent context

## Common Pitfalls
- Chrome must be running with `--remote-debugging-port` flag — if `list_pages` returns nothing, Chrome isn't in debug mode
- `evaluate_script` runs in the page context, not Node.js — no `require()` or `fs` access
- Screenshots capture the viewport only — use `resize_page` first if testing responsive layouts

For available tools, MCP configuration, and startup instructions, read `REFERENCE.md` in this directory.
