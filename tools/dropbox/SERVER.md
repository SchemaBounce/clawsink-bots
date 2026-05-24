---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: dropbox
  displayName: "Dropbox"
  version: "1.0.0"
  description: "Dropbox file storage, files, folders, sharing, and search"
  tags: ["dropbox", "storage", "files", "cloud-storage"]
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
auth:
  type: http_bearer
  token_env: DROPBOX_ACCESS_TOKEN

transport:
  type: "sse"
  url: "https://mcp.dropbox.com/sse"
env:
  - name: DROPBOX_ACCESS_TOKEN
    description: "Dropbox access token from Dropbox App Console"
    required: true
    sensitive: true

# /2/users/get_current_account returns the authenticated account.
# Dropbox requires POST with empty body for this endpoint.
validation:
  request:
    method: POST
    url: https://api.dropboxapi.com/2/users/get_current_account
    headers:
      Content-Type: application/json
    body: "null"
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Dropbox rejected the access token (401). Generate a new one in Dropbox App Console and update DROPBOX_ACCESS_TOKEN." }
    "403": { state: needs_setup, message: "Dropbox app lacks required scopes (403)." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: POST
    url: https://api.dropboxapi.com/2/users/get_current_account
    headers:
      Content-Type: application/json
    body: "null"
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

tools:
  - name: list_folder
    description: "List files in a folder"
    category: files
  - name: get_file
    description: "Download file content"
    category: files
  - name: upload_file
    description: "Upload a file"
    category: files
  - name: search_files
    description: "Search for files"
    category: search
  - name: create_folder
    description: "Create a folder"
    category: folders
  - name: share_file
    description: "Create a shared link"
    category: sharing
  - name: move_file
    description: "Move or rename a file"
    category: files
  - name: delete_file
    description: "Delete a file"
    category: files
---

# Dropbox MCP Server

Provides Dropbox file storage tools for bots that need to manage files, folders, sharing links, and search across cloud storage.

## Which Bots Use This

- **executive-assistant** — File management, document organization, and sharing
- **documentation-writer** — Document storage, retrieval, and collaboration

**Note:** OAuth-gated -- connect via Composio for managed auth.

## Setup

1. Create an app in the Dropbox App Console
2. Generate an access token
3. Add `DROPBOX_ACCESS_TOKEN` to your workspace secrets
4. The server connects via SSE when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Dropbox server instance across bots:

```yaml
mcpServers:
  - ref: "tools/dropbox"
    reason: "Bots need Dropbox access for file management and document sharing"
    config:
      root_folder: "/team-workspace"
```
