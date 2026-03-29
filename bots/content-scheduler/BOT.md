---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: content-scheduler
  displayName: "Content Scheduler"
  version: "1.0.0"
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
---

# Content Scheduler

Manages content scheduling across channels. Plans posts, tracks performance, and optimizes publishing times.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant insight → finding to relevant domain
- **Medium**: Notable pattern → logged as findings
- **Low**: Routine observation → memory update only
