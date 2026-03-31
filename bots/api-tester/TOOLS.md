# Data Access

- Query `api_endpoints`: `adl_query_records` — filter by `status` for active endpoints, by `created_at` for newly discovered ones
- Query `test_suites`: `adl_query_records` — filter by `endpoint_id` to load test cases for a specific endpoint
- Write `test_results`: `adl_upsert_record` — ID format `tr-{endpoint_id}-{timestamp}`, include status code, latency (P50/P95/P99), pass/fail, regression flag
- Write `api_health_reports`: `adl_upsert_record` — ID format `ahr-{date}`, aggregate health scores across all endpoints

# Memory Usage

- `endpoint_baselines`: per-endpoint latency benchmarks and expected response schemas — use `adl_read_memory` before testing, `adl_write_memory` to update baselines
- `failure_patterns`: historical failure and resolution patterns per endpoint — use `adl_add_memory` on state changes (pass-to-fail, fail-to-pass)

# Sub-Agent Orchestration

- `test-case-generator`: delegate generation of test cases for newly discovered endpoints
- `schema-validator`: delegate response body schema validation against documented contracts
- `performance-benchmarker`: delegate latency measurement and baseline comparison analysis
