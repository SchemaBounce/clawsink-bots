---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mongodb
  displayName: "MongoDB"
  version: "1.0.0"
  description: "MongoDB database, queries, collections, documents, and aggregation"
  tags: ["mongodb", "nosql", "database", "documents"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "mongodb-mcp-server@1.9.0"]
env:
  - name: MONGODB_CONNECTION_STRING
    description: "MongoDB connection URI e.g. mongodb://user:pass@host:27017/db"
    required: true
tools:
  - name: find
    description: "Query documents"
    category: queries
  - name: insert_one
    description: "Insert a document"
    category: documents
  - name: update_one
    description: "Update a document"
    category: documents
  - name: delete_one
    description: "Delete a document"
    category: documents
  - name: aggregate
    description: "Run aggregation pipeline"
    category: queries
  - name: list_collections
    description: "List collections"
    category: collections
  - name: list_databases
    description: "List databases"
    category: databases
  - name: count_documents
    description: "Count documents matching a filter"
    category: queries
---

# MongoDB MCP Server

Provides MongoDB database tools for bots that need to query documents, manage collections, and run aggregation pipelines.

## Which Bots Use This

- **data-analyst** — Document exploration, aggregation queries, and collection inspection

## Setup

1. Prepare a MongoDB connection URI with appropriate credentials
2. Add `MONGODB_CONNECTION_STRING` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single MongoDB server instance across bots:

```yaml
mcpServers:
  - ref: "tools/mongodb"
    reason: "Bots need MongoDB access for document queries and aggregation"
    config:
      default_database: "production"
```
