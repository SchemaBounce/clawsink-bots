#!/bin/bash
# Probe a remote MCP server's OAuth discovery chain, mirroring core-api's
# mcpoauth.Discover (RFC 9728 protected-resource challenge -> RFC 8414
# authorization-server metadata -> RFC 7591 dynamic client registration).
#
# Usage: probe-remote-mcp.sh <name> <url>
#
# Output (one line, pipe-delimited):
#   <name>|OK|<authorization_server>|dcr=yes|scopes=<space-separated list>
#   <name>|OK|<authorization_server>|dcr=NO|scopes=...     (needs a pinned client, see mcp-byo.md P2-2)
#   <name>|NO_CHALLENGE|http=<code>                        (no 401 on POST or GET; try another path, or it isn't oauth2_mcp-shaped)
#   <name>|NO_PR_METADATA|challenge=yes                    (401 seen but no oauth-protected-resource doc found)
#   <name>|NO_AS_METADATA|as=<url>                         (protected-resource doc found but AS metadata missing/broken)
#
# Only an OK+dcr=yes result is sufficient to author an oauth2_mcp (DCR)
# SERVER.md entry per docs/claude/... MCP OAuth client program rules. A
# 403/blocked response (common on Cloudflare-fronted vendor domains hitting
# bot protection) is NOT a verdict either way — it means "re-probe from a
# real browser session or ask the vendor", not "no MCP server here". Note
# that in remote-mcp-candidates.txt as BLOCKED, not as a miss.
#
# This script is self-contained: bash + curl + python3 (stdlib only).

set -u
name="${1:?usage: probe-remote-mcp.sh <name> <url>}"
url="${2:?usage: probe-remote-mcp.sh <name> <url>}"
UA="SchemaBounce-catalog-probe"
TO=12

# Step 1: hit the MCP URL, expect a 401 challenge (POST initialize, fall back GET).
hdrs=$(curl -sS -o /dev/null -D - -m "$TO" -A "$UA" -X POST "$url" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  --data '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"0"}}}' 2>/dev/null)
code=$(echo "$hdrs" | head -1 | awk '{print $2}')
www=$(echo "$hdrs" | grep -i '^www-authenticate:' | head -1)
if [ "$code" != "401" ]; then
  hdrs2=$(curl -sS -o /dev/null -D - -m "$TO" -A "$UA" "$url" 2>/dev/null)
  code2=$(echo "$hdrs2" | head -1 | awk '{print $2}')
  if [ "$code2" = "401" ]; then code="401"; www=$(echo "$hdrs2" | grep -i '^www-authenticate:' | head -1); fi
fi
if [ "$code" != "401" ]; then
  # Some servers (e.g. Gusto) never 401 the initialize call itself but still
  # publish a root-level oauth-protected-resource document. Fall through to
  # step 2 against the URL's origin before giving up.
  origin_fallback=$(echo "$url" | sed -E 's#^(https://[^/]+).*#\1#')
  pr_fallback=$(curl -sS -m "$TO" -A "$UA" "$origin_fallback/.well-known/oauth-protected-resource" 2>/dev/null)
  as_fallback=$(echo "$pr_fallback" | python3 -c "import sys,json;d=json.load(sys.stdin);print((d.get('authorization_servers') or [''])[0])" 2>/dev/null)
  if [ -z "$as_fallback" ]; then
    echo "$name|NO_CHALLENGE|http=$code"
    exit 0
  fi
  as="$as_fallback"
else
  # Step 2: protected-resource metadata (from the challenge, else well-known).
  prurl=$(echo "$www" | grep -o 'resource_metadata="[^"]*"' | cut -d'"' -f2)
  origin=$(echo "$url" | sed -E 's#^(https://[^/]+).*#\1#')
  path=$(echo "$url" | sed -E 's#^https://[^/]+##')
  [ -z "$prurl" ] && prurl="$origin/.well-known/oauth-protected-resource$path"
  pr=$(curl -sS -m "$TO" -A "$UA" "$prurl" 2>/dev/null)
  as=$(echo "$pr" | python3 -c "import sys,json;d=json.load(sys.stdin);print((d.get('authorization_servers') or [''])[0])" 2>/dev/null)
  if [ -z "$as" ]; then
    pr=$(curl -sS -m "$TO" -A "$UA" "$origin/.well-known/oauth-protected-resource" 2>/dev/null)
    as=$(echo "$pr" | python3 -c "import sys,json;d=json.load(sys.stdin);print((d.get('authorization_servers') or [''])[0])" 2>/dev/null)
  fi
  if [ -z "$as" ]; then echo "$name|NO_PR_METADATA|challenge=yes"; exit 0; fi
fi

# Step 3: AS metadata (oauth-authorization-server, else openid-configuration;
# each tried at both the AS-path-suffixed well-known location per RFC 8414
# section 3.1 and the bare-origin well-known location some vendors use).
asbase=$(echo "$as" | sed 's#/$##')
asorigin=$(echo "$asbase" | sed -E 's#^(https://[^/]+).*#\1#')
aspath=$(echo "$asbase" | sed -E 's#^https://[^/]+##')
meta=""
for u in "$asorigin/.well-known/oauth-authorization-server$aspath" "$asbase/.well-known/oauth-authorization-server" "$asorigin/.well-known/openid-configuration$aspath" "$asbase/.well-known/openid-configuration"; do
  m=$(curl -sS -m "$TO" -A "$UA" "$u" 2>/dev/null)
  ok=$(echo "$m" | python3 -c "import sys,json;d=json.load(sys.stdin);print('y' if d.get('authorization_endpoint') and d.get('token_endpoint') else '')" 2>/dev/null)
  if [ "$ok" = "y" ]; then meta="$m"; break; fi
done
if [ -z "$meta" ]; then echo "$name|NO_AS_METADATA|as=$as"; exit 0; fi

echo "$meta" | python3 -c "
import sys, json
d = json.load(sys.stdin)
reg = 'dcr=yes' if d.get('registration_endpoint') else 'dcr=NO'
sc = d.get('scopes_supported') or []
print('$name|OK|$as|%s|scopes=%s' % (reg, ' '.join(sc[:6]) if sc else '(none advertised)'))"
