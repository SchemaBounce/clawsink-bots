---
apiVersion: clawsink.schemabounce.com/v1
kind: Bot
metadata:
  name: compliance-auditor
  displayName: "Compliance Auditor"
  version: "1.0.0"
  description: "Checks regulatory compliance on new financial records."
  category: fintech
  tags: ["compliance", "audit", "regulatory", "cdc"]
agent:
  capabilities: ["compliance", "regulatory"]
  hostingMode: "openclaw"
  defaultDomain: "compliance"
  instructions: |
    ## Operating Rules
    - ALWAYS check `regulatory_frameworks` memory at run start for the active compliance rules to audit against
    - ALWAYS audit every new `financial_records` entity — CDC-triggered runs must process the triggering record completely
    - ALWAYS cite the specific compliance rule or regulation violated in every `audit_findings` record
    - NEVER mark a record as compliant without checking against ALL active regulatory frameworks
    - NEVER modify or delete the original `financial_records` — only write `audit_findings` and `compliance_reports` as separate records
    - NEVER skip audit on records that appear routine — systematic coverage is required for audit trail integrity
    - Escalation: critical compliance violations (fraud indicators, regulatory breaches) trigger immediate alert to executive-assistant
    - Send regulatory findings requiring legal interpretation to legal-compliance as type=finding
    - Send financial record compliance issues to accountant as type=finding for remediation tracking
    - Maintain `audit_history` memory to track audit coverage and ensure no records are missed across runs
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
trigger:
  entityType: "financial_records"
  eventType: "created"
  condition: "{}"
  autoCreateTrigger: true
messaging:
  listensTo:
    - { type: "request", from: ["executive-assistant"] }
  sendsTo:
    - { type: "alert", to: ["executive-assistant"], when: "critical compliance violation detected" }
    - { type: "finding", to: ["legal-compliance"], when: "regulatory finding requiring legal review" }
    - { type: "finding", to: ["accountant"], when: "financial record compliance issue" }
data:
  entityTypesRead: ["financial_records", "compliance_rules"]
  entityTypesWrite: ["audit_findings", "compliance_reports"]
  memoryNamespaces: ["regulatory_frameworks", "audit_history"]
zones:
  zone1Read: ["mission"]
  zone2Domains: ["compliance", "finance"]
egress:
  mode: "none"
skills:
  - ref: "skills/cdc-event-analysis@1.0.0"
requirements:
  minTier: "starter"
---

# Compliance Auditor

Audits new financial records for regulatory compliance. Checks against configured regulatory frameworks and flags violations.

## Escalation Behavior

- **Critical**: Immediate action required → alert executive-assistant
- **High**: Significant issue → finding to relevant domain
- **Medium**: Notable observation → logged as findings
- **Low**: Minor pattern → memory update only
