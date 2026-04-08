---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: elasticsearch
  displayName: "Elasticsearch"
  version: "1.0.0"
  description: "Elasticsearch search and analytics — queries, indices, and aggregations"
  tags: ["elasticsearch", "search", "analytics", "logging"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@elastic/mcp-server-elasticsearch@0.3.1"]
env:
  - name: ELASTICSEARCH_URL
    description: "Elasticsearch cluster URL e.g. https://localhost:9200"
    required: true
  - name: ELASTICSEARCH_API_KEY
    description: "Elasticsearch API key"
    required: false
tools:
  - name: search
    description: "Search documents"
    category: search
  - name: get_document
    description: "Get document by ID"
    category: documents
  - name: index_document
    description: "Index a document"
    category: documents
  - name: list_indices
    description: "List indices"
    category: indices
  - name: get_mapping
    description: "Get index mapping"
    category: indices
  - name: aggregate
    description: "Run aggregation"
    category: search
  - name: get_cluster_health
    description: "Cluster health"
    category: cluster
---

# Elasticsearch MCP Server

Provides Elasticsearch tools for bots that need full-text search, log analysis, index management, and aggregation queries.

## Which Bots Use This

- **data-analyst** — Search queries, aggregations, and index exploration
- **sre-devops** — Log analysis, cluster health monitoring, and index management

## Setup

1. Ensure your Elasticsearch cluster is accessible from the workspace network
2. Add `ELASTICSEARCH_URL` to your workspace secrets
3. Optionally add `ELASTICSEARCH_API_KEY` for authenticated clusters
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Elasticsearch server instance across bots:

```yaml
mcpServers:
  - ref: "tools/elasticsearch"
    reason: "Bots need Elasticsearch access for search, log analysis, and monitoring"
    config:
      default_index: "logs-*"
```
