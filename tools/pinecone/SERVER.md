---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: pinecone
  displayName: "Pinecone"
  version: "1.0.0"
  description: "Pinecone vector database, indexes, upsert, query, and namespaces"
  tags: ["pinecone", "vector", "embeddings", "ai", "search"]
  category: "ai-memory"
  author: "schemabounce"
  license: "MIT"
# Declarative auth + validation + healthProbe.
# Pinecone uses Api-Key as the auth header.
auth:
  type: api_key_header
  token_env: PINECONE_API_KEY
  header_name: Api-Key

# PACKAGE MIGRATION (2026-09-09): pinecone-mcp@1.0.0 could not be installed at
# all. It depends on @modelcontextprotocol/sdk@^0.1.0, which is no longer
# published, so npm exits ETARGET ("No matching version found for
# @modelcontextprotocol/sdk@^0.1.0") before anything runs. That package has only
# ever published 1.0.0, so no pin of it can work. Replaced with Pinecone's own
# MCP server, @pinecone-database/mcp (bin: pinecone-mcp), which uses the same
# PINECONE_API_KEY env var. Verified by running it: installed 0.3.0 and got a
# real MCP initialize result back (serverInfo pinecone-mcp 0.3.0).
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@pinecone-database/mcp@0.3.0"]
env:
  - name: PINECONE_API_KEY
    description: "Pinecone API key from app.pinecone.io"
    required: true
    sensitive: true

# /indexes lists all indexes in the account. Lightweight, idempotent.
validation:
  request:
    method: GET
    url: https://api.pinecone.io/indexes
    headers:
      X-Pinecone-API-Version: "2024-07"
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Pinecone rejected the API key (401). Generate a new key in your Pinecone console at https://app.pinecone.io and update PINECONE_API_KEY." }
    "403": { state: needs_setup, message: "Pinecone API key lacks required permissions (403). Check the project the key was issued for." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://api.pinecone.io/indexes
    headers:
      X-Pinecone-API-Version: "2024-07"
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

tools:
  - name: search-docs
    description: "Search the Pinecone documentation"
    category: docs
  - name: list-indexes
    description: "List all indexes in the account"
    category: indexes
  - name: describe-index
    description: "Get the configuration of an index"
    category: indexes
  - name: describe-index-stats
    description: "Get record counts and namespace stats for an index"
    category: indexes
  - name: create-index-for-model
    description: "Create an index that embeds text with a hosted model"
    category: indexes
  - name: upsert-records
    description: "Upsert records into an index namespace"
    category: records
  - name: search-records
    description: "Search an index namespace for similar records"
    category: records
  - name: rerank-documents
    description: "Rerank documents against a query with a hosted model"
    category: records
  - name: cascading-search
    description: "Search several indexes and merge the ranked results"
    category: records
---

# Pinecone MCP Server

Provides Pinecone vector database tools for bots that work with embeddings, semantic search, and retrieval-augmented generation (RAG) pipelines.

## Which Bots Use This

- **data-analyst** -- Performs semantic search across vectorized datasets for similarity-based analysis
- **software-architect** -- Builds and queries RAG pipelines for codebase knowledge retrieval

## Setup

1. Create an API key at [app.pinecone.io](https://app.pinecone.io)
2. Add `PINECONE_API_KEY` in the MCP connection setup
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
