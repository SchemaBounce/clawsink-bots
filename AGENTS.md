# Working in clawsink-bots: notes for agents

`README.md` describes this repository. This file carries the text other agents read. The SchemaBounce decisions
block below is rendered by the SchemaBounce agent kit (`schemabounce@schemabounce`)
and checked by `scripts/check-agent-kit.py`; it is never edited by hand.

<!-- schemabounce-agent-kit:decisions start kit=0.4.2 sha256=1ef8bae21c26f91ebe47412932918dc0aacec921a8aed89c97ecf4ad7fc28bcc -->
## SchemaBounce decisions

SchemaBounce records its rulings as decision records (`dec-NNN`) in its
Context Engine. An accepted decision is the authority for its subject; when
any other text disagrees with it, the decision wins.

- Before changing anything a decision may govern (architecture, pricing,
  security, licensing, infrastructure, product behaviour), find the accepted
  decisions that apply through the SchemaBounce MCP and follow them.
- Use only `accepted` decisions. Ignore `superseded` and `rejected` ones; a
  `proposed` decision is not binding.
- Cite the ids you relied on in your plan, report and commit message.
- If a change contradicts an accepted decision, stop and say which one; do not
  code around it.
- Read a decision's status in the same turn before you report it; never
  repeat it from memory.
- Propose, never ratify. Corrections and merges are new proposals whose
  `supersedes` lists the old ids.

Full procedure: `skills/schemabounce-decisions/SKILL.md` from
https://github.com/SchemaBounce/schemabounce-agent-kit.

### Getting the kit

This repository enables the SchemaBounce agent kit for everyone in
`.claude/settings.json`. Once per machine: accept Claude Code's folder-trust
dialog, run `claude plugin install schemabounce@schemabounce --scope project`
(Claude Code prompts for it), then sign in to the SchemaBounce MCP with `/mcp`.
No GitHub SSH key is needed. Codex and other agents: copy
`skills/schemabounce-decisions/` from the kit and add the hosted MCP
(https://mcp.schemabounce.com/mcp) to their configuration.
<!-- schemabounce-agent-kit:decisions end -->

