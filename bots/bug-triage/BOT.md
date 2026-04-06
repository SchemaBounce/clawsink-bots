---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: bug-triage
  displayName: "Bug Triage"
  version: "1.0.3"
  description: "Triages bug reports by severity and assigns owners."
  category: engineering
  tags: ["bugs", "triage", "severity"]
agent:
  capabilities: ["bug_analysis", "prioritization"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS check `bug_patterns` memory before triaging a new report — if a similar bug was triaged before, reference the prior decision and outcome.
    - ALWAYS assign a severity score (P0-P4) and a category (code, infrastructure, data, UX) to every bug before routing.
    - NEVER auto-close or dismiss a bug report — every report must produce a triage_decision record, even if classified as "won't fix" or "duplicate".
    - Route bugs with identifiable code-level root causes to code-reviewer — include the suspected file/module and reproduction steps.
    - Route bugs requiring architectural changes or implementation fixes to software-architect.
    - Route infrastructure or deployment-related bugs to sre-devops — include environment context and timeline.
    - Escalate P0/critical bugs to executive-assistant immediately with impact assessment and affected user count estimate.
    - When receiving findings from api-tester, cross-reference with existing open bug_reports to avoid creating duplicates.
    - Track resolution times in `resolution_times` memory — use this data to estimate fix timelines in triage decisions.
    - Consider `team_capacity` when assigning severity and routing — P2 bugs should not be routed to overloaded teams without noting the capacity constraint.
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
    - { type: "request", from: ["executive-assistant"] }
    - { type: "finding", from: ["api-tester"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "critical bug requiring immediate attention" }
    - { type: "finding", to: ["code-reviewer"], when: "bug with identifiable code-level root cause" }
    - { type: "finding", to: ["software-architect"], when: "bug requiring implementation fix" }
    - { type: "finding", to: ["sre-devops"], when: "bug related to infrastructure or deployment" }
data:
  entityTypesRead: ["bug_reports", "team_capacity"]
  entityTypesWrite: ["triage_decisions", "severity_scores"]
  memoryNamespaces: ["bug_patterns", "resolution_times"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/incident-triage@1.0.0"
  - ref: "skills/notification-dispatch@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
presence:
  web:
    search: true
    browsing: true
    crawling: false
mcpServers:
  - ref: "tools/github"
    required: false
    reason: "Creates bug issues, searches for duplicates, labels and assigns issues"
  - ref: "tools/jira"
    required: false
    reason: "Creates and tracks bugs in Jira project"
  - ref: "tools/linear"
    required: false
    reason: "Creates and tracks bugs in Linear"
  - ref: "tools/exa"
    required: false
    reason: "Search for known bugs, CVEs, and related issue reports across public trackers"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse error tracking dashboards and stack trace analysis tools"
  - ref: "tools/composio"
    required: false
    reason: "Sync triage decisions with project management and incident tracking SaaS tools"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-issue-tracker
      name: "Connect issue tracker"
      description: "Links your bug tracking system so triage decisions sync back automatically"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: required
      reason: "Primary system of record for bug reports — creates issues, detects duplicates, assigns owners"
      ui:
        icon: github
        actionLabel: "Connect Issue Tracker"
        helpUrl: "https://docs.schemabounce.com/integrations/github"
    - id: import-bug-reports
      name: "Import existing bug reports"
      description: "Seed with open bugs so triage starts immediately on the current backlog"
      type: data_presence
      entityType: bug_reports
      minCount: 1
      group: data
      priority: required
      reason: "Bot needs bug reports to triage — without them there is nothing to classify"
      ui:
        actionLabel: "Import Bugs"
        emptyState: "No bug reports found. Import from your issue tracker or wait for API Tester findings."
    - id: set-severity-policy
      name: "Define severity policy"
      description: "Map P0-P4 severity levels to response time expectations and routing rules"
      type: config
      group: configuration
      target: { namespace: bug_patterns, key: severity_policy }
      priority: recommended
      reason: "Consistent triage requires agreed severity definitions and SLA expectations"
      ui:
        inputType: json
        placeholder: '{"P0": "1h response", "P1": "4h response", "P2": "24h response", "P3": "next sprint", "P4": "backlog"}'
    - id: import-team-capacity
      name: "Import team capacity"
      description: "Current team workload data helps route bugs to teams with bandwidth"
      type: data_presence
      entityType: team_capacity
      minCount: 1
      group: data
      priority: recommended
      reason: "Routing considers capacity — without it, overloaded teams receive unfairly"
      ui:
        actionLabel: "Import Capacity"
        emptyState: "No team capacity data. The bot will still triage but cannot optimize routing by workload."
    - id: connect-exa
      name: "Connect web search"
      description: "Search for known bugs, CVEs, and related issue reports across public trackers"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: optional
      reason: "Enriches triage with external context — known CVEs, upstream issues, community reports"
      ui:
        icon: search
        actionLabel: "Connect Exa Search"
goals:
  - name: bugs_triaged
    description: "Produce a triage_decision for every incoming bug report"
    category: primary
    metric:
      type: count
      entity: triage_decisions
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when new bug_reports exist"
    feedback:
      enabled: true
      entityType: triage_decisions
      actions:
        - { value: correct, label: "Good triage" }
        - { value: wrong_severity, label: "Severity was wrong" }
        - { value: wrong_owner, label: "Routed to wrong team" }
        - { value: duplicate_missed, label: "Was a duplicate" }
  - name: severity_accuracy
    description: "Severity assignments confirmed correct by engineering leads"
    category: primary
    metric:
      type: rate
      numerator: { entity: triage_decisions, filter: { feedback: "correct" } }
      denominator: { entity: triage_decisions, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.80
      period: monthly
  - name: pattern_learning
    description: "Build bug pattern memory from triage history to improve future classifications"
    category: health
    metric:
      type: count
      source: memory
      namespace: bug_patterns
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: critical_escalation_speed
    description: "P0 bugs escalated to executive-assistant within the same run"
    category: secondary
    metric:
      type: boolean
      measurement: p0_escalated_same_run
    target:
      operator: "=="
      value: true
      period: per_run
---

# Bug Triage

Triages incoming bug reports. Analyzes severity, identifies root causes, and assigns to appropriate team members.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
