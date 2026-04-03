---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: devops-automator
  displayName: "DevOps Automator"
  version: "1.0.2"
  description: "CI/CD pipeline monitoring, deployment verification, and infrastructure automation."
  category: engineering
  tags: ["devops", "ci-cd", "deployments", "automation", "infrastructure"]
agent:
  capabilities: ["deployment_monitoring", "pipeline_analysis"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS check `adl_list_triggers` first to see what is already automated before doing manual work
    - ALWAYS read `adl_read_messages` for pending requests from sre-devops, executive-assistant, release-manager, and security-agent before starting analysis
    - ALWAYS verify deployment health within the same run a new `deployments` record arrives -- never defer health checks to the next cycle
    - NEVER approve or dismiss a deployment without checking error rate thresholds from North Star key `error_rate_thresholds`
    - NEVER send alerts to sre-devops for informational observations -- only for failed deployments, pipeline failures, or rollback-required situations
    - Escalate to sre-devops (type=alert) when error rate rises post-deploy or a main-branch pipeline fails; send findings to release-manager for completed deployments
    - Forward deployment availability impacts to uptime-manager (type=finding) and security-related CI/CD issues to security-agent (type=finding)
    - Store deployment-to-incident correlations in `incident_correlations` memory namespace for cross-run pattern analysis
    - Write automation proposals as `automation_proposals` entity type only after confirming the same manual pattern has occurred 3+ times in `deployment_patterns` memory
    - Respect `deployment_environments` North Star key to weight criticality -- production failures always escalate, staging failures are logged as findings
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
  default: "@every 4h"
  recommendations:
    light: "@every 8h"
    standard: "@every 4h"
    intensive: "@every 1h"
messaging:
  listensTo:
    - { type: "request", from: ["sre-devops", "executive-assistant", "release-manager"] }
    - { type: "alert", from: ["sre-devops"] }
    - { type: "finding", from: ["security-agent"] }
  sendsTo:
    - { type: "alert", to: ["sre-devops"], when: "failed deployment, pipeline failure, or rollback needed" }
    - { type: "finding", to: ["release-manager"], when: "deployment completed or release pipeline status update" }
    - { type: "finding", to: ["uptime-manager"], when: "deployment affecting service availability" }
data:
  entityTypesRead: ["deployments", "infrastructure_events", "pipeline_runs"]
  entityTypesWrite: ["devops_findings", "automation_proposals"]
  memoryNamespaces: ["deployment_patterns", "incident_correlations"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering", "operations"]
egress:
  mode: "restricted"
  allowedDomains: ["api.github.com", "api.gitlab.com", "circleci.com"]
skills:
  - ref: "skills/pipeline-monitoring@1.0.0"
  - ref: "skills/incident-triage@1.0.0"
  - ref: "skills/notification-dispatch@1.0.0"
automations:
  triggers:
    - name: "Verify deployment health"
      entityType: "deployments"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "Verify deployment health and rollback if error rate exceeds threshold."
plugins:
  - ref: "n8n-workflow@latest"
    required: true
    reason: "Triggers CI/CD pipelines, deployment rollbacks, and infrastructure automation workflows in external systems"
presence:
  web:
    search: true
    browsing: true
    crawling: false
mcpServers:
  - ref: "tools/github"
    required: false
    reason: "Monitors CI/CD pipelines and GitHub Actions workflows"
  - ref: "tools/exa"
    required: false
    reason: "Search for deployment best practices, incident postmortems, and infrastructure documentation"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse cloud provider consoles, monitoring dashboards, and CI/CD pipeline UIs"
  - ref: "tools/composio"
    required: false
    reason: "Integrate with PagerDuty, Datadog, and other DevOps SaaS platforms"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-deployment-environments
      name: "Define deployment environments"
      description: "Your environments and their criticality (production, staging, dev)"
      type: north_star
      key: deployment_environments
      group: configuration
      priority: required
      reason: "Cannot weight deployment severity without knowing environment criticality"
      ui:
        inputType: text
        placeholder: '{"production": "critical", "staging": "high", "dev": "low"}'
    - id: set-error-thresholds
      name: "Set error rate thresholds"
      description: "Error rate limits that trigger rollback recommendations"
      type: north_star
      key: error_rate_thresholds
      group: configuration
      priority: required
      reason: "Cannot recommend rollbacks without defined error rate limits"
      ui:
        inputType: text
        placeholder: '{"production": 0.01, "staging": 0.05, "dev": 0.10}'
    - id: import-deployments
      name: "Connect deployment data"
      description: "Deployment records with environment, version, and status"
      type: data_presence
      entityType: deployments
      minCount: 1
      group: data
      priority: required
      reason: "No deployment data means no health verification or pattern analysis"
      ui:
        actionLabel: "Import Deployments"
        emptyState: "No deployment data found. Connect your CI/CD pipeline or import deployment records."
    - id: connect-github
      name: "Connect GitHub for CI/CD monitoring"
      description: "Monitor GitHub Actions workflows and pipeline runs"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: recommended
      reason: "Enables real-time CI/CD pipeline monitoring and failure detection"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
    - id: connect-composio
      name: "Connect incident management tools"
      description: "Integrate with PagerDuty, Datadog, or OpsGenie for alerting"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: recommended
      reason: "Automated incident creation and on-call notification for failed deployments"
      ui:
        icon: pagerduty
        actionLabel: "Connect Incident Management"
    - id: set-pipeline-patterns
      name: "Configure automation pattern threshold"
      description: "Number of times a manual pattern must repeat before proposing automation"
      type: config
      group: configuration
      target: { namespace: deployment_patterns, key: automation_threshold }
      priority: optional
      reason: "Controls when the bot starts suggesting automation for repetitive tasks"
      ui:
        inputType: text
        placeholder: '{"repeat_count": 3}'
        default: '{"repeat_count": 3}'
goals:
  - name: deployment_verification
    description: "Verify health of every deployment within the same run cycle"
    category: primary
    metric:
      type: rate
      numerator: { entity: deployments, filter: { health_checked: true } }
      denominator: { entity: deployments, filter: { status: "completed" } }
    target:
      operator: ">"
      value: 0.95
      period: per_run
  - name: failed_deployment_escalation
    description: "Escalate all failed production deployments to SRE within the same run"
    category: primary
    metric:
      type: boolean
      check: "failed_prod_deployments_escalated"
    target:
      operator: "=="
      value: 1
      period: per_run
  - name: automation_proposals
    description: "Identify and propose automation for repetitive manual operations"
    category: secondary
    metric:
      type: count
      entity: automation_proposals
    target:
      operator: ">"
      value: 0
      period: monthly
  - name: incident_correlation_accuracy
    description: "Correlate deployment events with incidents before escalating"
    category: health
    metric:
      type: rate
      numerator: { entity: devops_findings, filter: { correlated: true } }
      denominator: { entity: devops_findings }
    target:
      operator: ">"
      value: 0.85
      period: monthly
---

# DevOps Automator

Proactive DevOps agent that monitors CI/CD pipelines, verifies deployments, and proposes automation for repetitive infrastructure tasks. Escalates failed deployments immediately.

## What It Does

- Monitors CI/CD pipeline runs for failures and slowdowns
- Verifies deployment health after rollout (error rates, latency, pod restarts)
- Correlates deployment events with infrastructure incidents
- Proposes automation for repetitive operational tasks
- Tracks deployment patterns to identify flaky pipelines
- Escalates failed deployments with rollback recommendations

## Escalation Behavior

- **Critical**: Failed deployment with rising error rate -> alert to sre-devops
- **High**: Pipeline failure on main branch, rollback triggered -> alert to sre-devops
- **Medium**: Slow pipeline, resource pressure -> logged as devops_findings
- **Low**: Optimization opportunity, automation proposal -> logged as automation_proposals

## Recommended Setup

Set these North Star keys for best results:
- `deployment_environments` -- Your deployment environments and their criticality
- `error_rate_thresholds` -- Error rate thresholds that trigger rollback
