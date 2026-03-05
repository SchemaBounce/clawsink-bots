---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: legal-compliance
  displayName: "Legal & Compliance"
  version: "1.0.0"
  description: "Contract review queue, GDPR/SOC2 compliance tracking, regulatory change monitoring."
  category: legal
  tags: ["legal", "compliance", "gdpr", "soc2", "contracts", "regulatory"]
agent:
  capabilities: ["legal_compliance", "research"]
  hostingMode: "openclaw"
  defaultDomain: "compliance"
model:
  provider: "anthropic"
  preferred: "claude-sonnet-4-6"
  fallback: "claude-haiku-4-5-20251001"
  thinkLevel: null
schedule:
  default: "@weekly"
  recommendations:
    light: "@weekly"
    standard: "@weekly"
    intensive: "@every 3d"
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "compliance violation or regulatory deadline" }
    - { type: "finding", to: ["business-analyst", "executive-assistant"], when: "compliance risk or contract issue" }
data:
  entityTypesRead: ["contracts", "companies"]
  entityTypesWrite: ["legal_findings", "legal_alerts", "contracts"]
  memoryNamespaces: ["working_notes", "learned_patterns", "compliance_calendar"]
zones:
  zone1Read: ["mission", "industry", "compliance_requirements"]
  zone2Domains: ["compliance"]
skills:
  - inline: "core-analysis"
requirements:
  minTier: "starter"
---

# Legal & Compliance

Monitors compliance posture, tracks contract review queues, and watches for regulatory changes. Uses Sonnet for nuanced analysis of compliance requirements.

## What It Does

- Tracks contract review queue and approaching deadlines
- Monitors compliance status against configured frameworks (GDPR, SOC2, PCI, etc.)
- Identifies regulatory changes relevant to the business industry
- Reviews data handling practices for compliance alignment
- Flags expiring contracts and renewal deadlines

## Escalation Behavior

- **Critical**: Compliance violation, regulatory deadline breach → alerts executive-assistant
- **High**: Contract expiry within 30 days, compliance gap → finding to executive-assistant
- **Medium**: Routine compliance observation → logged as legal_findings
- **Low**: Minor documentation updates → memory update only

## Recommended Setup

Set these North Star keys:
- `compliance_requirements` — Active compliance frameworks (GDPR, SOC2, PCI, etc.)
- `industry` — Used to filter relevant regulatory changes
