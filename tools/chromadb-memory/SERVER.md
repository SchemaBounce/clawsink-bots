---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: chromadb-memory
  displayName: ChromaDB Memory
  version: 1.0.0
  description: Developer-friendly embedding database for agent memory
  tags: [memory, vector-search, collections, developer-friendly]
  author: Chroma
  license: Apache-2.0
transport:
  type: streamable-http
  url: "http://chromadb-mcp:8080/mcp"
env:
  - name: CHROMA_URL
    description: ChromaDB server HTTP endpoint
    required: true
tools:
  - name: chroma_create_collection
    description: Create a new memory collection
    category: collections
  - name: chroma_add_documents
    description: Add documents/memories to a collection
    category: memory
  - name: chroma_query
    description: Query a collection by semantic similarity
    category: memory
  - name: chroma_get_documents
    description: Get documents by ID from a collection
    category: memory
  - name: chroma_delete_documents
    description: Delete documents from a collection
    category: memory
  - name: chroma_list_collections
    description: List all memory collections
    category: collections
---

# ChromaDB Memory

ChromaDB is a developer-friendly embedding database with 27K+ GitHub stars and 11M+ monthly downloads. It provides simple, intuitive APIs for storing and querying embeddings organized in collections.

## Which Bots Use This

Best for bots that need simple, collection-based memory organization:
- **knowledge-base-curator** -- organizes knowledge into themed collections
- **blog-writer** -- stores research and references in topic collections
- **ux-researcher** -- maintains collections of user feedback and insights

## Setup

ChromaDB is deployed as a managed single-pod backend within your workspace. Select it from Workspace Settings > Memory Backend.

Note: ChromaDB has no built-in authentication. Access is secured via Kubernetes NetworkPolicy -- only the OpenCLAW runtime pod can reach it.

## Capabilities

- **vector-search** -- Embedding-based similarity search
- **collections** -- Organize memories into named collections
- **document-storage** -- Store documents with metadata and embeddings
