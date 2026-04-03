---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: content-scheduler
  displayName: "Content Scheduler"
  version: "1.0.2"
  description: "Plans and schedules content calendar across channels."
  category: marketing
  tags: ["content", "calendar", "planning"]
agent:
  capabilities: ["content_planning", "scheduling"]
  hostingMode: "openclaw"
  defaultDomain: "marketing"
  instructions: |
    ## Operating Rules
    - ALWAYS read zone1 key (mission) at run start to ensure scheduled content aligns with current brand direction.
    - ALWAYS check the editorial_calendar memory namespace for existing scheduled items before creating new ones to prevent double-booking time slots or channels.
    - NEVER publish or push content live. Your role is schedule management — create scheduled_posts entities that humans or publishing tools execute.
    - NEVER reschedule or cancel content created by other bots without sending a finding to the originating bot first (blog-writer for blog content, social-media-strategist for social content).
    - When a content deadline is approaching (within 48 hours) and the expected draft has not arrived, send a request to blog-writer or social-media-strategist specifying the missing item and deadline.
    - When a scheduling conflict is detected (two items targeting the same channel within 2 hours), escalate to executive-assistant with both items and a recommended resolution.
    - Send a weekly content calendar utilization report to marketing-growth showing: slots filled vs available, channel distribution, and gaps.
    - When receiving scheduling requests from marketing-growth or social-media-strategist, validate against channel_configs before creating scheduled_posts — respect per-channel frequency limits.
    - Update performance_data memory at the end of each run with publishing outcomes (on-time rate, missed deadlines, rescheduled items).
    - Runs weekdays at 9 AM — process all incoming requests accumulated overnight in a single batch to minimize message overhead.
  toolInstructions: |
    ## Tool Usage — Minimal Calls
    - Target: 3-5 tool calls per run, never more than 8
    - Step 1: `adl_read_memory` key `last_run_state` — get last run timestamp
    - Step 2: `adl_read_messages` — check for new requests
    - Step 3: `adl_query_records` with filter `created_at > {last_run_timestamp}` — ONE query for all new records
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
  default: "0 9 * * 1-5"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant", "marketing-growth", "social-media-strategist"] }
    - { type: "finding", from: ["blog-writer"] }
  sendsTo:
    - { type: "finding", to: ["executive-assistant"], when: "publishing schedule conflict or missed deadline" }
    - { type: "request", to: ["blog-writer"], when: "content deadline approaching and draft not received" }
    - { type: "request", to: ["social-media-strategist"], when: "social content slot open and needs scheduling" }
    - { type: "finding", to: ["marketing-growth"], when: "content calendar utilization report or gap detected" }
