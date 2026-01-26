# Keycloak OIDC Integration for Headlamp

This document provides comprehensive guidance for integrating Headlamp with Keycloak for Single Sign-On (SSO) authentication and group-based RBAC authorization.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Architecture Overview](#architecture-overview)
- [Keycloak Client Setup](#keycloak-client-setup)
- [Groups Configuration](#groups-configuration)
- [Kubernetes API Server OIDC Configuration](#kubernetes-api-server-oidc-configuration)
- [Headlamp Helm Values](#headlamp-helm-values)
- [Group-Based RBAC Configuration](#group-based-rbac-configuration)
- [OIDC Custom CA](#oidc-custom-ca)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before configuring Headlamp with Keycloak SSO, ensure you have:

1. **Keycloak instance** accessible from both users and the Kubernetes cluster
2. **Admin access** to Keycloak to create clients, groups, and mappers
3. **Kubernetes cluster** with OIDC authentication configured on the API server (required for group-based RBAC)
4. **Helm** installed for deploying Headlamp

> **Important**: For group-based authorization to work, the Kubernetes API server must be configured with OIDC flags. See [Kubernetes API Server OIDC Configuration](#kubernetes-api-server-oidc-configuration).

---

## Architecture Overview

Headlamp's Keycloak integration involves two separate systems:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Authentication Flow                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  User → Headlamp → Keycloak → ID Token (with groups claim) → Headlamp      │
│                                                                             │
│  This handles: "Who are you?"                                               │
│  Configured in: Headlamp Helm chart (clientID, issuerURL)                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           Authorization Flow                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Headlamp → Kubernetes API (with OIDC token) → RBAC evaluation → Response  │
│                                                                             │
│  This handles: "What can you do?"                                           │
│  Configured in: kube-apiserver (OIDC flags) + ClusterRoleBindings          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Insight**: Headlamp's OIDC configuration only handles login. The actual permissions are determined by Kubernetes RBAC based on groups extracted from the OIDC token by the Kubernetes API server.

---

## Keycloak Client Setup

The Keycloak client can be set up by following [this tutorial](https://headlamp.dev/docs/latest/installation/in-cluster/keycloak/). A summary is provided below.

### Create the Client

1. Navigate to your Keycloak realm
2. Go to **Clients** → **Create client**
3. Configure:
   - **Client ID**: `headlamp` (or your preferred name)
   - **Client Protocol**: `openid-connect`
   - **Client authentication**: `Off` (public client)
   - **Standard flow enabled**: `On`
   - **Valid redirect URIs**: `https://{headlamp-url}/oidc-callback`

> **Note**: Big Bang's Headlamp integration uses **PKCE (Proof Key for Code Exchange)** which allows secure authentication with public clients. This eliminates the need to manage client secrets.

### Create Token Mappers

Under the client's **Client scopes** → **headlamp-dedicated** → **Mappers** tab, create the following mappers:

#### 1. HeadlampId Mapper
| Setting | Value |
|---------|-------|
| Name | `headlampId` |
| Mapper Type | User Attribute |
| User Attribute | `headlampId` |
| Token Claim Name | `id` |
| Claim JSON Type | `long` |
| Add to ID token | `On` |
| Add to userinfo | `On` |

#### 2. Username Mapper
| Setting | Value |
|---------|-------|
| Name | `username` |
| Mapper Type | User Property |
| Property | `username` |
| Token Claim Name | `username` |
| Claim JSON Type | `String` |
| Add to ID token | `On` |
| Add to userinfo | `On` |

#### 3. Email Mapper
| Setting | Value |
|---------|-------|
| Name | `email` |
| Mapper Type | User Property |
| Property | `email` |
| Token Claim Name | `email` |
| Claim JSON Type | `String` |
| Add to ID token | `On` |
| Add to userinfo | `On` |

### Add HeadlampId to Users

For each user that will access Headlamp:
1. Go to **Users** → Select user → **Attributes**
2. Add attribute: Key = `headlampId`, Value = unique number
3. Click **Save**

> **Note**: The `headlampId` must be unique per user.

---

## Groups Configuration

To enable group-based access control, you must configure Keycloak to include group membership in the OIDC token.

### Step 1: Create Groups in Keycloak

1. Navigate to your realm → **Groups**
2. Create groups for different access levels:
   - `headlamp-admins` - Full cluster access
   - `headlamp-readers` - Read-only access
   - `headlamp-developers` - Developer namespace access

### Step 2: Assign Users to Groups

1. Go to **Users** → Select user → **Groups**
2. Click **Join Group** and select appropriate groups

### Step 3: Create Groups Client Scope

1. Go to **Client scopes** → **Create client scope**
2. Configure:
   - **Name**: `groups`
   - **Type**: `Default`
   - **Protocol**: `OpenID Connect`
3. Click **Save**

### Step 4: Add Groups Mapper to the Scope

1. In the `groups` client scope, go to **Mappers** → **Configure a new mapper**
2. Select **Group Membership**
3. Configure:

| Setting | Value |
|---------|-------|
| Name | `groups` |
| Token Claim Name | `groups` |
| Full group path | `Off` (or `On` if you need hierarchical paths like `/org/team`) |
| Add to ID token | `On` |
| Add to access token | `On` |
| Add to userinfo | `On` |

### Step 5: Attach Scope to Headlamp Client

1. Go to **Clients** → `headlamp` → **Client scopes**
2. Click **Add client scope**
3. Select `groups` and add as **Default**

### Step 6: Verify Token Contains Groups

1. Go to **Clients** → `headlamp` → **Client scopes** → **Evaluate**
2. Select a user and click **Generated ID token**
3. Verify the token contains the groups claim:

```json
{
  "sub": "user-uuid",
  "email": "user@example.com",
  "preferred_username": "johndoe",
  "groups": [
    "headlamp-readers",
    "developers"
  ]
}
```

---

## Kubernetes API Server OIDC Configuration

> **Critical**: This is a cluster-level configuration that must be done during cluster provisioning or by modifying the kube-apiserver. This is NOT configured by the Headlamp Helm chart.

For Kubernetes to recognize groups from OIDC tokens, the API server must be configured with OIDC flags.

### Required kube-apiserver Flags

```bash
kube-apiserver \
  --oidc-issuer-url=https://keycloak.example.com/auth/realms/your-realm \
  --oidc-client-id=kubernetes \
  --oidc-username-claim=preferred_username \
  --oidc-username-prefix=oidc: \
  --oidc-groups-claim=groups \
  --oidc-groups-prefix=oidc: \
  --oidc-signing-algs=RS256
```

| Flag | Description |
|------|-------------|
| `--oidc-issuer-url` | Keycloak realm URL (must match `issuerURL` in Headlamp config) |
| `--oidc-client-id` | Client ID for Kubernetes API (can be same as Headlamp or separate) |
| `--oidc-username-claim` | Claim to use for username (usually `preferred_username` or `sub`) |
| `--oidc-groups-claim` | Claim containing user's groups (must be `groups` to match our mapper) |
| `--oidc-groups-prefix` | Optional prefix for group names to avoid collisions |

### Configuration by Kubernetes Distribution

#### RKE2
Add to `/etc/rancher/rke2/config.yaml`:
```yaml
kube-apiserver-arg:
  - "oidc-issuer-url=https://keycloak.example.com/auth/realms/your-realm"
  - "oidc-client-id=kubernetes"
  - "oidc-username-claim=preferred_username"
  - "oidc-groups-claim=groups"
```

#### EKS
Use the [OIDC identity provider](https://docs.aws.amazon.com/eks/latest/userguide/authenticate-oidc-identity-provider.html) feature in the EKS console or via `aws eks associate-identity-provider-config`.

#### k3s
Add to `/etc/rancher/k3s/config.yaml`:
```yaml
kube-apiserver-arg:
  - "oidc-issuer-url=https://keycloak.example.com/auth/realms/your-realm"
  - "oidc-client-id=kubernetes"
  - "oidc-groups-claim=groups"
```

### Verify API Server OIDC Configuration

```bash
# Check if OIDC is configured (on a control plane node)
ps aux | grep kube-apiserver | grep oidc
```

---

## Headlamp Helm Values

### Basic OIDC Configuration

```yaml
# values.yaml
upstream:
  config:
    oidc:
      clientID: "headlamp"
      issuerURL: "https://keycloak.example.com/auth/realms/your-realm"
      scopes: "openid,email,profile,groups"
      usePKCE: true
```

### Big Bang Deployment

When deploying via Big Bang, configure in the umbrella chart:

```yaml
# Big Bang values.yaml
addons:
  headlamp:
    enabled: true
    sso:
      enabled: true
      client_id: "headlamp"

sso:
  url: "https://keycloak.example.com/auth/realms/your-realm"
```

> **Note**: Big Bang automatically enables PKCE for Headlamp. No client_secret is required.

### Getting Keycloak Values

1. **client_id**: The Client ID you created earlier (public client)
2. **issuerURL**: Your realm URL (e.g., `https://keycloak.example.com/auth/realms/baby-yoda`)

---

## Group-Based RBAC Configuration

Once Keycloak is configured to emit groups and the Kubernetes API server is configured to recognize them, you can create ClusterRoleBindings that grant permissions based on group membership.

### Example: Read-Only Access for a Group

```yaml
# In Headlamp values.yaml
bigbang:
  rbac:
    enabled: true
    clusterRoles:
      - name: headlamp-readonly
        create: true
        rules:
          - apiGroups: [""]
            resources:
              - pods
              - pods/log
              - services
              - configmaps
              - events
              - namespaces
              - nodes
              - persistentvolumeclaims
              - persistentvolumes
            verbs: ["get", "list", "watch"]
          - apiGroups: ["apps"]
            resources:
              - deployments
              - daemonsets
              - replicasets
              - statefulsets
            verbs: ["get", "list", "watch"]
          - apiGroups: ["batch"]
            resources:
              - jobs
              - cronjobs
            verbs: ["get", "list", "watch"]
          - apiGroups: ["networking.k8s.io"]
            resources:
              - ingresses
              - networkpolicies
            verbs: ["get", "list", "watch"]

    clusterRoleBindings:
      - name: headlamp-readonly-binding
        roleRef: headlamp-readonly
        subjects:
          - kind: Group
            name: "headlamp-readers"  # Must match Keycloak group name exactly
            apiGroup: rbac.authorization.k8s.io
```

### Example: Admin Access for a Group

```yaml
bigbang:
  rbac:
    enabled: true
    clusterRoleBindings:
      - name: headlamp-admin-binding
        roleRef: cluster-admin  # Use built-in cluster-admin role
        subjects:
          - kind: Group
            name: "headlamp-admins"
            apiGroup: rbac.authorization.k8s.io
```

### Example: Multiple Groups with Different Access

```yaml
bigbang:
  rbac:
    enabled: true
    clusterRoles:
      - name: headlamp-readonly
        create: true
        rules:
          - apiGroups: [""]
            resources: ["pods", "services", "configmaps", "namespaces"]
            verbs: ["get", "list", "watch"]

      - name: headlamp-developer
        create: true
        rules:
          - apiGroups: [""]
            resources: ["pods", "pods/log", "pods/exec", "services", "configmaps"]
            verbs: ["get", "list", "watch", "create", "update", "delete"]
          - apiGroups: ["apps"]
            resources: ["deployments", "replicasets"]
            verbs: ["get", "list", "watch", "create", "update", "delete"]

    clusterRoleBindings:
      - name: headlamp-readers-binding
        roleRef: headlamp-readonly
        subjects:
          - kind: Group
            name: "headlamp-readers"
            apiGroup: rbac.authorization.k8s.io

      - name: headlamp-developers-binding
        roleRef: headlamp-developer
        subjects:
          - kind: Group
            name: "headlamp-developers"
            apiGroup: rbac.authorization.k8s.io

      - name: headlamp-admins-binding
        roleRef: cluster-admin
        subjects:
          - kind: Group
            name: "headlamp-admins"
            apiGroup: rbac.authorization.k8s.io
```

### Important Notes on Group Names

- Group names in ClusterRoleBindings must **exactly match** the names in Keycloak
- If you configured `--oidc-groups-prefix=oidc:` on the API server, prepend the prefix:
  ```yaml
  subjects:
    - kind: Group
      name: "oidc:headlamp-readers"  # With prefix
  ```
- If using full group paths in Keycloak (`Full group path: On`), use the full path:
  ```yaml
  subjects:
    - kind: Group
      name: "/organization/headlamp-readers"
  ```

---

## OIDC Custom CA

If your Keycloak instance uses a self-signed certificate or a private CA, configure Headlamp to trust it:

```yaml
addons:
  headlamp:
    values:
      upstream:
        extraVolumes:
          - name: ca-cert
            secret:
              secretName: keycloak-ca-secret
              defaultMode: 0644
        extraVolumeMounts:
          - name: ca-cert
            mountPath: /etc/ssl/certs/keycloak-ca.crt
            subPath: ca.crt
            readOnly: true
```

Create the secret:
```bash
kubectl create secret generic keycloak-ca-secret \
  --from-file=ca.crt=/path/to/keycloak-ca.pem \
  -n headlamp
```

---

## Troubleshooting

### User authenticates but sees no resources

**Symptom**: User can log in via Keycloak but Headlamp shows empty resource lists.

**Causes**:
1. **kube-apiserver not configured with OIDC** - Verify OIDC flags are set
2. **No ClusterRoleBinding for user's group** - Create appropriate binding
3. **Group name mismatch** - Ensure Keycloak group name exactly matches binding

**Debug steps**:
```bash
# Check if user has any RBAC permissions
kubectl auth can-i list pods --as=oidc:username --as-group=oidc:groupname

# View ClusterRoleBindings
kubectl get clusterrolebindings -o wide | grep headlamp
```

### Groups not appearing in token

**Symptom**: Token doesn't contain `groups` claim.

**Fix**:
1. Verify the `groups` client scope is attached to the client
2. Verify the Group Membership mapper is configured correctly
3. Use Keycloak's token evaluation feature to debug

### "Unauthorized" errors in Headlamp

**Symptom**: User gets 401/403 errors when accessing resources.

**Causes**:
1. Token expired - Re-login
2. OIDC issuer URL mismatch between Headlamp and kube-apiserver
3. Client ID mismatch

### Token validation fails

**Symptom**: kube-apiserver rejects the OIDC token.

**Debug**:
```bash
# Decode the JWT token (use jwt.io or similar)
# Verify:
# - "iss" matches --oidc-issuer-url
# - "aud" contains the --oidc-client-id value
# - Token is not expired
```

---

## Complete Example: End-to-End Setup

### 1. Keycloak Configuration

```
Realm: baby-yoda
Client: headlamp
  - Client authentication: Off (public client with PKCE)
  - Valid redirect URIs: https://headlamp.bigbang.dev/oidc-callback
  - Client scopes: groups (default)

Groups:
  - headlamp-admins
  - headlamp-readers

Client Scope "groups":
  - Mapper: Group Membership
    - Token Claim Name: groups
    - Add to ID token: On
```

### 2. Kubernetes API Server

```yaml
# RKE2 config.yaml
kube-apiserver-arg:
  - "oidc-issuer-url=https://keycloak.bigbang.dev/auth/realms/baby-yoda"
  - "oidc-client-id=kubernetes"
  - "oidc-groups-claim=groups"
```

### 3. Headlamp Deployment (Big Bang)

```yaml
# Big Bang values.yaml
sso:
  url: "https://keycloak.bigbang.dev/auth/realms/baby-yoda"

addons:
  headlamp:
    enabled: true
    sso:
      enabled: true
      client_id: "headlamp"
    values:
      bigbang:
        rbac:
          enabled: true
          clusterRoles:
            - name: headlamp-readonly
              create: true
              rules:
                - apiGroups: [""]
                  resources: ["pods", "services", "namespaces", "nodes"]
                  verbs: ["get", "list", "watch"]
          clusterRoleBindings:
            - name: headlamp-readers-binding
              roleRef: headlamp-readonly
              subjects:
                - kind: Group
                  name: "headlamp-readers"
                  apiGroup: rbac.authorization.k8s.io
            - name: headlamp-admins-binding
              roleRef: cluster-admin
              subjects:
                - kind: Group
                  name: "headlamp-admins"
                  apiGroup: rbac.authorization.k8s.io
```

### 4. Verify

```bash
# Test RBAC for a user in headlamp-readers group
kubectl auth can-i list pods --as=johndoe --as-group=headlamp-readers
# Expected: yes

kubectl auth can-i delete pods --as=johndoe --as-group=headlamp-readers
# Expected: no

# Test for admin group
kubectl auth can-i delete pods --as=admin --as-group=headlamp-admins
# Expected: yes
```
