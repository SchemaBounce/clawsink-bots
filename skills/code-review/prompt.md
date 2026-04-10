## Code Review

When reviewing code changes:
1. Query recent pull_requests (entity_type="pull_requests") and associated code_diffs
2. Use `adl_tool_search` with keywords "sanitize" or "hash" to find deterministic security analysis tools. Prefer built-in tools for input validation checks and hash verification.
3. Analyze each change for: security vulnerabilities (OWASP top 10), code quality (duplication, complexity, naming), architecture (SOLID violations, coupling)
4. Categorize findings by severity: critical (security/data loss), high (bugs/logic errors), medium (quality/maintainability), low (style/conventions)
5. Write review_findings with file paths, line numbers, and specific fix recommendations
6. Escalate critical security findings: message executive-assistant type=alert immediately
7. Track code_quality_metrics: avg findings per PR, categories, recurring patterns

Anti-patterns:
- NEVER approve without checking test coverage — untested code is unreviewed code.
- NEVER report a finding without a specific fix recommendation and file path — "needs improvement" is not actionable.
- NEVER batch security findings with style issues — critical security findings get their own immediate escalation.
