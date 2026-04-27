---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: infrastructure-reporter
  displayName: "Infrastructure Reporter"
  version: "1.0.6"
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
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
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
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/scheduled-report@1.0.0"
plugins: []
mcpServers: []
# Internal-only by design — first-party platform bot. Reads pipeline,
# environment, and ADL infrastructure state via adl_list_pipeline_routes,
# adl_get_route_status, adl_list_workflows, adl_get_data_stats runtime
# built-ins. No third-party MCP, no external SaaS.
requirements:
  minTier: "starter"
setup:
  steps:
    - id: seed-infra-metrics
      name: "Feed infrastructure metrics"
      description: "Ensure infra_metrics records are flowing into ADL from your monitoring stack (CPU, memory, disk, network, latency)."
      type: data_presence
      group: data
      priority: required
      reason: "The bot queries infra_metrics and service_status every 6 hours. Without data, reports are empty."
      ui:
        entityType: "infra_metrics"
        minCount: 10
    - id: seed-service-status
      name: "Feed service status records"
      description: "Ensure service_status records are available with current health state of your services and endpoints."
      type: data_presence
      group: data
      priority: required
      reason: "The bot cross-references infra_metrics with service_status for complete health reports. Partial data misses cross-cutting issues."
      ui:
        entityType: "service_status"
        minCount: 3
    - id: set-north-star-mission
      name: "Define North Star mission"
      description: "Set the workspace mission so the bot understands which infrastructure components are most critical to the business."
      type: north_star
      group: configuration
      priority: required
      reason: "Mission context drives prioritization of which capacity risks and degradation trends appear first in the report."
      ui:
        key: "mission"
    - id: configure-performance-baselines
      name: "Set performance baselines"
      description: "Optionally seed the performance_baselines memory with known-good metric ranges for your infrastructure."
      type: config
      group: configuration
      priority: recommended
      reason: "Baselines let the bot detect degradation trends by comparing current vs historical norms. Without them, the bot learns baselines over time but initial reports lack trend context."
      ui:
        target:
          namespace: "performance_baselines"
          key: "initial_baselines"
    - id: verify-sre-devops-active
      name: "Ensure SRE/DevOps bot is active"
      description: "Health degradation findings are sent to sre-devops for operational response. Confirm that bot is deployed."
      type: manual
      group: external
      priority: recommended
      reason: "Operational remediation suggestions route to sre-devops. Without it, degradation findings go unactioned."
      ui:
        instructions: "Deploy the sre-devops bot from the marketplace, or confirm it is already active in your workspace."
    - id: verify-anomaly-detector-active
      name: "Ensure Anomaly Detector bot is active"
      description: "The reporter consumes anomaly patterns from anomaly-detector to enrich health reports. Confirm that bot is deployed."
      type: manual
      group: external
      priority: optional
      reason: "Anomaly patterns from anomaly-detector are incorporated into the health report narrative. Without it, reports still work but miss anomaly context."
      ui:
        instructions: "Deploy the anomaly-detector bot from the marketplace for enriched reports, or skip if not needed."
goals:
  - id: reports-generated
    name: "Reports generated"
    description: "Health reports produced on schedule (every 6 hours by default)."
    metricType: count
    target: ">= 4 per day"
    category: primary
    feedback:
      question: "Are the infrastructure health reports actionable and useful?"
      options: ["yes", "mostly", "too verbose", "missing key metrics"]
  - id: capacity-forecast-accuracy
    name: "Capacity forecast accuracy"
    description: "Percentage of capacity threshold breach predictions that proved correct within the forecasted timeframe."
    metricType: rate
    target: "> 70%"
    category: primary
  - id: report-completeness
    name: "Report completeness"
    description: "Every report includes both infra_metrics and service_status data (no partial reports)."
    metricType: boolean
    target: "true"
    category: health
  - id: capacity-trends-freshness
    name: "Capacity trends freshness"
    description: "The capacity_trends memory namespace is updated after each report generation."
    metricType: boolean
    target: "updated within last 6h"
    category: health
---

# Infrastructure Reporter

Generates infrastructure health reports every 6 hours. Tracks uptime, resource utilization, and capacity trends.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
