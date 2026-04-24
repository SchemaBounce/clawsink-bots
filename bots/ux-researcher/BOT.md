---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: ux-researcher
  displayName: "UX Researcher"
  version: "1.0.6"
  description: "User research synthesis, feedback analysis, and usability insight generation."
  category: design
  tags: ["ux", "research", "usability", "feedback", "user-experience", "design"]
agent:
  capabilities: ["analytics", "research"]
  hostingMode: "openclaw"
  defaultDomain: "design"
  instructions: |
    ## Operating Rules
    - ALWAYS categorize incoming `user_feedback` records by theme (onboarding, navigation, performance, accessibility, etc.) and severity before analysis
    - ALWAYS include evidence count and affected user personas in every `ux_findings` record
    - ALWAYS check `pain_points` memory for existing themes before creating new findings, merge signals into existing themes when possible
    - NEVER write a finding without a concrete recommendation. Every pain point must include a suggested improvement
    - NEVER report individual feedback items as findings, cluster at least 3 signals into a theme first
    - NEVER modify support ticket or customer data, only read and analyze
    - Escalation: usability issues causing measurable churn or data loss go to executive-assistant immediately
    - Send actionable UX patterns with clear fix recommendations to product-owner as type=finding
    - Maintain `research_backlog` memory for emerging patterns that need more data before becoming findings
    - Score pain points by frequency, severity, and user segment impact to prioritize recommendations
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
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@every 3d"
    intensive: "@daily"
messaging:
  listensTo:
    - { type: "finding", from: ["customer-support", "product-owner"] }
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "finding", to: ["product-owner"], when: "usability issue or UX pattern with actionable recommendation" }
    - { type: "finding", to: ["executive-assistant"], when: "critical user experience issue affecting retention" }
data:
  entityTypesRead: ["user_feedback", "usage_analytics", "support_tickets"]
  entityTypesWrite: ["ux_findings", "usability_reports"]
  memoryNamespaces: ["user_patterns", "pain_points", "research_backlog"]
zones:
  zone1Read: ["mission", "industry", "stage", "priorities"]
  zone2Domains: ["design", "support", "product"]
egress:
  mode: "none"
skills:
  - ref: "skills/platform-awareness@1.0.0"
  - ref: "skills/inter-agent-comms@1.0.0"
  - ref: "skills/brand-audit@1.0.0"
mcpServers:
  - ref: "tools/exa"
    required: true
    reason: "Research UX best practices, competitor product experiences, and usability benchmarks"
  - ref: "tools/hyperbrowser"
    required: true
    reason: "Browse competitor products and review sites to analyze user experience patterns"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl user forums, review sites, and community discussions for qualitative feedback"
presence:
  web:
    browsing: true
    search: true
    crawling: true
automations:
  triggers:
    - entityType: "user_feedback"
      event: "created"
      prompt: "Categorize this feedback by theme and severity."
requirements:
  minTier: "starter"
