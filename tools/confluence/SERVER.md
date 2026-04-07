---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: confluence
  displayName: "Confluence"
  version: "1.0.0"
  description: "Confluence wiki -- pages, spaces, search, and content management"
  tags: ["confluence", "atlassian", "wiki", "documentation"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "confluence-mcp-server@1.1.0"]
env:
  - name: CONFLUENCE_URL
    description: "Confluence instance URL"
    required: true
  - name: CONFLUENCE_EMAIL
    description: "Confluence user email"
    required: true
  - name: CONFLUENCE_API_TOKEN
    description: "Atlassian API token"
    required: true
tools:
  - name: search_content
    description: "Search content across spaces"
    category: search
  - name: get_page
    description: "Get a page by ID"
    category: pages
  - name: create_page
    description: "Create a new page"
    category: pages
  - name: update_page
    description: "Update an existing page"
    category: pages
  - name: list_spaces
    description: "List all spaces"
    category: spaces
  - name: get_space
    description: "Get space details"
    category: spaces
  - name: list_children
    description: "List child pages"
    category: pages
  - name: get_attachments
    description: "Get page attachments"
    category: attachments
---

# Confluence MCP Server

Provides Confluence wiki tools for bots that manage documentation, knowledge bases, and team wikis.

## Which Bots Use This

- **documentation-writer** -- Creates and updates technical documentation pages
- **software-architect** -- Publishes architecture decision records and design docs

## Setup

1. Generate an Atlassian API token at https://id.atlassian.com/manage-profile/security/api-tokens
2. Add `CONFLUENCE_URL`, `CONFLUENCE_EMAIL`, and `CONFLUENCE_API_TOKEN` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Confluence server instance across bots:

```yaml
mcpServers:
  - ref: "tools/confluence"
    reason: "Bots need wiki access for documentation and knowledge management"
    config:
      default_space: "ENG"
```
