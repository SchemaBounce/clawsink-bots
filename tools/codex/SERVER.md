---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: codex
  displayName: "Codex (Preview)"
  version: "0.1.0"
  description: "[Preview] Sandboxed OpenAI Codex sessions for implementation. Managed inference, backend service not yet deployed"
  tags: ["codex", "openai", "coding", "implementation", "managed", "preview"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "streamable-http"
  url: "${CODEX_MCP_URL}/mcp"
env:
  - name: CODEX_MCP_URL
    description: "SchemaBounce-managed Codex service URL (injected by platform; never customer-provided). Not yet deployed, enabling this bot will fail until the backend service is live."
    required: true
  - name: REPO_CLONE_TOKEN
    description: "Git personal access token with repo read/write scope. Used by the sandboxed container to clone the target repo; kept separate from the tools/github MCP token because the two run in different trust contexts (see README body)."
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

# Codex MCP Server — Preview

> ⚠️ **Preview / Not Yet Deployed.** This manifest describes the intended shape of a SchemaBounce-managed MCP service that wraps the [OpenAI Codex SDK](https://developers.openai.com/codex/sdk). The backend service is **not yet built** — enabling this tool in a workspace today will fail to connect because `CODEX_MCP_URL` has no running target. The manifest is landed early so bots can declare their dependency shape, but the MCP server implementation, the managed-inference billing hook, and the sandbox container adapter all still need to be built.
>
> **Do not advertise this as a working feature to customers until the backend service is live.**

## Intent

Once implemented, this MCP server will provide sandboxed coding sessions to bots that need to write and test code (`software-architect`, `documentation-writer`). The SchemaBounce platform will provision isolated containers on demand, each running a Codex SDK instance against the target repository.

## Managed Inference — Why Not BYOK?

Customers will **not** provide an OpenAI API key. This is non-negotiable: OpenAI staff explicitly stated in the [developer community](https://community.openai.com/t/is-this-allowed-this-bring-your-own-key-usage/161185) that users "are not permitted to share their API keys with others, including via bring-your-own-key applications." The only compliant integration path for Codex inside a third-party SaaS is for SchemaBounce to use its own OpenAI credentials and monetize the wrapping value.

**Note:** One forum response from an OpenAI employee is not a substitute for formal legal review. Before this moves from preview to GA, SchemaBounce should get written confirmation from OpenAI's business / legal team that the managed-inference-for-Codex pattern is acceptable under current business terms.

## Transport

Uses `streamable-http` transport. When the backend service is deployed, it will provision isolated containers on demand; bots will communicate with the service over HTTP rather than spawning a local process.

## Session Lifecycle (Adapter Surface)

The 7 tools below are the **SchemaBounce adapter surface**, not raw Codex SDK methods. The underlying SDK exposes a simpler `thread.run(prompt)` API; this adapter splits that into explicit create / execute / poll / result / diff / push phases so long-running sessions can be tracked across the agentic loop. If the adapter's actual implementation ends up diverging from this shape, this list is the source of truth for what bots will expect.

1. **Create** — `code_session_create` provisions a container and clones the target repo using `REPO_CLONE_TOKEN`.
2. **Execute** — `code_session_execute` sends the task description to the Codex SDK inside the container. Uses the platform-configured Codex model (default TBD — `codex-mini-latest` is the SDK's CLI default but the production choice will be set by SchemaBounce based on cost/quality trade-offs).
3. **Poll** — `code_session_status` returns `provisioning` / `running` / `completed` / `failed` / `cancelled`.
4. **Result** — `code_session_result` returns files changed, test output, summary.
5. **Diff** — `code_session_diff` returns the full git diff.
6. **Push** — `code_session_push` commits and pushes to a feature branch.
7. **Cleanup** — Auto-terminate after 15 minutes of inactivity. `code_session_cancel` for early release.

## Resource Limits (target)

These are design targets for the backend implementation, not enforced by this manifest:

- 1 active session per bot run
- Maximum 10 minutes per session execution
- 100 MB workspace size limit
- Auto-cleanup after 15 minutes of inactivity

## Sandbox & Approval Policies (target)

Target defaults when the service ships: `approval_policy: never`, `sandbox: workspace-write`. The agent will have full write access inside the sandboxed container but never touch the host system or any network other than the cloned repo's Git remote. These are Codex SDK configuration knobs — the backend service has to set them explicitly; they are not enforced by this manifest.

## Which Bots Depend on This

- **software-architect** — would spawn coding sessions for issue implementation
- **documentation-writer** — would spawn coding sessions for documentation file edits

The manifest pins `required: false` on both bots today so they can still provision in preview workspaces that haven't enabled Codex. When the backend ships and GA is declared, bump to `required: true` in a follow-up commit.

## Billing & Credits (planned, not wired)

Once the backend is built, usage will route through SchemaBounce's existing managed-inference credit ledger (`inferenceMode: managed` in the ADL, per `project_managed_inference.md`). The intent is:

- Per-session cost ≈ underlying Codex token usage + flat compute surcharge for the sandboxed container
- Credit cost visible in the workspace **Usage & Cost** tab (per-agent)
- Reserve-on-start check; refuse to start if workspace credit balance is below the session reserve

None of this plumbing exists yet. Treat the billing prose in this document as a design intent, not a promise.

## Two Git Tokens — Why?

Bots that use Codex also typically declare `tools/github` (for issue reads, PR creation, labels). That GitHub MCP runs inside the agent's own execution context using its own auth (installation-scoped). The Codex MCP needs a **separate** Git token (`REPO_CLONE_TOKEN`) because the sandboxed container is a different trust boundary: it's a short-lived worker the platform spins up on behalf of the session, and that worker needs its own credential to clone the customer's repo.

This is UX-awkward (two token pastes for what looks like one integration). A better future state is to have the SchemaBounce-managed Codex service exchange a short-lived token via the customer's GitHub App installation, so no second PAT is required. Tracking that as a follow-up — see the issue tracker for the "unified GitHub auth for Codex sandbox" task.

## Setup (once backend ships)

1. Requires **Team tier or above**.
2. Add to workspace secrets: `REPO_CLONE_TOKEN` (Git PAT, repo read/write scope on the target repository).
3. Ensure the workspace has a positive credit balance.
4. `CODEX_MCP_URL` is injected by the platform. Customers never set it.

## Team Usage (once backend ships)

```yaml
mcpServers:
  - ref: "tools/codex"
    reason: "Engineering bots need sandboxed code sessions for implementation and testing"
    config:
      default_repo: "your-org/your-repo"
      default_branch: "development"
```

`max_concurrent_sessions` is intentionally not defaulted here — the platform should apply a tier-based cap, and workspaces can override based on their credit budget.

## Terms of Use

- [OpenAI service terms](https://openai.com/policies/service-terms/)
- [OpenAI business terms](https://openai.com/policies/business-terms)
- [OpenAI usage policies](https://openai.com/policies/usage-policies/)
- [Codex SDK docs](https://developers.openai.com/codex/sdk)
- [BYOK prohibition (OpenAI staff, dev community)](https://community.openai.com/t/is-this-allowed-this-bring-your-own-key-usage/161185)

Generated code may be subject to third-party open source licenses; review diffs before merging.
