---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: docker
  displayName: "Docker"
  version: "1.0.0"
  description: "Docker container management, images, containers, and registries"
  tags: ["docker", "containers", "images", "devops"]
  category: "cloud-infra"
  author: "schemabounce"
  license: "MIT"
# PACKAGE MIGRATION (2026-09-09): docker-mcp-server@2.1.1 was declared stdio but
# has no stdio mode at all. Started with its old args it binds an HTTP listener
# on port 30000 with a self-generated bearer token and never reads stdin, so the
# gateway's handshake could never be answered and no argument could fix it
# (--help offers only -p/-t/-w/--http-timeout/--socket-timeout).
#
# Replaced with mcp-server-docker, a real stdio Docker MCP that talks to the
# Docker Engine API through DOCKER_HOST and pins mcp>=2,<3. Verified by running
# it: with DOCKER_HOST pointed at a Docker Engine endpoint it answers a real MCP
# initialize (serverInfo docker-server 0.3.0); with no reachable daemon it exits
# during startup, which is why DOCKER_HOST is required below rather than
# optional. There is no Docker socket inside the gateway, so this server is only
# usable against a Docker Engine endpoint the workspace can reach.
transport:
  type: "stdio"
  command: "uvx"
  args: ["mcp-server-docker@0.3.0"]
env:
  - name: DOCKER_HOST
    description: "Docker Engine endpoint to manage, e.g. tcp://docker.internal:2376"
    required: true
tools:
  - name: list_containers
    description: "List running and stopped containers"
    category: containers
  - name: create_container
    description: "Create a container without starting it"
    category: containers
  - name: run_container
    description: "Create and start a container"
    category: containers
  - name: recreate_container
    description: "Stop, remove, and recreate a container"
    category: containers
  - name: start_container
    description: "Start a stopped container"
    category: containers
  - name: fetch_container_logs
    description: "Get logs from a container"
    category: containers
  - name: stop_container
    description: "Stop a running container"
    category: containers
  - name: remove_container
    description: "Remove a container"
    category: containers
  - name: list_images
    description: "List local Docker images"
    category: images
  - name: pull_image
    description: "Pull an image from a registry"
    category: images
  - name: push_image
    description: "Push an image to a registry"
    category: images
  - name: build_image
    description: "Build a Docker image from a Dockerfile"
    category: images
  - name: remove_image
    description: "Remove a local image"
    category: images
  - name: list_networks
    description: "List Docker networks"
    category: networks
  - name: create_network
    description: "Create a Docker network"
    category: networks
  - name: remove_network
    description: "Remove a Docker network"
    category: networks
  - name: list_volumes
    description: "List Docker volumes"
    category: volumes
  - name: create_volume
    description: "Create a Docker volume"
    category: volumes
  - name: remove_volume
    description: "Remove a Docker volume"
    category: volumes
---

# Docker MCP Server

Provides Docker tools for managing containers, images, volumes, and networks on a Docker host.

## Which Bots Use This

- **devops-automator** -- Manages container lifecycle, builds and deploys images
- **sre-devops** -- Debugs container issues, inspects logs, manages resources
- **qa-tester** -- Spins up test environments in containers
- **release-manager** -- Builds and tags release images

## Setup

1. Expose a Docker Engine API endpoint your workspace can reach. There is no Docker socket where this server runs, so a local daemon on your laptop will not work.
2. Set `DOCKER_HOST` to that endpoint, for example `tcp://docker.internal:2376`. The server needs it to start.
3. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single Docker server instance across ops bots:

```yaml
mcpServers:
  - ref: "tools/docker"
    reason: "Ops bots need Docker access for container management and image builds"
    config:
      default_registry: "your-registry.example.com"
```
