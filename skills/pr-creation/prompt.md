## PR Creation

1. Read the implementation plan and code session results (files changed, test results).
2. Generate a PR title: concise, imperative mood, under 70 characters.
3. Write a PR body: summary of changes, linked issue, test results, risk level.
4. Suggest labels based on change type (bug, feature, docs, refactor).
5. Identify reviewers based on affected code areas.
6. Output a structured PR spec. Pass its title and body to `adl_push_code_session` (session_id, commit_message, open_pr: true, pr_title, pr_body), the built-in tool that commits, pushes the work branch and opens the pull request through the workspace's GitHub App. A session that ends without this call leaves its work as a local commit and no pull request exists. The push may wait for a person's approval; when the tool says so, report the escalation and stop instead of calling it again. Use the GitHub MCP `create_pull_request` tool only when that server is connected and the branch is already on GitHub.

Anti-patterns:
- NEVER create a PR without linking it to the originating issue or task — orphaned PRs lack context for reviewers.
- NEVER omit test results from the PR body — reviewers cannot assess risk without knowing what was tested.
- NEVER suggest reviewers outside the affected code areas — use file ownership and recent commit history to identify the right people.
