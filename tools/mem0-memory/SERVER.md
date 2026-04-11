---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: mem0-memory
  displayName: Mem0 Memory
  version: 1.0.0
  description: Purpose-built agent memory layer with automatic fact extraction and personalization
  tags: [memory, vector-search, fact-extraction, personalization]
  author: Mem0 AI
  license: Apache-2.0
transport:
  type: streamable-http
  url: "http://mem0-mcp:8080/mcp"
env:
  - name: MEM0_API_URL
    description: Mem0 self-hosted API endpoint
    required: true
  - name: MEM0_EMBEDDING_MODEL
    description: Embedding model for semantic search (default text-embedding-3-small)
    required: false
tools:
  - name: add_memory
    description: Add a memory with automatic fact extraction
    category: memory
  - name: search_memory
    description: Search memories by semantic similarity
    category: memory
  - name: get_memories
    description: List all memories with optional filtering
    category: memory
  - name: delete_memory
    description: Delete a specific memory by ID
    category: memory
  - name: memory_history
    description: View the change history of a memory
    category: memory
---

# Mem0 Memory

Mem0 is a purpose-built memory layer for AI agents with 52K+ GitHub stars. It automatically extracts facts, preferences, and entities from conversations, providing personalized memory that improves over time.

## Which Bots Use This

Any bot that benefits from long-term personalization and fact tracking:
- **customer-support** -- remembers customer preferences and history
- **executive-assistant** -- tracks decisions, preferences, and context
- **mentor-coach** -- maintains learning progress and style preferences

## Setup

Mem0 is deployed as a managed backend within your workspace. Select it from Workspace Settings > Memory Backend.

When running in pgvector-only mode (default), Mem0 reuses your existing workspace PostgreSQL -- no additional database pods required.

## Capabilities

- **vector-search** -- Semantic similarity search across all memories
- **fact-extraction** -- Automatic extraction of facts from unstructured text
- **memory-history** -- Full change history for any memory entry
- **personalization** -- Learns user/agent preferences over time
