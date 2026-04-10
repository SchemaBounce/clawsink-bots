---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: n8n
  displayName: "n8n"
  version: "1.0.0"
  description: "n8n workflow automation — workflows, executions, and credentials"
  tags: ["n8n", "automation", "workflow", "self-hosted"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "n8n-mcp@2.47.6"]
env:
  - name: N8N_API_URL
    description: "n8n instance URL"
    required: true
  - name: N8N_API_KEY
    description: "n8n API key"
    required: true
tools:
  - name: list_workflows
    description: "List all workflows in the instance"
    category: workflows
  - name: get_workflow
    description: "Get details of a specific workflow"
    category: workflows
  - name: execute_workflow
    description: "Execute a workflow by ID"
    category: executions
  - name: list_executions
    description: "List recent workflow executions"
    category: executions
  - name: get_execution
    description: "Get details of a specific execution"
    category: executions
  - name: activate_workflow
    description: "Activate a workflow"
    category: workflows
  - name: deactivate_workflow
    description: "Deactivate a workflow"
    category: workflows
---

# n8n MCP Server

Provides n8n API tools for managing workflows, triggering executions, and monitoring automation pipelines.

## Which Bots Use This

- **devops-automator** -- Orchestrates infrastructure workflows and monitors execution results

## Setup

1. Deploy an n8n instance (self-hosted or [n8n.cloud](https://n8n.cloud/))
2. Enable the API and generate an API key in Settings > API
3. Add `N8N_API_URL` and `N8N_API_KEY` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single n8n server instance across bots:

```yaml
mcpServers:
  - ref: "tools/n8n"
    reason: "Bots need n8n access for workflow orchestration and automation"
    config:
      timeout_seconds: 120
```
