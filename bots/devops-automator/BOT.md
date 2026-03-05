---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: devops-automator
  displayName: "DevOps Automator"
  version: "1.0.0"
  description: "CI/CD pipeline monitoring, deployment verification, and infrastructure automation."
  category: engineering
  tags: ["devops", "ci-cd", "deployments", "automation", "infrastructure"]
agent:
  capabilities: ["deployment_monitoring", "pipeline_analysis"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
  maxTokenBudget: 50000
schedule:
  default: "@every 4h"
  recommendations:
    light: "@every 8h"
    standard: "@every 4h"
    intensive: "@every 1h"
messaging:
  listensTo:
    - { type: "request", from: ["sre-devops", "executive-assistant"] }
    - { type: "alert", from: ["sre-devops"] }
  sendsTo:
    - { type: "alert", to: ["sre-devops"], when: "failed deployment, pipeline failure, or rollback needed" }
data:
  entityTypesRead: ["deployments", "infrastructure_events", "pipeline_runs"]
  entityTypesWrite: ["devops_findings", "automation_proposals"]
  memoryNamespaces: ["deployment_patterns", "incident_correlations"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
skills: []
automations:
  triggers:
    - name: "Verify deployment health"
      entityType: "deployments"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "Verify deployment health and rollback if error rate exceeds threshold."
requirements:
  minTier: "starter"
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
