---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: trello
  displayName: "Trello"
  version: "1.0.0"
  description: "Trello boards — cards, lists, boards, and checklists"
  tags: ["trello", "kanban", "project-management", "boards"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "trello-mcp@1.0.3"]
env:
  - name: TRELLO_API_KEY
    description: "Trello API key from trello.com/power-ups/admin"
    required: true
  - name: TRELLO_TOKEN
    description: "Trello API token from trello.com/power-ups/admin"
    required: true
tools:
  - name: list_boards
    description: "List all boards for the authenticated user"
    category: boards
  - name: get_board
    description: "Get details of a specific board"
    category: boards
  - name: list_cards
    description: "List cards on a board or in a list"
    category: cards
  - name: create_card
    description: "Create a new card on a list"
    category: cards
  - name: update_card
    description: "Update an existing card"
    category: cards
  - name: move_card
    description: "Move a card to a different list or board"
    category: cards
  - name: list_lists
    description: "List all lists on a board"
    category: lists
  - name: add_checklist
    description: "Add a checklist to a card"
    category: checklists
---

# Trello MCP Server

Provides Trello API tools for bots that manage kanban boards, cards, lists, and checklists.

## Which Bots Use This

- **project-manager** -- Tracks tasks across kanban boards, moves cards through stages
- **executive-assistant** -- Creates and organizes cards for action items from meetings

## Setup

1. Get your Trello API key and token from [trello.com/power-ups/admin](https://trello.com/power-ups/admin)
2. Add `TRELLO_API_KEY` and `TRELLO_TOKEN` to your workspace secrets
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Trello server instance across bots:

```yaml
mcpServers:
  - ref: "tools/trello"
    reason: "Bots need Trello access for task tracking and kanban board management"
    config:
      default_board: "Sprint Board"
```
