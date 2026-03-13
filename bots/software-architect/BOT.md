---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: software-architect
  displayName: "Software Architect"
  version: "1.0.0"
  description: "Receives tasks and GitHub issues, plans implementations, spawns Claude Code sessions to write and test code, and creates pull requests for review."
  category: engineering
  tags: ["coding", "implementation", "architecture", "pull-requests", "testing"]
agent:
  capabilities: ["implementation", "architecture", "code-generation", "testing"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "high"
cost:
  estimatedTokensPerRun: 80000
  estimatedCostTier: "high"
schedule: null
messaging:
  listensTo:
    - { type: "request", from: ["product-owner", "sprint-planner"] }
    - { type: "finding", from: ["code-reviewer", "bug-triage", "tech-debt-tracker"] }
  sendsTo:
    - { type: "request", to: ["code-reviewer"], when: "PR ready for review" }
    - { type: "finding", to: ["release-manager"], when: "implementation complete" }
    - { type: "finding", to: ["documentation-writer"], when: "docs need updating" }
    - { type: "alert", to: ["executive-assistant"], when: "high-risk implementation requires approval" }
data:
  entityTypesRead: ["gh_issues", "review_findings", "architecture_decisions"]
  entityTypesWrite: ["implementation_plans", "code_sessions", "architecture_decisions"]
  memoryNamespaces: ["working_notes", "architecture_patterns", "codebase_map"]
zones:
  zone1Read: ["repository_config", "architecture_principles"]
  zone2Domains: ["engineering"]
skills:
  - ref: "skills/implementation-planning@1.0.0"
  - ref: "skills/test-generation@1.0.0"
  - ref: "skills/pr-creation@1.0.0"
mcpServers:
  - ref: "tools/claude-code"
    required: true
    reason: "Spawns sandboxed Claude Code sessions for implementation"
  - ref: "tools/github"
    required: true
    reason: "Creates branches, pull requests, and manages issues"
requirements:
  minTier: "team"
---

# Software Architect

Orchestrates the full implementation lifecycle from GitHub issue to pull request. Reads tasks from product-owner, sprint-planner, and issue trackers, then plans, implements, tests, and delivers code as reviewable PRs.

## What It Does

- Receives implementation requests from product-owner, sprint-planner, and findings from code-reviewer, bug-triage, and tech-debt-tracker
- Orchestrates three sub-agents in isolated sessions: **planner** -> (Claude Code session) -> **test-fixer** (if needed) -> **reviewer**
- Planner analyzes the issue and produces a structured implementation plan with risk assessment
- Claude Code sessions execute the implementation in a sandboxed environment
- Test-fixer analyzes failures and produces fix instructions for retry (max 2 retries)
- Reviewer performs a quick self-check of the diff before PR creation
- Creates pull requests with structured descriptions, linked issues, and labels
- Never merges code -- always creates PRs for human and code-reviewer review

## Risk-Based Escalation

| Risk Level | Behavior |
|-----------|----------|
| Low | Auto-proceed: implement, test, create PR |
| Medium | Implement, test, create PR with review-required label |
| High | Alert executive-assistant with plan details, STOP and wait for approval |

## MCP Servers

- **claude-code** (required) -- Spawns sandboxed Claude Code sessions for implementation. Provides `code_session_create`, `code_session_execute`, `code_session_status`, `code_session_result`, `code_session_diff`, and `code_session_push` tools.
- **github** (required) -- Creates branches, pull requests, and manages issues. Provides `create_pull_request`, `list_issues`, `add_labels`, and `link_issue` tools.

## Recommended North Star Keys

Set these in your workspace's North Star zone for best results:

- `repository_config` -- Repository URL, main branch name, test commands, and build commands
- `architecture_principles` -- Coding standards, design patterns, and architectural constraints
