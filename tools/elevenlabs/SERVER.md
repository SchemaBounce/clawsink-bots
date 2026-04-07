---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: elevenlabs
  displayName: "ElevenLabs"
  version: "1.0.0"
  description: "Voice and audio for AI agents — text-to-speech, speech-to-text, voice cloning"
  tags: ["voice", "audio", "tts", "stt", "presence", "phone"]
  author: "elevenlabs"
  license: "MIT"
transport:
  type: "stdio"
  command: "uvx"
  args: ["elevenlabs-mcp==0.9.1"]
env:
  - name: ELEVENLABS_API_KEY
    description: "API key from elevenlabs.io"
    required: true
  - name: ELEVENLABS_MCP_BASE_PATH
    description: "Base path for audio file output (default: ~/Desktop)"
    required: false
tools:
  - name: text_to_speech
    description: "Convert text to speech with a selected voice"
    category: speech
  - name: speech_to_text
    description: "Transcribe speech from an audio file with optional diarization"
    category: transcription
  - name: text_to_sound_effects
    description: "Generate sound effects from a text description"
    category: audio
  - name: search_voices
    description: "Search voices in the ElevenLabs voice library"
    category: voices
  - name: get_voice
    description: "Get details of a specific voice"
    category: voices
  - name: voice_clone
    description: "Create an instant voice clone from audio samples"
    category: voices
  - name: list_models
    description: "List all available text-to-speech models"
    category: models
  - name: speech_to_speech
    description: "Transform audio from one voice to another"
    category: speech
  - name: text_to_voice
    description: "Create voice previews from a text prompt"
    category: voices
  - name: create_voice_from_preview
    description: "Save a generated voice preview to the voice library"
    category: voices
  - name: isolate_audio
    description: "Isolate voice from background noise in an audio file"
    category: audio
  - name: create_agent
    description: "Create a conversational AI agent with voice configuration"
    category: agents
  - name: list_agents
    description: "List all conversational AI agents"
    category: agents
  - name: get_agent
    description: "Get details about a specific conversational agent"
    category: agents
  - name: make_outbound_call
    description: "Make an outbound phone call using an ElevenLabs agent"
    category: phone
  - name: list_phone_numbers
    description: "List all phone numbers associated with the account"
    category: phone
  - name: get_conversation
    description: "Get a conversation transcript with an agent"
    category: conversations
  - name: list_conversations
    description: "List all conversations with metadata"
    category: conversations
  - name: check_subscription
    description: "Check current subscription status and API usage"
    category: account
  - name: search_voice_library
    description: "Search the entire ElevenLabs community voice library"
    category: voices
---

# ElevenLabs MCP Server

Provides voice and audio capabilities for AI agents. Agents can speak, listen, clone voices, and make phone calls — enabling voice-first workflows and phone-based interactions.

**Note:** This server uses Python (`uvx`) instead of Node.js (`npx`). Requires the `uv` Python package manager.

## Which Bots Use This

- **executive-assistant** — Dictates briefings and reads reports aloud
- **customer-support** — Handles voice calls and voicemail responses
- **meeting-summarizer** — Transcribes meeting recordings
- **mentor-coach** — Provides spoken feedback and coaching
- **str-guest-communicator** — Voice interactions with property guests

## Setup

1. Sign up at [elevenlabs.io](https://elevenlabs.io) and get your API key
2. Add `ELEVENLABS_API_KEY` to your workspace secrets
3. Ensure `uv` is installed: `curl -LsSf https://astral.sh/uv/install.sh | sh`

## Presence Integration

When a bot declares `presence.voice.provider: elevenlabs`, the platform:
1. Creates or assigns a voice identity for the agent
2. Stores the voice ID in `agent_external_identities`
3. Requires admin approval before activation (recurring cost)

## Team Usage

```yaml
mcpServers:
  - ref: "tools/elevenlabs"
    reason: "Team bots need voice for phone calls and audio output"
    config: {}
```
