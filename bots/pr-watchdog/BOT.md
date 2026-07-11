---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: pr-watchdog
  displayName: "PR Watchdog"
  version: "1.0.1"
  description: "Flags stale and unreviewed pull requests, especially AI-authored ones, and routes them to a human before the review SLA is missed."
  category: engineering
  tags: ["github", "pull-requests", "code-review", "sla", "ai-governance"]
agent:
  capabilities: ["dev_devops", "operations"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star keys `pr_review_sla_hours`, `pr_ai_author_patterns`, and `pr_watchdog_repos` before checking any PR — thresholds, author patterns, and the watched repo list are workspace-specific, never hardcode defaults.
    - ALWAYS list open pull requests across every repository named in `pr_watchdog_repos` before drawing any conclusion — a partial repo list produces a false "all clear".
    - ALWAYS classify a PR's author, and separately every reviewer's login, against `pr_ai_author_patterns` plus anything already learned in `known_ai_authors` memory. A review from a login that matches the AI patterns does not count as human review.
    - NEVER call a GitHub tool that comments, approves, reviews, merges, or closes a pull request or issue. This bot is read-only against GitHub — only `get_*`, `list_*`, and `search_*` tools are permitted. Routing and escalation only.
    - NEVER treat "stale" (past half the SLA window with no human review) the same as "SLA breach" (past the full window). Stale becomes a task-board task. Breach becomes an Inbox escalation.
    - ALWAYS check for an existing open `tasks` record for a PR (entity_id convention below) before creating a new one — update it instead of duplicating.
    - Batch every new SLA breach found in a run into ONE `adl_request_escalation` call — the tool pauses this agent's run until a human responds, so escalating breaches one at a time would silently drop the rest of the run's work. List every breached PR in the escalation summary.
    - If `adl_request_escalation` fails because this agent has no org chart position or supervisor, fall back to writing a `tasks` record with `priority: "critical"` and `"sla-breach"` in `tags`, and note the fallback in that action's receipt.
    - Write exactly one `receipts` record for every task created, task updated, and escalation sent — a sibling dashboard reads this table as the sole audit trail of what this bot did. Never skip it, never batch multiple actions into one receipt.
  toolInstructions: |
    ## Tool Usage
    - Target: 4-7 tool calls per run
    - Step 1: `adl_read_memory` key `last_run_state` — last run timestamp and previously seen PR ids
    - Step 2: `adl_read_messages` — check for requests from other agents
    - Step 3: `list_pull_requests` (state=open) once per repo in `pr_watchdog_repos`
    - Step 4: `get_pull_request_reviews` only for PRs without a cached review verdict in `prw_findings` from a prior run
    - Step 5: `adl_upsert_record` entity_type `tasks` for stale/breached PRs — entity_id convention: `task_pr_{owner}_{repo}_{number}`
    - Step 6: `adl_write_record` entity_type `prw_findings` (one per PR checked this run) and entity_type `receipts` (one per action taken)
    - Step 7: `adl_request_escalation` once per run, batching every new breach

    ### Receipt records (entity_type: receipts)
    One record per action, written with `adl_write_record`:
    - `entity_id`: `receipt_{metric}_{owner}_{repo}_{pr_number}_{ISO-timestamp-no-colons}`
    - `data.kind`: `"receipt"` (constant)
    - `data.metric`: `"stale_pr_detected"` (task created/updated for a stale PR) | `"sla_breach_escalated"` (breach sent to Inbox, or fell back to a critical task) | `"pr_routed"` (an AI-authored PR got its first task-board task this run, distinct from a plain staleness update)
    - `data.value`: hours the PR has been open with no human review (for `stale_pr_detected` / `sla_breach_escalated`), or `1` (for `pr_routed`)
    - `data.unit`: `"hours"` or `"count"` matching `data.value`
    - `data.subject`: the PR's URL
    - `data.occurredAt`: ISO 8601 UTC timestamp of the action (use the `datetime-toolkit` pack's `calculate_date` with a zero offset for a deterministic "now")
    - `data.agentSlug`: `"pr-watchdog"`
model:
  provider: "anthropic"
  preferred: "haiku_latest"
  fallback: "haiku_latest"
  thinkLevel: "low"
  maxTokenBudget: 12000
cost:
  estimatedTokensPerRun: 12000
  estimatedCostTier: "low"
schedule:
  default: "@every 4h"
  recommendations:
    light: "@every 12h"
    standard: "@every 4h"
    intensive: "@every 1h"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["release-manager"], when: "an AI-authored or stale PR crosses the SLA threshold and is escalated" }
data:
  entityTypesRead: ["prw_findings"]
  entityTypesWrite: ["tasks", "receipts", "prw_findings"]
  memoryNamespaces: ["last_run_state", "known_ai_authors"]
zones:
  zone1Read: ["mission", "pr_review_sla_hours", "pr_ai_author_patterns", "pr_watchdog_repos"]
  zone2Domains: ["engineering"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/task-management@1.0.0"
  - ref: "skills/record-monitoring@1.0.0"
toolPacks:
  - ref: "packs/datetime-toolkit@1.0.0"
    reason: "Deterministic hour math for SLA and staleness thresholds, and a reliable current-time source for receipt timestamps — avoids LLM date arithmetic errors."
mcpServers:
  - ref: "tools/github"
    reason: "Reads open PR state, review history, and author identity across connected repositories to detect AI-authored and unreviewed PRs. Never used to comment, approve, merge, or close — grant this agent read-only GitHub tools only (list_pull_requests, get_pull_request, get_pull_request_reviews, get_pull_request_status, get_pull_request_files, list_issues, get_issue, search_issues, list_commits) via the connection's tool allowlist."
egress:
  mode: "none"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-github
      name: "Connect GitHub"
      description: "Links your repositories so PR Watchdog can read open PR and review state"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: required
      reason: "Primary and only data source — without it there is nothing to watch"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
        helpUrl: "https://docs.schemabounce.com/integrations/github"
    - id: restrict-github-tools
      name: "Restrict GitHub tools to read-only"
      description: "Set this agent's GitHub tool grant to read-only calls (list/get/search) so it cannot comment, review, merge, or close even by mistake"
      type: manual
      group: connections
      priority: required
      reason: "The bot manifest cannot restrict which tools of a granted MCP server an agent can call — that allowlist is a per-agent grant setting only a human can set"
      ui:
        actionLabel: "I've set the read-only tool allowlist"
        instructions: |
          Open this agent's MCP Servers tab, find the GitHub grant, and set its tool
          allowlist to: list_pull_requests, get_pull_request, get_pull_request_reviews,
          get_pull_request_status, get_pull_request_files, list_issues, get_issue,
          search_issues, list_commits. Leave out create_issue, create_pull_request,
          add_issue_comment, create_pull_request_review, merge_pull_request, and
          update_issue.
    - id: set-watched-repos
      name: "List repositories to watch"
      description: "The GitHub tool set has no \"list my repos\" call, so name every repository PR Watchdog should check"
      type: north_star
      key: pr_watchdog_repos
      group: configuration
      priority: required
      reason: "Without an explicit repo list the bot cannot discover which repositories to query"
      ui:
        inputType: text
        placeholder: "acme/frontend, acme/core-api"
        instructions: "Comma-separated owner/repo pairs."
    - id: set-sla-threshold
      name: "Set the review SLA"
      description: "Hours a PR can go without human review before it's an SLA breach"
      type: north_star
      key: pr_review_sla_hours
      group: configuration
      priority: recommended
      reason: "Defaults to 24h; teams with faster or slower review cadence should adjust"
      ui:
        inputType: number
        min: 1
        max: 168
        step: 1
        default: 24
        unit: hours
    - id: set-ai-author-patterns
      name: "Set AI-author login patterns"
      description: "Login substrings that identify an AI-authored PR or an AI-generated review"
      type: north_star
      key: pr_ai_author_patterns
      group: configuration
      priority: recommended
      reason: "The default list covers common AI coding agents; add workspace-specific bot account names"
      ui:
        inputType: text
        default: "copilot, devin, cursor, claude, codex, chatgpt, -bot"
    - id: assign-org-chart-position
      name: "Add PR Watchdog to the org chart"
      description: "SLA-breach escalations need this agent to have a supervisor or a matching escalation rule"
      type: manual
      group: external
      priority: required
      reason: "Without an org chart position, adl_request_escalation cannot resolve a target and every breach falls back to a critical task instead of reaching the Inbox"
      ui:
        actionLabel: "I've added this agent to the org chart"
        instructions: "Open Teams > Org Chart, add PR Watchdog as a position reporting to a human (or a supervisor bot that ultimately reports to one), then save."
goals:
  - name: breaches_escalated
    description: "Every SLA breach reaches a human before the window closes"
    category: primary
    metric:
      type: count
      entity: receipts
      filter: { metric: "sla_breach_escalated" }
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when a PR crosses the SLA threshold this run"
  - name: time_to_human_touch
    description: "Median hours a PR sits open before its first human review"
    category: primary
    metric:
      type: threshold
      measurement: "median_hours_open_at_first_human_review"
    target:
      operator: "<"
      value: 24
      period: weekly
  - name: full_repo_coverage
    description: "Every run checks every watched repository, not a subset"
    category: health
    metric:
      type: boolean
      check: "all_watched_repos_checked_this_run"
    target:
      operator: "=="
      value: true
      period: per_run
---

# PR Watchdog

Keeps ticket and PR review state truthful. Lists open pull requests across every connected
repository, classifies AI-authored PRs and unreviewed PRs against a configurable SLA, creates
and updates task-board tasks for stale ones, and escalates SLA breaches to the human Inbox.
Never approves, merges, closes, or comments on a PR — routing and escalation only.

## Escalation Behavior

- **SLA breach** (past the full review window, no human review): escalated to the human Inbox via `adl_request_escalation`, batched once per run.
- **Stale** (past half the review window, no human review): tracked as a task-board task, not escalated.
- **Everything else**: logged as a `prw_findings` record only.
