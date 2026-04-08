---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: google-docs
  displayName: "Google Docs"
  version: "1.0.0"
  description: "Google Docs document creation, reading, and editing"
  tags: ["google", "docs", "documents", "writing"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "google-docs-mcp@1.0.0"]
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
  - name: create_document
    description: "Create a new document"
    category: documents
  - name: read_document
    description: "Read document content"
    category: documents
  - name: update_document
    description: "Update document content"
    category: editing
  - name: search_documents
    description: "Search for documents"
    category: search
  - name: insert_text
    description: "Insert text at position"
    category: editing
  - name: delete_content
    description: "Delete content range"
    category: editing
---

# Google Docs MCP Server

Provides Google Docs API tools for bots that create, read, and edit documents.

## Which Bots Use This

- **documentation-writer** -- Creates and updates technical documentation in Google Docs
- **executive-assistant** -- Generates reports and meeting summaries as documents
- **blog-writer** -- Drafts blog posts and content in Google Docs for review

## Setup

1. Create a Google Cloud project and enable the Docs API
2. Create OAuth 2.0 credentials (client ID and secret)
3. Add `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, and `GOOGLE_REDIRECT_URI` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Google Docs server instance across bots:

```yaml
mcpServers:
  - ref: "tools/google-docs"
    reason: "Bots need document access for creating reports, docs, and content drafts"
    config:
      default_folder_id: "your-drive-folder-id"
```
