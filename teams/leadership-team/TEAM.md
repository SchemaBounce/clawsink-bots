---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: leadership-team
  displayName: "Leadership"
  version: "1.0.0"
  description: "Executive support team handling briefings, meeting summaries, release communications, and strategic coordination"
  domain: leadership
  category: leadership
  tags: ["leadership", "executive", "briefings", "meetings", "communications", "strategy"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/meeting-summarizer@1.0.0"
  - ref: "bots/release-notes-writer@1.0.0"
dataKits:
  - ref: "data-kits/leadership@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Leadership"
  context: "Executive team needing consolidated briefings, meeting outcomes, release communications, and strategic goal tracking"
  requiredKeys:
    - company_okrs
    - executive_cadence
    - release_schedule
    - communication_channels
orgChart:
  lead: executive-assistant
  domains:
    - name: "Executive Coordination"
      description: "Strategic briefings, cross-team coordination, and executive communications"
      head: executive-assistant
      children:
        - name: "Meeting Intelligence"
          description: "Meeting summaries, action item tracking, and follow-up coordination"
          head: meeting-summarizer
        - name: "Release Communications"
          description: "Release notes, changelogs, and stakeholder announcements"
          head: release-notes-writer
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: executive-coordination
    - bot: meeting-summarizer
      role: specialist
      reportsTo: executive-assistant
      domain: executive-coordination
    - bot: release-notes-writer
      role: specialist
      reportsTo: executive-assistant
      domain: executive-coordination
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Missed Action Item"
        trigger: "action_item_overdue"
        chain: [meeting-summarizer, executive-assistant]
      - name: "Release Communication Gap"
        trigger: "release_comms_missing"
        chain: [release-notes-writer, executive-assistant]
---
# Leadership

Three bots providing executive support: strategic coordination and briefings, meeting intelligence and action tracking, and release communications. The Executive Assistant acts as the central coordinator, ensuring leadership has the right information at the right time.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Assistant | Lead coordinator, strategic briefings, cross-team liaison | @every 4h |
| Meeting Summarizer | Meeting summaries, action item extraction and tracking | @after_meeting |
| Release Notes Writer | Release notes, changelogs, stakeholder announcements | @on_release |

## How They Work Together

The Executive Assistant consolidates signals from across the organization into leadership-ready briefings. Meeting Summarizer processes meeting transcripts and recordings into structured summaries with clear action items and owners, surfacing overdue items to the Executive Assistant. Release Notes Writer drafts release communications in the appropriate voice for each audience (internal, customer, technical) and flags when a release lacks proper coverage.

**Communication flow:**
- Meeting Summarizer completes a summary -> finding to Executive Assistant
- Meeting Summarizer detects overdue action item -> alert to Executive Assistant
- Release Notes Writer completes a draft -> finding to Executive Assistant
- Release Notes Writer detects missing release communication -> alert to Executive Assistant
- Executive Assistant coordinates cross-team briefing -> request to all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `company_okrs`, `executive_cadence`, `release_schedule`, `communication_channels`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's briefings for consolidated leadership status
