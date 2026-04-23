---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: terraform
  displayName: "Terraform"
  version: "1.0.0"
  description: "Terraform infrastructure as code, plan, apply, and state management"
  tags: ["terraform", "iac", "infrastructure", "hashicorp", "devops"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "terraform-mcp-server@0.13.0"]
env:
  - name: TERRAFORM_CLOUD_TOKEN
    description: "Terraform Cloud API token"
    required: false
tools:
  - name: plan
    description: "Run terraform plan"
    category: plans
  - name: show_plan
    description: "Show plan details"
    category: plans
  - name: list_workspaces
    description: "List Terraform Cloud workspaces"
    category: workspaces
  - name: get_workspace
    description: "Get workspace details"
    category: workspaces
  - name: list_runs
    description: "List runs in a workspace"
    category: workspaces
  - name: get_state
    description: "Get current state"
    category: state
  - name: list_resources
    description: "List resources in state"
    category: resources
  - name: validate
    description: "Validate configuration"
    category: plans
---

# Terraform MCP Server

Provides Terraform tools for infrastructure planning, state inspection, and Terraform Cloud workspace management. Requires Terraform CLI installed locally for plan/apply operations.

## Which Bots Use This

- **devops-automator** -- Plans and manages infrastructure changes, inspects state
- **sre-devops** -- Audits infrastructure drift, reviews planned changes
- **security-agent** -- Scans Terraform configurations for security misconfigurations

## Setup

1. Install the [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) on the host
2. Optionally create a Terraform Cloud API token at [app.terraform.io/settings/tokens](https://app.terraform.io/app/settings/tokens)
3. Add it to your workspace secrets as `TERRAFORM_CLOUD_TOKEN` if using Terraform Cloud
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Terraform server instance across infrastructure bots:

```yaml
mcpServers:
  - ref: "tools/terraform"
    reason: "Infrastructure bots need Terraform access for IaC management and state inspection"
    config:
      default_workspace: "your-workspace"
```
