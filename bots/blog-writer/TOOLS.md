# Data Access

- Query `blog_topics`: `adl_query_records` — filter by status or category to find pending topics
- Query `product_docs`: `adl_query_records` — filter by feature area for research source material
- Write `blog_drafts`: `adl_upsert_record` — ID format `draft_{category}_{date}`, required fields: title, body, category, status="draft", target_publish_date
- Write `editorial_notes`: `adl_upsert_record` — ID format `note_{topic_slug}`, attach research gaps or revision feedback

# Memory Usage

- `editorial_calendar`: scheduled topics, in-progress markers, last category written — use `adl_write_memory` to update after each run
- `writing_notes`: research outlines, draft state, revision history — use `adl_write_memory` to save progress
- `topic_research`: validated source material gathered during the research phase — use `adl_add_memory` to append findings

# MCP Server Tools

## Your blog/CMS connector (recommended connection)

The bot publishes through whichever CMS connector you attach at activation: tools/webflow, tools/contentful, tools/sanity, or tools/notion for hosted CMSs, or tools/github for git-backed sites. Credentials live on the connection, not the agent.

The typical CMS tool shape:

- a create-draft tool: create a new post — returns a post id; save it
- a publish tool: make the post live. Publishing is a public-content mutation, so the call pauses for the operator's Inbox approval; request it and wait
- an update tool: correct a live post — read the current content first, send the complete replacement. Also Inbox-approved
- a delete tool: only for a specific post the operator explicitly asked to remove. Also Inbox-approved
- a list tool: check existing posts for duplicate-topic overlap before drafting

## tools/github (recommended connection)

- `github.create_pull_request`: publish blog post drafts as PRs to the content repository
- `github.get_file_contents`: read existing blog posts to check for topic overlap

# Work Phases (single agent, no spawning)

You produce each post yourself in three sequential phases. There are no sub-agents and no `sessions_spawn` tool. To address a real teammate, discover it first with `adl_list_agents`; never invent an agent name.

1. **Research** — validate topic feasibility, gather source material from product docs and the knowledge graph (`adl_query_records`, `adl_search_memory`). Append findings to `topic_research` memory.
2. **Draft** — write the full blog post from your research notes, following the editorial guidelines. Save progress to `writing_notes` memory.
3. **Self-edit** — review your own draft for voice, accuracy, and style guide adherence. Revise until it passes, up to 2 revision cycles, then create the draft in your connected CMS and request publish approval.
