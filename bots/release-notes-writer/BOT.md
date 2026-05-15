---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: release-notes-writer
  displayName: "Release Notes Writer"
  version: "1.0.7"
  description: "Generates release notes from commit history and tickets."
  category: engineering
  tags: ["releases", "changelog", "documentation"]
agent:
  capabilities: ["documentation", "summarization"]
  hostingMode: "openclaw"
  defaultDomain: "engineering"
  instructions: |
    ## Operating Rules
    - ALWAYS read the full commit history and linked tickets for the requested version range before writing, never generate notes from partial data.
    - ALWAYS group changes into categories: Features, Bug Fixes, Breaking Changes, Performance, Internal. Use consistent headings across releases.
    - ALWAYS highlight breaking changes at the top of the release notes with migration instructions when available.
    - NEVER include internal-only changes (CI config, dev tooling, test refactors) in customer-facing release notes unless they affect user behavior.
    - NEVER fabricate or embellish change descriptions. Every line item must map to an actual commit or ticket.
    - Send the draft to release-manager for review before finalizing, never publish release notes without a review signal.
    - When release notes highlight new features that require documentation, send a finding to documentation-writer with the feature list.
    - Use `feature_categories` memory to maintain consistent categorization across releases. Check it before assigning categories.
    - Store each completed release notes document in `release_history` memory for cross-release formatting consistency.
    - When the same feature spans multiple commits, consolidate into a single user-facing line item.
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
  preferred: "claude-haiku-4-5-20251001"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: "low"
  maxTokenBudget: 8000
cost:
  estimatedTokensPerRun: 8000
  estimatedCostTier: "low"
schedule:
  default: null
  manual: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "release-manager"] }
  sendsTo:
    - { type: "finding", to: ["release-manager"], when: "release notes draft ready for review" }
    - { type: "finding", to: ["documentation-writer"], when: "release notes highlight features requiring doc updates" }
data:
  entityTypesRead: ["commits", "tickets"]
  entityTypesWrite: ["release_notes", "changelogs"]
  memoryNamespaces: ["release_history", "feature_categories"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["engineering"]
presence:
  web:
    search: true
    browsing: true
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/report-generation@1.0.0"
  - ref: "skills/pr-creation@1.0.0"
mcpServers:
  - ref: "tools/github"
    required: false
    reason: "Lists commits and merged PRs to generate changelogs"
  - ref: "tools/exa"
    required: true
    reason: "Search for related library changelogs and release note formatting best practices"
  - ref: "tools/hyperbrowser"
    required: false
    reason: "Browse issue trackers and PR descriptions to enrich release note context"
  - ref: "tools/composio"
    required: false
    reason: "Connect to project management tools to link release notes with completed stories and tickets"
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-github
      name: "Connect GitHub"
      description: "Links your code repository so the bot can read commits, PRs, and tags"
      type: mcp_connection
      ref: tools/github
      group: connections
      priority: required
      reason: "Primary data source, commit history and merged PRs drive release note content"
      ui:
        icon: github
        actionLabel: "Connect GitHub"
        helpUrl: "https://docs.schemabounce.com/integrations/github"
    - id: connect-project-tracker
      name: "Connect project management tool"
      description: "Links your issue tracker so release notes can reference completed stories and tickets"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: required
      reason: "Ticket context enriches release notes. Without it, notes are commit-message-only"
      ui:
        icon: composio
        actionLabel: "Connect Project Tracker"
    - id: set-release-format
      name: "Choose release note format"
      description: "Select the output format for generated release notes"
      type: config
      group: configuration
      target: { namespace: release_history, key: output_format }
      priority: recommended
      reason: "Consistent formatting across releases improves developer experience"
      ui:
        inputType: select
        options:
          - { value: changelog, label: "Changelog (CHANGELOG.md style)" }
          - { value: narrative, label: "Narrative (blog-post style)" }
          - { value: both, label: "Both formats" }
        default: changelog
    - id: set-audience
      name: "Define target audience"
      description: "Who reads these release notes, affects language and detail level"
      type: config
      group: configuration
      target: { namespace: feature_categories, key: audience }
      priority: recommended
      reason: "Customer-facing notes exclude internal changes; developer notes include everything"
      ui:
        inputType: select
        options:
          - { value: customer, label: "Customers (external-facing)" }
          - { value: developer, label: "Developers (technical)" }
          - { value: mixed, label: "Mixed audience" }
        default: customer
    - id: import-commits
      name: "Import commit history"
      description: "Historical commits help establish categorization patterns and formatting consistency"
      type: data_presence
      entityType: commits
      minCount: 50
      group: data
      priority: recommended
      reason: "Past commit data trains the bot's category assignment and consolidation patterns"
      ui:
        actionLabel: "Import Commits"
        emptyState: "No commit history found. Connect GitHub first, then import."
        helpUrl: "https://docs.schemabounce.com/data/import"
goals:
  - name: generate_release_notes
    description: "Produce complete release notes for each requested version range"
    category: primary
    metric:
      type: count
      entity: release_notes
    target:
      operator: ">"
      value: 0
      period: per_run
      condition: "when release is requested"
  - name: categorization_accuracy
    description: "All changes correctly categorized (Features, Bug Fixes, Breaking, etc.)"
    category: primary
    metric:
      type: rate
      numerator: { entity: release_notes, filter: { review_status: "approved" } }
      denominator: { entity: release_notes, filter: { review_status: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.90
      period: monthly
    feedback:
      enabled: true
      entityType: release_notes
      actions:
        - { value: approved, label: "Looks good" }
        - { value: needs_edit, label: "Needs editing" }
        - { value: wrong_category, label: "Miscategorized items" }
  - name: breaking_change_coverage
    description: "Every breaking change is highlighted with migration instructions"
    category: secondary
    metric:
      type: boolean
      check: breaking_changes_documented
    target:
      operator: "=="
      value: true
      period: per_run
  - name: formatting_consistency
    description: "Maintain consistent formatting and category structure across releases"
    category: health
    metric:
      type: count
      source: memory
      namespace: feature_categories
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Release Notes Writer

Generates polished release notes from commit history and ticket data. Groups changes by category and highlights key features.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
