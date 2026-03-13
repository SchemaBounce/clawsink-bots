---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: claude-code
  displayName: "Claude Code"
  version: "1.0.0"
  description: "Sandboxed Claude Code sessions for automated code implementation, testing, and PR creation"
  tags: ["claude-code", "coding", "implementation", "testing", "agent-sdk"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "streamable-http"
  url: "${CLAUDE_CODE_SERVICE_URL}/mcp"
env:
  - name: ANTHROPIC_API_KEY
    description: "Anthropic API key for Claude Code sessions"
    required: true
  - name: CLAUDE_CODE_SERVICE_URL
    description: "URL of the SchemaBounce-managed Claude Code service"
    required: true
  - name: REPO_CLONE_TOKEN
    description: "Git token for cloning repositories into sandboxed containers"
    required: true
tools:
  - name: code_session_create
    description: "Provision a sandboxed container and clone a repository"
    category: session
  - name: code_session_execute
    description: "Send a task to the Claude Agent SDK for implementation"
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

# Claude Code MCP Server

Provides sandboxed Claude Code sessions for bots that need to implement code changes, run tests, and create pull requests. This is a SchemaBounce-managed service, not an npm package -- sessions run on provisioned containers that are automatically cleaned up.

## Transport

Unlike stdio-based MCP servers (GitHub, Slack, Stripe), Claude Code uses `streamable-http` transport. The SchemaBounce platform provisions isolated containers on demand, each with a cloned repository and a Claude Agent SDK instance. Bots communicate with the service over HTTP rather than spawning a local process.

## Session Lifecycle

1. **Create** -- `code_session_create` provisions a container, clones the target repo, and returns a session ID.
2. **Execute** -- `code_session_execute` sends a task description to the Claude Agent SDK running inside the container. The agent implements the changes autonomously.
3. **Poll** -- `code_session_status` returns the current state (provisioning, running, completed, failed, cancelled).
4. **Result** -- `code_session_result` returns files changed, test output, and a summary of what was done.
5. **Diff** -- `code_session_diff` returns the full git diff of all changes.
6. **Push** -- `code_session_push` commits and pushes changes to a feature branch.
7. **Cleanup** -- Sessions auto-terminate after 15 minutes of inactivity. Use `code_session_cancel` to reclaim resources early.

## Resource Limits

- 1 active session per bot run
- Maximum 10 minutes per session execution
- 100MB workspace size limit
- Sessions auto-cleanup after 15 minutes of inactivity

## Which Bots Use This

- **software-architect** -- Implements planned changes, runs tests, and pushes feature branches
- **documentation-writer** -- Generates and updates documentation from code analysis

## Setup

1. Requires **Team tier or above**
2. Add the following to your workspace secrets:
   - `ANTHROPIC_API_KEY` -- Your Anthropic API key
   - `CLAUDE_CODE_SERVICE_URL` -- Provided by SchemaBounce when Claude Code is enabled for your workspace
   - `REPO_CLONE_TOKEN` -- A Git personal access token with repo read/write scope
3. The service starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share Claude Code across engineering bots:

```yaml
mcpServers:
  - ref: "tools/claude-code"
    reason: "Engineering bots need sandboxed code sessions for implementation and testing"
    config:
      default_repo: "your-org/your-repo"
      default_branch: "development"
```
