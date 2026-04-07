---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: google-drive
  displayName: "Google Drive"
  version: "1.0.0"
  description: "Google Drive file management — read, search, and organize files and folders"
  tags: ["google", "drive", "storage", "files", "documents"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "google-drive-mcp"]
env:
  - name: GOOGLE_CLIENT_ID
    description: "Google OAuth 2.0 client ID"
    required: true
  - name: GOOGLE_CLIENT_SECRET
    description: "Google OAuth 2.0 client secret"
    required: true
  - name: GOOGLE_REDIRECT_URI
    description: "OAuth redirect URI"
    required: true
tools:
  - name: list_files
    description: "List files and folders in a directory"
    category: files
  - name: get_file
    description: "Get file metadata and content"
    category: files
  - name: search_files
    description: "Search for files by name or content"
    category: search
  - name: create_folder
    description: "Create a new folder"
    category: folders
  - name: upload_file
    description: "Upload a file to Google Drive"
    category: files
  - name: move_file
    description: "Move a file to a different folder"
    category: files
---

# Google Drive MCP Server

Provides Google Drive API tools for bots that manage files, documents, and folders.

## Which Bots Use This

- **executive-assistant** — Organizes files, creates shared folders for projects
- **documentation-writer** — Manages documentation files and shared drives
- **data-analyst** — Reads spreadsheets and data files from Drive

## Setup

1. Create a Google Cloud project and enable the Drive API
2. Create OAuth 2.0 credentials (Desktop or Web application type)
3. Add the credentials to your workspace secrets
4. The server starts automatically when a bot that references it runs

**Note:** Google Drive requires OAuth authentication. Connect via Composio for managed OAuth, or provide service account credentials for server-to-server access.

## Team Usage

Add to your TEAM.md to share a single Google Drive server instance across all bots:

```yaml
mcpServers:
  - ref: "tools/google-drive"
    reason: "Bots need access to shared Drive files and folders"
```
