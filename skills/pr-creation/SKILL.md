---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: pr-creation
  displayName: "PR Creation"
  version: "1.0.0"
  description: "Creates structured pull requests with descriptions, linked issues, labels, and review assignments."
  tags: ["pull-request", "github", "code-review", "engineering"]
tools:
  required: ["adl_query_records", "adl_read_memory"]
data:
  consumesEntityTypes: ["implementation_plans", "code_sessions"]
  producesEntityTypes: []
---

# PR Creation

Creates structured pull request specifications from implementation plans and code session results. The skill generates a title, body, labels, and reviewer suggestions ready for the code session's push, which opens the pull request through the workspace's GitHub App, or for the GitHub MCP `create_pull_request` tool when that server is connected.

## When to Use

Use this skill in bots that push code changes and need to open well-formatted pull requests. Pairs with `implementation-planning` and code sessions (`adl_start_code_session`). The `tools/github` MCP server is optional.

## Typical Bots

Software architects, release managers, and any bot that automates the code-to-PR pipeline.
