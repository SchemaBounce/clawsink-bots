---
apiVersion: clawsink.schemabounce.com/v1
kind: Team
metadata:
  name: legal-practice
  displayName: "Legal Practice"
  version: "1.0.0"
  description: "Case management, regulatory tracking, and institutional knowledge for law firms and legal departments."
  category: legal
  tags: ["legal", "law-firm", "compliance", "contracts", "knowledge", "scale"]
  author: "schemabounce"
  license: "MIT"
  estimatedMonthlyCost: "varies"
bots:
  - ref: "bots/executive-assistant@1.0.0"
  - ref: "bots/legal-compliance@1.0.0"
  - ref: "bots/compliance-auditor@1.0.0"
  - ref: "bots/meeting-summarizer@1.0.0"
  - ref: "bots/knowledge-base-curator@1.0.0"
  - ref: "bots/accountant@1.0.0"
dataKits:
  - ref: "data-kits/legal@1.0.0"
    required: true
    installSampleData: false
  - ref: "data-kits/financial-ops@1.0.0"
    required: false
    installSampleData: false
  - ref: "data-kits/compliance-governance@1.0.0"
    required: false
    installSampleData: false
requirements:
  minTier: "scale"
northStar:
  industry: "Legal Practice / Law Firm"
  context: "Law firms or legal departments where case management, regulatory tracking, billable hours, and institutional knowledge are critical"
  requiredKeys:
    - practice_areas
    - jurisdictions
    - billing_structure
    - case_management_system
    - regulatory_bodies
    - knowledge_domains
orgChart:
  lead: executive-assistant
  domains:
    - name: "Legal Ops"
      description: "Matter intake, deadlines, team coordination"
      head: executive-assistant
      children:
        - name: "Meetings"
          description: "Client call transcripts, deposition summaries"
          head: meeting-summarizer
    - name: "Compliance"
      description: "Regulatory watch and engagement-letter review"
      head: legal-compliance
      children:
        - name: "Audit"
          description: "Internal controls and evidence collection"
          head: compliance-auditor
    - name: "Knowledge"
      description: "Briefs, precedent, internal memos"
      head: knowledge-base-curator
    - name: "Finance"
      description: "Billable hours, realization, trust accounting"
      head: accountant
  roles:
    - bot: executive-assistant
      role: lead
      reportsTo: null
      domain: legal-ops
    - bot: legal-compliance
      role: specialist
      reportsTo: executive-assistant
      domain: compliance
    - bot: compliance-auditor
      role: support
      reportsTo: legal-compliance
      domain: compliance
    - bot: meeting-summarizer
      role: support
      reportsTo: executive-assistant
      domain: legal-ops
    - bot: knowledge-base-curator
      role: specialist
      reportsTo: executive-assistant
      domain: knowledge
    - bot: accountant
      role: specialist
      reportsTo: executive-assistant
      domain: finance
  escalation:
    critical: executive-assistant
    unhandled: executive-assistant
    paths:
      - name: "Regulatory change impact"
        trigger: "regulation_change"
        chain: [legal-compliance, executive-assistant]
      - name: "Compliance violation"
        trigger: "audit_finding_critical"
        chain: [compliance-auditor, legal-compliance, executive-assistant]
      - name: "Trust account discrepancy"
        trigger: "trust_account_alert"
        chain: [accountant, executive-assistant]
---
# Legal Practice

An operations team for law firms and in-house legal departments. Six bots cover the areas where legal practices lose the most time and money: tracking regulatory changes, maintaining compliance processes, capturing institutional knowledge, and managing the financials that keep the lights on. Built for firms where a missed deadline is malpractice and a forgotten precedent is lost revenue.

## Included Bots

| Bot | Role | Schedule |
|-----|------|----------|
| Executive Assistant | Partners meeting agenda, matter deadlines, court dates | @daily |
| Legal Compliance | Regulatory change tracking across jurisdictions | @daily |
| Compliance Auditor | Internal process validation: conflicts, deadlines, trust accounts | @weekly |
| Meeting Summarizer | Client meetings, depositions, case strategy sessions | @on-trigger |
| Knowledge Base Curator | Precedent library, legal research index, template documents | @daily |
| Accountant | Trust accounting, billable hour reconciliation, firm financials | @daily |

## How They Work Together

A law firm runs on deadlines, knowledge, and trust -- in every sense of the word. These bots address the operational gaps that even well-run firms struggle with: the regulatory change that nobody caught, the brilliant brief from three years ago that nobody can find, and the trust account reconciliation that is always behind.

Legal Compliance monitors regulatory changes across the jurisdictions the firm operates in. When a new ruling, regulation, or enforcement action drops, it flags the impact on active matters and notifies relevant attorneys. This is not theoretical -- a change in data privacy law affects every tech client the firm represents, and missing it is not an option. Compliance Auditor handles the internal side: conflict-of-interest checks on new matters, filing deadline tracking, trust account rule compliance, and the procedural discipline that bar associations audit.

Meeting Summarizer captures the substance of client meetings, depositions, and internal case strategy sessions. It produces structured notes with action items, deadlines, and key decisions -- the things that get lost when a busy associate scribbles notes and forgets to circulate them. Those notes feed into Knowledge Base Curator, which maintains the firm's institutional memory. It indexes case outcomes, legal research, template documents, and prior work product so that when an attorney needs a similar motion from a previous matter, they can actually find it instead of rewriting from scratch.

Accountant manages the financial operations that are unique to legal practice: trust account management (where commingling client funds is an ethics violation), billable hour reconciliation, and the firm-level financials that partners review. Executive Assistant coordinates the operational rhythm -- matter deadlines, court dates, filing schedules -- and compiles the weekly partners meeting agenda with the matters, finances, and compliance items that need attention.

**Communication flow:**
- Legal Compliance detects regulatory change -> alert to Executive Assistant with affected matters
- Compliance Auditor finds process gap -> finding to Executive Assistant for partners review
- Meeting Summarizer captures action items -> deadlines to Executive Assistant, research notes to Knowledge Base Curator
- Knowledge Base Curator indexes new case outcome -> available for future matter research
- Accountant flags trust account discrepancy -> urgent alert to Executive Assistant
- Executive Assistant compiles partners meeting agenda from all bot signals: deadlines, compliance, financials

## Getting Started

1. Activate the team via the ADL onboarding wizard
2. Fill in North Star keys: `practice_areas`, `jurisdictions`, `billing_structure`, `case_management_system`, `regulatory_bodies`, `knowledge_domains`
3. Bots begin running on their default schedules automatically
4. Check the Executive Assistant's daily briefing for matter deadlines, regulatory alerts, and the weekly partners meeting agenda
