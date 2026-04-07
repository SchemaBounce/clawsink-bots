---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: google-sheets
  displayName: "Google Sheets"
  version: "1.0.0"
  description: "Google Sheets spreadsheet reading, writing, and formula management"
  tags: ["google", "sheets", "spreadsheet", "data"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "google-sheets-mcp"]
env:
  - name: GOOGLE_CLIENT_ID
    description: "Google OAuth client ID"
    required: true
  - name: GOOGLE_CLIENT_SECRET
    description: "Google OAuth client secret"
    required: true
  - name: GOOGLE_REDIRECT_URI
    description: "Google OAuth redirect URI"
    required: true
tools:
  - name: read_sheet
    description: "Read data from a sheet range"
    category: sheets
  - name: write_sheet
    description: "Write data to a sheet range"
    category: sheets
  - name: create_spreadsheet
    description: "Create a new spreadsheet"
    category: management
  - name: list_sheets
    description: "List sheets in a spreadsheet"
    category: management
  - name: append_rows
    description: "Append rows to a sheet"
    category: data
  - name: clear_range
    description: "Clear a range of cells"
    category: data
  - name: get_spreadsheet_info
    description: "Get spreadsheet metadata"
    category: management
---

# Google Sheets MCP Server

Provides Google Sheets API tools for bots that read, write, and manage spreadsheet data.

## Which Bots Use This

- **data-analyst** -- Reads and writes reporting data to shared spreadsheets
- **accountant** -- Tracks financial data, budgets, and reconciliation in spreadsheets
- **inventory-tracker** -- Monitors stock levels and updates inventory sheets

## Setup

1. Create a Google Cloud project and enable the Sheets API
2. Create OAuth 2.0 credentials (client ID and secret)
3. Add `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and `GOOGLE_REDIRECT_URI` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Google Sheets server instance across bots:

```yaml
mcpServers:
  - ref: "tools/google-sheets"
    reason: "Bots need spreadsheet access for reporting and data tracking"
    config:
      default_spreadsheet_id: "your-spreadsheet-id"
```
