---
apiVersion: clawsink.schemabounce.com/v1
kind: Skill
metadata:
  name: ui-navigation
  displayName: "UI Navigation"
  version: "1.0.0"
  description: "Look up real console paths, deep links, and permission gates instead of recalling navigation that has moved."
  tags: ["navigation", "console", "ui", "permissions", "docs"]
  author: "schemabounce"
  license: "MIT"
tools:
  required: ["adl_find_ui_path", "adl_get_ui_map", "adl_search_docs"]
data:
  producesEntityTypes: []
  consumesEntityTypes: []
---
# UI Navigation

Answers "where do I do X in the console?" from the live navigation map instead of from memory. The console is reworked regularly: destinations move between sections, labels change, and every destination carries a required permission and an enabled state. An agent that recalls a path rather than looking one up sends people to screens that are gone, gated, or switched off, and the product takes the blame.

## When to Use

- Someone asks where a setting, page, or feature lives
- You are about to write any console link or any `Settings > X` breadcrumb, in a chat reply, a message to another agent, a record, a report, or a document
- You need a human to finish something you cannot do yourself: approve, pay, grant, rotate, connect
- You are not sure the destination exists at all

## What You Get

- **`adl_find_ui_path(query)`**: one lookup, plain language in. The response names the section, the label, the path, the permission the destination requires, and whether it is enabled.
- **`adl_get_ui_map(section?)`**: the whole navigation tree, or one section of it. Use it when you are orienting rather than answering a single question.
- **`adl_search_docs(query)`**: the documentation, for when the answer is a procedure rather than a screen.
- **Permission and enabled state on every destination**, so an answer can say "you will need `billing:view` for this" instead of sending a member to a page that renders nothing for them.
- **Deep links**: console URLs are shaped `/workspaces/{workspaceId}/...` and accept query params, so one link can land someone on the exact agent and tab they need.

## The Sections

Work, Agents, Context Engine, Data, Kolumn, Settings. Six sections, 35 destinations.

That list is the shape of the map, not the map. `adl_get_ui_map` is the map. Section names are stable enough to say out loud; the destinations inside them are not, which is the whole reason this skill exists.

## What This Replaces

Guessing. Older documentation and older agent habits teach `Settings > X` breadcrumbs that no longer resolve, and a guessed path is indistinguishable from a real one until the person clicking it wastes a minute finding out. Looking it up costs one tool call.
