---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: constellation
  displayName: "Constellation"
  version: "1.1.0"
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
  # The server reads its project from a constellation.json at the root of a git
  # checkout, found through the cwd argument of every code_intel call. It never
  # reads source files: queries go to the Constellation API by project id and
  # branch. So the session gets a folder holding only an empty .git and a
  # constellation.json built from this connection's settings, and cwd is always
  # that folder. The agent never chooses a path.
  workdir:
    files:
      - path: .git
        dir: true
      - path: constellation.json
        json:
          projectId: "${CONSTELLATION_PROJECT_ID}"
          branch: "${CONSTELLATION_BRANCH:-main}"
          # Used only to check the file extension of a filePath in a query.
          languages:
            typescript: {fileExtensions: [".ts", ".tsx", ".mts", ".cts"]}
            javascript: {fileExtensions: [".js", ".jsx", ".mjs", ".cjs"]}
            go: {fileExtensions: [".go"]}
            python: {fileExtensions: [".py"]}
            java: {fileExtensions: [".java"]}
            kotlin: {fileExtensions: [".kt", ".kts"]}
            csharp: {fileExtensions: [".cs"]}
            ruby: {fileExtensions: [".rb"]}
            php: {fileExtensions: [".php"]}
            rust: {fileExtensions: [".rs"]}
            swift: {fileExtensions: [".swift"]}
            c: {fileExtensions: [".c", ".h"]}
            cpp: {fileExtensions: [".cc", ".cpp", ".cxx", ".hpp", ".hh"]}
    toolArgs:
      code_intel:
        cwd: "${WORKDIR}"
env:
  - name: CONSTELLATION_ACCESS_KEY
    description: "Constellation access key. Create one in your Constellation account (https://docs.constellationdev.io/auth)."
    required: true
    sensitive: true
  - name: CONSTELLATION_PROJECT_ID
    description: "The projectId from the repository's constellation.json, for example proj:0123abcd. One connection covers one repository."
    required: true
    sensitive: false
  - name: CONSTELLATION_BRANCH
    description: "The indexed branch agents should query. Leave empty for main."
    required: false
    sensitive: false

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
2. The repository root gets a `constellation.json` that names the project and
   the indexed branch.
3. Add one Constellation connection per repository, with that project id. The
   agent queries the repository through `code_intel`; it does not need a
   checkout and never passes a path.

## Setup

1. Create a Constellation account at [constellationdev.io](https://constellationdev.io).
2. Index each repository you want agents to understand with the Constellation CLI.
3. Create an access key.
4. Add a Constellation connection with the access key and the `projectId` from
   the repository's `constellation.json`. Set the branch if agents should query
   a branch other than `main`; that branch must be indexed.

## Key features

- **Symbol search and definitions** across every indexed file.
- **Callers, callees and dependents**, including indirect ones a text search misses.
- **Impact analysis** before a rename, refactor or deletion.
- **Branch isolation**: each git branch keeps its own code graph.
