---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: argocd
  displayName: "Argo CD"
  version: "1.0.0"
  description: "Argo CD GitOps — applications, sync, resources, logs, and events"
  tags: ["argocd", "gitops", "kubernetes", "cd", "deployment"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "argocd-mcp@0.5.0", "stdio"]
env:
  - name: ARGOCD_BASE_URL
    description: "Argo CD server URL (e.g., https://argocd.example.com)"
    required: true
  - name: ARGOCD_AUTH_TOKEN
    description: "Argo CD API token or JWT for authentication"
    required: true
  - name: ARGOCD_INSECURE
    description: "Set to true to skip TLS certificate verification"
    required: false
tools:
  - name: list_applications
    description: "List applications with optional search and pagination"
    category: applications
  - name: get_application
    description: "Get application details by name"
    category: applications
  - name: create_application
    description: "Create a new Argo CD application"
    category: applications
  - name: update_application
    description: "Update an existing application"
    category: applications
  - name: delete_application
    description: "Delete an application with cascade options"
    category: applications
  - name: sync_application
    description: "Sync an application with dry-run, prune, and revision options"
    category: sync
  - name: get_application_resource_tree
    description: "Get the resource tree for an application"
    category: resources
  - name: get_application_managed_resources
    description: "Get managed resources with kind, namespace, and name filters"
    category: resources
  - name: get_resources
    description: "Get manifests for specific resources by ref"
    category: resources
  - name: get_resource_actions
    description: "Get available actions for a managed resource"
    category: resources
  - name: run_resource_action
    description: "Run an action on a managed resource"
    category: resources
  - name: get_application_workload_logs
    description: "Get logs for a workload (Deployment, Pod, etc.)"
    category: logs
  - name: get_application_events
    description: "Get events for an application"
    category: events
  - name: get_resource_events
    description: "Get events for a specific managed resource"
    category: events
---

# Argo CD MCP Server

Provides full Argo CD API access for bots that manage GitOps deployments, monitor application health, and automate sync operations.

## Which Bots Use This

- **sre-devops** — Monitors application sync status, investigates deployment failures, checks resource health
- **devops-automator** — Automates application sync, manages deployment pipelines, creates new applications
- **release-manager** — Tracks release deployments, syncs to specific revisions, monitors rollouts

## Setup

1. Generate an Argo CD API token: `argocd account generate-token --account <account>`
2. Or use a JWT from Argo CD SSO authentication
3. Add `ARGOCD_BASE_URL` and `ARGOCD_AUTH_TOKEN` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Argo CD server instance across all DevOps bots:

```yaml
mcpServers:
  - ref: "tools/argocd"
    reason: "DevOps bots need Argo CD access for deployment management and health monitoring"
```
