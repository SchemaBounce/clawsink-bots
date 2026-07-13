---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: github-official
  displayName: "GitHub (Official)"
  version: "1.0.0"
  description: "Official GitHub MCP server (Go binary) covering repos, issues, pull requests, Actions, code and secret scanning, Dependabot, notifications, discussions, gists, projects, and security advisories"
  tags: ["github", "git", "issues", "pull-requests", "actions", "ci-cd", "security", "official"]
  category: "project-issue"
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  # Pinned release of github/github-mcp-server. The gateway's github source
  # downloads this exact asset, verifies its SHA-256 against the release's
  # published checksums, caches it, and runs it as a stdio child. The ref is
  # a pinned tag by design; never change it to "latest" or a branch name.
  packageType: "github"
  repo: "github/github-mcp-server"
  ref: "v1.3.0"
  asset: "github-mcp-server_Linux_x86_64.tar.gz"
  # The upstream binary is a cobra CLI with multiple subcommands (stdio,
  # generate-docs, ...). Launched with no args it prints usage and exits
  # instead of speaking MCP over stdio ("child_exited" at gateway start,
  # local repro 2026-07-13). "stdio" is the documented subcommand that runs
  # it as an MCP stdio server — see github/github-mcp-server's own README.
  args: ["stdio"]
env:
  # OPTIONAL: the token is bridged from the workspace's connected GitHub
  # (Settings -> Git Connections) by core-api's ResolveConnectionSecret OAuth
  # bridge, so leaving this blank uses that connection. Provide a PAT only to
  # override it. Same pattern as tools/github; required:true here would make
  # the setup/reconnect modal demand a PAT the workspace OAuth already covers.
  - name: GITHUB_PERSONAL_ACCESS_TOKEN
    description: "Optional GitHub PAT with repo, workflow, and read:org scope. Leave blank to use your connected GitHub (Settings -> Git Connections); provide one only to override."
    required: false
    sensitive: true
  - name: GITHUB_TOOLSETS
    description: "Optional comma-separated toolsets to enable (for example: all, or default,actions,notifications). Leave blank for the default set: context, repos, issues, pull_requests, users. Set to all to enable every tool listed below."
    required: false
    sensitive: false

# Declarative auth + validation + healthProbe (SchemaBounce #1614).
# Identical to tools/github: both servers authenticate against the same
# GitHub REST API with the same bearer token, so the generic validation
# engine can test credentials and probe upstream reachability without
# per-server Go code. Credentials never leave the engine; only the env-var
# name is referenced and the value substitutes at request time.
auth:
  type: http_bearer
  token_env: GITHUB_PERSONAL_ACCESS_TOKEN

validation:
  request:
    method: GET
    url: https://api.github.com/user
  expect:
    status: 200
    extract:
      authenticated_as_field: login
  on_status:
    "401": { state: needs_setup, message: "GitHub rejected the token (401). Check the PAT value and that it has not been revoked." }
    "403": { state: needs_setup, message: "Token lacks required scopes (403). Add 'repo' and 'workflow' scopes on the GitHub PAT settings page." }
    "default": { state: failed }
  timeout_ms: 5000

healthProbe:
  request:
    method: GET
    url: https://api.github.com/rate_limit
  expect:
    status: 200
  on_status:
    "default": { state: failed }
  timeout_ms: 3000
  interval_seconds: 300

