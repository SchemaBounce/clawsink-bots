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
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "vercel-mcp-server@1.0.0"]
env:
  - name: VERCEL_TOKEN
    description: "Vercel API token from vercel.com/account/tokens"
    required: true
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
