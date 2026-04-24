---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: aws
  displayName: "AWS"
  version: "1.0.0"
  description: "Amazon Web Services, manage EC2, S3, Lambda, RDS, and 1000+ AWS resources"
  tags: ["aws", "amazon", "cloud", "infrastructure", "ec2", "s3", "lambda"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "uvx"
  args: ["awslabs.ccapi-mcp-server==1.0.18"]
env:
  - name: AWS_ACCESS_KEY_ID
    description: "AWS access key ID"
    required: true
  - name: AWS_SECRET_ACCESS_KEY
    description: "AWS secret access key"
    required: true
  - name: AWS_REGION
    description: "Default AWS region e.g. us-east-1"
    required: false
tools:
  - name: describe_instances
    description: "List EC2 instances"
    category: compute
  - name: list_buckets
    description: "List S3 buckets"
    category: storage
  - name: list_functions
    description: "List Lambda functions"
    category: serverless
  - name: describe_db_instances
    description: "List RDS instances"
    category: database
  - name: get_log_events
    description: "Get CloudWatch log events"
    category: monitoring
  - name: list_queues
    description: "List SQS queues"
    category: compute
  - name: describe_clusters
    description: "List ECS/EKS clusters"
    category: compute
  - name: get_metric_data
    description: "Get CloudWatch metrics"
    category: monitoring
  - name: list_alarms
    description: "List CloudWatch alarms"
    category: monitoring
  - name: describe_vpcs
    description: "List VPCs"
    category: networking
  - name: list_roles
    description: "List IAM roles"
    category: security
---

# AWS MCP Server

Provides broad AWS API access for bots that manage cloud infrastructure, deployments, and operational resources across EC2, S3, Lambda, RDS, and more.

## Which Bots Use This

- **sre-devops** -- Infrastructure management, instance monitoring, and operational troubleshooting
- **devops-automator** -- Deployment automation, Lambda management, and resource provisioning

## Setup

1. Create an IAM user or role with appropriate permissions for the AWS services your bots need
2. Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to your workspace secrets
3. Optionally set `AWS_REGION` for a default region (bots can override per-request)
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single AWS server instance across infrastructure bots:

```yaml
mcpServers:
  - ref: "tools/aws"
    reason: "Infrastructure bots need AWS access for compute, storage, and deployment management"
    config:
      default_region: "us-east-1"
```
