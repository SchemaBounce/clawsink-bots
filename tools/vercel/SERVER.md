---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: vercel
  displayName: "Vercel"
  version: "1.0.0"
  description: "Vercel deployments, projects, domains, and deployment management"
  tags: ["vercel", "deployment", "hosting", "frontend", "serverless"]
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
auth:
  type: http_bearer
  token_env: VERCEL_TOKEN

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "vercel-mcp-server@1.0.0"]
env:
  - name: VERCEL_TOKEN
    description: "Vercel API token from vercel.com/account/tokens"
    required: true
    sensitive: true

# /v2/user returns the authenticated user. Vercel deprecated /v9/user
# in favor of /v2/user; /v2 is current.
validation:
  request:
    method: GET
    url: https://api.vercel.com/v2/user
  expect:
    status: 200
    extract:
      authenticated_as_field: user
  on_status:
    "401": { state: needs_setup, message: "Vercel rejected the API token (401). Generate a new one at https://vercel.com/account/tokens and update VERCEL_TOKEN." }
    "403": { state: needs_setup, message: "Token lacks required permissions (403)." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://api.vercel.com/v2/user
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

tools:
  - name: list_projects
    description: "List all Vercel projects"
    category: projects
  - name: get_project
    description: "Get details of a specific project"
    category: projects
  - name: list_deployments
    description: "List deployments for a project"
    category: deployments
  - name: get_deployment
    description: "Get details of a specific deployment"
    category: deployments
  - name: list_domains
    description: "List domains for a project"
    category: domains
  - name: create_deployment
    description: "Create a new deployment"
    category: deployments
  - name: list_env_vars
    description: "List environment variables for a project"
    category: projects
  - name: get_deployment_logs
    description: "Get logs for a deployment"
    category: deployments
---

# Vercel MCP Server

Provides Vercel tools for managing deployments, projects, and domains on the Vercel platform.

## Which Bots Use This

- **devops-automator** -- Monitors deployment status, manages environment variables, triggers redeployments
- **release-manager** -- Tracks production deployments, verifies successful rollouts
- **sre-devops** -- Investigates deployment failures, checks build logs

## Setup

1. Create an API token at [Vercel Account Tokens](https://vercel.com/account/tokens)
2. Add it to your workspace secrets as `VERCEL_TOKEN`
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Vercel server instance across deployment bots:

```yaml
mcpServers:
  - ref: "tools/vercel"
    reason: "Deployment bots need Vercel access for managing frontend deployments"
    config:
      default_team: "your-team-slug"
```
