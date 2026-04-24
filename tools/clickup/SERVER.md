---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: clickup
  displayName: "ClickUp"
  version: "1.0.0"
  description: "ClickUp project management, tasks, lists, spaces, and goals"
  tags: ["clickup", "project-management", "tasks", "productivity"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "clickup-mcp@1.0.1"]
env:
  - name: CLICKUP_API_TOKEN
    description: "ClickUp personal API token from Settings > Apps"
    required: true
tools:
  - name: list_tasks
    description: "List tasks in a list"
    category: tasks
  - name: create_task
    description: "Create a new task"
    category: tasks
  - name: update_task
    description: "Update an existing task"
    category: tasks
  - name: get_task
    description: "Get details of a specific task"
    category: tasks
  - name: list_spaces
    description: "List spaces in a workspace"
    category: spaces
  - name: list_lists
    description: "List lists in a folder or space"
    category: lists
  - name: list_goals
    description: "List goals in the workspace"
    category: goals
  - name: add_comment
    description: "Add a comment to a task"
    category: tasks
---

# ClickUp MCP Server

Provides ClickUp API tools for managing tasks, organizing spaces and lists, and tracking goals.

## Which Bots Use This

- **project-manager** -- Creates and tracks tasks, monitors sprint progress, and manages project timelines
- **executive-assistant** -- Creates follow-up tasks from meetings and tracks action items

## Setup

1. Log in to [ClickUp](https://app.clickup.com/) and navigate to Settings > Apps
2. Copy your personal API token
3. Add `CLICKUP_API_TOKEN` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single ClickUp server instance across bots:

```yaml
mcpServers:
  - ref: "tools/clickup"
    reason: "Bots need ClickUp access for task management and project tracking"
    config:
      default_space_id: "your-space-id"
```
