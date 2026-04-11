---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: qdrant-memory
  displayName: Qdrant Vector Memory
  version: 1.0.0
  description: High-performance vector database for agent memory with advanced filtering
  tags: [memory, vector-search, filtering, rust]
  author: Qdrant
  license: Apache-2.0
transport:
  type: streamable-http
  url: "http://qdrant-mcp:8080/mcp"
env:
  - name: QDRANT_URL
    description: Qdrant server REST endpoint
    required: true
  - name: QDRANT_API_KEY
    description: Qdrant API key (if authentication enabled)
    required: false
  - name: EMBEDDING_MODEL
    description: Embedding model name (default sentence-transformers/all-MiniLM-L6-v2)
    required: false
tools:
  - name: qdrant-store
    description: Store a memory with semantic embedding in Qdrant
    category: memory
  - name: qdrant-find
    description: Search memories by semantic similarity with optional filtering
    category: memory
---

# Qdrant Vector Memory

Qdrant is a high-performance vector database written in Rust with 29K+ GitHub stars. It provides production-grade vector search with advanced filtering, payload storage, and horizontal scaling.

## Which Bots Use This

Best for bots that need fast, filtered vector search over large memory sets:
- **anomaly-detector** -- stores and queries metric baselines at scale
- **market-intelligence** -- searches across large knowledge bases with metadata filters
- **data-quality-monitor** -- pattern matching across historical data points

## Setup

Qdrant is deployed as a managed single-pod backend within your workspace. Select it from Workspace Settings > Memory Backend. Requires block storage (not NFS) for its persistence volume.

## Capabilities

- **vector-search** -- HNSW-based approximate nearest neighbor search
- **filtering** -- Rich payload filtering (match, range, geo, nested)
- **payload-storage** -- Arbitrary JSON payloads attached to vectors
