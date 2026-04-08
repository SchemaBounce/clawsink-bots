---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: twilio
  displayName: "Twilio"
  version: "1.0.0"
  description: "Twilio communications — SMS, voice calls, and messaging"
  tags: ["twilio", "sms", "voice", "messaging", "communications"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@twilio-alpha/mcp@0.7.0"]
env:
  - name: TWILIO_ACCOUNT_SID
    description: "Twilio Account SID from twilio.com/console"
    required: true
  - name: TWILIO_AUTH_TOKEN
    description: "Twilio Auth Token from twilio.com/console"
    required: true
tools:
  - name: send_sms
    description: "Send an SMS message"
    category: sms
  - name: list_messages
    description: "List SMS messages"
    category: sms
  - name: get_message
    description: "Get details of a specific message"
    category: sms
  - name: make_call
    description: "Initiate a voice call"
    category: voice
  - name: list_calls
    description: "List voice calls"
    category: voice
  - name: get_call
    description: "Get details of a specific call"
    category: voice
  - name: list_phone_numbers
    description: "List phone numbers on the account"
    category: numbers
  - name: lookup_phone_number
    description: "Look up information about a phone number"
    category: numbers
---

# Twilio MCP Server

Provides Twilio communications tools for SMS, voice calls, and phone number management. An alternative to agentphone for bots that need direct Twilio API access.

## Which Bots Use This

- **customer-support** -- Sends SMS notifications and follow-ups to customers
- **sales-pipeline** -- Sends outreach SMS and initiates demo call scheduling
- **executive-assistant** -- Sends reminders and notifications via SMS
- **incident-commander** -- Sends SMS alerts during incidents

## Setup

1. Get your Account SID and Auth Token from the [Twilio Console](https://www.twilio.com/console)
2. Add them to your workspace secrets as `TWILIO_ACCOUNT_SID` and `TWILIO_AUTH_TOKEN`
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Twilio server instance across bots:

```yaml
mcpServers:
  - ref: "tools/twilio"
    reason: "Bots need SMS and voice capabilities for customer communication"
    config:
      default_from_number: "+1234567890"
```