# Tool list is the authoritative enumeration for the PINNED release v1.3.0,
# taken from the generated tool docs in github/github-mcp-server README.md at
# tag v1.3.0 (local stdio server tools only; remote-only Copilot Spaces and
# support-docs tools are excluded). Category = upstream toolset name, which is
# also the value you pass in GITHUB_TOOLSETS. get_label is registered in both
# the issues and labels toolsets upstream; it is listed once here under labels.
# 82 tools total.
tools:
  # actions
  - name: actions_get
    description: "Get details of GitHub Actions resources (workflows, workflow runs, jobs, and artifacts)"
    category: actions
  - name: actions_list
    description: "List GitHub Actions workflows in a repository"
    category: actions
  - name: actions_run_trigger
    description: "Trigger GitHub Actions workflow actions"
    category: actions
  - name: get_job_logs
    description: "Get GitHub Actions workflow job logs"
    category: actions
  # code_security
  - name: get_code_scanning_alert
    description: "Get a code scanning alert"
    category: code_security
  - name: list_code_scanning_alerts
    description: "List code scanning alerts for a repository"
    category: code_security
  # context
  - name: get_me
    description: "Get the authenticated user's profile"
    category: context
  - name: get_team_members
    description: "Get members of a team"
    category: context
  - name: get_teams
    description: "Get teams for the authenticated user or an organization"
    category: context
  # copilot
  - name: assign_copilot_to_issue
    description: "Assign GitHub Copilot to an issue"
    category: copilot
  - name: request_copilot_review
    description: "Request a GitHub Copilot review on a pull request"
    category: copilot
  # dependabot
  - name: get_dependabot_alert
    description: "Get a Dependabot alert"
    category: dependabot
  - name: list_dependabot_alerts
    description: "List Dependabot alerts for a repository"
    category: dependabot
  # discussions
  - name: discussion_comment_write
    description: "Manage discussion comments"
    category: discussions
  - name: get_discussion
    description: "Get a discussion"
    category: discussions
  - name: get_discussion_comments
    description: "Get comments on a discussion"
    category: discussions
  - name: list_discussion_categories
    description: "List discussion categories"
    category: discussions
  - name: list_discussions
    description: "List discussions"
    category: discussions
  # gists
  - name: create_gist
    description: "Create a gist"
    category: gists
  - name: get_gist
    description: "Get gist content"
    category: gists
  - name: list_gists
    description: "List gists"
    category: gists
  - name: update_gist
    description: "Update a gist"
    category: gists
  # git
  - name: get_repository_tree
    description: "Get the repository tree"
    category: git
  # issues
  - name: add_issue_comment
    description: "Add a comment to an issue or pull request"
    category: issues
  - name: issue_read
    description: "Get issue details"
    category: issues
  - name: issue_write
    description: "Create or update an issue or pull request"
    category: issues
  - name: list_issue_types
    description: "List available issue types"
    category: issues
  - name: list_issues
    description: "List issues for a repository"
    category: issues
  - name: search_issues
    description: "Search issues"
    category: issues
  - name: sub_issue_write
    description: "Change a sub-issue"
    category: issues
  # labels (get_label is also part of the issues toolset upstream)
  - name: get_label
    description: "Get a specific label from a repository"
    category: labels
  - name: label_write
    description: "Write operations on repository labels"
    category: labels
  - name: list_label
    description: "List labels from a repository"
    category: labels
  # notifications
  - name: dismiss_notification
    description: "Dismiss a notification"
    category: notifications
  - name: get_notification_details
    description: "Get notification details"
    category: notifications
  - name: list_notifications
    description: "List notifications"
    category: notifications
  - name: manage_notification_subscription
    description: "Manage a notification subscription"
    category: notifications
  - name: manage_repository_notification_subscription
    description: "Manage a repository notification subscription"
    category: notifications
  - name: mark_all_notifications_read
    description: "Mark all notifications as read"
    category: notifications
  # orgs
  - name: search_orgs
    description: "Search organizations"
    category: orgs
  # projects
  - name: projects_get
    description: "Get details of GitHub Projects resources"
    category: projects
  - name: projects_list
    description: "List GitHub Projects resources"
    category: projects
  - name: projects_write
    description: "Manage GitHub Projects"
    category: projects
  # pull_requests
  - name: add_comment_to_pending_review
    description: "Add a review comment to the requester's latest pending pull request review"
    category: pull_requests
  - name: add_reply_to_pull_request_comment
    description: "Add a reply to a pull request comment"
    category: pull_requests
  - name: create_pull_request
    description: "Open a new pull request"
    category: pull_requests
  - name: list_pull_requests
    description: "List pull requests for a repository"
    category: pull_requests
  - name: merge_pull_request
    description: "Merge a pull request"
    category: pull_requests
  - name: pull_request_read
    description: "Get details for a single pull request"
    category: pull_requests
  - name: pull_request_review_write
    description: "Write operations (create, submit, delete) on pull request reviews"
    category: pull_requests
  - name: search_pull_requests
    description: "Search pull requests"
    category: pull_requests
  - name: update_pull_request
    description: "Edit a pull request"
    category: pull_requests
  - name: update_pull_request_branch
    description: "Update a pull request branch with the latest base"
    category: pull_requests
  # repos
  - name: create_branch
    description: "Create a branch"
    category: repos
  - name: create_or_update_file
    description: "Create or update a file in a repository"
    category: repos
  - name: create_repository
    description: "Create a repository"
    category: repos
  - name: delete_file
    description: "Delete a file from a repository"
    category: repos
  - name: fork_repository
    description: "Fork a repository"
    category: repos
  - name: get_commit
    description: "Get commit details"
    category: repos
  - name: get_file_contents
    description: "Get file or directory contents"
    category: repos
  - name: get_latest_release
    description: "Get the latest release"
    category: repos
  - name: get_release_by_tag
    description: "Get a release by tag name"
    category: repos
  - name: get_tag
    description: "Get tag details"
    category: repos
  - name: list_branches
    description: "List branches"
    category: repos
  - name: list_commits
    description: "List commits in a repository"
    category: repos
  - name: list_releases
    description: "List releases"
    category: repos
  - name: list_repository_collaborators
    description: "List repository collaborators"
    category: repos
  - name: list_tags
    description: "List tags"
    category: repos
  - name: push_files
    description: "Push multiple files to a repository"
    category: repos
  - name: search_code
    description: "Search code across repositories"
    category: repos
  - name: search_commits
    description: "Search commits"
    category: repos
  - name: search_repositories
    description: "Search GitHub repositories"
    category: repos
  # secret_protection
  - name: get_secret_scanning_alert
    description: "Get a secret scanning alert"
    category: secret_protection
  - name: list_secret_scanning_alerts
    description: "List secret scanning alerts for a repository"
    category: secret_protection
  # security_advisories
  - name: get_global_security_advisory
    description: "Get a global security advisory"
    category: security_advisories
  - name: list_global_security_advisories
    description: "List global security advisories"
    category: security_advisories
  - name: list_org_repository_security_advisories
    description: "List repository security advisories for an organization"
    category: security_advisories
  - name: list_repository_security_advisories
    description: "List repository security advisories"
    category: security_advisories
  # stargazers
  - name: list_starred_repositories
    description: "List starred repositories"
    category: stargazers
  - name: star_repository
    description: "Star a repository"
    category: stargazers
  - name: unstar_repository
    description: "Unstar a repository"
    category: stargazers
  # users
  - name: search_users
    description: "Search users"
    category: users
