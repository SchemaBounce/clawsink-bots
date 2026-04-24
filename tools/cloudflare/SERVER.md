---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: cloudflare
  displayName: "Cloudflare"
  version: "1.0.0"
  description: "Cloudflare. DNS, Workers, Pages, and CDN management"
  tags: ["cloudflare", "cdn", "dns", "workers", "edge"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@cloudflare/mcp-server-cloudflare@0.2.0"]
env:
  - name: CLOUDFLARE_API_TOKEN
    description: "Cloudflare API token from dash.cloudflare.com/profile/api-tokens"
    required: true
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
2. Add `CLOUDFLARE_API_TOKEN` to your workspace secrets
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
