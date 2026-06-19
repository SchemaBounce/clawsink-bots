---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: cloudflare
  displayName: "Cloudflare"
  version: "1.0.0"
  description: "Cloudflare. DNS, Workers, Pages, and CDN management"
  tags: ["cloudflare", "cdn", "dns", "workers", "edge"]
  category: "cloud-infra"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
auth:
  type: http_bearer
  token_env: CLOUDFLARE_API_TOKEN

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@cloudflare/mcp-server-cloudflare@0.2.0"]
env:
  - name: CLOUDFLARE_API_TOKEN
    description: "Cloudflare API token from dash.cloudflare.com/profile/api-tokens"
    required: true
    sensitive: true

# Cloudflare's token verify endpoint returns {success: true} on valid
# tokens. The status code is also 200, which is enough for the engine
# to flag connected without inspecting the body.
validation:
  request:
    method: GET
    url: https://api.cloudflare.com/client/v4/user/tokens/verify
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Cloudflare rejected the API token (401). Generate a new token at https://dash.cloudflare.com/profile/api-tokens and update CLOUDFLARE_API_TOKEN." }
    "403": { state: needs_setup, message: "Token lacks required permissions (403). Grant Zone:Read or Account:Read scopes as appropriate." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://api.cloudflare.com/client/v4/user/tokens/verify
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

tools:
  - name: list_zones
    description: "List all DNS zones in the account"
    category: dns
  - name: get_zone
    description: "Get details of a specific DNS zone"
    category: dns
  - name: list_dns_records
    description: "List DNS records for a zone"
    category: dns
  - name: create_dns_record
    description: "Create a new DNS record"
    category: dns
  - name: list_workers
    description: "List deployed Workers scripts"
    category: workers
  - name: deploy_worker
    description: "Deploy a Worker script"
    category: workers
  - name: purge_cache
    description: "Purge CDN cache for a zone"
    category: cache
  - name: list_pages_projects
    description: "List Cloudflare Pages projects"
    category: pages
---

# Cloudflare MCP Server

Provides Cloudflare API tools for bots that manage DNS records, Workers, Pages deployments, and CDN caching.

## Which Bots Use This

- **devops-automator** -- Manages DNS records, deploys Workers, and purges caches
- **sre-devops** -- Monitors zones, troubleshoots DNS issues, and manages edge configuration

## Setup

1. Create a Cloudflare API token at [dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens) with the required permissions (Zone:Read, DNS:Edit, Workers:Edit, Pages:Read)
2. Add `CLOUDFLARE_API_TOKEN` in the MCP connection setup
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Cloudflare server instance across bots:

```yaml
mcpServers:
  - ref: "tools/cloudflare"
    reason: "Infrastructure bots need Cloudflare access for DNS and edge management"
    config:
      default_zone: "example.com"
```
