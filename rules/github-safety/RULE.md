---
apiVersion: clawsink.schemabounce.com/v1
kind: Rule
metadata:
  name: github-safety
  displayName: "GitHub Safety"
  version: "1.0.0"
  description: "Destructive GitHub operations are off-limits: no force-push, no deletions, no direct pushes to protected branches."
  tags: ["github", "git", "safety"]
  author: "schemabounce"
  license: "MIT"
severity: hard
appliesTo:
  - tools/github
# Deterministic half of the rule. The prompt text below asks the agent not to do
# these things; this block means the platform will not let it, whatever the model
# decides. Only honoured on severity: hard.
enforce:
  denyTools:
    - "*_delete_repository"
    - "*_delete_repo"
    - "*_force_push"
  askTools:
    - "*_merge_pull_request"
---

# GitHub Safety

Non-negotiable guardrails for any agent with GitHub access. GitHub is where irreversible damage happens fastest: a force-push rewrites shared history, a deleted branch takes its review trail with it, and a direct push to main skips every human gate a team has set up.

This rule attaches automatically wherever the `tools/github` MCP server is granted. It does not grant or restrict any tool; it constrains how the granted tools are used. Deterministic enforcement of the deletion ban is layered separately by the platform.

## What it enforces

- No force-push, ever. A rejected push is a signal to stop and report, not to overwrite.
- No deletion of repositories, branches, tags, or releases. Deletions route to a human.
- No direct pushes to protected branches; changes arrive by pull request.
- No merging a pull request the run's instructions did not explicitly name.
- No editing or deleting other authors' comments and reviews.