data:
  entityTypesRead: ["content_calendar", "channel_configs"]
  entityTypesWrite: ["scheduled_posts", "content_plans"]
  memoryNamespaces: ["editorial_calendar", "performance_data"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["marketing", "content"]
presence:
  email:
    required: false
    provider: agentmail
  web:
    search: true
    browsing: false
    crawling: true
mcpServers:
  - ref: "tools/agentmail"
    required: false
    reason: "Send content deadline reminders and publishing schedule notifications to creators"
  - ref: "tools/exa"
    required: false
    reason: "Search for optimal publishing times and trending content topics"
  - ref: "tools/firecrawl"
    required: false
    reason: "Crawl competitor content calendars and publishing patterns"
  - ref: "tools/composio"
    required: false
    reason: "Sync content schedules with CMS, social media, and marketing automation platforms"
egress:
  mode: "restricted"
  allowedDomains: ["www.googleapis.com"]
skills:
  - ref: "skills/record-monitoring@1.0.0"
plugins:
  - ref: "gog@latest"
    required: true
    reason: "Google Calendar for managing the content publishing schedule and editorial deadlines"
    config:
      scopes: ["calendar.events"]
requirements:
  minTier: "starter"
setup:
  steps:
    - id: set-mission
      name: "Define brand mission"
      description: "Brand direction ensures scheduled content aligns with company voice and goals"
      type: north_star
      key: mission
      group: configuration
      priority: required
      reason: "Content scheduling decisions must reflect current brand direction and priorities"
      ui:
        inputType: text
        placeholder: "e.g., Position our brand as the thought leader in real-time data infrastructure"
        prefillFrom: "workspace.mission"
    - id: configure-channels
      name: "Set up content channels"
      description: "Define publishing channels with frequency limits and time zone preferences"
      type: data_presence
      entityType: channel_configs
      minCount: 1
      group: data
      priority: required
      reason: "Cannot schedule content without knowing which channels are available and their constraints"
      ui:
        actionLabel: "Configure Channels"
        emptyState: "No channels configured. Add at least one publishing channel (blog, social, newsletter) to begin scheduling."
    - id: connect-google-calendar
      name: "Connect Google Calendar"
      description: "Sync editorial calendar with Google Calendar for team visibility"
      type: plugin_connection
      ref: gog
      group: connections
      priority: recommended
      reason: "Team-visible calendar ensures content creators know their deadlines"
      ui:
        icon: calendar
        actionLabel: "Connect Google Calendar"
    - id: connect-composio
      name: "Connect CMS and social platforms"
      description: "Sync schedules with your CMS, social media, and marketing automation tools"
      type: mcp_connection
      ref: tools/composio
      group: connections
      priority: recommended
      reason: "Automated sync keeps publishing schedules consistent across platforms"
      ui:
        icon: integration
        actionLabel: "Connect Publishing Platforms"
    - id: connect-exa
      name: "Connect Exa for publishing insights"
      description: "Research optimal publishing times and trending content topics"
      type: mcp_connection
      ref: tools/exa
      group: connections
      priority: optional
      reason: "Data-driven scheduling based on audience engagement patterns"
      ui:
        icon: search
        actionLabel: "Connect Exa"
    - id: setup-email
      name: "Verify email identity"
      description: "Bot sends deadline reminders and schedule notifications to content creators"
      type: mcp_connection
      ref: tools/agentmail
      group: connections
      priority: optional
      reason: "Email reminders help content creators meet their publishing deadlines"
      ui:
        icon: email
        actionLabel: "Verify Email"
goals:
  - name: schedule_coverage
    description: "All content calendar slots filled with scheduled posts"
    category: primary
    metric:
      type: rate
      numerator: { entity: scheduled_posts, filter: { status: "scheduled" } }
      denominator: { entity: content_calendar, filter: { slot_type: "open" } }
    target:
      operator: ">"
      value: 0.85
      period: weekly
      condition: "at least 85% of available slots filled"
  - name: on_time_publishing
    description: "Scheduled posts published on time without missed deadlines"
    category: primary
    metric:
      type: rate
      numerator: { entity: scheduled_posts, filter: { published_on_time: true } }
      denominator: { entity: scheduled_posts, filter: { status: "published" } }
    target:
      operator: ">"
      value: 0.9
      period: weekly
  - name: scheduling_quality
    description: "Content scheduling decisions rated effective by marketing team"
    category: secondary
    metric:
      type: rate
      numerator: { entity: scheduled_posts, filter: { feedback: "good_timing" } }
      denominator: { entity: scheduled_posts, filter: { feedback: { "$exists": true } } }
    target:
      operator: ">"
      value: 0.75
      period: monthly
    feedback:
      enabled: true
      entityType: scheduled_posts
      actions:
        - { value: good_timing, label: "Good timing" }
        - { value: wrong_time, label: "Wrong time slot" }
        - { value: conflict, label: "Scheduling conflict" }
        - { value: missed_opportunity, label: "Missed better slot" }
  - name: calendar_health
    description: "Track editorial calendar performance data and improve scheduling"
    category: health
    metric:
      type: count
      source: memory
      namespace: performance_data
    target:
      operator: ">"
      value: 0
      period: monthly
      condition: "cumulative growth"
---

# Content Scheduler

Manages content scheduling across channels. Plans posts, tracks performance, and optimizes publishing times.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
