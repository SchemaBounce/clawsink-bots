---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: jira
  displayName: "Jira"
  version: "1.0.0"
  description: "Jira project management tools for issues, sprints, and boards"
  tags: ["jira", "project-management", "issues", "sprints", "agile"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@modelcontextprotocol/server-atlassian"]
env:
  - name: JIRA_API_TOKEN
    description: "Jira API Token for authentication"
    required: true
  - name: JIRA_EMAIL
    description: "Email address associated with the Jira API token"
    required: true
  - name: JIRA_URL
    description: "Jira instance URL (e.g., https://company.atlassian.net)"
    required: true
tools:
  - name: create_issue
    description: "Create a new Jira issue"
    category: issues
  - name: get_issue
    description: "Get details of a Jira issue"
    category: issues
  - name: update_issue
    description: "Update an existing issue"
    category: issues
  - name: search_issues
    description: "Search issues using JQL"
    category: issues
  - name: list_projects
    description: "List all projects"
    category: projects
  - name: get_board
    description: "Get board details and configuration"
    category: boards
  - name: list_sprints
    description: "List sprints for a board"
    category: sprints
  - name: get_sprint
    description: "Get sprint details and issues"
    category: sprints
  - name: add_comment
    description: "Add a comment to an issue"
    category: issues
  - name: transition_issue
    description: "Move an issue to a different status"
    category: issues
  - name: assign_issue
    description: "Assign an issue to a user"
    category: issues
  - name: list_issue_types
    description: "List available issue types for a project"
    category: projects
  - name: get_project
    description: "Get project details"
    category: projects
  - name: list_boards
    description: "List all boards"
    category: boards
  - name: get_issue_comments
    description: "Get comments on an issue"
    category: issues
---

# Jira MCP Server

Provides Jira project management tools for bots that manage sprints, issues, backlogs, and agile workflows.

## Which Bots Use This

- **sprint-planner** -- Manages sprints, creates and assigns issues, tracks velocity
- **product-owner** -- Prioritizes backlog, creates feature requests, manages roadmap
- **bug-triage** -- Creates and tracks bugs in Jira project

## Setup

1. Create a Jira API Token at [id.atlassian.com/manage-profile/security/api-tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Add it to your workspace secrets as `JIRA_API_TOKEN` along with your `JIRA_EMAIL` and `JIRA_URL`
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Jira server instance across all project management bots:

```yaml
mcpServers:
  - ref: "tools/jira"
    reason: "Project management bots need Jira access for sprint planning and issue tracking"
    config:
      default_project: "YOUR-PROJECT"
```
