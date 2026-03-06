# Plugins

Plugins are OpenCLAW runtime extensions installed via npm. This directory does NOT contain plugin source code — it provides setup guides and recommended configurations for plugins commonly used by ClawSink bots.

## Installation

```bash
openclaw plugins install <npm-package-name>
```

## Commonly Used Plugins

| Plugin | Slot | Install | What It Does |
|--------|------|---------|-------------|
| `composio` | oauth | `openclaw plugins install composio` | Managed OAuth for 860+ apps (Gmail, Slack, GitHub, Notion, etc.) |
| `memory-lancedb` | memory | `openclaw plugins install memory-lancedb` | Vector memory with auto-recall — replaces default memory |
| `microsoft-teams` | channel | `openclaw plugins install microsoft-teams` | Teams channel with thread awareness and mention support |
| `voice-call` | channel | `openclaw plugins install voice-call` | Telephony via Twilio — outbound calls and multi-turn voice |
| `n8n-workflow` | — | `openclaw plugins install n8n-workflow` | Create, trigger, and monitor n8n workflows from agents |
| `gog` | — | `openclaw plugins install gog` | Google Workspace: Gmail, Calendar, Drive, Contacts, Sheets, Docs |
| `memos-cloud` | memory | `openclaw plugins install memos-cloud` | Cross-agent memory with async recall/save and configurable limits |
| `wacli` | channel | `openclaw plugins install wacli` | WhatsApp integration — message contacts, search history |

## Plugin Slots

Slots are exclusive — only one plugin per slot loads at a time:

- **memory**: `memory-lancedb` OR `memos-cloud` (not both)
- **channel**: `microsoft-teams` OR `voice-call` OR `wacli` (one per channel type)
- **oauth**: `composio` (currently the only OAuth manager)

Configure the active memory slot:
```
plugins.slots.memory = "memory-lancedb"
```

## Bot Plugin Dependencies

Bots declare plugin dependencies in their `BOT.md` manifest under `plugins:`. When you install a bot pack, check its `plugins:` section to see what needs to be installed. Bots with `required: true` (the default) won't start without their plugins.

## Configuration

Plugin-specific configuration goes in your workspace settings, NOT in bot manifests. Bot manifests only declare *what* plugins are needed and *why* — secrets and environment-specific config live in the workspace.
