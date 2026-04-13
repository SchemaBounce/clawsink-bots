---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: codex
  displayName: "Codex"
  version: "1.0.0"
  description: "Sandboxed OpenAI Codex sessions for implementation, testing, and PRs — billed via workspace credits"
  tags: ["codex", "openai", "coding", "implementation", "testing", "managed"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "streamable-http"
  url: "${CODEX_MCP_URL}/mcp"
env:
  - name: CODEX_MCP_URL
    description: "SchemaBounce-managed Codex service URL (injected by platform; never customer-provided)"
    required: true
  - name: REPO_CLONE_TOKEN
    description: "Git personal access token for cloning the target repository into the sandbox (repo read/write scope)"
    required: true
tools:
  - name: code_session_create
    description: "Provision a sandboxed container and clone a repository"
    category: session
  - name: code_session_execute
    description: "Send a task to the Codex SDK for implementation"
    category: session
  - name: code_session_status
    description: "Poll the current state of a code session"
    category: session
  - name: code_session_result
    description: "Get final output including files changed and test results"
    category: session
  - name: code_session_diff
    description: "Get the git diff of all changes made in the session"
    category: session
  - name: code_session_push
    description: "Push session changes to a feature branch"
    category: session
  - name: code_session_cancel
    description: "Cancel an active session and reclaim resources"
    category: session
---

# Codex MCP Server

Provides sandboxed OpenAI Codex sessions for bots that need to implement code changes, run tests, and create pull requests. This is a **SchemaBounce-managed service** wrapping the [OpenAI Codex SDK](https://developers.openai.com/codex/sdk) — sessions run on provisioned containers that are automatically cleaned up.

## Managed Inference — No API Keys Required

**You do not provide an OpenAI API key.** The underlying Codex SDK runs against SchemaBounce's managed OpenAI service, so sessions are authenticated by the platform. Usage is metered per session (compute time + tokens) and deducted from your workspace's **credit balance**, billed monthly like any other ADL inference under `inferenceMode: managed`.

This architecture is required by OpenAI's terms of use: customers [may not share API keys with third-party applications](https://community.openai.com/t/is-this-allowed-this-bring-your-own-key-usage/161185), so bring-your-own-key is not an option for Codex. The managed path is the only compliant integration.

## Transport

Uses `streamable-http` transport. The SchemaBounce platform provisions isolated containers on demand, each with a cloned repository and a Codex SDK instance. Bots communicate with the service over HTTP rather than spawning a local process.

## Session Lifecycle

1. **Create** — `code_session_create` provisions a container, clones the target repo using `REPO_CLONE_TOKEN`, and returns a session ID.
2. **Execute** — `code_session_execute` sends a task description to the Codex SDK running inside the container. The agent implements the changes autonomously using the default `gpt-5-codex` model.
3. **Poll** — `code_session_status` returns the current state (`provisioning`, `running`, `completed`, `failed`, `cancelled`).
4. **Result** — `code_session_result` returns files changed, test output, and a summary of what was done.
5. **Diff** — `code_session_diff` returns the full git diff of all changes.
6. **Push** — `code_session_push` commits and pushes changes to a feature branch.
7. **Cleanup** — Sessions auto-terminate after 15 minutes of inactivity. Use `code_session_cancel` to reclaim resources early.

## Resource Limits

- 1 active session per bot run
- Maximum 10 minutes per session execution
- 100MB workspace size limit
- Sessions auto-cleanup after 15 minutes of inactivity

## Sandbox & Approval Policies

By default, sessions run with `approval_policy: never` and `sandbox: workspace-write` — the Codex agent has full write access inside the sandboxed container but never touches the host system or external networks other than the cloned repo's Git remote. Escape from the sandbox is not possible; there is no mechanism to execute code outside the provisioned container.

## Which Bots Use This

- **software-architect** — Implements planned changes, runs tests, and pushes feature branches
- **documentation-writer** — Generates and updates documentation from code analysis

This is SchemaBounce's **default coding agent** for bots that need to write code. Other coding-session providers may be added in the future, but Codex (managed) is the current baseline.

## Billing & Credits

- Each session consumes credits roughly proportional to the underlying Codex token usage plus a flat compute surcharge for the sandboxed container.
- Credit cost per session is visible in the workspace **Usage & Cost** tab (per-agent breakdown) and in the audit log for each run.
- The bot will refuse to start a session if the workspace credit balance falls below the session's reserve threshold — no surprise overages.

## Setup

1. Requires **Team tier or above**.
2. Add the following to your workspace secrets:
   - `REPO_CLONE_TOKEN` — a Git personal access token with repo read/write scope for the target repository
3. Ensure your workspace has a positive credit balance. Top up in Workspace Settings → Billing if needed.
4. The service starts automatically when a bot that references it runs. `CODEX_MCP_URL` is injected by the platform — you do **not** configure this manually.

## Team Usage

Add to your `TEAM.md` to share a single Codex service instance across engineering bots:

```yaml
mcpServers:
  - ref: "tools/codex"
    reason: "Engineering bots need sandboxed code sessions for implementation and testing"
    config:
      default_repo: "your-org/your-repo"
      default_branch: "development"
```

## Terms of Use

This MCP server invokes OpenAI's Codex SDK on SchemaBounce's behalf. Usage is subject to both [OpenAI's usage policies](https://openai.com/policies/usage-policies/) and SchemaBounce's own acceptable use policy. Generated code may be subject to third-party open source licenses; review diffs before merging to main.
