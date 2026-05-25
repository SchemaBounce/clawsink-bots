---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: gitlab
  displayName: "GitLab"
  version: "1.0.0"
  description: "GitLab API, projects, merge requests, issues, and CI/CD pipelines"
  tags: ["gitlab", "git", "merge-requests", "ci-cd", "devops"]
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
# GitLab uses a custom PRIVATE-TOKEN header (NOT Authorization Bearer).
# api_key_header with the explicit header_name handles this.
auth:
  type: api_key_header
  token_env: GITLAB_PERSONAL_ACCESS_TOKEN
  header_name: PRIVATE-TOKEN

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@modelcontextprotocol/server-gitlab@2025.4.25"]
env:
  - name: GITLAB_PERSONAL_ACCESS_TOKEN
    description: "GitLab PAT with api scope"
    required: true
    sensitive: true
  - name: GITLAB_API_URL
    description: "GitLab API URL, defaults to https://gitlab.com/api/v4"
    required: false

# /user returns the authenticated user. Same on both gitlab.com and
# self-hosted instances.
#
# NOTE: this spec hard-codes https://gitlab.com — for self-hosted
# GitLab instances, GITLAB_API_URL is set on the connection but the
# current engine doesn't support {ENV_VAR} URL substitution + a
# default fallback in one shape. Self-hosted instances will get
# health_state='unverified' until Stage D.next adds optional-template
# resolution.
validation:
  request:
    method: GET
    url: https://gitlab.com/api/v4/user
  expect:
    status: 200
    extract:
      authenticated_as_field: username
  on_status:
    "401": { state: needs_setup, message: "GitLab rejected the personal access token (401). Generate a new token at https://gitlab.com/-/profile/personal_access_tokens and update GITLAB_PERSONAL_ACCESS_TOKEN." }
    "403": { state: needs_setup, message: "Token lacks required scopes (403). Add the 'api' scope to the PAT." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://gitlab.com/api/v4/user
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

tools:
  - name: create_issue
    description: "Create a new issue in a project"
    category: issues
  - name: list_issues
    description: "List issues for a project"
    category: issues
  - name: get_issue
    description: "Get details of a specific issue"
    category: issues
  - name: create_merge_request
    description: "Create a new merge request"
    category: merge-requests
  - name: list_merge_requests
    description: "List merge requests for a project"
    category: merge-requests
  - name: get_merge_request
    description: "Get details of a specific merge request"
    category: merge-requests
  - name: list_projects
    description: "List accessible projects"
    category: projects
  - name: get_project
    description: "Get details of a specific project"
    category: projects
  - name: list_pipelines
    description: "List CI/CD pipelines for a project"
    category: pipelines
  - name: get_pipeline
    description: "Get details of a specific pipeline"
    category: pipelines
  - name: list_branches
    description: "List branches in a project"
    category: projects
  - name: search_code
    description: "Search code across projects"
    category: projects
---

# GitLab MCP Server

Provides GitLab API tools for project management, merge requests, issue tracking, and CI/CD pipeline monitoring. Supports both GitLab.com and self-hosted instances.

## Which Bots Use This

- **software-architect** -- Creates merge requests, manages branches, reviews code architecture
- **code-reviewer** -- Reviews merge requests, adds inline comments
- **release-manager** -- Monitors pipelines, manages release branches, tags releases
- **bug-triage** -- Creates and categorizes bug issues, searches for duplicates
- **devops-automator** -- Monitors CI/CD pipeline status and triggers retries
- **tech-debt-tracker** -- Tracks technical debt issues across projects

## Setup

1. Create a GitLab Personal Access Token with `api` scope at Settings > Access Tokens
2. Add it to your workspace secrets as `GITLAB_PERSONAL_ACCESS_TOKEN`
3. For self-hosted GitLab, also set `GITLAB_API_URL` to your instance's API endpoint
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single GitLab server instance across engineering bots:

```yaml
mcpServers:
  - ref: "tools/gitlab"
    reason: "Engineering bots need GitLab access for code review, issue tracking, and CI/CD"
    config:
      default_group: "your-group"
```
