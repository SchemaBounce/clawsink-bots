---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: software-architect
  displayName: "Software Architect"
  version: "1.0.10"
  description: "Receives tasks and GitHub issues, plans implementations, spawns sandboxed code sessions to write and test code, and creates pull requests for review."
  category: engineering
  tags: ["coding", "implementation", "architecture", "pull-requests", "testing"]
agent:
  capabilities: ["implementation", "architecture", "code-generation", "testing"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star keys `repository_config` and `architecture_principles` before planning any implementation, branch names, test commands, and design constraints are workspace-specific.
    - ALWAYS produce a structured implementation plan before spawning any code session. The plan must include file changes, risk assessment, and test strategy.
    - ALWAYS run tests in the code session before creating a PR, never create a PR with failing tests.
    - NEVER merge PRs. This bot creates PRs for human and code-reviewer review only.
    - NEVER modify files outside the scope of the implementation plan, if scope creep is needed, update the plan first and record the rationale.
    - For high-risk implementations, alert executive-assistant with plan details and STOP, do not proceed until approval is received.
    - Route completed PRs to code-reviewer for review, include the implementation plan ID and linked issues in the PR description.
    - Notify documentation-writer when an implementation changes APIs, interfaces, or user-facing behavior.
    - Notify release-manager when an implementation is complete and the PR is merged.
    - When receiving findings from bug-triage or tech-debt-tracker, check `codebase_map` memory to identify affected modules before planning.
    - Store architecture decisions in `architecture_patterns` memory, reference prior decisions to maintain consistency across implementations.
    - Limit code session retries to 2 attempts, if tests still fail after 2 retries, record the failure and escalate to human review.
  toolInstructions: |
    ## Tool Usage: Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state`: get last run timestamp
    - Step 2: `adl_read_messages`: check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}`. ONE query for all new records
    - Step 4: If zero new records → `adl_write_memory` updated timestamp → STOP
    - Step 5: If new records → process deltas → write findings → update memory
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 16000
cost:
  estimatedTokensPerRun: 15000
  estimatedCostTier: "medium"
schedule: null
messaging:
  listensTo:
    - { type: "request", from: ["product-owner", "sprint-planner"] }
    - { type: "finding", from: ["code-reviewer", "bug-triage", "tech-debt-tracker"] }
  sendsTo:
    - { type: "request", to: ["code-reviewer"], when: "PR ready for review" }
    - { type: "finding", to: ["release-manager"], when: "implementation complete" }
    - { type: "finding", to: ["documentation-writer"], when: "docs need updating" }
    - { type: "alert", to: ["executive-assistant"], when: "high-risk implementation requires approval" }
data:
  entityTypesRead: ["gh_issues", "review_findings", "architecture_decisions"]
  entityTypesWrite: ["implementation_plans", "code_sessions", "architecture_decisions"]
  memoryNamespaces: ["working_notes", "architecture_patterns", "codebase_map"]
zones:
  zone1Read: ["repository_config", "architecture_principles"]
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
# tools/codex was declared here previously but its backend MCP service
# is not deployed and the tool is not in the runtime registry — silent
# no-op when activated. Stripped 2026-04-27 per the no-vaporware sweep.
# Re-add once the codex backend ships and the SERVER.md graduates from
# preview.
  - ref: "tools/github"
    required: true
    reason: "Creates branches, pull requests, and manages issues"
  - ref: "tools/exa"
    required: false
    reason: "Research library documentation, API references, and best practices for implementation decisions"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse documentation sites and Stack Overflow for technical reference during implementation"
  - ref: "tools/composio"
    required: false
    reason: "Connect to project management and CI/CD tools for implementation tracking"
presence:
  web:
    browsing: true
    search: true
requirements:
  minTier: "team"
setup:
  steps:
    - id: connect-github
      name: "Connect GitHub"
      description: "Links your GitHub repository for issue reading, branch creation, and PR management"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: required
      reason: "Primary interface for reading issues, creating branches, and submitting pull requests"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
        helpUrl: "https://docs.schemabounce.com/integrations/github"
    - id: enable-codex
      name: "Enable Codex (Preview, coming soon)"
      description: "Confirms workspace credit balance and provisions the sandboxed Codex service. Preview. The backend service is not yet live; this setup step will succeed once the Codex managed-inference service is deployed."
      type: mcp_connection
      ref: tools/codex
      group: connections
      priority: recommended
      reason: "Intended default coding agent, will be required once the backend ships; optional until then"
      ui:
        icon: code
        actionLabel: "Enable Codex"
        helpUrl: "https://docs.schemabounce.com/integrations/codex"
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
        helpUrl: "https://docs.schemabounce.com/bots/software-architect/repo-config"
    - id: set-architecture-principles
      name: "Define architecture principles"
      description: "Coding standards, design patterns, and architectural constraints"
      type: north_star
      key: architecture_principles
      group: configuration
      priority: recommended
      reason: "Guides implementation decisions and ensures consistency across code sessions"
      ui:
        inputType: text
        placeholder: '{"language": "TypeScript", "patterns": ["clean-architecture"], "testing": "jest"}'
    - id: import-issues
      name: "Import GitHub issues"
      description: "Existing issues give the bot work items to plan and implement"
      type: data_presence
      entityType: gh_issues
      minCount: 1
      group: data
      priority: recommended
      reason: "The bot needs issues or tasks to begin planning implementations"
      ui:
        actionLabel: "Sync Issues"
        emptyState: "No issues found. Create GitHub issues or send requests from product-owner."
goals:
  - name: pr_delivery
    description: "Deliver working pull requests from assigned issues"
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
      entityType: implementation_plans
      actions:
        - { value: merged, label: "PR merged" }
        - { value: revision_needed, label: "Needed revision" }
        - { value: rejected, label: "PR rejected" }
  - name: test_pass_rate
    description: "PRs should pass all tests before submission"
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
    description: "Every implementation must have a structured plan before coding begins"
    category: secondary
    metric:
      type: rate
      numerator: { entity: code_sessions, filter: { has_plan: true } }
      denominator: { entity: code_sessions }
    target:
      operator: "=="
      value: 1.0
      period: monthly
  - name: architecture_knowledge
    description: "Build and maintain architecture decision records for consistency"
    category: health
    metric:
      type: count
      source: memory
      namespace: architecture_patterns
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Software Architect

Orchestrates the full implementation lifecycle from GitHub issue to pull request. Reads tasks from product-owner, sprint-planner, and issue trackers, then plans, implements, tests, and delivers code as reviewable PRs.

## What It Does

- Receives implementation requests from product-owner, sprint-planner, and findings from code-reviewer, bug-triage, and tech-debt-tracker
- Orchestrates three sub-agents in isolated sessions: **planner** -> (code session) -> **test-fixer** (if needed) -> **reviewer**
- Planner analyzes the issue and produces a structured implementation plan with risk assessment
- Code sessions execute the implementation in a sandboxed environment
- Test-fixer analyzes failures and produces fix instructions for retry (max 2 retries)
- Reviewer performs a quick self-check of the diff before PR creation
- Creates pull requests with structured descriptions, linked issues, and labels
- Never merges code -- always creates PRs for human and code-reviewer review

## Risk-Based Escalation

| Risk Level | Behavior |
|-----------|----------|
| Low | Auto-proceed: implement, test, create PR |
| Medium | Implement, test, create PR with review-required label |
| High | Alert executive-assistant with plan details, STOP and wait for approval |

## MCP Servers

- **codex** (preview, optional today) -- Intended default coding agent. Will spawn sandboxed OpenAI Codex sessions for implementation, billed via workspace credits (managed inference — no customer API key). Provides (once the backend ships) `code_session_create`, `code_session_execute`, `code_session_status`, `code_session_result`, `code_session_diff`, `code_session_push`, and `code_session_cancel` tools. See `tools/codex/SERVER.md` for the preview status and what still needs to be built.
- **github** (required) -- Creates branches, pull requests, and manages issues. Provides `create_pull_request`, `list_issues`, `add_labels`, and `link_issue` tools.

## Recommended North Star Keys

Set these in your workspace's North Star zone for best results:

- `repository_config` -- Repository URL, main branch name, test commands, and build commands
- `architecture_principles` -- Coding standards, design patterns, and architectural constraints
