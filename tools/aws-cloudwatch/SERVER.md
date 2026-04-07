---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: aws-cloudwatch
  displayName: "AWS CloudWatch"
  version: "1.0.0"
  description: "AWS CloudWatch — logs, metrics, alarms, and dashboards"
  tags: ["aws", "cloudwatch", "monitoring", "logs", "metrics", "alarms"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "uvx"
  args: ["awslabs.cloudwatch-logs-mcp-server"]
env:
  - name: AWS_ACCESS_KEY_ID
    description: "AWS access key ID"
    required: true
  - name: AWS_SECRET_ACCESS_KEY
    description: "AWS secret access key"
    required: true
  - name: AWS_REGION
    description: "AWS region for CloudWatch e.g. us-east-1"
    required: false
tools:
  - name: query_logs
    description: "Query CloudWatch Logs Insights"
    category: logs
  - name: list_log_groups
    description: "List log groups"
    category: logs
  - name: get_log_events
    description: "Get log events from a log stream"
    category: logs
  - name: get_metric_data
    description: "Get CloudWatch metric data points"
    category: metrics
  - name: list_metrics
    description: "List available metrics"
    category: metrics
  - name: describe_alarms
    description: "List CloudWatch alarms"
    category: alarms
  - name: get_dashboard
    description: "Get dashboard definition"
    category: dashboards
  - name: put_metric_alarm
    description: "Create or update an alarm"
    category: alarms
---

# AWS CloudWatch MCP Server

Provides focused CloudWatch tools for bots that need log analysis, metric queries, alarm management, and dashboard access.

## Which Bots Use This

- **sre-devops** -- Log analysis via CloudWatch Logs Insights, alarm monitoring, and metric-based incident investigation
- **infra-monitor** -- Real-time metric tracking, alarm creation, and proactive alerting on infrastructure health

## Setup

1. Create an IAM user or role with `CloudWatchReadOnlyAccess` and `CloudWatchLogsReadOnlyAccess` policies (add `CloudWatchFullAccess` if bots need to create alarms)
2. Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to your workspace secrets
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
