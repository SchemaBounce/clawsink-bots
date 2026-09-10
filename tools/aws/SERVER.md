---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: aws
  displayName: "AWS"
  version: "1.0.0"
  description: "Amazon Web Services, manage EC2, S3, Lambda, RDS, and 1000+ AWS resources"
  tags: ["aws", "amazon", "cloud", "infrastructure", "ec2", "s3", "lambda"]
  category: "cloud-infra"
  author: "schemabounce"
  license: "MIT"
# PACKAGE MIGRATION (2026-09-09): awslabs.ccapi-mcp-server@1.0.18 never started
# and can no longer be pinned. It is yanked on PyPI ("Superceeded by
# awslabs.aws-iac-mcp-server"), and every published version of it declares
# mcp[cli]>=1.23.0 with no upper bound, so the resolver installs mcp 2.x, where
# FastMCP was renamed and `from mcp.server.fastmcp import FastMCP` raises
# ModuleNotFoundError at import. No pin of that package can work.
#
# Replaced with awslabs.aws-api-mcp-server, which reaches the same AWS API
# surface (EC2, S3, Lambda, RDS and every other service) through the AWS CLI,
# takes the same AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_REGION env
# block, and pins mcp<2.0 so it resolves an SDK it was written against. Its
# named successor is not usable here: awslabs.aws-iac-mcp-server covers
# CloudFormation and CDK, not general resource access, and the AWS MCP Server
# that this package points to is a managed REMOTE server behind OAuth 2.1.
# Verified by running it: 1.5.5 answers a real MCP initialize (serverInfo
# AWS-API-MCP) with placeholder credentials and no AWS_REGION set. The server
# does report a deprecation notice of its own in its initialize instructions.
transport:
  type: "stdio"
  command: "uvx"
  args: ["awslabs.aws-api-mcp-server@1.5.5"]
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
    description: "Default AWS region e.g. us-east-1"
    required: false
tools:
  - name: call_aws
    description: "Run one AWS CLI command against any AWS service"
    category: aws
  - name: suggest_aws_commands
    description: "Suggest AWS CLI commands for a described task"
    category: aws
---

# AWS MCP Server

Provides broad AWS API access for bots that manage cloud infrastructure, deployments, and operational resources across EC2, S3, Lambda, RDS, and more.

## Which Bots Use This

- **sre-devops** -- Infrastructure management, instance monitoring, and operational troubleshooting
- **devops-automator** -- Deployment automation, Lambda management, and resource provisioning

## Setup

1. Create an IAM user or role with appropriate permissions for the AWS services your bots need
2. Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in the MCP connection setup
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
