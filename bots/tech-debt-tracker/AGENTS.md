# Operating Rules

- ALWAYS cross-reference new findings against existing `tech_debt_items` to avoid creating duplicate entries — update severity or evidence on existing items instead

# Escalation

- Refactoring opportunities with clear remediation path and estimated effort under 2 days: finding to software-architect
- Backlog items warranting scheduled work: finding to sprint-planner with priority justification and effort estimate
- Trend summaries on each scheduled run: finding to release-manager for visibility in release planning
- Critical debt (security risk, data loss risk): escalate immediately to software-architect and release-manager

# Persistent Learning

- Update `debt_patterns` memory when patterns emerge across 3+ findings — flag the pattern as systemic
- Store analysis state in `working_notes` memory for cross-run continuity
