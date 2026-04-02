---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: agentphone
  displayName: "AgentPhone"
  version: "1.0.0"
  description: "Phone and SMS for AI agents — provision numbers, send texts, make calls"
  tags: ["phone", "sms", "voice", "calls", "presence", "communication"]
  author: "agentphone"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "agentphone-mcp"]
env:
  - name: AGENTPHONE_API_KEY
    description: "API key from agentphone.to"
    required: true
tools:
  - name: account_overview
    description: "Full snapshot of account — agents, numbers, webhook, usage"
    category: account
  - name: get_usage
    description: "Detailed usage stats: plan limits, number quotas, message/call volume"
    category: account
  - name: list_numbers
    description: "List all phone numbers in the account"
    category: numbers
  - name: buy_number
    description: "Purchase a new phone number with optional area code preference"
    category: numbers
  - name: release_number
    description: "Release a phone number (irreversible)"
    category: numbers
  - name: get_messages
    description: "Get SMS messages for a specific number"
    category: sms
  - name: list_conversations
    description: "List SMS conversation threads across all numbers"
    category: sms
  - name: get_conversation
    description: "Get a conversation with full message history"
    category: sms
  - name: list_calls
    description: "List recent calls across all numbers"
    category: calls
  - name: list_calls_for_number
    description: "List calls for a specific phone number"
    category: calls
  - name: get_call
    description: "Get call details and transcript"
    category: calls
  - name: make_call
    description: "Place an outbound call using webhook for conversation"
    category: calls
  - name: make_conversation_call
    description: "Place a call with built-in AI conversation — no webhook needed"
    category: calls
  - name: list_agents
    description: "List all phone agents with numbers and voice config"
    category: agents
  - name: create_agent
    description: "Create a phone agent with voice mode, system prompt, and voice selection"
    category: agents
  - name: update_agent
    description: "Update phone agent name, voice mode, system prompt, or greeting"
    category: agents
  - name: delete_agent
    description: "Delete a phone agent (numbers kept but unassigned)"
    category: agents
  - name: get_agent
    description: "Get phone agent details including numbers and voice config"
    category: agents
  - name: attach_number
    description: "Assign a phone number to a phone agent"
    category: agents
  - name: list_voices
    description: "List available voices for phone agents"
    category: agents
  - name: get_webhook
    description: "Get project-level webhook configuration"
    category: webhooks
  - name: set_webhook
    description: "Set webhook URL for inbound messages and call events"
    category: webhooks
  - name: delete_webhook
    description: "Remove project-level webhook"
    category: webhooks
  - name: get_agent_webhook
    description: "Get webhook for a specific phone agent"
    category: webhooks
  - name: set_agent_webhook
    description: "Set webhook URL for a specific phone agent"
    category: webhooks
  - name: delete_agent_webhook
    description: "Remove agent-specific webhook (falls back to project default)"
    category: webhooks
---

# AgentPhone MCP Server

Provides phone numbers and SMS/voice capabilities for AI agents. Agents can provision their own phone numbers, send and receive SMS, make outbound calls with AI conversation, and manage call transcripts.

## Which Bots Use This

- **customer-support** — Handles inbound support calls and sends SMS updates
- **sales-pipeline** — Cold calls prospects and sends follow-up texts
- **str-guest-communicator** — Communicates with property guests via SMS/phone
- **order-fulfillment** — Sends delivery notifications via SMS
- **hr-onboarding** — Sends onboarding reminders via SMS
- **uptime-manager** — Calls on-call engineers during critical incidents

## Setup

1. Sign up at [agentphone.to](https://agentphone.to) and get your API key
2. Add `AGENTPHONE_API_KEY` to your workspace secrets
3. Use `buy_number` to provision phone numbers for agents

## Presence Integration

When a bot declares `presence.phone.provider: agentphone`, the platform:
1. Provisions a phone number for the agent via `buy_number`
2. Stores the number in `agent_external_identities`
3. Requires admin approval before activation (recurring cost + real phone number)

## Key Features

- **Sub-60 second provisioning** — no paperwork, instant phone numbers
- **Built-in AI conversation** — `make_conversation_call` handles full voice conversations without external webhooks
- **Real-time transcription** — all calls automatically transcribed
- **SMS threading** — automatic conversation threading for SMS

## Team Usage

```yaml
mcpServers:
  - ref: "tools/agentphone"
    reason: "Team bots need phone/SMS for external communication"
    config: {}
```
