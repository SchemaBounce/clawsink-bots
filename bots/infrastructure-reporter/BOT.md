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
  instructions: |
    ## Operating Rules
    - ALWAYS read `adl_read_messages` for pending requests from executive-assistant before starting report generation
    - ALWAYS read `performance_baselines` memory namespace to compare current metrics against historical norms for trend detection
    - ALWAYS prioritize actionable insights over exhaustive data dumps -- surface capacity risks, degradation trends, and anomalies first
    - NEVER generate a report without querying both `infra_metrics` and `service_status` records -- partial reports miss cross-cutting issues
    - NEVER include raw metric dumps in findings -- summarize with trend direction, percentage change, and risk assessment
    - Send significant infrastructure insights and capacity concerns to executive-assistant (type=finding) for leadership visibility
    - Send health degradation requiring operational response to sre-devops (type=finding) with specific remediation suggestions
    - Consume anomaly patterns from anomaly-detector via messages and incorporate them into the health report narrative
    - Track resource utilization trends in `capacity_trends` memory to forecast when thresholds will be breached (weeks/months ahead)
    - Complete all analysis within token budget -- if data volume is large, sample representative time windows rather than processing everything
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
  default: "0 */6 * * *"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "significant infrastructure insight or capacity concern" }
    - { type: "finding", to: ["sre-devops"], when: "infrastructure health degradation requiring operational response" }
data:
  entityTypesRead: ["infra_metrics", "service_status"]
  entityTypesWrite: ["health_reports", "infra_alerts"]
  memoryNamespaces: ["performance_baselines", "capacity_trends"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering", "operations"]
egress:
  mode: "none"
skills:
  - ref: "skills/scheduled-report@1.0.0"
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
