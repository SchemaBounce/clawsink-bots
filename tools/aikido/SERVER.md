---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: aikido
  displayName: "Aikido Security"
  version: "1.0.0"
  description: "Aikido Security code scanning: SAST, secrets detection, and security-issue triage"
  tags: ["aikido", "security", "sast", "secrets", "vulnerability", "appsec"]
  category: "developer-tools"
  author: "aikido"
  # Upstream package license (npm @aikidosec/mcp). The gateway runs it as an
  # unmodified child process, which AGPL permits without source obligations.
  license: "AGPL-3.0"
transport:
  # Official Aikido Security MCP server (npm @aikidosec/mcp, published by
  # AikidoSec). Verified 2026-07-16: latest 1.0.14 (published 2026-07-07),
  # bin aikido-mcp, stdio transport. Pinned like other npm entries.
  # Docs: https://help.aikido.dev/ai-and-dev-tools/aikido-mcp
  type: "stdio"
  command: "npx"
  args: ["-y", "@aikidosec/mcp@1.0.14"]
env:
  # Headless auth path: a Personal Access Token generated in Aikido under
  # Settings -> Integrations -> MCP Server, passed as AIKIDO_API_KEY. The
  # package's alternative browser sign-in flow (aikido_login) cannot complete
  # inside the gateway pod, so the token is required here. Region (EU/US/ME)
  # is resolved from the token; the package reads no region env var
  # (verified against the 1.0.14 dist: only AIKIDO_API_KEY,
  # AIKIDO_MCP_ALL_TOOLS, AIKIDO_DEV_MODE, LOG_LEVEL).
  - name: AIKIDO_API_KEY
    description: "Aikido Personal Access Token. Generate it in Aikido under Settings -> Integrations -> MCP Server."
    required: true
    sensitive: true
  - name: AIKIDO_MCP_ALL_TOOLS
    description: "Set to 'true' to also expose the granular aikido_sast_scan, aikido_secrets_scan, and aikido_iac_scan tools in addition to the default set."
    required: false
    sensitive: false

# No validation/healthProbe block: the MCP Personal Access Token is a
# token type specific to the MCP server (not Aikido's public REST API
# client-credentials flow), and Aikido documents no standalone endpoint to
# verify it against. Credential problems surface on the first tool call.

tools:
  - name: aikido_full_scan
    description: "Scan local code for vulnerabilities (SAST) and hardcoded secrets, returning machine-readable findings"
    category: scanning
  - name: aikido_issues_list
    description: "Retrieve security issues from the Aikido feed, filtered by repos, clouds, VMs, containers, or domains"
    category: triage
  - name: aikido_ignore_issue
    description: "Dismiss a security finding with a documented reason"
    category: triage
  - name: aikido_login
    description: "Start the Aikido browser sign-in flow (not used on this platform; AIKIDO_API_KEY replaces it)"
    category: auth
---

# Aikido Security MCP Server

Provides Aikido Security scanning for bots that write or review code. Agents can run SAST and secrets scans on local code, pull existing findings from the Aikido feed, and triage issues with documented dismissals. Useful as a deterministic security check on every AI-generated change.

## Which Bots Use This

- **code-reviewer** -- Runs a scan on changed files before approving a diff
- **security-analyst** -- Pulls the Aikido issue feed, prioritizes findings, and documents triage decisions

This runs Aikido's official MCP server (`@aikidosec/mcp`, published by AikidoSec) as a stdio child process in the gateway.

## Setup

1. Sign in to Aikido at https://app.aikido.dev (any region: EU, US, or ME)
2. Generate a Personal Access Token under Settings -> Integrations -> MCP Server
3. Add `AIKIDO_API_KEY` in the MCP connection setup
4. Optional: set `AIKIDO_MCP_ALL_TOOLS` to `true` to expose the granular `aikido_sast_scan`, `aikido_secrets_scan`, and `aikido_iac_scan` tools alongside the default set
5. The server starts automatically when a bot that references it runs

The token determines your Aikido region automatically; no region variable is needed.

## Team Usage

Add to your TEAM.md to share a single Aikido server instance across engineering bots:

```yaml
mcpServers:
  - ref: "tools/aikido"
    reason: "Engineering bots run security scans and triage Aikido findings on every change"
```
