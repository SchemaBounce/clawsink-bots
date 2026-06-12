---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: code-sandbox
  displayName: "Code Sandbox"
  version: "1.0.0"
  description: "Sandboxed coding sessions running Claude Code in per-workspace Kubernetes Job sandboxes. Create a session against a repo, execute a prompt, review the diff, and push behind an approval gate."
  tags: ["coding", "implementation", "claude-code", "sandbox", "pull-requests", "managed"]
  category: "ai-memory"
  author: "schemabounce"
  license: "MIT"
transport:
  type: "streamable-http"
  url: "${CODE_SANDBOX_MCP_URL}/mcp"
env:
  - name: CODE_SANDBOX_MCP_URL
    description: "SchemaBounce-managed code-session service URL. Injected by the platform; never customer-provided."
    required: true
  - name: REPO_CLONE_TOKEN
    description: "Optional Git PAT override. Leave blank to use your connected GitHub (Settings -> Git Connections)."
    required: false
    sensitive: true
tools:
  - name: code_session_create
    description: "Provision a sandboxed Kubernetes Job, clone the target repository, and start a coding session. Accepts repo, base_branch, engine, prompt, model, and max_budget_usd."
    category: session
  - name: code_session_execute
    description: "Send a follow-up prompt to a running session, or resume a session that is awaiting input"
    category: session
  - name: code_session_status
    description: "Poll the current lifecycle state of a code session (pending through completed, failed, or cancelled)"
    category: session
  - name: code_session_result
    description: "Get the final session output: summary, files changed, test results, and token/credit usage"
    category: session
  - name: code_session_diff
    description: "Get the git diff of all changes made inside the session sandbox"
    category: session
  - name: code_session_push
    description: "Push session changes to a feature branch and optionally open a PR. Agent-initiated pushes require human approval via the Inbox."
    category: session
  - name: code_session_cancel
    description: "Cancel an active session, tear down the sandbox Job, and reclaim resources"
    category: session
---

# Code Sandbox

SchemaBounce's hosted coding agent. The platform runs the genuine Claude Code CLI inside a per-workspace Kubernetes Job sandbox and exposes it as a remote MCP service. Bots (and humans, through agents) create a session against a Git repository, describe the work, watch progress, review the diff, and push the result to a feature branch.

This server supersedes the retired `tools/codex` preview manifest. The 7-tool adapter surface is carried forward unchanged; the backing service is live infrastructure, not a preview shape.

## Session Lifecycle

`code_session_create` accepts `{repo, base_branch, engine?, prompt, model?, max_budget_usd?}` and returns a session ID. From there the session moves through these states (reported by `code_session_status`):

1. **pending**: request accepted, waiting for sandbox capacity
2. **provisioning**: the per-workspace Kubernetes Job is being created
3. **cloning**: the target repository is cloned at `base_branch` into `/workspace`
4. **running**: the engine is executing the prompt; tests run inside the session
5. **awaiting_approval**: the session asked to push or open a PR and is parked until a human approves it in the Inbox
6. **awaiting_resume**: the session paused for more input; send a follow-up with `code_session_execute`
7. **completed** / **failed** / **cancelled**: terminal states. `code_session_result` returns the summary, file list, and test output; `code_session_diff` returns the full diff.

Sessions are single-purpose: one repo, one branch, one body of work. Create a new session for unrelated work rather than reusing one.

## Sandbox Isolation

- Each session runs in an ephemeral Kubernetes Job scoped to the workspace. The Job is deleted when the session ends.
- The filesystem is writable only inside `/workspace` (the cloned repo). There is no host access and no access to other workspaces.
- Network egress is HTTPS only: package registries, the Git remote, and the model API. No raw TCP, no private-network reach.
- Repo credentials enter the sandbox as short-lived session secrets and are never written to disk or logs.

## Engines

| Engine | Status | Notes |
| --- | --- | --- |
| `claude-code` | GA (v1) | The default. Genuine Claude Code CLI; supports model selection via the `model` parameter. |
| `codex` | Planned | Reserved engine value. Sessions created with it are rejected until the engine ships. |

## Auth Modes

Two ways to pay for the model tokens a session burns:

- **Platform credits (default).** Sessions are metered against the workspace credit balance, the same ledger as every other managed-inference feature. Cost shows up per-agent in the Usage and Cost tab. `max_budget_usd` caps a single session's spend.
- **Personal Claude subscription token (optional).** A user can paste a subscription token into their user settings. They generate it themselves by running `claude setup-token` on their own machine; SchemaBounce never runs a Claude OAuth flow and never sees the user's Anthropic password. Claude subscriptions include a monthly Agent SDK allowance of roughly $20 to $200 depending on plan. When the allowance is exhausted mid-month, sessions continue on workspace credits.

`REPO_CLONE_TOKEN` is separate from billing auth: it is an optional Git PAT override for cloning. Most workspaces leave it blank and the platform bridges the token from the connected GitHub in Settings -> Git Connections.

## Approval Gates

`code_session_push` from an agent-initiated session does not push directly. It escalates to the workspace Inbox with the diff, the target branch, and the session summary; the push (and any PR creation) happens only after a human approves. Human-initiated sessions can be configured to push without the gate. Merging is always human-only; no session ever merges a PR.

## Setup

1. Requires **Starter tier or above**.
2. Connect GitHub under Settings -> Git Connections (or set `REPO_CLONE_TOKEN` to override with a PAT).
3. Ensure the workspace has a positive credit balance, or paste a personal Claude subscription token in user settings.
4. `CODE_SANDBOX_MCP_URL` is injected by the platform. Customers never set it.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/code-sandbox"
    reason: "Shared coding sessions for engineering bots"
    config:
      default_repo: "your-org/your-repo"
      default_branch: "development"
```

Concurrent-session caps are applied per tier by the platform; workspaces can lower them based on credit budget.

## Which Bots Depend on This

- **coding-agent** (required): the dedicated implementer; every run that writes code goes through a session here
- **software-architect** (optional): spawns sessions when an implementation plan calls for code
- **documentation-writer** (optional): spawns sessions for documentation file edits

## Notes

Generated code may be subject to third-party open source licenses; review diffs before merging.
