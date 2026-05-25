---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: sentry
  displayName: "Sentry"
  version: "1.0.0"
  description: "Sentry error tracking, issues, events, releases, and performance"
  tags: ["sentry", "errors", "monitoring", "debugging", "performance"]
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe (SchemaBounce #1614).
auth:
  type: http_bearer
  token_env: SENTRY_AUTH_TOKEN

transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@sentry/mcp-server@0.31.0"]
env:
  - name: SENTRY_AUTH_TOKEN
    description: "Sentry auth token with project:read and issue:read scopes"
    required: true
    sensitive: true
  - name: SENTRY_ORGANIZATION
    description: "Sentry organization slug"
    required: false

# /api/0/ returns the API root index with the authenticated user info.
# Lightweight, free, idempotent.
validation:
  request:
    method: GET
    url: https://sentry.io/api/0/
  expect:
    status: 200
    extract:
      authenticated_as_field: user
  on_status:
    "401": { state: needs_setup, message: "Sentry rejected the auth token (401). Create a new token at https://sentry.io/settings/account/api/auth-tokens/ and update SENTRY_AUTH_TOKEN." }
    "403": { state: needs_setup, message: "Token lacks required scopes (403). Add at least project:read and issue:read." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://sentry.io/api/0/
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

tools:
  - name: list_issues
    description: "List unresolved issues"
    category: issues
  - name: get_issue
    description: "Get details of a specific issue"
    category: issues
  - name: resolve_issue
    description: "Resolve or unresolve an issue"
    category: issues
  - name: list_events
    description: "List events for an issue"
    category: events
  - name: get_event
    description: "Get details of a specific event"
    category: events
  - name: list_projects
    description: "List projects in the organization"
    category: issues
  - name: search_issues
    description: "Search issues with query syntax"
    category: issues
  - name: get_release
    description: "Get details of a specific release"
    category: releases
  - name: list_releases
    description: "List releases for a project"
    category: releases
  - name: get_performance_issues
    description: "Get performance issues and bottlenecks"
    category: performance
---

# Sentry MCP Server

Provides Sentry error tracking tools for monitoring issues, analyzing crash events, managing releases, and tracking performance regressions.

## Which Bots Use This

- **sre-devops** -- Monitors error rates, tracks regressions after deployments, resolves known issues
- **bug-triage** -- Analyzes crash reports, identifies duplicate issues, prioritizes by impact
- **release-manager** -- Validates releases by checking error rates post-deploy
- **incident-commander** -- Investigates error spikes during incidents

## Setup

1. Create an auth token at [Sentry Settings > Auth Tokens](https://sentry.io/settings/auth-tokens/)
2. Grant `project:read`, `issue:read`, and `event:read` scopes
3. Add it to your workspace secrets as `SENTRY_AUTH_TOKEN`
4. Optionally set `SENTRY_ORGANIZATION` to default to a specific org
5. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Sentry server instance across ops bots:

```yaml
mcpServers:
  - ref: "tools/sentry"
    reason: "Ops bots need Sentry access for error tracking and incident investigation"
    config:
      default_project: "your-project"
```
