# Google Workspace MCP - Detailed Configuration

## MCP Configuration Options

**Option 1: All-in-one (Docs + Sheets + Drive)**
```json
{
  "mcpServers": {
    "google-workspace": {
      "command": "npx",
      "args": ["-y", "@a-bonus/google-docs-mcp"],
      "env": {
        "GOOGLE_CLIENT_ID": "your-client-id",
        "GOOGLE_CLIENT_SECRET": "your-client-secret"
      }
    }
  }
}
```
First-time auth: `GOOGLE_CLIENT_ID="..." GOOGLE_CLIENT_SECRET="..." npx -y @a-bonus/google-docs-mcp auth`

**Option 2: Drive + Docs + Sheets + Calendar**
```json
{
  "mcpServers": {
    "google-drive": {
      "command": "npx",
      "args": ["-y", "@piotr-agier/google-drive-mcp"],
      "env": {
        "GOOGLE_DRIVE_MCP_SCOPES": "drive,documents,spreadsheets,calendar"
      }
    }
  }
}
```

**Option 3: Sheets-only (lighter weight)**
```json
{
  "mcpServers": {
    "google-sheets": {
      "command": "npx",
      "args": ["-y", "mcp-gsheets@latest"],
      "env": {
        "GOOGLE_PROJECT_ID": "your-project-id",
        "GOOGLE_APPLICATION_CREDENTIALS": "/path/to/service-account-key.json"
      }
    }
  }
}
```

## Setup Requirements
All options require Google Cloud Platform credentials:
1. Create a project in Google Cloud Console
2. Enable Docs, Sheets, and/or Drive APIs
3. Create OAuth 2.0 credentials (or Service Account for Sheets-only)
4. Run initial auth to generate refresh token
5. Token is saved locally for future sessions

## Safety Notes
- Review document contents before sharing broadly
- Service accounts create files owned by the service account (share explicitly)
- OAuth tokens expire - re-auth if connections fail after 7 days (testing mode)

## Capabilities Detail

### Google Sheets
- Create spreadsheets with multiple tabs
- Read/write cell ranges and named ranges
- Build tables with headers, dropdowns, formatting
- Append rows, batch update cells
- Create charts from data

### Google Docs
- Create documents with rich formatting
- Insert headers, footers, tables, images
- Find and replace text
- Add comments and suggestions
- Convert markdown to Docs format

### Google Drive
- Search files and folders
- Create, move, copy, rename files
- Navigate folder hierarchies
- Manage file sharing and permissions
