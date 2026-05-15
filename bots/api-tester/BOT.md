---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: api-tester
  displayName: "API Tester"
  version: "1.0.6"
  description: "API endpoint testing, performance benchmarking, and health monitoring."
  category: engineering
  tags: ["api-testing", "performance", "health-monitoring", "regression", "benchmarks"]
agent:
  capabilities: ["api_testing", "performance_analysis"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS load existing endpoint baselines from `endpoint_baselines` memory before running tests, never compare against hardcoded values.
    - ALWAYS test both happy-path and error-path (4xx, 5xx, malformed input, missing auth) for every endpoint.
    - NEVER send real credentials or PII in test payloads. Use synthetic test data only.
    - Route 5xx errors and auth bypass findings to sre-devops immediately, do not wait for the next scheduled run.
    - Route confirmed bug-indicating failures (consistent logic errors, schema violations) to bug-triage for triage.
    - Route sustained endpoint unavailability (3+ consecutive failures) to uptime-manager for status page consideration.
    - When a new endpoint appears in `api_endpoints`, auto-generate baseline test cases and store initial latency benchmarks.
    - Update `failure_patterns` memory when a previously failing test starts passing, track resolution patterns, not just failures.
    - On latency regressions, record the percentage increase and the specific P50/P95/P99 values, never report raw numbers without baseline context.
    - Do not re-test endpoints that have been marked as deprecated in the `api_endpoints` entity unless explicitly requested.
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
  default: "@daily"
  recommendations:
    light: "@weekly"
    standard: "@daily"
    intensive: "@every 4h"
messaging:
  listensTo:
    - { type: "request", from: ["sre-devops", "executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["sre-devops"], when: "API health degradation, failed tests, or regression detected" }
    - { type: "finding", to: ["bug-triage"], when: "test failure indicates a bug requiring triage" }
    - { type: "finding", to: ["uptime-manager"], when: "endpoint unavailability or sustained error response" }
data:
  entityTypesRead: ["api_endpoints", "test_suites"]
  entityTypesWrite: ["test_results", "api_health_reports"]
  memoryNamespaces: ["endpoint_baselines", "failure_patterns"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering", "operations"]
presence:
  web:
    search: true
    browsing: true
    crawling: false
mcpServers:
  - ref: "tools/exa"
    required: false
    reason: "Search for API documentation, changelog updates, and known issues for endpoints under test"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse API documentation portals and interactive API explorers"
  - ref: "tools/composio"
    required: false
    reason: "Integrate with project management tools to sync test results and create tickets"
egress:
  mode: "open"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/test-generation@1.0.0"
  - ref: "skills/report-generation@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
automations:
  triggers:
    - name: "Generate tests for new endpoint"
      entityType: "api_endpoints"
      eventType: "created"
      targetAgent: "self"
      promptTemplate: "Generate test cases for this new API endpoint."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-api-base-url
      name: "Set API base URL"
      description: "The root URL of the API under test. All endpoint paths are relative to this"
      type: north_star
      key: api_base_url
      group: configuration
      priority: required
      reason: "Cannot test endpoints without knowing where the API lives"
      ui:
        inputType: text
        placeholder: "https://api.example.com/v1"
    - id: set-latency-thresholds
      name: "Define latency thresholds"
      description: "Acceptable P50/P95/P99 latency targets for regression detection"
      type: config
      group: configuration
      target: { namespace: endpoint_baselines, key: latency_thresholds }
      priority: required
      reason: "Regression detection requires defined performance baselines"
      ui:
        inputType: json
        placeholder: '{"p50_ms": 200, "p95_ms": 500, "p99_ms": 1000}'
    - id: import-endpoints
      name: "Import API endpoints"
      description: "Seed endpoint inventory so testing begins immediately"
      type: data_presence
      entityType: api_endpoints
      minCount: 1
      group: data
      priority: required
      reason: "Bot needs endpoint definitions to generate and run test cases"
      ui:
        actionLabel: "Import Endpoints"
        emptyState: "No endpoints found. Import an OpenAPI spec or add endpoints manually."
    - id: set-api-auth
      name: "Configure API authentication"
      description: "Auth credentials for the API under test, stored securely as a workspace secret"
      type: secret
      secretName: api_test_credentials
      group: configuration
      priority: recommended
      reason: "Most APIs require authentication. Without it, tests only cover public endpoints"
      ui:
        inputType: secret
        placeholder: "Bearer token or API key"
    - id: connect-composio
      name: "Connect project management"
      description: "Syncs test results with your project tracker to auto-create tickets"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: optional
      reason: "Auto-creates tickets from test failures so nothing falls through the cracks"
      ui:
        icon: composio
        actionLabel: "Connect Project Tool"
goals:
  - name: endpoints_tested
    description: "Test all registered endpoints on each scheduled run"
    category: primary
    metric:
      type: count
      entity: test_results
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when api_endpoints records exist"
    feedback:
      enabled: true
      entityType: test_results
      actions:
        - { value: accurate, label: "Correct result" }
        - { value: false_positive, label: "Flagged but actually fine" }
        - { value: missed, label: "Missed a real issue" }
  - name: regression_detection
    description: "Detect latency regressions exceeding defined thresholds"
    category: primary
    metric:
      type: count
      entity: api_health_reports
      filter: { regression_detected: true }
    target:
      operator: ">="
      value: 0
      period: per_run
  - name: baseline_coverage
    description: "Maintain up-to-date performance baselines for all active endpoints"
    category: health
    metric:
      type: count
      source: memory
      namespace: endpoint_baselines
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
  - name: critical_escalation_speed
    description: "5xx and auth bypass findings routed to sre-devops within the same run"
    category: secondary
    metric:
      type: boolean
      measurement: critical_findings_routed_same_run
    target:
      operator: "=="
      value: true
      period: per_run
---

# API Tester

Systematic API testing agent that validates endpoints for correctness, performance, and reliability. Tracks response baselines and detects regressions over time.

## What It Does

- Validates HTTP response codes against expected values
- Checks response schemas for structural correctness
- Measures latency and compares against baselines
- Tests error handling paths (invalid input, auth failures, edge cases)
- Generates test cases for newly discovered endpoints
- Tracks regressions across runs to detect degradation trends

## Escalation Behavior

- **Critical**: Endpoint returning 5xx, auth bypass detected -> finding to sre-devops
- **High**: Latency regression >50%, schema breaking change -> finding to sre-devops
- **Medium**: Minor latency increase, deprecated field usage -> logged as test_results
- **Low**: New endpoint discovered, baseline established -> memory update only

## Recommended Setup

Set these North Star keys for best results:
- `api_base_url` -- Base URL for the API under test
- `latency_thresholds` -- Acceptable P50/P95/P99 latency targets
