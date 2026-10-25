# Bot Guidance Stays Generic: No Vendor Tool Names in Bots or Skills

## Loaded when

Writing or editing any `bots/*/BOT.md`, `SOUL.md`, `TOOLS.md`, `AGENTS.md`,
`IDENTITY.md`, or any bot or skill instruction text.

## Rule (owner ruling, repeated; recorded 2026-10-16)

**Bot and skill text never names a third-party MCP server's tools, routes,
fields or error codes, and never names the vendor as the way to do a step.**
It describes the behaviour and the evidence it needs ("open the page with a
connected browser tool and take a screenshot", "prefer a server's
higher-level tools as their descriptions explain them over raw field
writes"). The agent learns a server's tools from the server: its tool list,
its descriptions, and `adl_tool_search`.

May appear:

- Platform tools (`adl_*`, `code_session_*`, pack tools such as
  `contrast_ratio`): they are the same in every workspace.
- A setup step's `ref: tools/<name>` for a connection the bot cannot work
  without, as it already exists for publishing targets.
- A server's own tool names inside its own `tools/<name>/SERVER.md`.

Never:

- `<vendor>_<tool>` or `<plugin>-<tool>` names in a bot or skill
  (`browserbase_screenshot`, `elementor-get-page-structure`).
- A vendor's private routes, field paths or error codes as instructions.
- "Use <vendor>" as the only way to do a step that any connected server with
  the capability could do.

Before committing, grep the diff of every bot and skill file for vendor and
tool names; each hit must be a platform tool or a `ref`.

## Why

Workspaces connect different servers, custom servers included, and vendors
rename and retire tools. A bot that names one vendor's tools breaks for every
workspace that connected something else, and for everyone the day the vendor
renames a tool. Generic guidance keeps working with any server that has the
capability.
