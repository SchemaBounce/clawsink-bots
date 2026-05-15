---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: basecamp
  displayName: "Basecamp"
  version: "1.0.0"
  description: "Basecamp project management, projects, todos, messages, and schedules"
  tags: ["basecamp", "project-management", "collaboration", "todos"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "BASECAMP"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like BASECAMP_*."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "basecamp-mcp@1.1.0"]
env:
  - name: BASECAMP_ACCESS_TOKEN
    description: "Basecamp OAuth access token"
    required: true
  - name: BASECAMP_ACCOUNT_ID
    description: "Basecamp account ID"
    required: true
tools:
  - name: list_projects
    description: "List all projects in the account"
    category: projects
  - name: get_project
    description: "Get details of a specific project"
    category: projects
  - name: list_todolists
    description: "List to-do lists in a project"
    category: todos
  - name: create_todo
    description: "Create a new to-do item"
    category: todos
  - name: list_messages
    description: "List messages in a project message board"
    category: messages
  - name: post_message
    description: "Post a message to a project message board"
    category: messages
  - name: list_events
    description: "List events on a project schedule"
    category: schedules
  - name: list_people
    description: "List people in the account or project"
    category: projects
---

# Basecamp MCP Server

Provides Basecamp API tools for bots that manage projects, to-do lists, messages, and schedules.

## Which Bots Use This

- **project-manager** -- Manages projects, assigns to-dos, and tracks progress
- **executive-assistant** -- Posts messages and monitors project schedules

## Setup

1. Create a Basecamp integration and obtain an OAuth access token
2. Find your Basecamp account ID from the URL (e.g., `https://3.basecamp.com/1234567/`)
3. Add `BASECAMP_ACCESS_TOKEN` and `BASECAMP_ACCOUNT_ID` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Basecamp server instance across bots:

```yaml
mcpServers:
  - ref: "tools/basecamp"
    reason: "Bots need Basecamp access for project management and team collaboration"
    config:
      default_project: "Main Project"
```
