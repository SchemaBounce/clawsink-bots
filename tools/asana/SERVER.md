---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: asana
  displayName: "Asana"
  version: "1.0.0"
  description: "Asana project management -- tasks, projects, teams, and portfolios"
  tags: ["asana", "project-management", "tasks", "enterprise"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "sse"
  url: "https://mcp.asana.com/sse"
env:
  - name: ASANA_ACCESS_TOKEN
    description: "Asana personal access token"
    required: true
tools:
  - name: list_tasks
    description: "List tasks in a project"
    category: tasks
  - name: create_task
    description: "Create a new task"
    category: tasks
  - name: update_task
    description: "Update an existing task"
    category: tasks
  - name: complete_task
    description: "Mark a task as complete"
    category: tasks
  - name: list_projects
    description: "List projects in a workspace"
    category: projects
  - name: create_project
    description: "Create a new project"
    category: projects
  - name: list_sections
    description: "List sections in a project"
    category: sections
  - name: list_workspaces
    description: "List accessible workspaces"
    category: workspaces
  - name: search_tasks
    description: "Search tasks across projects"
    category: tasks
  - name: add_comment
    description: "Add a comment to a task"
    category: tasks
---

# Asana MCP Server

Provides Asana project management tools for bots that coordinate tasks, track projects, and manage team workflows.

> **Note:** Asana's MCP server is OAuth-gated. Connect via Composio for managed auth.

## Which Bots Use This

- **project-manager** -- Creates and tracks project tasks, milestones, and assignments
- **executive-assistant** -- Monitors task progress and surfaces overdue items

## Setup

1. Create an Asana personal access token at https://app.asana.com/0/developer-console
2. Add `ASANA_ACCESS_TOKEN` to your workspace secrets
3. The server connects via SSE to Asana's hosted MCP endpoint

## Team Usage

Add to your TEAM.md to share a single Asana server instance across bots:

```yaml
mcpServers:
  - ref: "tools/asana"
    reason: "Bots need project management access for task tracking and coordination"
    config:
      default_workspace: "your-workspace-gid"
```
