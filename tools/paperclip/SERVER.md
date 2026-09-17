---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: paperclip
  displayName: "Paperclip"
  version: "1.0.0"
  description: "Paperclip issues, agents, goals, approvals, documents, and execution workspaces"
  tags: ["paperclip", "orchestration", "issues", "agents", "approvals"]
  category: "project-issue"
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@paperclipai/mcp-server@2026.831.1"]
env:
  - name: PAPERCLIP_API_URL
    description: "Base URL of the reachable Paperclip instance (self-hosted, so no default)"
    required: true
    sensitive: false
  - name: PAPERCLIP_API_KEY
    description: "Paperclip agent API key used for authenticated requests"
    required: true
    sensitive: true
  - name: PAPERCLIP_COMPANY_ID
    description: "Default Paperclip company ID for company-scoped tools"
    required: true
    sensitive: false
  - name: PAPERCLIP_AGENT_ID
    description: "Paperclip agent ID used for issue checkout"
    required: true
    sensitive: false
  - name: PAPERCLIP_RUN_ID
    description: "Heartbeat run ID. Injected automatically by the hosted worker for every dispatched run (see openclaw-runtime paperclipMCPRuntimeEnv) so mutating requests stay attributable. Never set manually in connection config."
    required: false
    sensitive: false

# paperclipMe takes no arguments and only reads, so it safely proves the
# API key and company/agent IDs resolve against the configured instance.
validation:
  tool:
    name: paperclipMe

tools:
  - name: connections_search
    description: "Search run-scoped Paperclip connections"
    category: connections
  - name: connection_request
    description: "Request access to a run-scoped Paperclip connection"
    category: connections
  - name: paperclipMe
    description: "Get the authenticated Paperclip actor"
    category: agents
  - name: paperclipInboxLite
    description: "List the current agent's compact assignment inbox"
    category: issues
  - name: paperclipListAgents
    description: "List agents in a Paperclip company"
    category: agents
  - name: paperclipGetAgent
    description: "Get one Paperclip agent"
    category: agents
  - name: paperclipListIssues
    description: "List and filter company issues"
    category: issues
  - name: paperclipGetIssue
    description: "Get an issue by ID or identifier"
    category: issues
  - name: paperclipGetHeartbeatContext
    description: "Get compact heartbeat context for an issue"
    category: issues
  - name: paperclipListComments
    description: "List issue comments"
    category: issues
  - name: paperclipGetComment
    description: "Get one issue comment"
    category: issues
  - name: paperclipListIssueApprovals
    description: "List approvals linked to an issue"
    category: approvals
  - name: paperclipListDocuments
    description: "List documents attached to an issue"
    category: documents
  - name: paperclipGetDocument
    description: "Get one issue document"
    category: documents
  - name: paperclipListDocumentRevisions
    description: "List revisions of an issue document"
    category: documents
  - name: paperclipListProjects
    description: "List projects in a company"
    category: projects
  - name: paperclipGetProject
    description: "Get one Paperclip project"
    category: projects
  - name: paperclipGetIssueWorkspaceRuntime
    description: "Get an issue's execution workspace and service URLs"
    category: workspaces
  - name: paperclipWaitForIssueWorkspaceService
    description: "Wait for an issue workspace service to become ready"
    category: workspaces
  - name: paperclipListGoals
    description: "List company goals"
    category: goals
  - name: paperclipGetGoal
    description: "Get one company goal"
    category: goals
  - name: paperclipListApprovals
    description: "List company approvals"
    category: approvals
  - name: paperclipGetApproval
    description: "Get one approval"
    category: approvals
  - name: paperclipGetApprovalIssues
    description: "List issues linked to an approval"
    category: approvals
  - name: paperclipListApprovalComments
    description: "List comments on an approval"
    category: approvals
  - name: paperclipCreateIssue
    description: "Create a Paperclip issue"
    category: issues
  - name: paperclipUpdateIssue
    description: "Update a Paperclip issue and its status"
    category: issues
  - name: paperclipCheckoutIssue
    description: "Check out an issue for an agent"
    category: issues
  - name: paperclipReleaseIssue
    description: "Release an issue checkout"
    category: issues
  - name: paperclipAddComment
    description: "Add a comment to an issue"
    category: issues
  - name: paperclipSuggestTasks
    description: "Create a task-suggestion interaction"
    category: interactions
  - name: paperclipAskUserQuestions
    description: "Ask the user structured questions on an issue"
    category: interactions
  - name: paperclipRequestConfirmation
    description: "Request user confirmation on an issue"
    category: interactions
  - name: paperclipRequestCheckboxConfirmation
    description: "Request checkbox confirmation on an issue"
    category: interactions
  - name: paperclipUpsertIssueDocument
    description: "Create or update an issue document"
    category: documents
  - name: paperclipRestoreIssueDocumentRevision
    description: "Restore an earlier issue document revision"
    category: documents
  - name: paperclipControlIssueWorkspaceServices
    description: "Start, stop, or restart issue workspace services"
    category: workspaces
  - name: paperclipCreateApproval
    description: "Create a board approval request"
    category: approvals
  - name: paperclipLinkIssueApproval
    description: "Link an approval to an issue"
    category: approvals
  - name: paperclipUnlinkIssueApproval
    description: "Unlink an approval from an issue"
    category: approvals
  - name: paperclipApprovalDecision
    description: "Record an approval decision"
    category: approvals
  - name: paperclipAddApprovalComment
    description: "Add a comment to an approval"
    category: approvals
  - name: paperclipApiRequest
    description: "Call a Paperclip JSON API endpoint under /api"
    category: advanced
---

# Paperclip MCP Server

Connects SchemaBounce agents to a Paperclip company through Paperclip's
official MCP server (`@paperclipai/mcp-server`, pinned to `2026.831.1`), run
by the mcp-gateway as an `npx` stdio child (dec-023).

This is the callback direction for the Hosted Agent Worker contract: the
`@schemabounce/paperclip-adapter` npm package lets Paperclip dispatch a
heartbeat INTO a SchemaBounce agent over A2A; this MCP connection lets that
SchemaBounce agent call back OUT to Paperclip to check out the issue, read
its context, and update its status.

## Which Bots Use This

- Any hosted agent employed as a Paperclip worker through
  `@schemabounce/paperclip-adapter`.

## Setup

1. Create an agent API key in Paperclip for the agent this worker represents.
2. Add a Paperclip connection in the SchemaBounce workspace with:
   - `PAPERCLIP_API_URL`: the reachable base URL of the Paperclip instance
   - `PAPERCLIP_API_KEY`: the agent API key
   - `PAPERCLIP_COMPANY_ID`: the company the worker belongs to
   - `PAPERCLIP_AGENT_ID`: the Paperclip agent represented by the worker
3. Do not set `PAPERCLIP_RUN_ID` yourself. The hosted worker's runtime injects
   it per dispatched heartbeat (openclaw-runtime
   `internal/executor/paperclip_runtime_env.go`, keyed off this server's
   `tools/paperclip` ref) so every mutating call carries the right
   `X-Paperclip-Run-Id` audit attribution.

## Usage

Call `paperclipGetIssue` before changing an assignment. Call
`paperclipCheckoutIssue` before starting work, and treat HTTP 409 as final:
another agent already owns the issue. Add concise progress or blocker
comments with `paperclipAddComment`. Set the issue to done only when the
requested result is complete; otherwise update the status honestly and
release the checkout with `paperclipReleaseIssue` when no more work can be
done. Never retry a 409 checkout. Never expose `PAPERCLIP_API_KEY` in output.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/paperclip"
    reason: "Hosted worker agents check out and update Paperclip issues"
```
