---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: aws-cloudwatch
  displayName: "AWS CloudWatch"
  version: "1.0.1"
  description: "AWS CloudWatch, logs, metrics, alarms, and dashboards"
  tags: ["aws", "cloudwatch", "monitoring", "logs", "metrics", "alarms"]
  category: "observability"
  author: "schemabounce"
  license: "MIT"
# PACKAGE MIGRATION (2026-06-10): the original awslabs.cloudwatch-logs-mcp-server
# package was yanked on PyPI (reason: "Superceeded by awslabs.cloudwatch-mcp-server").
# Updated to the successor package awslabs.cloudwatch-mcp-server==0.1.4 (latest stable,
# confirmed via pypi.org/pypi/awslabs.cloudwatch-mcp-server/json on 2026-06-10).
# The new package provides unified CloudWatch telemetry covering logs, metrics, and alarms.
# VERSION FIX (2026-09-09): 0.1.4 never started. It declared mcp[cli]>=1.23.0 with
# no upper bound, so the resolver installed mcp 2.x, where FastMCP was renamed and
# `from mcp.server.fastmcp import Context` raises ModuleNotFoundError at import.
# 0.2.1 pins mcp[cli]>=2.0.0,<3.0.0 and is written against that SDK. Verified by
# running it: 0.1.4 dies on the ModuleNotFoundError, 0.2.1 answers a real MCP
# initialize (serverInfo awslabs.cloudwatch-mcp-server).
transport:
  type: "stdio"
  command: "uvx"
  args: ["awslabs.cloudwatch-mcp-server@0.2.1"]
env:
  - name: AWS_ACCESS_KEY_ID
    description: "AWS access key ID"
    required: true
    sensitive: true
  - name: AWS_SECRET_ACCESS_KEY
    description: "AWS secret access key"
    required: true
    sensitive: true
  - name: AWS_REGION
    description: "AWS region for CloudWatch e.g. us-east-1"
    required: false
tools:
  - name: describe_log_groups
    description: "List and describe CloudWatch log groups"
    category: logs
  - name: analyze_log_group
    description: "Summarize anomalies and error patterns in a log group"
    category: logs
  - name: execute_log_insights_query
    description: "Start a CloudWatch Logs Insights query"
    category: logs
  - name: get_logs_insight_query_results
    description: "Fetch the results of a Logs Insights query"
    category: logs
  - name: cancel_logs_insight_query
    description: "Cancel a running Logs Insights query"
    category: logs
  - name: execute_cwl_insights_batch
    description: "Run a batch of Logs Insights queries"
    category: logs
  - name: recommend_indexes_loggroup
    description: "Recommend log field indexes for a log group"
    category: logs
  - name: recommend_indexes_account
    description: "Recommend log field indexes across the account"
    category: logs
  - name: get_metric_data
    description: "Get CloudWatch metric data points"
    category: metrics
  - name: get_metric_metadata
    description: "Get metadata for a CloudWatch metric"
    category: metrics
  - name: analyze_metric
    description: "Analyze a metric for anomalies and trends"
    category: metrics
  - name: get_recommended_metric_alarms
    description: "Get recommended alarm settings for a metric"
    category: metrics
  - name: execute_promql_query
    description: "Run a PromQL instant query"
    category: metrics
  - name: execute_promql_range_query
    description: "Run a PromQL range query"
    category: metrics
  - name: get_promql_label_values
    description: "List values for a PromQL label"
    category: metrics
  - name: get_promql_series
    description: "List PromQL series matching a selector"
    category: metrics
  - name: get_promql_labels
    description: "List available PromQL labels"
    category: metrics
  - name: get_active_alarms
    description: "List currently active CloudWatch alarms"
    category: alarms
  - name: get_alarm_history
    description: "Get the state history for an alarm"
    category: alarms
---

# AWS CloudWatch MCP Server

Provides focused CloudWatch tools for bots that need log analysis, metric queries, alarm management, and dashboard access.

## Which Bots Use This

- **sre-devops** -- Log analysis via CloudWatch Logs Insights, alarm monitoring, and metric-based incident investigation
- **infra-monitor** -- Real-time metric tracking, alarm creation, and proactive alerting on infrastructure health

## Setup

1. Create an IAM user or role with `CloudWatchReadOnlyAccess` and `CloudWatchLogsReadOnlyAccess` policies (add `CloudWatchFullAccess` if bots need to create alarms)
2. Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in the MCP connection setup
3. Optionally set `AWS_REGION` for a default region
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single CloudWatch server instance across monitoring bots:

```yaml
mcpServers:
  - ref: "tools/aws-cloudwatch"
    reason: "Monitoring bots need CloudWatch access for logs, metrics, and alarms"
    config:
      default_region: "us-east-1"
```
