---
apiVersion: clawsink.schemabounce.com/v1
kind: ToolPack
metadata:
  name: security-compliance
  displayName: Security & Compliance
  version: 1.0.0
  description: Encryption, hashing, PII detection, data masking, and audit logging
  category: Security
  tags: [encryption, hashing, pii, masking, audit, compliance, security]
  icon: security
tools:
  - name: hash_data
    description: Hash input data using SHA-256, SHA-512, or HMAC algorithms
    category: hashing
  - name: encrypt_field
    description: Encrypt a field value using AES-256-GCM with a provided key
    category: encryption
  - name: decrypt_field
    description: Decrypt an AES-256-GCM encrypted field with the original key
    category: encryption
  - name: detect_pii
    description: Scan text for personally identifiable information and return matches with types
    category: detection
  - name: mask_data
    description: Mask sensitive fields using configurable patterns (partial, full, hash)
    category: masking
  - name: generate_token
    description: Generate a cryptographically secure random token of specified length
    category: generation
  - name: validate_password
    description: Check password strength against configurable complexity requirements
    category: validation
  - name: audit_log
    description: Format a structured audit log entry with actor, action, resource, and timestamp
    category: audit
  - name: checksum_verify
    description: Compute or verify checksums (MD5, SHA-256, CRC32) for data integrity
    category: verification
  - name: sanitize_input
    description: Sanitize user input by removing or escaping potentially dangerous characters
    category: sanitization
---

# Security & Compliance

Encryption, hashing, PII detection, data masking, and audit logging. All tools are deterministic Go functions -- fast, zero LLM tokens, fully reproducible.

Essential for any agent handling sensitive data, compliance requirements, or security operations.

## Use Cases

- Hash and encrypt sensitive fields before storage
- Scan documents for PII before sharing externally
- Mask credit card numbers and SSNs in logs
- Generate secure tokens for API keys or session IDs
- Create structured audit log entries for compliance

## Tools

### hash_data
Hash input data using SHA-256, SHA-512, or HMAC with a secret key. Returns hex-encoded digest.

### encrypt_field
Encrypt a string value using AES-256-GCM. Returns base64-encoded ciphertext and nonce.

### decrypt_field
Decrypt an AES-256-GCM encrypted value using the original key and nonce.

### detect_pii
Scan text for PII patterns (emails, phone numbers, SSNs, credit cards, names, addresses) and return matches with classification.

### mask_data
Apply masking rules to sensitive fields. Supports partial masking (last 4 digits), full replacement, or hash-based pseudonymization.

### generate_token
Generate a cryptographically secure random token in hex, base64, or alphanumeric format.

### validate_password
Evaluate password strength against configurable rules (length, uppercase, lowercase, digits, special characters).

### audit_log
Build a structured audit log entry with actor, action, resource type, resource ID, timestamp, and metadata.

### checksum_verify
Compute MD5, SHA-256, or CRC32 checksums for data integrity verification. Optionally compare against an expected value.

### sanitize_input
Strip or escape HTML tags, SQL injection patterns, and control characters from user-provided input.
