---
apiVersion: clawsink.schemabounce.com/v1
kind: DataKit
metadata:
  name: customer-service
  displayName: Customer Service
  version: "1.0.0"
  description: "Customer support tickets, contact records, conversation history, feedback, and NPS responses for service teams"
  domain: customer-service
  category: domain
  tags:
    - customer-service
    - support
    - tickets
    - nps
    - feedback
    - csat
    - conversations
  author: SchemaBounce
compatibility:
  teams: ["customer-service-team"]
  composableWith:
    - sales
    - marketing
entityPrefix: "cs_"
entityCount: 5
graphEdgeTypes:
  - CONTACTED_BY
  - ESCALATED_TO
  - LINKED_TO_CONTACT
vectorCollections:
  - cs_tickets
  - cs_conversations
---

# Customer Service

A domain data kit for customer service teams. Covers the core entities: support tickets, contacts, conversation history, customer feedback, and NPS responses.

## What's Included

- **Tickets** - support tickets with severity, SLA tracking, channel, status, and CSAT scores
- **Contacts** - customer contact records linked to tickets and conversations
- **Conversations** - full conversation history with transcripts and resolution notes
- **Feedback** - post-interaction satisfaction ratings and free-text comments
- **NPS Responses** - Net Promoter Score survey results with segment and follow-up tracking

## Key KPIs Tracked

| KPI | Target | Why It Matters |
|-----|--------|----------------|
| First Response Time | <4 hours (standard), <1 hour (priority) | Sets the tone for resolution quality |
| Resolution Rate (first contact) | >70% | Repeated contacts cost 2-3x more to resolve |
| CSAT Score | >4.2 / 5 | Strong predictor of renewal and expansion |
| NPS | >40 | Measures loyalty and advocacy potential |
| Ticket Backlog Growth | <5% week-over-week | Uncontrolled growth signals capacity issues |

## Graph Relationships

- `CONTACTED_BY` links tickets to customer contacts
- `ESCALATED_TO` links a ticket to the escalation target (agent or team)
- `LINKED_TO_CONTACT` links conversations and NPS responses to contacts

## Composability

Pairs well with `sales` for full customer lifecycle visibility, and with `sales` when churn risk identified in support feeds into pipeline intelligence.
