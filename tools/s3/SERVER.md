---
apiVersion: clawsink.schemabounce.com/v1
kind: McpServer
metadata:
  name: s3
  displayName: "Amazon S3"
  version: "1.0.0"
  description: "AWS S3 — buckets, objects, presigned URLs, and storage management"
  tags: ["s3", "aws", "storage", "objects", "cloud"]
  author: "schemabounce"
  license: "MIT"
transport:
  type: "stdio"
  command: "npx"
  args: ["-y", "aws-s3-mcp@0.4.0"]
env:
  - name: AWS_ACCESS_KEY_ID
    description: "AWS access key ID with S3 permissions"
    required: true
  - name: AWS_SECRET_ACCESS_KEY
    description: "AWS secret access key"
    required: true
  - name: AWS_REGION
    description: "Default AWS region (e.g., us-east-1)"
    required: false
tools:
  - name: list_buckets
    description: "List all S3 buckets in the account"
    category: buckets
  - name: list_objects
    description: "List objects in a bucket with optional prefix"
    category: objects
  - name: get_object
    description: "Get the contents of an object"
    category: objects
  - name: put_object
    description: "Upload an object to a bucket"
    category: objects
  - name: delete_object
    description: "Delete an object from a bucket"
    category: objects
  - name: generate_presigned_url
    description: "Generate a presigned URL for temporary access"
    category: urls
  - name: get_bucket_policy
    description: "Get the access policy for a bucket"
    category: buckets
  - name: copy_object
    description: "Copy an object between buckets or keys"
    category: objects
---

# Amazon S3 MCP Server

Provides AWS S3 tools for bots that manage cloud storage, file uploads, presigned URLs, and bucket policies.

## Which Bots Use This

- **devops-automator** -- Manages storage buckets, uploads artifacts, and configures bucket policies
- **data-analyst** -- Reads data files from S3 for analysis and reporting

## Setup

1. Create an IAM user or role with S3 permissions (`s3:ListBucket`, `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`)
2. Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to your workspace secrets
3. Optionally set `AWS_REGION` for a default region (defaults to `us-east-1`)
4. The server starts automatically when a bot that references it runs

## Team Usage

Add to your TEAM.md to share a single S3 server instance across bots:

```yaml
mcpServers:
  - ref: "tools/s3"
    reason: "Bots need S3 access for file storage, data retrieval, and artifact management"
    config:
      default_bucket: "my-data-bucket"
```
