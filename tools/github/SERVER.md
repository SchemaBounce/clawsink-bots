---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: github
  displayName: "GitHub"
  version: "1.0.0"
  description: "GitHub API tools for issues, pull requests, repos, and actions"
  tags: ["github", "git", "issues", "pull-requests", "ci-cd"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "@modelcontextprotocol/server-github"]
env:
  - name: GITHUB_PERSONAL_ACCESS_TOKEN
    description: "GitHub PAT with repo and issues scope"
    required: true
tools:
  - name: create_or_update_file
    description: "Create or update a file in a repository"
    category: repos
  - name: search_repositories
    description: "Search GitHub repositories"
    category: repos
  - name: create_repository
    description: "Create a new repository"
    category: repos
  - name: get_file_contents
    description: "Read file contents from a repository"
    category: repos
  - name: push_files
    description: "Push multiple files to a repository"
    category: repos
  - name: create_issue
    description: "Create a new issue"
    category: issues
  - name: create_pull_request
    description: "Create a pull request"
    category: pull-requests
  - name: fork_repository
    description: "Fork a repository"
    category: repos
  - name: create_branch
    description: "Create a new branch"
    category: repos
  - name: list_issues
    description: "List issues for a repository"
    category: issues
  - name: update_issue
    description: "Update an existing issue"
    category: issues
  - name: add_issue_comment
    description: "Add a comment to an issue"
    category: issues
  - name: search_code
    description: "Search code across repositories"
    category: repos
  - name: search_issues
    description: "Search issues and pull requests"
    category: issues
  - name: list_commits
    description: "List commits in a repository"
    category: repos
  - name: get_issue
    description: "Get details of a specific issue"
    category: issues
  - name: get_pull_request
    description: "Get details of a pull request"
    category: pull-requests
  - name: list_pull_requests
    description: "List pull requests for a repository"
    category: pull-requests
  - name: create_pull_request_review
    description: "Submit a review on a pull request"
    category: pull-requests
  - name: merge_pull_request
    description: "Merge a pull request"
    category: pull-requests
  - name: get_pull_request_files
    description: "List files changed in a pull request"
    category: pull-requests
  - name: get_pull_request_status
    description: "Get combined status checks for a pull request"
    category: pull-requests
  - name: update_pull_request_branch
    description: "Update a pull request branch with latest base"
    category: pull-requests
  - name: get_pull_request_comments
    description: "Get review comments on a pull request"
    category: pull-requests
  - name: get_pull_request_reviews
    description: "Get reviews on a pull request"
    category: pull-requests
---

# GitHub MCP Server

Provides comprehensive GitHub API tools for bots that manage code, issues, pull requests, and repositories.

## Which Bots Use This

- **devrel** -- Monitors repo stars, issues, contributions, and community activity
- **software-architect** -- Creates branches, PRs, manages issues for architecture work
- **documentation-writer** -- Creates documentation PRs
- **code-reviewer** -- Reviews PRs, adds comments
- **bug-triage** -- Creates bug issues, searches for duplicates
- **release-manager** -- Creates release branches, merges PRs, tags releases
- **release-notes-writer** -- Lists commits and merged PRs for changelogs
- **devops-automator** -- Monitors CI/CD pipelines and GitHub Actions
- **security-agent** -- Scans repos for security vulnerabilities
- **tech-debt-tracker** -- Tracks technical debt across repos
- **blog-writer** -- Publishes posts via PR to content repo

## Setup

1. Create a GitHub Personal Access Token with `repo` and `issues` scopes
2. Add it to your workspace secrets as `GITHUB_PERSONAL_ACCESS_TOKEN`
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single GitHub server instance across all engineering bots:

```yaml
mcpServers:
  - ref: "tools/github"
    reason: "Engineering bots need GitHub access for code review, issue tracking, and releases"
    config:
      default_org: "your-org"
```
