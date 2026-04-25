---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: crm
  displayName: "CRM Starter"
  version: "1.0.0"
  description: "Lead research data kit — leads, companies, news signals, outreach templates, and AI-generated research briefs"
  category: crm
  tags:
    - crm
    - leads
    - companies
    - research
    - outreach
    - b2b
    - prospecting
    - sales-intelligence
  author: SchemaBounce
compatibility:
  teams:
    - lead-researcher
  composableWith:
    - saas
    - consulting
    - financial-ops
    - legal
entityPrefix: "crm_"
entityCount: 5
graphEdgeTypes:
  - WORKS_AT
  - RESEARCHED_BY
vectorCollections:
  - crm_research_briefs
  - crm_news_items
useCases:
  - "Track B2B leads and prospect companies with enriched context"
  - "Store AI-generated research briefs linking leads to company intelligence"
  - "Capture news signals and trigger insights for outreach timing"
  - "Manage outreach templates personalized by industry and lead status"
---

# CRM Starter

A focused B2B lead research data kit powering the Lead Researcher agent. Covers the five entity types needed to run a full prospecting workflow: leads, their companies, news signals, outreach templates, and AI-generated research briefs.

## What's Included

- **Leads** — people your team is prospecting, including title, company, LinkedIn, status, and notes
- **Companies** — target accounts with industry, size, location, and an "about" summary
- **News Items** — recent press, funding announcements, and signals linked to leads and companies
- **Outreach Templates** — cold, follow-up, and re-engagement email templates by industry
- **Research Briefs** — AI-generated summaries produced per-lead by the Lead Researcher agent

## Graph Relationships

- `WORKS_AT` — links a lead to their company
- `RESEARCHED_BY` — links a research brief back to the lead and agent that generated it

## Vector Collections

- `crm_research_briefs` — semantic search across all generated briefs
- `crm_news_items` — semantic search over news summaries for trend detection

## Composability

Pairs cleanly with the `saas`, `consulting`, and `financial-ops` data kits. The `crm_` prefix prevents entity collisions. The `research_briefs` entity is purpose-built for the Lead Researcher agent and carries an `agentId` field linking each brief to the agent run that produced it.
