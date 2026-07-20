---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: huggingface
  displayName: "Hugging Face"
  version: "1.0.0"
  description: "Hugging Face's official hosted MCP server. Search models, datasets, Spaces, and papers on the Hub"
  tags: ["huggingface", "ai", "models", "datasets", "ml"]
  category: "ai"
  author: "huggingface"
  license: "Proprietary"
# Anonymous access works (live-probed 2026-07-16: initialize succeeds with no
# credential); an optional fine-grained HF token raises rate limits and
# reaches private repos. Declarative bearer injection, same pattern as other
# http_bearer remotes.
auth:
  type: http_bearer
  token_env: HF_TOKEN

transport:
  # Official Hugging Face hosted MCP endpoint (streamable HTTP).
  type: "streamable-http"
  url: "https://huggingface.co/mcp"
env:
  - name: HF_TOKEN
    description: "Hugging Face access token from huggingface.co/settings/tokens. Optional; anonymous access works with public rate limits, a token raises limits and reaches private repos."
    required: false
    sensitive: true

validation:
  request:
    method: GET
    url: https://huggingface.co/api/whoami-v2
  expect:
    status: 200
  on_status:
    "401": { state: needs_setup, message: "Hugging Face rejected the token (401). Create a new one at https://huggingface.co/settings/tokens and update HF_TOKEN, or leave it blank for anonymous access." }
    "default": { state: failed }
  timeout_ms: 5000
---

# Hugging Face MCP Server

Hugging Face's official hosted MCP server. Agents can search the Hub for models, datasets, Spaces, and papers, and read their metadata and cards.

## Setup

1. Optional: create a read token at https://huggingface.co/settings/tokens
2. Add `HF_TOKEN` in the MCP connection setup, or leave it blank for anonymous access with public rate limits
3. The server is reached directly by URL when a bot that references it runs

## Notes

- Anonymous access works; a token raises rate limits and reaches private repos.
- Tools are served by the vendor and discovered at session start.
