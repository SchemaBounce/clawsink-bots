---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: code-reviewer
  displayName: "Code Reviewer"
  version: "1.0.4"
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
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/code-review@1.0.0"
presence:
  web:
    search: true
    browsing: true
    crawling: false
mcpServers:
  - ref: "tools/github"
    required: false
    reason: "Reviews pull requests, adds code review comments, searches for related issues"
  - ref: "tools/exa"
    required: false
    reason: "Search for security advisories, CVE databases, and best practice documentation"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse library documentation and security advisory pages for vulnerability context"
  - ref: "tools/composio"
    required: false
    reason: "Sync review findings with project management and CI/CD pipeline tools"
automations:
  triggers:
    - name: "Review new pull request"
      entityType: "pull_requests"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "Review this pull request for security, quality, and architecture issues."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-coding-standards
      name: "Define coding standards"
      description: "Your team's coding conventions, style rules, and architecture guidelines"
      type: north_star
      key: coding_standards
      group: configuration
      priority: required
      reason: "Reviews apply workspace-specific conventions instead of generic rules"
      ui:
        inputType: text
        placeholder: "e.g., TypeScript strict mode, no any types, max function length 50 lines, prefer composition over inheritance"
        helpUrl: "https://docs.schemabounce.com/bots/code-reviewer/standards"
    - id: set-security-policy
      name: "Set security policy"
      description: "Security requirements and compliance standards for vulnerability classification"
      type: north_star
      key: security_policy
      group: configuration
      priority: required
      reason: "Severity classification must match your compliance requirements (SOC 2, PCI, HIPAA)"
      ui:
        inputType: text
        placeholder: "e.g., SOC 2 Type II, no hardcoded secrets, all inputs sanitized, SQL injection = critical"
    - id: connect-github
      name: "Connect GitHub"
      description: "Pull request access for automated code review and inline comments"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: recommended
      reason: "Enables automated pull request reviews with inline code comments"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
    - id: connect-exa
      name: "Connect Exa for security research"
      description: "Search CVE databases and security advisories for vulnerability context"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: optional
      reason: "Enriches security findings with CVE references and advisory context"
      ui:
        icon: search
        actionLabel: "Connect Exa"
    - id: import-pull-requests
      name: "Verify pull request data"
      description: "At least one pull request must be available for review"
      type: data_presence
      entityType: pull_requests
      minCount: 1
      group: data
      priority: recommended
      reason: "The bot reviews pull requests — needs PR data to start working"
      ui:
        actionLabel: "Check Pull Requests"
        emptyState: "No pull requests found. Connect GitHub or import PR data to begin reviews."
    - id: connect-composio
      name: "Connect project management"
      description: "Sync review findings with your CI/CD pipeline and issue tracker"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: optional
      reason: "Route findings to Jira, Linear, or CI/CD tools automatically"
      ui:
        icon: integration
        actionLabel: "Connect Project Tools"
goals:
  - name: review_coverage
    description: "Every new pull request receives a review within one run cycle"
    category: primary
    metric:
      type: rate
      numerator: { entity: review_findings, filter: { source: "pull_request" } }
      denominator: { entity: pull_requests, filter: { status: "open" } }
    target:
      operator: ">"
      value: 0.95
      period: weekly
      condition: "all open PRs reviewed"
  - name: security_detection
    description: "Detect OWASP Top 10 vulnerabilities and flag with severity"
    category: primary
    metric:
      type: count
      entity: review_findings
      filter: { category: "security" }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when security issues exist in reviewed code"
  - name: review_accuracy
    description: "Review findings confirmed as valid by developers"
    category: secondary
    metric:
      type: rate
      numerator: { entity: review_findings, filter: { feedback: "valid" } }
      denominator: { entity: review_findings, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.85
      period: monthly
    feedback:
      enabled: true
      entityType: review_findings
      actions:
        - { value: valid, label: "Valid finding" }
        - { value: false_positive, label: "False positive" }
        - { value: nitpick, label: "Too nitpicky" }
        - { value: missed, label: "Missed an issue" }
  - name: recurring_issue_tracking
    description: "Track and escalate patterns that appear across multiple PRs"
    category: health
    metric:
      type: count
      source: memory
      namespace: recurring_issues
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
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
