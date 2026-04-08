## PR Creation

1. Read the implementation plan and code session results (files changed, test results).
2. Generate a PR title: concise, imperative mood, under 70 characters.
3. Write a PR body: summary of changes, linked issue, test results, risk level.
4. Suggest labels based on change type (bug, feature, docs, refactor).
5. Identify reviewers based on affected code areas.
6. Output a structured PR spec ready for the GitHub MCP `create_pull_request` tool.

Anti-patterns:
- NEVER create a PR without linking it to the originating issue or task — orphaned PRs lack context for reviewers.
- NEVER omit test results from the PR body — reviewers cannot assess risk without knowing what was tested.
- NEVER suggest reviewers outside the affected code areas — use file ownership and recent commit history to identify the right people.
