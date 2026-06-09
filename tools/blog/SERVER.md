---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: blog
  displayName: "Blog (SchemaBounce CMS)"
  version: "1.0.0"
  description: "Publish blog drafts to the SchemaBounce CMS via a workspace service account with blog:write scope"
  tags: ["blog", "cms", "content", "publishing", "schemabounce"]
  category: "platform"
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "sb-blog-mcp"
  args: []
env:
  - name: SCHEMABOUNCE_API_URL
    description: "SchemaBounce API base URL (e.g. https://api.schemabounce.com or http://localhost:8080 for local dev)"
    required: true
  - name: SCHEMABOUNCE_CLIENT_ID
    description: "Service account client ID with blog:write scope (e.g. sa_...)"
    required: true
  - name: SCHEMABOUNCE_CLIENT_SECRET
    description: "Service account client secret — shown only once at creation time"
    required: true
    sensitive: true
validation:
  request:
    method: GET
    url: "{SCHEMABOUNCE_API_URL}/api/v1/workspaces"
    headers:
      Accept: application/json
      Authorization: "Bearer {SCHEMABOUNCE_CLIENT_SECRET}"
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Service account credentials rejected (401). Check SCHEMABOUNCE_CLIENT_ID and SCHEMABOUNCE_CLIENT_SECRET." }
    "403": { state: needs_setup, message: "Service account lacks required scope (403). Ensure the account has blog:write." }
    "default": { state: failed }
  timeout_ms: 5000
tools:
  - name: blog_create_draft
    description: "Create a new blog post draft. Returns post_id, slug, and status."
    category: publishing
  - name: blog_submit_review
    description: "Submit a draft post for human review. Moves status from draft to review. There is no agent-callable approve tool."
    category: publishing
  - name: blog_list
    description: "List blog posts for the workspace. Useful for duplicate-topic checks before drafting."
    category: publishing
---

# Blog (SchemaBounce CMS) MCP Server

Provides three tools for the blog-writer agent to publish content to the SchemaBounce CMS. The server authenticates using a workspace service account with the `blog:write` scope. Human approval (`blog:manage`) is never exposed as a tool.

This is a dedicated, standalone MCP server (`sb-blog-mcp` binary, stdio transport). It is separate from the main `tools/schemabounce` platform MCP — the blog is a CMS concern, and keeping it isolated means future targets (WordPress, Ghost, Webflow) become additive sibling connectors without touching the platform MCP.

## Which Bots Use This

- **blog-writer** — creates and submits drafts on a weekly schedule

## Setup

1. In your SchemaBounce workspace, go to **Settings > Service Accounts** and create a new service account.
2. Assign it the `blog:write` scope (grants `blog:write` + `blog:view`; does NOT grant `blog:manage` — approval stays human-only).
3. Copy the `client_id` and `client_secret` (the secret is shown only once).
4. Go to **Connections > Add Connection** and choose **Blog (SchemaBounce CMS)**.
5. Enter `SCHEMABOUNCE_API_URL`, `SCHEMABOUNCE_CLIENT_ID`, and `SCHEMABOUNCE_CLIENT_SECRET`.
6. Click **Test Connection** — you should see a green `connected` badge.
7. Grant the `blog-writer` agent access to the connection via **Agent > Connections**.

## Tool Reference

### `blog_create_draft`

Creates a new blog post with `status=draft` and `author_type=agent`.

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | No | Defaults to the workspace bound to the SA token |
| `title` | string | Yes | Post title |
| `description` | string | No | Short summary (meta description, under 155 chars) |
| `content` | string | Yes | Full post body in Markdown |
| `section` | string | No | `"schemabounce"` or `"openclaw"` |
| `category` | string | No | Editorial category (e.g. engineering, product, tutorial) |
| `tags` | string[] | No | Keyword tags for filtering |

Returns `{ post_id, slug, status }`.

### `blog_submit_review`

Moves a draft post to `status=review` for human approval.

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | No | Defaults to the workspace bound to the SA token |
| `post_id` | string | Yes | The `post_id` returned by `blog_create_draft` |

Returns `{ post_id, status }`.

There is no `blog_approve` tool. Approval is a human action performed in the Blog Management UI by a workspace member with the `blog:manage` permission.

### `blog_list`

Lists blog posts visible to the connected service account. Useful for checking whether a topic has already been covered before starting a new draft.

| Parameter | Type | Required | Notes |
|-----------|------|----------|-------|
| `workspace_id` | string | No | Defaults to the workspace bound to the SA token |

Returns `{ posts, total }`.

## Authorization Model

The `blog:write` scope grants `{ blog:write, blog:view }`. No scope maps to `blog:manage`. This means:

- An agent with a `blog:write` service account **can**: create drafts, submit for review, list posts.
- An agent **cannot**: approve, reject, or delete posts. These actions require a human with the `blog:manage` permission (Owner role).

This is enforced at the API level — even if an agent constructs a raw HTTP request to the approve endpoint, it will receive a `403 Forbidden`.

## How the server launches

The runtime starts `sb-blog-mcp` as a child process (stdio transport). The process reads JSON-RPC from stdin and writes responses to stdout; stderr carries structured logs. The three env vars are injected from the workspace connection store at startup.

The server performs an OAuth `client_credentials` token exchange against `<SCHEMABOUNCE_API_URL>/api/v1/oauth/token` on startup using `SCHEMABOUNCE_CLIENT_ID` / `SCHEMABOUNCE_CLIENT_SECRET`, then caches and auto-refreshes the Bearer token for all subsequent tool calls.
