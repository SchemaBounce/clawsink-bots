---
apiVersion: clawsink.schemabounce.com/v1
kind: Rule
metadata:
  name: blog-publishing
  displayName: "Blog Publishing"
  version: "2.0.0"
  description: "Public-content mutations wait for Inbox approval; no invented facts; destructive changes only when the operator asked for that specific post."
  tags: ["blog", "content", "publishing", "safety"]
  author: "schemabounce"
  license: "MIT"
severity: guardrail
---

# Blog Publishing

Guardrails for any agent that can write to a blog or CMS. Published content is customer-facing and indexed within minutes; a wrong claim, an unapproved publish, or an unrequested delete is a public event, not an internal one.

This rule attaches automatically wherever a blog/CMS MCP server declares it. Publishing is agent-driven: the operator approves each publish, update, or delete in the Inbox before it runs, and that approval is the gate the rule protects.

## What it enforces

- Every publish, update, or delete of public content goes through the Inbox approval; the agent requests it and waits.
- Destructive or content-changing actions on a published post happen only when the operator explicitly asked for that specific post; corrections prefer an update over delete-and-recreate.
- Every factual claim traces to the agent's knowledge zones or a cited source.
- One post per run unless the request explicitly asks for a series.
