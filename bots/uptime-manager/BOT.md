---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: uptime-manager
  displayName: "Uptime Manager"
  version: "1.0.0"
  description: "Manages status pages, tracks SLA compliance, monitors uptime percentages, and produces incident postmortems."
  category: operations
  tags: ["uptime", "status-page", "sla", "postmortem", "incident-communication"]
agent:
  capabilities: ["operations", "customer_support"]
  hostingMode: "openclaw"
  defaultDomain: "operations"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
cost:
  estimatedTokensPerRun: 12000
  estimatedCostTier: "medium"
schedule:
  default: "@every 2h"
  recommendations:
    light: "@every 4h"
    standard: "@every 2h"
    intensive: "@every 1h"
messaging:
  listensTo:
    - { type: "alert", from: ["sre-devops"] }
    - { type: "finding", from: ["sre-devops", "api-tester"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "uptime report, SLA status update, or postmortem ready" }
    - { type: "request", to: ["sre-devops"], when: "requesting postmortem details or incident timeline" }
    - { type: "finding", to: ["customer-support"], when: "incident notification for customer communication" }
data:
  entityTypesRead: ["sre_findings", "sre_alerts", "incidents", "test_results", "pipeline_status"]
  entityTypesWrite: ["uptime_findings", "uptime_alerts", "uptime_incidents", "uptime_sla_reports"]
  memoryNamespaces: ["working_notes", "learned_patterns", "sla_tracker", "incident_history"]
zones:
  zone1Read: ["mission", "sla_targets", "incident_severity_definitions", "status_page_config"]
  zone2Domains: ["operations", "support"]
skills:
  - ref: "skills/incident-triage@1.0.0"
  - ref: "skills/sla-compliance@1.0.0"
  - ref: "skills/notification-dispatch@1.0.0"
egress:
  mode: "restricted"
  allowedDomains: ["api.statuspage.io", "*.atlassian.net"]
requirements:
  minTier: "starter"
---

# Uptime Manager

Manages status page updates, tracks SLA compliance against configured targets, monitors uptime percentages, and produces structured incident postmortems that build trust through transparency.

## What It Does

- Correlates sre-devops alerts with customer-facing impact to maintain accurate status pages
- Tracks rolling uptime percentages against SLA targets (30-day, 90-day, calendar year)
- Detects SLA budget consumption and alerts before breaches occur
- Spawns a postmortem-writer sub-agent for every resolved incident
- Notifies customer-support of active incidents and executive-assistant of SLA reports

## Escalation Behavior

- **Critical**: SLA breach imminent, major outage → finding to executive-assistant
- **High**: Partial outage, degraded performance affecting customers → finding to customer-support
- **Medium**: SLA budget warning, minor service degradation → logged as uptime_findings
- **Low**: Routine uptime report, minor threshold adjustment → memory update only

## Recommended Setup

Set these North Star keys for best results:
- `sla_targets` — Your uptime SLA targets per window (30-day, 90-day, yearly)
- `status_page_config` — Status page component mapping and update preferences
- `incident_severity_definitions` — How to classify incident severity for customer communication
