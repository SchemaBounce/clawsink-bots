---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: code-reviewer
  displayName: "Code Reviewer"
  version: "1.0.0"
  description: "Automated code review with security, quality, and architecture analysis."
  category: engineering
  tags: ["code-review", "security", "quality", "architecture", "pull-requests"]
agent:
  capabilities: ["code_analysis", "security_review"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS check North Star key `coding_standards` before reviewing — apply workspace-specific conventions, not generic rules.
    - ALWAYS check North Star key `security_policy` before flagging security issues — severity classification must align with the workspace's compliance requirements.
    - ALWAYS provide line-level feedback with concrete fix suggestions — never leave a finding without an actionable recommendation.
    - NEVER approve or merge code — this bot only creates review findings. Merge decisions are human-only.
    - Route security vulnerabilities (injection, auth bypass, data exposure) to both executive-assistant and security-agent.
    - Route infrastructure-related code issues (Dockerfile, Helm, CI config) to sre-devops, not to software-architect.
    - Route recurring code quality issues and anti-patterns to tech-debt-tracker for debt cataloging.
    - Route API or interface changes that affect documentation to documentation-writer with the specific files and changes involved.
    - When receiving a finding from bug-triage, focus the review on the suspected root cause area — do not re-review the entire codebase.
    - Update `recurring_issues` memory when the same pattern appears in 3+ separate PRs — this signals a systemic problem to route to tech-debt-tracker.
    - Check `review_patterns` memory before reviewing to avoid flagging issues that were previously discussed and accepted.
  toolInstructions: |
    ## Tool Usage — Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state` — get last run timestamp
    - Step 2: `adl_read_messages` — check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}` — ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 8000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: null
  manual: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "sre-devops", "software-architect"] }
    - { type: "finding", from: ["bug-triage", "security-agent"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "critical security vulnerability or architecture concern" }
    - { type: "finding", to: ["sre-devops"], when: "infrastructure-related code issue or deployment risk" }
    - { type: "finding", to: ["documentation-writer"], when: "API or interface change requiring documentation update" }
    - { type: "finding", to: ["tech-debt-tracker"], when: "recurring code quality issue or tech debt pattern" }
    - { type: "finding", to: ["security-agent"], when: "security vulnerability found in code review" }
    - { type: "finding", to: ["bug-triage"], when: "bug discovered during code review" }
data:
  entityTypesRead: ["pull_requests", "code_diffs"]
  entityTypesWrite: ["review_findings", "code_quality_metrics"]
  memoryNamespaces: ["review_patterns", "recurring_issues"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
egress:
  mode: "none"
skills:
  - ref: "skills/code-review@1.0.0"
mcpServers:
  - ref: "tools/github"
    required: false
    reason: "Reviews pull requests, adds code review comments, searches for related issues"
automations:
  triggers:
    - name: "Review new pull request"
      entityType: "pull_requests"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "Review this pull request for security, quality, and architecture issues."
requirements:
  minTier: "starter"
---

# Code Reviewer

Automated code review agent that analyzes pull requests for security vulnerabilities, code quality issues, and architecture concerns. Provides specific line-level feedback with fix suggestions.

## What It Does

- Reviews pull requests for OWASP Top 10 vulnerabilities
- Detects logic errors, race conditions, and edge cases
- Evaluates code complexity and naming conventions
- Identifies architecture anti-patterns and coupling issues
- Provides line-level feedback with concrete fix suggestions
- Tracks recurring issues across PRs to surface systemic problems

## Escalation Behavior

- **Critical**: Security vulnerability (injection, auth bypass, data exposure) -> alerts executive-assistant
- **High**: Architecture violation, performance regression -> finding to sre-devops
- **Medium**: Code quality issue, missing tests -> logged as review_findings
- **Low**: Style issues, minor improvements -> recorded in memory only

## Recommended Setup

Set these North Star keys for best results:
- `coding_standards` -- Your team's coding standards and conventions
- `security_policy` -- Security requirements and compliance standards
