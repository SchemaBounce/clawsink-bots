---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: azure
  displayName: "Microsoft Azure"
  version: "1.0.0"
  description: "Azure cloud management — VMs, storage, databases, and App Service"
  tags: ["azure", "microsoft", "cloud", "infrastructure"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@azure/mcp"]
env:
  - name: AZURE_CLIENT_ID
    description: "Azure service principal client ID"
    required: true
  - name: AZURE_CLIENT_SECRET
    description: "Azure service principal client secret"
    required: true
  - name: AZURE_TENANT_ID
    description: "Azure Active Directory tenant ID"
    required: true
  - name: AZURE_SUBSCRIPTION_ID
    description: "Azure subscription ID"
    required: true
tools:
  - name: list_vms
    description: "List virtual machines"
    category: compute
  - name: list_storage_accounts
    description: "List storage accounts"
    category: storage
  - name: list_sql_databases
    description: "List SQL databases"
    category: databases
  - name: list_app_services
    description: "List App Service plans"
    category: apps
  - name: list_resource_groups
    description: "List resource groups"
    category: compute
  - name: get_metrics
    description: "Get Azure Monitor metrics"
    category: monitoring
  - name: list_web_apps
    description: "List web applications"
    category: apps
  - name: get_activity_logs
    description: "Get activity log entries"
    category: monitoring
---

# Microsoft Azure MCP Server

Provides Azure cloud management tools for bots that need to manage virtual machines, storage accounts, SQL databases, and App Service deployments.

## Which Bots Use This

- **sre-devops** -- VM monitoring, Azure Monitor metrics, and activity log analysis for incident response
- **devops-automator** -- App Service deployments, resource group management, and infrastructure provisioning

## Setup

1. Create an Azure service principal with appropriate role assignments for the resources your bots need
2. Add `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Azure server instance across infrastructure bots:

```yaml
mcpServers:
  - ref: "tools/azure"
    reason: "Infrastructure bots need Azure access for compute, storage, and deployment management"
    config:
      default_resource_group: "production-rg"
```
