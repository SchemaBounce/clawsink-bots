---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: api-tester
  displayName: "API Tester"
  version: "1.0.0"
  description: "API endpoint testing, performance benchmarking, and health monitoring."
  category: engineering
  tags: ["api-testing", "performance", "health-monitoring", "regression", "benchmarks"]
agent:
  capabilities: ["api_testing", "performance_analysis"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
model:
  provider: "anthropic"
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
  maxTokenBudget: 50000
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
data:
  entityTypesRead: ["api_endpoints", "test_suites"]
  entityTypesWrite: ["test_results", "api_health_reports"]
  memoryNamespaces: ["endpoint_baselines", "failure_patterns"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
skills: []
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
