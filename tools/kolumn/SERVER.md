---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: kolumn
  displayName: "Kolumn"
  version: "1.1.0"
  description: "Kolumn IaC — schema patterns, HCL generation, validation, and documentation"
  tags: ["kolumn", "iac", "schema", "hcl", "migration", "infrastructure-as-code"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "streamable-http"
  url: "${KOLUMN_MCP_URL}/mcp"
env:
  - name: KOLUMN_MCP_URL
    description: "Kolumn MCP service URL (managed by platform)"
    required: true
tools:
  - name: kolumn_pattern
    description: "Get Kolumn HCL patterns for common schema operations"
    category: patterns
  - name: kolumn_schema
    description: "Query Kolumn schema reference — column types, policies, provider features"
    category: reference
  - name: kolumn_validate
    description: "Validate Kolumn HCL configuration for correctness"
    category: validation
  - name: kolumn_generate
    description: "Generate Kolumn HCL from natural language or existing schemas"
    category: generation
---

# Kolumn MCP Server

Provides Kolumn IaC schema management tools — patterns, HCL generation, validation, and documentation with TOON encoding for token efficiency.

Kolumn is SchemaBounce's bundled Infrastructure as Code tool (free with platform). This MCP server gives agents the ability to generate and validate schema changes.

## Which Bots Use This

- **software-architect** — Generates Kolumn HCL for database schema changes
- **data-analyst** — Queries column types, indexes, and provider feature support
- **devops-automator** — Validates HCL before applying, generates migration plans

## Setup

This server is managed by the SchemaBounce platform. It provides documentation and validation capabilities that don't require database credentials.

For agents that need to apply schema changes, combine with the `schemabounce` MCP server which provides environment-level access.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/kolumn"
    reason: "Generate and validate Kolumn HCL for schema management"
```
