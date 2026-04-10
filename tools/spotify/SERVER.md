---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: spotify
  displayName: "Spotify"
  version: "1.0.0"
  description: "Spotify Web API — tracks, playlists, artists, and playback"
  tags: ["spotify", "music", "audio", "streaming"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "spotify-mcp@0.1.4"]
env:
  - name: SPOTIFY_CLIENT_ID
    description: "Spotify app client ID"
    required: true
  - name: SPOTIFY_CLIENT_SECRET
    description: "Spotify app client secret"
    required: true
tools:
  - name: search_tracks
    description: "Search for tracks by query"
    category: tracks
  - name: get_track
    description: "Get details of a specific track"
    category: tracks
  - name: get_playlist
    description: "Get a playlist and its tracks"
    category: playlists
  - name: create_playlist
    description: "Create a new playlist"
    category: playlists
  - name: add_to_playlist
    description: "Add tracks to a playlist"
    category: playlists
  - name: get_artist
    description: "Get artist information and discography"
    category: artists
  - name: get_recommendations
    description: "Get track recommendations based on seeds"
    category: tracks
---

# Spotify MCP Server

Provides Spotify Web API tools for searching music, managing playlists, and retrieving artist and track data.

## Which Bots Use This

- **content-strategist** -- Curates playlists for brand campaigns and content themes
- **data-analyst** -- Analyzes listening trends and audience engagement metrics

## Setup

1. Create a Spotify app in the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Copy the Client ID and Client Secret
3. Add `SPOTIFY_CLIENT_ID` and `SPOTIFY_CLIENT_SECRET` to your workspace secrets
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Spotify server instance across bots:

```yaml
mcpServers:
  - ref: "tools/spotify"
    reason: "Bots need Spotify access for playlist curation and music analytics"
    config:
      default_market: "US"
```
