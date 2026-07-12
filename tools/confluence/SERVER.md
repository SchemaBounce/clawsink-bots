---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: confluence
  displayName: "Confluence"
  version: "1.0.0"
  description: "Confluence wiki -- pages, spaces, search, and content management"
  tags: ["confluence", "atlassian", "wiki", "documentation"]
  category: "files-docs"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
# Same Atlassian two-credential http_basic + per-tenant URL pattern
# as Jira. The same Atlassian API token works for both products.
auth:
  type: http_basic
  username_env: CONFLUENCE_EMAIL
  password_env: CONFLUENCE_API_TOKEN

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "confluence-mcp-server@1.1.0"]
env:
  # OPTIONAL: credentials are bridged from the workspace's Atlassian OAuth (Confluence cloud)
  # connection stored by core-api's ResolveConnectionSecret OAuth bridge.
  # Leaving these blank uses the workspace's connected OAuth integration;
  # provide values only to override. Marked required:true previously, which
  # made the setup/reconnect modal demand credentials the OAuth flow already covers.
  - name: CONFLUENCE_URL
    description: "Confluence instance URL"
    required: false
  - name: CONFLUENCE_EMAIL
    description: "Confluence user email"
    required: false
  - name: CONFLUENCE_API_TOKEN
    description: "Atlassian API token"
    required: false
    sensitive: true

# /wiki/rest/api/user/current returns the authenticated user.
validation:
  request:
    method: GET
    url: "{CONFLUENCE_URL}/wiki/rest/api/user/current"
    headers:
      Accept: application/json
  expect:
    status: 200
    extract:
      authenticated_as_field: displayName
  on_status:
    "401": { state: needs_setup, message: "Confluence rejected the email/token combination (401). Verify the API token at https://id.atlassian.com/manage-profile/security/api-tokens." }
    "403": { state: needs_setup, message: "Account lacks permission (403). The token's account needs at least Confluence read access." }
    "404": { state: needs_setup, message: "Confluence host returned 404 — check CONFLUENCE_URL is the base URL (no /wiki suffix, no trailing slash)." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: "{CONFLUENCE_URL}/wiki/rest/api/user/current"
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

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
2. Add `CONFLUENCE_URL`, `CONFLUENCE_EMAIL`, and `CONFLUENCE_API_TOKEN` in the MCP connection setup
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