---

# GitHub (Official) MCP Server

GitHub's first-party MCP server, written in Go and released at
[github/github-mcp-server](https://github.com/github/github-mcp-server). This
is the higher-fidelity alternative to `tools/github` (the community npm
package): it covers 82 tools across 19 toolsets, including GitHub Actions,
code scanning, secret scanning, Dependabot, discussions, gists, notifications,
Projects, and security advisories, none of which the npm server exposes.

The catalog pins release `v1.3.0` (published 2026-06-11). The gateway
downloads the exact release asset, verifies its SHA-256 against the release's
published checksums, and runs it as a stdio child inside the gateway pod.
Nothing is fetched from npm and no floating "latest" ref is ever used.

## Toolsets

The binary groups tools into toolsets and only starts the default set unless
told otherwise. The default set is: `context`, `repos`, `issues`,
`pull_requests`, `users`. Set the `GITHUB_TOOLSETS` connection variable to
`all` to enable every tool listed in this manifest, or to a comma-separated
list (for example `default,actions,notifications`) to add specific groups.
Each tool's `category` above is its toolset name, so the list doubles as the
`GITHUB_TOOLSETS` reference.

## Which Bots Use This

None yet. New bots that need GitHub Actions, security scanning, notifications,
discussions, or Projects should reference this server. Bots that only need
basic repo/issue/PR operations can keep using `tools/github`; the two servers
accept the same `GITHUB_PERSONAL_ACCESS_TOKEN` credential and the same
workspace OAuth bridge.

## Setup

1. Connect GitHub in Workspace Settings -> Git Connections (recommended), or
   create a Personal Access Token with `repo`, `workflow`, and `read:org`
   scopes.
2. Leave `GITHUB_PERSONAL_ACCESS_TOKEN` blank to use the workspace connection;
   paste a PAT only to override it.
3. Optionally set `GITHUB_TOOLSETS` (see Toolsets above). Blank means the
   default toolsets only.

## Hosting Notes (maintainers)

- The pinned asset `github-mcp-server_Linux_x86_64.tar.gz` is a tar.gz
  archive; upstream publishes no bare Linux binary. The gateway's github
  source (`mcp-gateway/internal/source/github.go`) currently downloads,
  chmods, and executes the asset directly with no archive extraction, and its
  checksums lookup only recognizes assets named `checksums.txt`, `checksums`,
  or `<asset>.sha256`, while this release names it
  `github-mcp-server_1.3.0_checksums.txt`. Both gaps must be closed in the
  gateway before this server can start. This manifest ships ahead of that
  work by design; the pinned repo/ref/asset above are the correct target
  state.
- To bump the version: update `ref` and re-verify the tool list against the
  README at the new tag (the upstream tool set changes between releases).
  Never relax `ref` to a branch or "latest".

## Team Usage

Add to your TEAM.md to share one GitHub (Official) server instance across
engineering bots:

```yaml
mcpServers:
  - ref: "tools/github-official"
    reason: "Engineering bots need Actions runs, security alerts, and notifications in addition to repo/issue/PR access"
    config:
      default_org: "your-org"
```
