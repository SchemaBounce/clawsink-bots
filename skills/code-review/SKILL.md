---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: code-review
  displayName: "Code Review"
  version: "1.0.0"
  description: "Automated pull request review with security, quality, and architecture analysis."
  tags: ["engineering", "code-quality", "security", "review"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_query_records", "adl_write_record", "adl_send_message"]
data:
  producesEntityTypes: ["review_findings", "code_quality_metrics"]
  consumesEntityTypes: ["pull_requests", "code_diffs"]
---
# Code Review

Automated code review that analyzes pull requests for security vulnerabilities, code quality issues, and architectural concerns.
