# HashiCorp Vault Commands for DevOps Engineers

A comprehensive reference for secrets management, KV-v2 engine operations, Raft cluster administration, policies, and Kubernetes authentication integration.

---

## Table of Contents

- [1. Environment Setup & Cluster Status](#1-environment-setup--cluster-status)
- [2. Operator Initialization & Unsealing](#2-operator-initialization--unsealing)
- [3. Authentication & Token Management](#3-authentication--token-management)
- [4. Key-Value v2 Secrets Management (KV2 Engine)](#4-key-value-v2-secrets-management-kv2-engine)
- [5. Policies & Access Control (RBAC)](#5-policies--access-control-rbac)
- [6. Kubernetes Authentication Integration](#6-kubernetes-authentication-integration)
- [7. Audit Logging](#7-audit-logging)

---

## 1. Environment Setup & Cluster Status

```bash
# Set Vault server address
export VAULT_ADDR="https://vault.internal.company.com:8200"
# For local dev / test:
export VAULT_ADDR="http://127.0.0.1:8200"

# Skip TLS verification for self-signed certificates (testing only)
export VAULT_SKIP_VERIFY=true

# Check Vault status (initialized, sealed, storage type, cluster name, version)
vault status

# View Vault CLI and server version
vault version
```

[Back to Top ↑](#table-of-contents)

---

## 2. Operator Initialization & Unsealing

```bash
# Initialize a newly deployed Vault cluster (specifying Shamir unseal keys)
vault operator init -key-shares=5 -key-threshold=3 > /tmp/vault-init-keys.txt

# Unseal Vault (must be run 3 times with 3 distinct unseal keys until "Sealed: false")
vault operator unseal <unseal-key-1>
vault operator unseal <unseal-key-2>
vault operator unseal <unseal-key-3>

# Inspect integrated Raft storage cluster peers
vault operator raft list-peers

# Join a standby Vault node to an existing Raft cluster
vault operator raft join https://vault-0.vault-internal:8200

# Create an on-demand Raft snapshot (cluster backup)
vault operator raft snapshot save /backups/vault-raft-$(date +%F).snap

# Restore Vault from a Raft snapshot
vault operator raft snapshot restore -force /backups/vault-raft-backup.snap
```

[Back to Top ↑](#table-of-contents)

---

## 3. Authentication & Token Management

```bash
# Authenticate using the root token or an admin token
vault login <token>

# Authenticate using Userpass method
vault login -method=userpass username=devops

# Authenticate using AWS IAM role
vault login -method=aws role=devops-admin

# Create a child token with attached policy and TTL
vault token create -policy="web-app-read" -ttl="1h"

# Create an orphaned token (survives if creator token expires)
vault token create -policy="ci-cd-policy" -orphan

# Lookup current token details and remaining TTL
vault token lookup

# Revoke a token and all its child tokens immediately
vault token revoke <token-string>

# Revoke all tokens issued under an accessor
vault token revoke -accessor <accessor-id>
```

[Back to Top ↑](#table-of-contents)

---

## 4. Key-Value v2 Secrets Management (KV2 Engine)

```bash
# Enable KV version 2 secrets engine at path secret/
vault secrets enable -path=secret kv-v2

# Write / Update secrets (creates a new version)
vault kv put secret/database \
  username="dbadmin" \
  password="SuperSecurePassword123!" \
  port="5432"

# Read latest version of secret
vault kv get secret/database

# Read specific field only (raw output, ideal for shell scripts)
vault kv get -field=password secret/database

# Output secret formatted as JSON
vault kv get -format=json secret/database | jq -r .data.data.password

# Read a specific older version of secret
vault kv get -version=1 secret/database

# Inspect secret metadata (versions, creation times, deletion state)
vault kv metadata get secret/database

# List secret keys under a path
vault kv list secret/

# Soft-delete latest version (can be undeleted)
vault kv delete secret/database

# Soft-delete specific versions
vault kv delete -versions=2,3 secret/database

# Undelete a soft-deleted version
vault kv undelete -versions=2 secret/database

# Permanently destroy specific versions (data wiped completely)
vault kv destroy -versions=1,2 secret/database
```

[Back to Top ↑](#table-of-contents)

---

## 5. Policies & Access Control (RBAC)

```bash
# List all active policies
vault policy list

# View contents of an existing policy
vault policy read web-app-policy

# Write / Apply a policy from an HCL file
vault policy write web-app-policy web-app-policy.hcl

# Write a policy directly from stdin
vault policy write microservice-policy - <<EOF
path "secret/data/my-app/*" {
  capabilities = ["read", "list"]
}
path "secret/metadata/my-app/*" {
  capabilities = ["read", "list"]
}
EOF

# Delete a policy
vault policy delete web-app-policy
```

[Back to Top ↑](#table-of-contents)

---

## 6. Kubernetes Authentication Integration

```bash
# Enable Kubernetes authentication method
vault auth enable kubernetes

# Configure Kubernetes auth with cluster API server and ServiceAccount JWT token
vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc.cluster.local:443"

# Create a role binding Kubernetes ServiceAccount & Namespace to a Vault Policy
vault write auth/kubernetes/role/my-app-role \
  bound_service_account_names=my-app-sa \
  bound_service_account_namespaces=production \
  policies=web-app-policy \
  ttl=24h

# Test authentication manually from a pod using its ServiceAccount JWT
SA_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
vault write auth/kubernetes/login role=my-app-role jwt="$SA_TOKEN"
```

[Back to Top ↑](#table-of-contents)

---

## 7. Audit Logging

```bash
# Enable audit logging to a local file
vault audit enable file file_path=/var/log/vault/audit.log

# List active audit devices
vault audit list

# Disable audit logging
vault audit disable file
```

[Back to Top ↑](#table-of-contents)
