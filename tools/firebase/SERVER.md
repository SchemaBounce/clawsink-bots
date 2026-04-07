---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: firebase
  displayName: "Firebase"
  version: "1.0.0"
  description: "Firebase application monitoring — logs, analytics, Firestore, and auth"
  tags: ["firebase", "google", "logs", "analytics", "firestore"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@gannonh/firebase-mcp"]
env:
  - name: GOOGLE_APPLICATION_CREDENTIALS
    description: "Path to Firebase service account JSON key"
    required: true
tools:
  - name: query_logs
    description: "Query Firebase log entries"
    category: logs
  - name: list_log_entries
    description: "List recent log entries"
    category: logs
  - name: get_analytics
    description: "Get Firebase analytics data"
    category: analytics
  - name: query_firestore
    description: "Query Firestore collection"
    category: firestore
  - name: get_document
    description: "Get a Firestore document"
    category: firestore
  - name: list_collections
    description: "List Firestore collections"
    category: firestore
  - name: list_users
    description: "List Firebase Auth users"
    category: auth
  - name: get_user
    description: "Get Firebase Auth user details"
    category: auth
  - name: get_crash_reports
    description: "Get Crashlytics crash reports"
    category: crashes
---

# Firebase MCP Server

Provides Firebase API tools for bots that need application monitoring, Firestore data access, analytics, and user management.

## Which Bots Use This

- **sre-devops** -- Log monitoring, crash analysis via Crashlytics, and real-time error detection
- **data-analyst** -- Analytics queries and Firestore data exploration for business insights

## Setup

1. Create a Firebase service account and download the JSON key file
2. Add the path to the key file as `GOOGLE_APPLICATION_CREDENTIALS` in your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Firebase server instance across bots:

```yaml
mcpServers:
  - ref: "tools/firebase"
    reason: "Application monitoring bots need Firebase access for logs, analytics, and crash reports"
    config:
      default_project: "your-firebase-project-id"
```
