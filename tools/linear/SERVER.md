---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: linear
  displayName: "Linear"
  version: "1.0.0"
  description: "Linear project management tools for issues, projects, and cycles"
  tags: ["linear", "project-management", "issues", "cycles", "roadmap"]
  author: "schemabounce"
  license: "MIT"
auth:
  method: "composio"
  composioToolkit: "LINEAR"
  setupReason: "Authorized via Composio's managed-OAuth gateway. The agent reaches this service through composio.execute_composio_tool with action names like LINEAR_*."
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "linear-mcp@1.2.0"]
env:
  - name: LINEAR_API_KEY
    description: "Linear Personal API Key"
    required: true
tools:
  - name: create_issue
    description: "Create a new Linear issue"
    category: issues
  - name: update_issue
    description: "Update an existing issue"
    category: issues
  - name: search_issues
    description: "Search issues with filters"
    category: issues
  - name: list_teams
    description: "List all teams"
    category: teams
  - name: list_projects
    description: "List projects for a team"
    category: projects
  - name: get_issue
    description: "Get issue details"
    category: issues
  - name: list_cycles
    description: "List cycles for a team"
    category: cycles
  - name: add_comment
    description: "Add a comment to an issue"
    category: issues
  - name: list_labels
    description: "List available labels"
    category: labels
  - name: assign_issue
    description: "Assign an issue to a team member"
    category: issues
---

# Linear MCP Server

Provides Linear project management tools for bots that manage issues, projects, cycles, and team workflows.

## Which Bots Use This

- **sprint-planner** -- Manages cycles, creates and assigns issues, tracks team velocity
- **product-owner** -- Prioritizes backlog, creates feature requests, manages project roadmap
- **bug-triage** -- Creates and tracks bugs in Linear

## Setup

1. Create a Personal API Key in Linear under Settings > API
2. Add it to your workspace secrets as `LINEAR_API_KEY`
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Linear server instance across all project management bots:

```yaml
mcpServers:
  - ref: "tools/linear"
    reason: "Project management bots need Linear access for issue tracking and cycle planning"
```
