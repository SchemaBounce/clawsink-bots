---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: todoist
  displayName: "Todoist"
  version: "1.0.0"
  description: "Todoist task management -- tasks, projects, labels, and reminders"
  tags: ["todoist", "tasks", "productivity", "project-management"]
  category: "project-issue"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
auth:
  type: http_bearer
  token_env: TODOIST_API_TOKEN

transport:
  type: "stdio"
  command: "uvx"
  args: ["todoist-mcp-server==0.1.3"]
env:
  # OPTIONAL: credentials are bridged from the workspace's Composio-managed OAuth
  # connection. Leaving these blank uses the workspace's Composio integration for
  # this service; provide values only to override the managed connection. Marked
  # required:true previously, which made the setup/reconnect modal demand
  # credentials the managed flow already covers.
  - name: TODOIST_API_TOKEN
    description: "Todoist API token from todoist.com/prefs/integrations"
    required: false
    sensitive: true

# /rest/v2/projects is a small list; returns 200 with [] even for
# new accounts with zero projects. Auth failures are cleanly 401.
validation:
  request:
    method: GET
    url: https://api.todoist.com/rest/v2/projects
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Todoist rejected the API token (401). Copy a fresh token from https://todoist.com/prefs/integrations and update TODOIST_API_TOKEN." }
    "403": { state: needs_setup, message: "Token lacks required permissions (403)." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://api.todoist.com/rest/v2/projects
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

tools:
  - name: list_tasks
    description: "List tasks with optional filters"
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
    description: "List all projects"
    category: projects
  - name: create_project
    description: "Create a new project"
    category: projects
  - name: list_labels
    description: "List all labels"
    category: labels
  - name: add_comment
    description: "Add a comment to a task"
    category: comments
---

# Todoist MCP Server

Provides Todoist task management tools for bots that organize work, track action items, and manage projects.

## Which Bots Use This

- **executive-assistant** -- Manages daily task lists and follow-ups
- **project-manager** -- Creates and tracks project tasks and deadlines

## Setup

1. Get your API token from https://todoist.com/prefs/integrations (under "Developer")
2. Add `TODOIST_API_TOKEN` in the MCP connection setup
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Todoist server instance across bots:

```yaml
mcpServers:
  - ref: "tools/todoist"
    reason: "Bots need task management for action items and follow-ups"
    config:
      default_project: "Inbox"
```
