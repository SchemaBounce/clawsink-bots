---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: api-tester
  displayName: "API Tester"
  version: "1.0.1"
  description: "API endpoint testing, performance benchmarking, and health monitoring."
  category: engineering
  tags: ["api-testing", "performance", "health-monitoring", "regression", "benchmarks"]
agent:
  capabilities: ["api_testing", "performance_analysis"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS load existing endpoint baselines from `endpoint_baselines` memory before running tests — never compare against hardcoded values.
    - ALWAYS test both happy-path and error-path (4xx, 5xx, malformed input, missing auth) for every endpoint.
    - NEVER send real credentials or PII in test payloads — use synthetic test data only.
    - Route 5xx errors and auth bypass findings to sre-devops immediately — do not wait for the next scheduled run.
    - Route confirmed bug-indicating failures (consistent logic errors, schema violations) to bug-triage for triage.
    - Route sustained endpoint unavailability (3+ consecutive failures) to uptime-manager for status page consideration.
    - When a new endpoint appears in `api_endpoints`, auto-generate baseline test cases and store initial latency benchmarks.
    - Update `failure_patterns` memory when a previously failing test starts passing — track resolution patterns, not just failures.
    - On latency regressions, record the percentage increase and the specific P50/P95/P99 values — never report raw numbers without baseline context.
    - Do not re-test endpoints that have been marked as deprecated in the `api_endpoints` entity unless explicitly requested.
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
