# Chrome DevTools MCP — Reference

## MCP Configuration
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

## Starting Chrome with Debugging
```bash
# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

# Linux
google-chrome --remote-debugging-port=9222

# With a specific profile (avoids conflicts with running Chrome)
google-chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug
```

## Tool Reference

### Page Management
| Tool | Purpose | Key Params |
|------|---------|------------|
| `list_pages` | List all debuggable pages/tabs | — |
| `select_page` | Switch to a specific page | `index` |
| `new_page` | Open new tab | `url` |
| `navigate_page` | Navigate current page | `url` |
| `close_page` | Close a tab | `index` |
| `resize_page` | Set viewport size | `width`, `height` |

### Inspection
| Tool | Purpose | Key Params |
|------|---------|------------|
| `take_snapshot` | Get accessibility tree (DOM) | — |
| `take_screenshot` | Capture viewport image | — |
| `evaluate_script` | Run JS in page context | `script` |

### Interaction
| Tool | Purpose | Key Params |
|------|---------|------------|
| `click` | Click element | `selector` |
| `fill` | Set input value | `selector`, `value` |
| `type_text` | Type character by character | `text` |
| `press_key` | Keyboard key press | `key` |
| `hover` | Hover over element | `selector` |
| `drag` | Drag element | `startSelector`, `endSelector` |
| `upload_file` | Upload file to input | `selector`, `filePath` |
| `fill_form` | Fill multiple form fields | `fields` |
| `handle_dialog` | Accept/dismiss dialogs | `accept`, `promptText` |
| `select_option` | Select dropdown option | `selector`, `value` |

### Performance & Network
| Tool | Purpose |
|------|---------|
| `performance_start_trace` | Begin performance recording |
| `performance_stop_trace` | End recording, get trace data |
| `performance_analyze_insight` | Analyze trace for bottlenecks |
| `list_network_requests` | List all network activity |
| `get_network_request` | Get details of specific request |
| `take_memory_snapshot` | Heap snapshot for memory analysis |

### Console & Device
| Tool | Purpose |
|------|---------|
| `list_console_messages` | Get all console output |
| `get_console_message` | Get specific console entry |
| `emulate` | Device emulation (mobile, etc.) |
| `wait_for` | Wait for element/condition |
| `lighthouse_audit` | Run Lighthouse accessibility/perf audit |
