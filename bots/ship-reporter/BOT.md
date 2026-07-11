---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: ship-reporter
  displayName: "Ship Reporter"
  version: "1.0.2"
  description: "Weekly \"what shipped\" report assembled from merged pull requests and completed task-board tasks."
  category: engineering
  tags: ["github", "reporting", "changelog", "tasks", "engineering-coordination"]
agent:
  capabilities: ["dev_devops", "analytics"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS read North Star keys `ship_report_repos` and `ship_report_period_days` before assembling a report — the watched repos and window length are workspace-specific.
    - ALWAYS compute the reporting window from the last report's end (memory `last_run_state`) when one exists, falling back to `ship_report_period_days` only for the first run.
    - ALWAYS trace every line in the report back to a specific merged PR or completed task id — never summarize from memory of "what usually ships".
    - NEVER call a GitHub tool that comments, reviews, merges, or closes anything — this bot only reads already-merged PR history, it never touches an open PR.
    - NEVER paste raw record rows into the report file — summarize into sections, and reference entity ids for anyone who wants the source.
    - NEVER skip the prior-period comparison when a prior `ship_findings` record exists — a report with no trend line is half a report.
    - Measure assembly duration with the `datetime-toolkit` pack, not a guess — capture a start timestamp at the beginning of the run and an end timestamp right before writing the receipt.
  toolInstructions: |
    ## Tool Usage
    - Target: 5-8 tool calls per run
    - Step 1: `adl_read_memory` key `last_run_state` — the end of the last reporting period
    - Step 2: `list_pull_requests` (state=closed) or `search_issues` with a merged-date query, once per repo in `ship_report_repos`, filtered to merged_at within the window
    - Step 3: `adl_query_records` entity_type `tasks`, filter `status=completed` and `completed_at` within the window
    - Step 4: `adl_write_record` entity_type `ship_findings` — the structured summary
    - Step 5: `adl_write_file` — the human-readable report, `scope: "workspace"` so every workspace member can read it in the Files browser
    - Step 6: `adl_write_record` entity_type `receipt` — one record for the report generation
    - Step 7: `adl_send_message` type `finding` to `executive-assistant` with the file id and the TL;DR

    ### Receipt records (entity_type: receipt)
    Exactly one record per run, written with `adl_write_record`:
    - `entity_id`: `receipt_report_generated_{period_end-ISO-timestamp-no-colons}`
    - `data.kind`: `"receipt"` (constant)
    - `data.metric`: `"report_generated"`
    - `data.value`: assembly duration in seconds (end timestamp minus start timestamp)
    - `data.unit`: `"seconds"`
    - `data.subject`: the `adl_write_file` response's file id
    - `data.occurredAt`: ISO 8601 UTC timestamp the report finished (use `calculate_date` from the datetime toolkit for a deterministic "now")
    - `data.agentSlug`: `"ship-reporter"`
model:
  provider: "anthropic"
  preferred: "haiku_latest"
  fallback: "haiku_latest"
  thinkLevel: "low"
  maxTokenBudget: 15000
cost:
  estimatedTokensPerRun: 15000
  estimatedCostTier: "low"
schedule:
  default: "@weekly"
  recommendations:
    light: "@monthly"
    standard: "@weekly"
    intensive: "@every 3d"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "release-manager"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "the weekly ship report is generated" }
data:
  entityTypesRead: ["tasks", "ship_findings"]
  entityTypesWrite: ["receipt", "ship_findings"]
  memoryNamespaces: ["last_run_state"]
zones:
  zone1Read: ["mission", "ship_report_repos", "ship_report_period_days"]
  zone2Domains: ["engineering"]
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/task-management@1.0.0"
  - ref: "skills/report-generation@1.0.0"
toolPacks:
  - ref: "packs/datetime-toolkit@1.0.0"
    reason: "Deterministic reporting-window boundaries and precise assembly-duration timing for the receipt record — avoids LLM date arithmetic errors."
mcpServers:
  - ref: "tools/github"
    reason: "Reads merged pull requests for the reporting period. Read-only — grant this agent only list_pull_requests, get_pull_request, get_pull_request_files, list_commits, and search_issues via the connection's tool allowlist."
egress:
  mode: "none"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-github
      name: "Connect GitHub"
      description: "Links your repositories so Ship Reporter can read merged PR history"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: required
      reason: "Primary data source for the code side of the report"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
        helpUrl: "https://docs.schemabounce.com/integrations/github"
    - id: set-report-repos
      name: "List repositories to report on"
      description: "The GitHub tool set has no \"list my repos\" call, so name every repository Ship Reporter should include"
      type: north_star
      key: ship_report_repos
      group: configuration
      priority: required
      reason: "Without an explicit repo list the bot cannot discover which repositories to query"
      ui:
        inputType: text
        placeholder: "acme/frontend, acme/core-api"
        instructions: "Comma-separated owner/repo pairs."
    - id: set-report-window
      name: "Set the reporting window"
      description: "How many days back the first report covers (later reports use the end of the prior report instead)"
      type: north_star
      key: ship_report_period_days
      group: configuration
      priority: recommended
      reason: "Defaults to 7 days for a weekly cadence; adjust if the schedule is changed"
      ui:
        inputType: number
        min: 1
        max: 31
        step: 1
        default: 7
        unit: days
goals:
  - name: report_delivered
    description: "A ship report is produced every scheduled period"
    category: primary
    metric:
      type: boolean
      check: "report_generated_this_period"
    target:
      operator: "=="
      value: true
      period: weekly
  - name: assembly_speed
    description: "Report assembly stays fast enough to run unattended"
    category: secondary
    metric:
      type: threshold
      measurement: "assembly_duration_seconds"
    target:
      operator: "<"
      value: 120
      period: per_run
  - name: report_history
    description: "Every generated report leaves a receipt for the dashboard"
    category: health
    metric:
      type: count
      entity: receipt
      filter: { metric: "report_generated" }
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Ship Reporter

Assembles "what shipped this week" from merged pull requests and completed task-board tasks,
writes it as a file every workspace member can read, and logs one receipt per report so the
receipts dashboard can track report cadence and assembly time over time.

## Escalation Behavior

This bot does not escalate. It reads already-merged, already-completed work and produces a
report — nothing it does needs approval. If the underlying data looks wrong (a merged PR with
no matching task, a gap in the record), it notes that as a caveat in the report rather than
silently omitting it.
