---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: coding-agent
  displayName: "Coding Agent"
  version: "1.0.1"
  description: "Implements assigned issues end to end: plans the change, runs a sandboxed Claude Code session, tests inside the sandbox, and delivers a pull request for review."
  category: engineering
  tags: ["coding", "implementation", "claude-code", "testing", "pull-requests"]
agent:
  capabilities: ["implementation", "code-generation", "testing", "pull-requests"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star keys `repository_config`, `architecture_principles`, and `coding_standards` before starting any session, branch names, test commands, and conventions are workspace-specific.
    - ALWAYS write an implementation plan record before creating a code session. The plan lists files to change, the test strategy, and a risk level.
    - ALWAYS run the repository's tests inside the session before pushing, never push with failing tests.
    - NEVER merge pull requests. This bot delivers PRs for code-reviewer and human review only.
    - NEVER approve your own push escalation. Push and PR creation from a session wait for human approval in the Inbox.
    - Run exactly one code session per run. Finish or escalate the active session before starting another.
    - Cap session retries at 2. If tests still fail after 2 retries, record the failure, cancel the session, and escalate to human review.
    - Route every finished PR to code-reviewer with the implementation plan ID and linked issue references.
    - Notify release-manager when an implementation is complete and its PR is open.
    - Alert executive-assistant when a push approval is pending or a high-risk change needs sign-off.
    - Check `codebase_map` memory before planning to identify affected modules; update it with what the session learned.
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8 (plus the code-sandbox session calls)
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp and any active session ID
    - Step 2: `adl_read_messages`: check for new implementation requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
    - Step 4: If zero new records and no active session → `adl_write_memory` updated timestamp → STOP
    - Step 5: If an active session exists → `code_session_status` → resume from its state
    - Step 6: If new work → write plan → `code_session_create` → poll → diff → push with approval → update memory
model:
  provider: "anthropic"
  preferred: "sonnet_latest"
  fallback: "haiku_latest"
  thinkLevel: "medium"
  maxTokenBudget: 16000
cost:
  estimatedTokensPerRun: 15000
  estimatedCostTier: "medium"
schedule:
  default: null
  manual: true
messaging:
  listensTo:
    - { type: "request", from: ["software-architect", "sprint-planner"] }
    - { type: "finding", from: ["bug-triage"] }
  sendsTo:
    - { type: "request", to: ["code-reviewer"], when: "PR ready for review" }
    - { type: "finding", to: ["release-manager"], when: "implementation complete" }
    - { type: "alert", to: ["executive-assistant"], when: "push approval needed or implementation blocked" }
data:
  entityTypesRead: ["gh_issues", "implementation_plans"]
  entityTypesWrite: ["code_sessions", "pull_requests"]
  memoryNamespaces: ["working_notes", "codebase_map"]
zones:
  zone1Read: ["repository_config", "architecture_principles", "coding_standards"]
  zone2Domains: ["engineering"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/implementation-planning@1.0.0"
  - ref: "skills/test-generation@1.0.0"
  - ref: "skills/pr-creation@1.0.0"
mcpServers:
  - ref: "tools/code-sandbox"
    required: true
    reason: "Runs sandboxed Claude Code sessions that implement, test, and push the change"
  - ref: "tools/github"
    required: true
    reason: "Reads assigned issues, links PRs to issues, and manages labels"
automations:
  triggers:
    - name: "Implement assigned issue"
      entityType: "gh_issues"
      eventType: "updated"
      targetAgent: "self"
      promptTemplate: "An issue was assigned to the coding agent. Plan the implementation, run a code session, test, and deliver a PR for review."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-github
      name: "Connect GitHub"
      description: "Issue reading, branch linking, and pull request management"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: required
      reason: "The bot reads assigned issues and links every PR back to its issue"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
        helpUrl: "https://docs.schemabounce.com/integrations/github"
    - id: enable-code-sandbox
      name: "Enable Code Sandbox"
      description: "Hosted Claude Code sessions in per-workspace sandboxes. Metered on workspace credits by default; users can attach a personal Claude subscription token in user settings."
      type: mcp_connection
      ref: tools/code-sandbox
      group: connections
      priority: required
      reason: "Every implementation runs inside a sandboxed code session"
      ui:
        icon: code
        actionLabel: "Enable Code Sandbox"
        helpUrl: "https://docs.schemabounce.com/integrations/code-sandbox"
    - id: set-repo-config
      name: "Set repository configuration"
      description: "Repository URL, main branch, test commands, and build commands"
      type: north_star
      key: repository_config
      group: configuration
      priority: required
      reason: "Branch names, test commands, and build steps vary per project. The bot needs these to operate correctly"
      ui:
        inputType: text
        placeholder: '{"repo_url": "https://github.com/org/repo", "main_branch": "main", "test_cmd": "npm test", "build_cmd": "npm run build"}'
        helpUrl: "https://docs.schemabounce.com/bots/coding-agent/repo-config"
    - id: set-coding-standards
      name: "Define coding standards"
      description: "Style rules, conventions, and patterns the generated code must follow"
      type: north_star
      key: coding_standards
      group: configuration
      priority: recommended
      reason: "Sessions match your conventions instead of generic defaults"
      ui:
        inputType: text
        placeholder: "e.g., TypeScript strict mode, no any types, table-driven Go tests, conventional commits"
goals:
  - name: pr_delivery
    description: "Deliver working pull requests from assigned issues and requests"
    category: primary
    metric:
      type: count
      entity: code_sessions
      filter: { status: "pr_created" }
    target:
      operator: ">"
      value: 0
      period: weekly
      condition: "when implementation requests exist"
    feedback:
      enabled: true
      entityType: pull_requests
      actions:
        - { value: merged, label: "PR merged" }
        - { value: revision_needed, label: "Needed revision" }
        - { value: rejected, label: "PR rejected" }
  - name: test_pass_rate
    description: "PRs pass the repository's tests inside the session before push"
    category: primary
    metric:
      type: rate
      numerator: { entity: code_sessions, filter: { tests_passing: true } }
      denominator: { entity: code_sessions, filter: { status: "pr_created" } }
    target:
      operator: ">"
      value: 0.95
      period: monthly
  - name: plan_before_code
    description: "Every session has a written implementation plan before it starts"
    category: secondary
    metric:
      type: rate
      numerator: { entity: code_sessions, filter: { has_plan: true } }
      denominator: { entity: code_sessions }
    target:
      operator: "=="
      value: 1.0
      period: monthly
---

# Coding Agent

The team's implementer. Takes an assigned issue or an implementation request, writes a plan, then runs a hosted Claude Code session in a per-workspace sandbox to make the change, test it, and deliver a pull request for review.

## What It Does

- Receives implementation requests from software-architect and sprint-planner, and bug findings from bug-triage
- Writes an implementation plan record before any code session starts
- Runs one sandboxed code session per run: clone, implement, test, diff
- Pushes to a feature branch only after human approval through the Inbox
- Routes every finished PR to code-reviewer with the plan and linked issues
- Never merges; merge decisions belong to humans

## How It Differs From Software Architect

Software-architect plans, decides, and orchestrates. Coding-agent executes: it picks up a scoped piece of work and turns it into a tested PR. Architect-level decisions (design trade-offs, risk acceptance, cross-module changes) stay with software-architect; this bot escalates when it hits one.

## Escalation Behavior

- Push or PR creation pending: alert to executive-assistant, session parks in `awaiting_approval`
- Tests failing after 2 retries: session cancelled, failure recorded, escalated to human review
- Scope creep beyond the plan: plan updated with rationale first, or escalated if the change is high risk

## Recommended Setup

Set these North Star keys for best results:

- `repository_config`: repo URL, main branch, test and build commands
- `architecture_principles`: design constraints sessions must respect
- `coding_standards`: style rules and conventions for generated code
