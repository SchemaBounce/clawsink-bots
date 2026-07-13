---
apiVersion: clawsink.schemabounce.com/v1
kind: Rule
metadata:
  name: blog-publishing
  displayName: "Blog Publishing"
  version: "1.0.0"
  description: "Drafts only: no direct publishing, no invented facts, no deleting published posts."
  tags: ["blog", "content", "publishing", "safety"]
  author: "schemabounce"
  license: "MIT"
severity: guardrail
appliesTo:
  - tools/blog
---

# Blog Publishing

Guardrails for any agent that can write to the blog. Published content is customer-facing and indexed within minutes; a wrong claim or an accidental publish is a public event, not an internal one.

This rule attaches automatically wherever the `tools/blog` MCP server is granted. The draft-then-review flow it enforces matches the blog connector's design: `blog_create_draft` and `blog_submit_review` are agent-callable, approval is human-only.

## What it enforces

- Drafts only; a human approves publication.
- Every factual claim traces to zone1 data or a cited source.
- Compliance wording stays honest: "SOC 2 Type II in progress", never "certified".
- Published posts are never deleted or overwritten; corrections ship as new revision drafts.
