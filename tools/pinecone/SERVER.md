---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: pinecone
  displayName: "Pinecone"
  version: "1.0.0"
  description: "Pinecone vector database, indexes, upsert, query, and namespaces"
  tags: ["pinecone", "vector", "embeddings", "ai", "search"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "pinecone-mcp@1.0.0"]
env:
  - name: PINECONE_API_KEY
    description: "Pinecone API key from app.pinecone.io"
    required: true
tools:
  - name: list_indexes
    description: "List all indexes in the account"
    category: indexes
  - name: create_index
    description: "Create a new vector index"
    category: indexes
  - name: upsert_vectors
    description: "Upsert vectors into an index"
    category: vectors
  - name: query_vectors
    description: "Query vectors by similarity"
    category: vectors
  - name: delete_vectors
    description: "Delete vectors from an index"
    category: vectors
  - name: describe_index
    description: "Get details and stats for an index"
    category: indexes
  - name: list_namespaces
    description: "List namespaces within an index"
    category: namespaces
---

# Pinecone MCP Server

Provides Pinecone vector database tools for bots that work with embeddings, semantic search, and retrieval-augmented generation (RAG) pipelines.

## Which Bots Use This

- **data-analyst** -- Performs semantic search across vectorized datasets for similarity-based analysis
- **software-architect** -- Builds and queries RAG pipelines for codebase knowledge retrieval

## Setup

1. Create an API key at [app.pinecone.io](https://app.pinecone.io)
2. Add `PINECONE_API_KEY` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Pinecone server instance across bots:

```yaml
mcpServers:
  - ref: "tools/pinecone"
    reason: "Bots need vector database access for semantic search and RAG pipelines"
    config:
      default_index: "knowledge-base"
```
