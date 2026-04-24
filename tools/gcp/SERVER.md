---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: gcp
  displayName: "Google Cloud"
  version: "1.0.0"
  description: "Google Cloud Platform, Compute, Storage, BigQuery, and Cloud Run"
  tags: ["gcp", "google-cloud", "cloud", "infrastructure"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "gcp-mcp-server@1.4.0"]
env:
  - name: GOOGLE_APPLICATION_CREDENTIALS
    description: "Path to GCP service account JSON key"
    required: true
  - name: GCP_PROJECT_ID
    description: "GCP project ID"
    required: true
tools:
  - name: list_instances
    description: "List Compute Engine instances"
    category: compute
  - name: list_buckets
    description: "List Cloud Storage buckets"
    category: storage
  - name: query_bigquery
    description: "Run a BigQuery SQL query"
    category: data
  - name: list_functions
    description: "List Cloud Functions"
    category: serverless
  - name: list_services
    description: "List Cloud Run services"
    category: serverless
  - name: get_logs
    description: "Get Cloud Logging entries"
    category: logging
  - name: list_clusters
    description: "List GKE clusters"
    category: containers
  - name: get_iam_policy
    description: "Get IAM policy for a resource"
    category: security
---

# Google Cloud MCP Server

Provides Google Cloud Platform API access for bots that manage compute instances, storage, BigQuery analytics, Cloud Run services, and GKE clusters.

## Which Bots Use This

- **sre-devops** -- GKE cluster management, Cloud Logging queries, and Compute Engine instance monitoring
- **devops-automator** -- Cloud Run deployments, Cloud Functions management, and resource provisioning

## Setup

1. Create a GCP service account with appropriate roles for the services your bots need
2. Download the JSON key file and make it available to the workspace
3. Add `GOOGLE_APPLICATION_CREDENTIALS` (path to the key file) and `GCP_PROJECT_ID` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single GCP server instance across infrastructure bots:

```yaml
mcpServers:
  - ref: "tools/gcp"
    reason: "Infrastructure bots need GCP access for compute, storage, and deployment management"
    config:
      default_region: "us-central1"
```
