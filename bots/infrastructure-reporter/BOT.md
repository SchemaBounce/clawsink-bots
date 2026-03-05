---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: infrastructure-reporter
  displayName: "Infrastructure Reporter"
  version: "1.0.0"
  description: "Periodic infrastructure health summary reports."
  category: engineering
  tags: ["infrastructure", "health", "monitoring"]
agent:
  capabilities: ["infrastructure_monitoring", "reporting"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-sonnet-4-6"
  thinkLevel: null
schedule:
  default: "0 */6 * * *"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant insight discovered" }
data:
  entityTypesRead: ["infra_metrics", "service_status"]
  entityTypesWrite: ["health_reports", "infra_alerts"]
  memoryNamespaces: ["performance_baselines", "capacity_trends"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Infrastructure Reporter

Generates infrastructure health reports every 6 hours. Tracks uptime, resource utilization, and capacity trends.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
