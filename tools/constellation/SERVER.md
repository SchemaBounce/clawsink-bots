---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: constellation
  displayName: "Constellation"
  version: "1.0.0"
  description: "Code intelligence for coding agents: symbol search, callers and callees, dependencies, and change impact across an indexed codebase"
  tags: ["code", "code-intelligence", "dependencies", "impact-analysis", "refactoring", "developer-tools"]
  category: "developer-tools"
  author: "shiftinbits"
  # Upstream package license (npm @constellationdev/mcp). The gateway runs it as
  # an unmodified child process, which AGPL permits without source obligations.
  license: "AGPL-3.0"
transport:
  # Official Constellation MCP server (npm @constellationdev/mcp, published by
  # ShiftinBits; registry name com.shiftinbits/constellation). Verified
  # 2026-10-19: latest 1.2.11, bin mcp-constellation, stdio transport, Node 20+.
  # Docs: https://docs.constellationdev.io/mcp/
  type: "stdio"
  command: "npx"
  args: ["-y", "@constellationdev/mcp@1.2.11"]
env:
  - name: CONSTELLATION_ACCESS_KEY
    description: "Constellation access key. Create one in your Constellation account (https://docs.constellationdev.io/auth)."
    required: true
    sensitive: true

# No validation/healthProbe block: Constellation documents no standalone
# endpoint to check an access key against. A rejected key surfaces on the first
# code_intel call.

tools:
  - name: code_intel
    description: "Query the code graph with a short JavaScript program: find symbols and definitions, trace callers and callees, map dependencies and dependents, and measure the impact of changing a symbol or file"
    category: code
---

# Constellation MCP Server

Constellation gives a coding agent a map of a codebase: where a symbol is
defined, who calls it, what a file depends on, and what breaks if it changes.
It answers from a knowledge graph built from code metadata, so no source code
leaves your environment.

## How it works

1. Index a repository with the Constellation CLI (`constellation init`,
   `constellation auth`, `constellation index`). The CLI uploads structural
   metadata only: functions, classes, imports, calls and references.
2. The repository root gets a `constellation.json` that names the project.
3. The agent calls `code_intel` with `cwd` set to that repository root. The
   server reads `constellation.json` and the current git branch from there.

Because `code_intel` reads the project from a checkout, it works where the
repository is checked out, such as a code session or a self-hosted runner. An
agent with no checkout gets an error naming the missing project root.

## Setup

1. Create a Constellation account at [constellationdev.io](https://constellationdev.io).
2. Index each repository you want agents to understand with the Constellation CLI.
3. Create an access key and add it as `CONSTELLATION_ACCESS_KEY` in the MCP
   connection setup.

## Key features

- **Symbol search and definitions** across every indexed file.
- **Callers, callees and dependents**, including indirect ones a text search misses.
- **Impact analysis** before a rename, refactor or deletion.
- **Branch isolation**: each git branch keeps its own code graph.
