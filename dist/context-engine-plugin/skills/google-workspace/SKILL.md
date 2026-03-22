---
description: Google Workspace operations via MCP - Docs, Sheets, Drive. Create, read, edit spreadsheets and documents directly from Claude Code.
globs:
  - "**/*spreadsheet*"
  - "**/*google*sheet*"
  - "**/*gdoc*"
  - "**/*gsheet*"
  - "**/*google*drive*"
  - "**/*csv-export*"
  - "**/*import*csv*"
---

# Google Workspace MCP - Docs, Sheets & Drive

Create, read, and edit Google Docs, Sheets, and Drive files directly from Claude Code.

## When to Use
- **Spreadsheet automation**: Create trackers, populate data, build charts
- **Document generation**: Create reports, proposals, meeting notes from code/data
- **Data pipelines**: Read spreadsheet data into your app, or export app data to Sheets
- **Project management**: Update project trackers, status sheets, budget docs
- **File organization**: Search, move, and manage Drive files

## Capabilities

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

## Workflow: Data Export to Sheets
```
1. Query your database or API for data
2. Format as rows/columns
3. Create or open a Google Sheet
4. Write data to the sheet
5. Add formatting, headers, charts as needed
```

## Workflow: Generate Report Doc
```
1. Gather data from code analysis or database
2. Create a Google Doc with title
3. Insert sections with findings
4. Add tables for data summaries
5. Share the document link
```

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
