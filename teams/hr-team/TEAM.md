---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: hr-team
  displayName: "Human Resources"
  version: "1.0.0"
  description: "HR automation covering employee onboarding, coaching and development, and internal knowledge management"
  domain: hr
  category: hr
  tags: ["hr", "people-ops", "onboarding", "coaching", "knowledge-management"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/hr-onboarding@1.0.0"
  - ref: "bots/mentor-coach@1.0.0"
  - ref: "bots/knowledge-base-curator@1.0.0"
plugins:
  - ref: "gog@latest"
    slot: "google"
    reason: "Google Calendar for interview scheduling and Google Drive for document management"
    config:
      calendar_access: "read_write"
      drive_access: "read_write"
  - ref: "n8n-workflow@latest"
    slot: "workflow"
    reason: "Onboarding workflow automation for hr-onboarding and knowledge-base-curator"
    config:
      webhook_triggers: true
      workflow_templates: ["onboarding", "offboarding", "compliance-review"]
dataKits:
  - ref: "data-kits/hr@1.0.0"
    required: true
    installSampleData: false
northStar:
  industry: "Human Resources"
  context: "HR team automating new hire onboarding, employee coaching and development, and internal knowledge base management"
  requiredKeys:
    - company_values
    - onboarding_checklist
    - review_cadence
    - org_structure
    - knowledge_base_sources
orgChart:
  lead: hr-onboarding
  domains:
    - name: "Talent"
      description: "Hiring, onboarding, performance, and career development"
      head: hr-onboarding
      children:
        - name: "Coaching"
          description: "1:1 cadence, mentorship, and career-path guidance"
          head: mentor-coach
    - name: "Knowledge"
      description: "Handbook, runbooks, policy docs, and internal how-tos"
      head: knowledge-base-curator
  roles:
    - bot: hr-onboarding
      role: lead
      reportsTo: null
      domain: talent
    - bot: mentor-coach
      role: specialist
      reportsTo: hr-onboarding
      domain: talent
    - bot: knowledge-base-curator
      role: specialist
      reportsTo: hr-onboarding
      domain: knowledge
  escalation:
    critical: hr-onboarding
    unhandled: hr-onboarding
    paths:
      - name: "Onboarding Blocker"
        trigger: "onboarding_blocked"
        chain: [hr-onboarding]
      - name: "Performance Concern"
        trigger: "performance_concern"
        chain: [mentor-coach, hr-onboarding]
      - name: "Stale Policy"
        trigger: "stale_documentation"
        chain: [knowledge-base-curator, hr-onboarding]
---
# Human Resources

Three bots covering core HR workflows: new hire onboarding, employee coaching and development, and internal knowledge base curation.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| HR Onboarding | Lead, new hire workflows | @daily |
| Mentor Coach | Specialist, coaching and development | @weekly |
| Knowledge Base Curator | Specialist, policy and documentation | @weekly |

## How They Work Together

HR Onboarding leads the team and manages the new hire pipeline end-to-end, including checklist tracking, document collection, and day-one readiness. The Mentor Coach tracks employee development, runs 1:1 prep, and flags performance concerns. The Knowledge Base Curator keeps policies, SOPs, and the internal handbook current, flagging stale or missing documentation.

**Communication flow:**
- HR Onboarding hits a blocker -> alert routed to the team lead (self-escalates)
- HR Onboarding completes onboarding -> finding to Mentor Coach to begin coaching cadence
- Mentor Coach identifies a performance concern -> finding to HR Onboarding
- Knowledge Base Curator finds stale docs -> finding to HR Onboarding
- Knowledge Base Curator identifies missing policy coverage -> alert to HR Onboarding

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `company_values`, `onboarding_checklist`, `review_cadence`, `org_structure`, `knowledge_base_sources`
3. Bots begin running on their default schedules automatically
4. Check HR Onboarding's daily briefing for new hire status and open tasks