setup:
  steps:
    - id: connect-exa
      name: "Connect Exa for UX research"
      description: "Search for UX best practices, competitor product experiences, and usability benchmarks"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: required
      reason: "UX benchmark research and competitor analysis require web search capabilities"
      ui:
        icon: exa
        actionLabel: "Connect Exa"
    - id: connect-hyperbrowser
      name: "Connect Hyperbrowser"
      description: "Browse competitor products and review sites to analyze user experience patterns"
      type: mcp_connection
      ref: tools/hyperbrowser
      group: connections
      priority: required
      reason: "Direct product browsing is needed to evaluate competitor UX flows and identify patterns"
      ui:
        icon: hyperbrowser
        actionLabel: "Connect Hyperbrowser"
    - id: set-industry
      name: "Define your industry"
      description: "Industry context shapes which UX benchmarks and best practices are most relevant"
      type: north_star
      key: industry
      group: configuration
      priority: required
      reason: "UX standards differ by industry, e-commerce checkout patterns differ from SaaS onboarding patterns"
      ui:
        inputType: select
        options:
          - { value: saas, label: "SaaS / Software" }
          - { value: ecommerce, label: "E-commerce / Retail" }
          - { value: fintech, label: "FinTech / Banking" }
          - { value: healthcare, label: "Healthcare" }
          - { value: marketplace, label: "Marketplace / Platform" }
          - { value: media, label: "Media / Content" }
          - { value: other, label: "Other" }
        default: saas
    - id: import-feedback
      name: "Import user feedback"
      description: "User feedback records are the primary data source for pain point analysis"
      type: data_presence
      entityType: user_feedback
      minCount: 3
      group: data
      priority: required
      reason: "Findings require at least 3 clustered signals, individual feedback items are not reported as findings"
      ui:
        actionLabel: "Import Feedback"
        emptyState: "No user feedback found. Import feedback from surveys, support tickets, or in-app feedback tools."
    - id: set-priorities
      name: "Set product priorities"
      description: "Current priorities help the bot focus UX analysis on the areas that matter most"
      type: north_star
      key: priorities
      group: configuration
      priority: recommended
      reason: "Pain point recommendations are more actionable when aligned with current product focus areas"
      ui:
        inputType: text
        placeholder: "e.g., onboarding conversion, mobile experience, accessibility"
        helpText: "List your current product focus areas so UX findings are prioritized accordingly"
    - id: connect-firecrawl
      name: "Connect Firecrawl for qualitative research"
      description: "Crawl user forums, review sites, and community discussions for qualitative feedback"
      type: mcp_connection
      ref: tools/firecrawl
      group: connections
      priority: recommended
      reason: "Community discussions and review sites provide unfiltered qualitative user sentiment"
      ui:
        icon: firecrawl
        actionLabel: "Connect Firecrawl"
goals:
  - name: pain_point_identification
    description: "Cluster user feedback into themed pain points with actionable recommendations"
    category: primary
    metric:
      type: count
      entity: ux_findings
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "when user_feedback records exist with sufficient volume"
  - name: recommendation_quality
    description: "Every UX finding includes a concrete improvement recommendation, no pain points without solutions"
    category: primary
    metric:
      type: rate
      numerator: { entity: ux_findings, filter: { has_recommendation: true } }
      denominator: { entity: ux_findings }
    target:
      operator: "=="
      value: 1.0
      period: per_run
  - name: pain_points_memory_maintained
    description: "Keep pain_points memory current to merge new signals into existing themes"
    category: health
    metric:
      type: boolean
      check: pain_points_namespace_updated
    target:
      operator: "=="
      value: true
      period: per_run
  - name: critical_ux_escalation
    description: "Escalate usability issues causing measurable churn or data loss to executive-assistant"
    category: secondary
    metric:
      type: boolean
      check: critical_ux_issues_escalated
    target:
      operator: "=="
      value: true
      period: per_run
      condition: "when churn-causing or data-loss UX issues are detected"
---

# UX Researcher

Synthesizes user feedback, usage analytics, and support tickets into actionable UX insights. Identifies pain points, usage patterns, and opportunities to improve the user experience.

## What It Does

- Reads user feedback records and categorizes by theme (onboarding, navigation, performance, etc.)
- Analyzes usage analytics to detect drop-off points and underused features
- Reviews support tickets for recurring usability complaints
- Clusters feedback into pain point themes with severity scoring
- Writes ux_findings with actionable recommendations for product and design teams
- Produces periodic usability reports summarizing trends and improvement opportunities

## UX Finding Format

Findings are written as `ux_findings` entity type records:
```json
{
  "severity": "high",
  "theme": "onboarding",
  "pain_point": "Users abandon signup at email verification step",
  "evidence_count": 12,
  "user_impact": "30% drop-off at verification, affects new user activation",
  "recommendation": "Implement magic link or reduce verification friction",
  "source_feedback": ["fb_20260301_001", "fb_20260301_005"],
  "affected_personas": ["new_user", "trial_user"]
}
```

## Escalation Behavior

- **Critical**: Usability issue causing significant churn or data loss -> finding to executive-assistant
- **High**: Pain point with 10+ signals and clear fix -> finding to product-owner
- **Medium**: Emerging pattern needing more data -> ux_findings record + research_backlog update
- **Low**: Individual feedback note -> user_patterns memory update
