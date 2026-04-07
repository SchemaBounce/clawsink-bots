---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: kubernetes
  displayName: "Kubernetes"
  version: "1.0.0"
  description: "Kubernetes cluster management — pods, services, deployments, and logs"
  tags: ["kubernetes", "k8s", "containers", "orchestration", "devops"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@strowk/mcp-k8s@0.6.1"]
env:
  - name: KUBECONFIG
    description: "Path to kubeconfig file, defaults to ~/.kube/config"
    required: false
tools:
  - name: list_pods
    description: "List pods in a namespace"
    category: pods
  - name: get_pod
    description: "Get details of a specific pod"
    category: pods
  - name: get_pod_logs
    description: "Get logs from a pod"
    category: pods
  - name: list_deployments
    description: "List deployments in a namespace"
    category: deployments
  - name: get_deployment
    description: "Get details of a specific deployment"
    category: deployments
  - name: scale_deployment
    description: "Scale a deployment up or down"
    category: deployments
  - name: list_services
    description: "List services in a namespace"
    category: services
  - name: list_namespaces
    description: "List all namespaces in the cluster"
    category: cluster
  - name: list_nodes
    description: "List nodes in the cluster"
    category: cluster
  - name: get_events
    description: "Get events for a namespace or resource"
    category: cluster
  - name: apply_manifest
    description: "Apply a Kubernetes manifest"
    category: cluster
  - name: delete_resource
    description: "Delete a Kubernetes resource"
    category: cluster
---

# Kubernetes MCP Server

Provides Kubernetes tools for cluster management, pod inspection, deployment scaling, and log retrieval via kubectl-compatible API access.

## Which Bots Use This

- **sre-devops** -- Monitors pod health, inspects logs, manages deployments, investigates incidents
- **devops-automator** -- Scales deployments, applies manifests, manages cluster resources
- **incident-commander** -- Checks pod status and events during incidents
- **release-manager** -- Verifies deployment rollouts and pod readiness

## Setup

1. Ensure a valid kubeconfig is available at `~/.kube/config` or set the `KUBECONFIG` path
2. The kubeconfig must have appropriate RBAC permissions for the target namespaces
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Kubernetes server instance across ops bots:

```yaml
mcpServers:
  - ref: "tools/kubernetes"
    reason: "Ops bots need Kubernetes access for cluster management and incident response"
    config:
      default_namespace: "production"
```
