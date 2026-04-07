---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: docker
  displayName: "Docker"
  version: "1.0.0"
  description: "Docker container management — images, containers, and registries"
  tags: ["docker", "containers", "images", "devops"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "docker-mcp-server"]
env:
  - name: DOCKER_HOST
    description: "Docker host URL, defaults to local socket"
    required: false
tools:
  - name: list_containers
    description: "List running and stopped containers"
    category: containers
  - name: get_container
    description: "Get details of a specific container"
    category: containers
  - name: start_container
    description: "Start a stopped container"
    category: containers
  - name: stop_container
    description: "Stop a running container"
    category: containers
  - name: list_images
    description: "List local Docker images"
    category: images
  - name: pull_image
    description: "Pull an image from a registry"
    category: images
  - name: build_image
    description: "Build a Docker image from a Dockerfile"
    category: images
  - name: container_logs
    description: "Get logs from a container"
    category: containers
  - name: list_volumes
    description: "List Docker volumes"
    category: volumes
  - name: list_networks
    description: "List Docker networks"
    category: networks
---

# Docker MCP Server

Provides Docker tools for managing containers, images, volumes, and networks on a Docker host.

## Which Bots Use This

- **devops-automator** -- Manages container lifecycle, builds and deploys images
- **sre-devops** -- Debugs container issues, inspects logs, manages resources
- **qa-tester** -- Spins up test environments in containers
- **release-manager** -- Builds and tags release images

## Setup

1. Ensure Docker is running on the host machine
2. Optionally set `DOCKER_HOST` to connect to a remote Docker daemon
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
