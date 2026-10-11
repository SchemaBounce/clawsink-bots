---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: wordpress
  displayName: "WordPress"
  version: "1.0.0"
  description: "Automattic's WordPress MCP proxy: read and write posts, pages, media and site settings on a self-hosted WordPress site that runs the MCP Adapter plugin."
  tags: ["website", "cms", "wordpress", "publishing", "web"]
  category: "cms"
  author: "automattic"
  # Upstream package license (npm @automattic/mcp-wordpress-remote). The
  # gateway runs it as an unmodified child process.
  license: "GPL-2.0-or-later"
transport:
  # Official Automattic proxy (npm @automattic/mcp-wordpress-remote, bin
  # mcp-wordpress-remote). Verified 2026-10-10: latest 0.5.1 (published
  # 2026-10-06), stdio transport. Pinned like other npm entries. It forwards
  # MCP traffic unchanged to the site's MCP Adapter endpoint and adds the
  # site's authentication. Docs: https://github.com/Automattic/mcp-wordpress-remote
  # The site needs the WordPress MCP Adapter plugin (developer.wordpress.org,
  # 2026-02); WordPress.com sites use @automattic/mcp-wpcom-remote instead,
  # which is a separate catalog entry when a workspace needs it.
  type: "stdio"
  command: "npx"
  args: ["-y", "@automattic/mcp-wordpress-remote@0.5.1"]
env:
  # Headless auth path: a WordPress application password for a user with
  # the editor or administrator role. The package's OAuth 2.1 browser flow
  # cannot complete inside the gateway pod, so the application password is
  # required here. Env names verified against the 0.5.1 README:
  # WP_API_URL, WP_API_USERNAME, WP_API_PASSWORD, JWT_TOKEN, CUSTOM_HEADERS,
  # WOO_CUSTOMER_KEY, WOO_CUSTOMER_SECRET, LOG_FILE.
  - name: WP_API_URL
    description: "The site's MCP Adapter endpoint, e.g. https://example.com/wp-json/mcp/mcp-adapter-default-server"
    required: true
    sensitive: false
  - name: WP_API_USERNAME
    description: "WordPress user name the agent acts as (editor or administrator)"
    required: true
    sensitive: false
  - name: WP_API_PASSWORD
    description: "An application password for that user (Users -> Profile -> Application Passwords). Not the login password."
    required: true
    sensitive: true

# No validation/healthProbe block: the application password is checked by
# the proxy on the first forwarded call, and the site's endpoint path varies
# per install.
---

# WordPress MCP Server

Automattic's proxy for a self-hosted WordPress site that runs the MCP Adapter
plugin. Agents read and write posts, pages, media and settings through the
site's own REST capabilities, as the WordPress user the connection names.

## What the site needs

1. WordPress 6.9 or newer with the **MCP Adapter** plugin active (the
   WordPress project's own adapter, February 2026). Its default endpoint is
   `/wp-json/mcp/mcp-adapter-default-server`.
2. A user with the editor or administrator role, and an **application
   password** created for that user under Users -> Profile -> Application
   Passwords. Paste the generated password here; it is stored encrypted and
   injected at session start. Agents never see it.

## Notes

- Everything the agent publishes is attributed to that WordPress user; use a
  dedicated user so the site's history says which changes an agent made.
- WordPress.com sites: the same proxy exists as `@automattic/mcp-wpcom-remote`
  with WordPress.com OAuth; it is not this entry.
- Tools are served by the site's adapter and discovered at session start
  (posts, pages, media, taxonomies, settings, plus whatever abilities the
  site's plugins register).
