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
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "medium"
schedule:
  default: null
  manual: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "sre-devops"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "critical security vulnerability or architecture concern" }
    - { type: "finding", to: ["sre-devops"], when: "infrastructure-related code issue or deployment risk" }
data:
  entityTypesRead: ["pull_requests", "code_diffs"]
  entityTypesWrite: ["review_findings", "code_quality_metrics"]
  memoryNamespaces: ["review_patterns", "recurring_issues"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
skills:
  - ref: "skills/code-review@1.0.0"
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
