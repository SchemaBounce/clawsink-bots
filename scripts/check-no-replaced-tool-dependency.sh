#!/usr/bin/env bash
# Guard: no bot or template may depend on a tool whose job the platform does
# itself. Workflows, app building and scraping run on SchemaBounce capabilities,
# so a first-party manifest that lists one of these makes a customer connect
# someone else's product to use ours. Customers can still connect any of them
# from the catalog: this checks our manifests, never tools/.
#
# Usage: ./scripts/check-no-replaced-tool-dependency.sh   (exit 1 on any hit)

set -euo pipefail
cd "$(dirname "$0")/.."

replaced='zapier|make|n8n|lovable|retool|keboola|val-town|skyvern|apify'
hits=$(grep -rnE "(tools|plugins)/($replaced)([@\"' ]|$)|\b($replaced)[a-z-]*@" bots/*/BOT.md templates/*/TEMPLATE.md || true)
if [ -n "$hits" ]; then
  echo "A bot or template depends on a tool the platform replaces. Use the built-in capability:" >&2
  echo "$hits" >&2
  exit 1
fi
