# Data Access

- Query `deployments`: `adl_query_records` — filter by `created_at` for new deployments, by `environment` for prod vs staging, by `status` for failed
- Query `infrastructure_events`: `adl_query_records` — filter by `timestamp` for events correlating with deployment windows
- Query `pipeline_runs`: `adl_query_records` — filter by `branch` for main-branch failures, by `status` for failed runs
- Write `devops_findings`: `adl_upsert_record` — ID format `dof-{deployment_id}-{type}`, include environment, error rate delta, health check results
- Write `automation_proposals`: `adl_upsert_record` — ID format `ap-{pattern_hash}`, include pattern description, occurrence count, proposed automation

# Memory Usage

- `deployment_patterns`: recurring manual operational patterns for automation proposals — use `adl_add_memory` per occurrence, `adl_read_memory` to check threshold
- `incident_correlations`: deployment-to-incident mappings for regression detection — use `adl_add_memory` when correlation found

# MCP Server Tools

- `github.actions`: monitor CI/CD pipeline runs, check workflow status, identify failures

# Sub-Agent Orchestration

- `deployment-verifier`: delegate post-deployment health checks (error rates, latency, pod restarts)
- `incident-correlator`: delegate mapping deployment events to infrastructure incidents
- `automation-proposer`: delegate analysis of repetitive patterns and generation of automation trigger proposals
