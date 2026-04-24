---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: netlify
  displayName: "Netlify"
  version: "1.0.0"
  description: "Netlify, sites, deploys, forms, and serverless functions"
  tags: ["netlify", "deployment", "hosting", "jamstack"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@netlify/mcp@1.15.1"]
env:
  - name: NETLIFY_AUTH_TOKEN
    description: "Netlify personal access token from app.netlify.com/user/applications"
    required: true
tools:
  - name: list_sites
    description: "List all sites in the account"
    category: sites
  - name: get_site
    description: "Get details of a specific site"
    category: sites
  - name: list_deploys
    description: "List deploys for a site"
    category: deploys
  - name: create_deploy
    description: "Create a new deploy for a site"
    category: deploys
  - name: list_forms
    description: "List forms for a site"
    category: forms
  - name: list_submissions
    description: "List form submissions"
    category: forms
  - name: list_functions
    description: "List serverless functions for a site"
    category: functions
  - name: get_build_log
    description: "Get the build log for a deploy"
    category: deploys
---

# Netlify MCP Server

Provides Netlify API tools for bots that manage sites, deployments, forms, and serverless functions.

## Which Bots Use This

- **devops-automator** -- Manages site deployments, monitors build logs, and triggers redeploys
- **release-manager** -- Coordinates releases, verifies deploy status, and rolls back failed deploys

## Setup

1. Create a personal access token at [app.netlify.com/user/applications](https://app.netlify.com/user/applications)
2. Add `NETLIFY_AUTH_TOKEN` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Netlify server instance across bots:

```yaml
mcpServers:
  - ref: "tools/netlify"
    reason: "Deployment bots need Netlify access for site management and release coordination"
    config:
      default_site: "my-production-site"
```
