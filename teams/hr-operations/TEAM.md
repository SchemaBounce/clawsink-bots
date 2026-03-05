---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: hr-operations
  displayName: "HR & People Operations"
  version: "1.0.0"
  description: "End-to-end HR automation covering onboarding, compliance, coaching, and knowledge management"
  category: hr
  tags: ["hr", "people-ops", "onboarding", "compliance", "coaching"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/hr-onboarding@1.0.0"
  - ref: "bots/mentor-coach@1.0.0"
  - ref: "bots/knowledge-base-curator@1.0.0"
  - ref: "bots/legal-compliance@1.0.0"
northStar:
  industry: "Human Resources"
  context: "HR team automating onboarding, compliance, coaching, and knowledge management"
  requiredKeys:
    - company_values
    - onboarding_checklist
    - compliance_requirements
    - review_cadence
    - org_structure
---
# HR & People Operations

Five bots covering the full HR lifecycle: people management coordination, new hire onboarding, mentoring and coaching, internal knowledge curation, and labor law compliance monitoring.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|----------|
| Executive Assistant | People Manager, HR coordination | @every 4h |
| HR Onboarding | New hire workflows, document collection, onboarding checklists | @daily |
| Mentor Coach | 1:1 prep, development plans, performance patterns | @weekly |
| Knowledge Base Curator | Policy docs, SOPs, internal wiki maintenance | @weekly |
| Legal Compliance | HR compliance, labor law monitoring, policy enforcement | @weekly |

## How They Work Together

The Executive Assistant acts as the central coordinator, routing tasks across all HR functions. HR Onboarding manages the new hire pipeline and escalates blockers or compliance gaps. The Mentor Coach tracks employee development and flags performance concerns. The Knowledge Base Curator keeps policies and SOPs current, flagging stale or missing documentation. Legal Compliance monitors labor law changes and ensures all HR processes stay compliant.

**Communication flow:**
- HR Onboarding hits a blocker -> alert to Executive Assistant
- HR Onboarding detects compliance gap -> finding to Legal Compliance
- Mentor Coach identifies performance concern -> finding to Executive Assistant
- Knowledge Base Curator finds stale docs -> finding to Executive Assistant
- Knowledge Base Curator finds outdated compliance docs -> alert to Legal Compliance
- Legal Compliance detects violation -> alert to Executive Assistant
- Legal Compliance updates onboarding requirements -> finding to HR Onboarding
- Executive Assistant coordinates cross-domain tasks -> request to all bots

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `company_values`, `onboarding_checklist`, `compliance_requirements`, `review_cadence`, `org_structure`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's briefings for consolidated HR status
