---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: llms-txt-generator
  displayName: "llms.txt Generator"
  version: "1.0.0"
  description: "Generates llms.txt and llms-full.txt files for a website — the emerging standard for making web content accessible to AI language models and answer engines."
  tags: ["geo", "aeo", "llms-txt", "ai-discovery", "seo", "content"]
  author: "aircodelabs"
  license: "MIT"
# npm package: llms-txt-generator (https://www.npmjs.com/package/llms-txt-generator)
# Published on npm at version 0.0.3 (verified 2026-06-11 via registry.npmjs.org).
# GitHub: github.com/aircodelabs/llms-txt-generator
#
# The package ships two binaries:
#   llms-txt-generator   — CLI tool (build/init/help commands)
#   llms-txt-generator-mcp — MCP server exposing the generate-llms tool
#
# Since the MCP binary name differs from the package name, we use the
# --package= flag so npx installs the package and then executes the
# correct binary rather than the default CLI binary.
#
# This MCP is used by the seo-expert bot's GEO/AEO workflow to draft
# llms.txt content for schemabounce.com. The draft is stored in ADL
# (entity_type=seo_llms_txt_draft) for human review before publishing.
# It does NOT push directly to production.
#
# AUTH: OPENAI_API_KEY is required. The generate-llms tool calls OpenAI
# to synthesize content descriptions from the project's documentation
# structure. Without a key the tool errors immediately.
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "--package=llms-txt-generator@0.0.3", "llms-txt-generator-mcp"]

env:
  - name: OPENAI_API_KEY
    description: "OpenAI API key used internally by the llms-txt-generator to synthesize content descriptions. Required for the generate-llms tool to run. Create at platform.openai.com/api-keys."
    required: true
    sensitive: true

tools:
  - name: generate-llms
    description: "Generate llms.txt and llms-full.txt files for the current project based on its documentation structure and user requirements."
    category: content
---

# llms.txt Generator MCP Server

Generates `llms.txt` and `llms-full.txt` documentation files following the [llmstxt.org](https://llmstxt.org) specification. These files give AI assistants a structured, low-noise summary of a website's content — the same role `robots.txt` plays for crawlers.

## Why This Matters for GEO

Answer engines (ChatGPT, Perplexity, Claude) read structured content more reliably than raw HTML. A well-formed `llms.txt` reduces the chance that an AI misrepresents or omits your product. It is a tactic, not a magic lever — the file amplifies good content, it does not substitute for it.

## How the seo-expert Bot Uses This

The bot's GEO sub-agent calls `generate-llms` to produce a draft `llms.txt` for `schemabounce.com`, then:

1. Stores the draft in ADL as `entity_type=seo_llms_txt_draft` for human review.
2. Diffs it against the previously approved draft (if any) to surface what changed.
3. Flags the draft for a human to review and deploy to `https://schemabounce.com/llms.txt`.

The bot does **not** push directly to production. Deployment is a human step.

## Setup

1. Add `OPENAI_API_KEY` in the MCP connection setup (the generator uses GPT to synthesize descriptions).
2. Connect this MCP server from the SEO Expert deploy modal.

## Team Usage

```yaml
mcpServers:
  - ref: "tools/llms-txt-generator"
    required: false
    reason: "GEO tactic: generate and maintain llms.txt for AI-discovery"
```
