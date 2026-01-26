# RBAC Configuration for Headlamp

This document describes how to configure Role-Based Access Control (RBAC) for Headlamp users, including integration with Keycloak SSO for group-based access control.

## Table of Contents

- [Overview](#overview)
- [Prerequisites for SSO Group-Based RBAC](#prerequisites-for-sso-group-based-rbac)
- [Configuration Reference](#configuration-reference)
- [ServiceAccount-Based Access](#serviceaccount-based-access)
- [SSO Group-Based Access (Keycloak)](#sso-group-based-access-keycloak)
- [Common Role Examples](#common-role-examples)
- [Troubleshooting](#troubleshooting)

---

## Overview

Headlamp's RBAC is managed through Kubernetes native RBAC resources (ClusterRoles and ClusterRoleBindings). The BigBang Headlamp chart provides a convenient way to create these resources through Helm values.

### How It Works

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           RBAC Architecture                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ClusterRole (defines permissions)                                          │
│       │                                                                     │
│       ▼                                                                     │
│  ClusterRoleBinding (binds role to subjects)                               │
│       │                                                                     │
│       ├─── ServiceAccount (token-based access)                              │
│       │                                                                     │
│       └─── Group (SSO/OIDC group-based access)                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

The `bigbang.rbac` section in values.yaml controls the creation of these resources:
- `clusterRoles`: Defines what permissions are available
- `clusterRoleBindings`: Defines who gets those permissions

---

## Prerequisites for SSO Group-Based RBAC

For Keycloak group-based RBAC to work, you need:

### 1. Kubernetes API Server OIDC Configuration

The kube-apiserver must be configured to recognize OIDC tokens and extract group claims:

```bash
kube-apiserver \
  --oidc-issuer-url=https://keycloak.example.com/auth/realms/your-realm \
  --oidc-client-id=kubernetes \
  --oidc-groups-claim=groups \
  --oidc-username-claim=preferred_username
```

> **Important**: This is cluster-level configuration done during cluster provisioning, NOT by the Headlamp chart.

### 2. Keycloak Groups Configuration

Keycloak must be configured to include group membership in OIDC tokens:
1. Create groups in Keycloak
2. Add a Group Membership mapper to include groups in tokens
3. Assign users to groups

See [docs/keycloak.md](keycloak.md) for detailed Keycloak configuration instructions.

---

## Configuration Reference

### Enabling RBAC

```yaml
bigbang:
  rbac:
    enabled: true  # Enable RBAC resource creation
```

### ClusterRoles

Define permissions using Kubernetes RBAC rules:

```yaml
bigbang:
  rbac:
    enabled: true
    clusterRoles:
      - name: my-role-name
        create: true  # Set to false to reference existing role
        rules:
          - apiGroups: [""]  # Core API group
            resources: ["pods", "services"]
            verbs: ["get", "list", "watch"]
          - apiGroups: ["apps"]
            resources: ["deployments"]
            verbs: ["get", "list", "watch"]
```

### ClusterRoleBindings

Bind roles to subjects (ServiceAccounts, Users, or Groups):

```yaml
bigbang:
  rbac:
    clusterRoleBindings:
      - name: my-binding-name
        roleRef: my-role-name  # References ClusterRole by name
        subjects:
          - kind: ServiceAccount
            name: my-sa
            namespace: my-namespace
          - kind: Group
            name: "keycloak-group-name"
            apiGroup: rbac.authorization.k8s.io
          - kind: User
            name: "specific-user"
            apiGroup: rbac.authorization.k8s.io
```

---

## ServiceAccount-Based Access

For non-SSO access using Kubernetes service account tokens:

```yaml
bigbang:
  rbac:
    enabled: true
    clusterRoles:
      - name: headlamp-readonly
        create: true
        rules:
          - apiGroups: [""]
            resources: ["pods", "services", "namespaces"]
            verbs: ["get", "list", "watch"]

    clusterRoleBindings:
      - name: headlamp-sa-binding
        roleRef: headlamp-readonly
        subjects:
          - kind: ServiceAccount
            name: dev-sa
            namespace: headlamp
```

Users can then generate a token for the service account:

```bash
kubectl create token dev-sa -n headlamp --duration=24h
```

---

## SSO Group-Based Access (Keycloak)

For SSO access where permissions are based on Keycloak group membership:

### Basic Example

```yaml
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
            name: "headlamp-readers"  # Keycloak group name
            apiGroup: rbac.authorization.k8s.io
```

### Multiple Groups with Different Access Levels

```yaml
bigbang:
  rbac:
    enabled: true
    clusterRoles:
      # Read-only role
      - name: headlamp-readonly
        create: true
        rules:
          - apiGroups: [""]
            resources: ["pods", "services", "configmaps", "namespaces"]
            verbs: ["get", "list", "watch"]

      # Developer role with more permissions
      - name: headlamp-developer
        create: true
        rules:
          - apiGroups: [""]
            resources: ["pods", "pods/log", "pods/exec", "services", "configmaps"]
            verbs: ["get", "list", "watch", "create", "update", "delete"]
          - apiGroups: ["apps"]
            resources: ["deployments", "replicasets"]
            verbs: ["get", "list", "watch", "create", "update", "patch"]

    clusterRoleBindings:
      # Viewers group
      - name: headlamp-viewers-binding
        roleRef: headlamp-readonly
        subjects:
          - kind: Group
            name: "headlamp-viewers"
            apiGroup: rbac.authorization.k8s.io

      # Developers group
      - name: headlamp-devs-binding
        roleRef: headlamp-developer
        subjects:
          - kind: Group
            name: "headlamp-developers"
            apiGroup: rbac.authorization.k8s.io

      # Admins group - uses built-in cluster-admin role
      - name: headlamp-admins-binding
        roleRef: cluster-admin
        subjects:
          - kind: Group
            name: "headlamp-admins"
            apiGroup: rbac.authorization.k8s.io
```

### Important: Group Name Matching

The group name in `clusterRoleBindings.subjects[].name` must **exactly match** the Keycloak group name:

| Keycloak Group | ClusterRoleBinding Subject |
|----------------|---------------------------|
| `headlamp-readers` | `name: "headlamp-readers"` |
| `/org/headlamp-readers` (full path) | `name: "/org/headlamp-readers"` |

If your kube-apiserver uses `--oidc-groups-prefix`, include the prefix:

```yaml
subjects:
  - kind: Group
    name: "oidc:headlamp-readers"  # With oidc: prefix
    apiGroup: rbac.authorization.k8s.io
```

---

## Common Role Examples

### Read-Only Cluster Viewer

```yaml
- name: headlamp-readonly
  create: true
  rules:
    - apiGroups: [""]
      resources:
        - namespaces
        - pods
        - pods/log
        - services
        - endpoints
        - configmaps
        - events
        - nodes
        - persistentvolumeclaims
        - persistentvolumes
        - resourcequotas
        - limitranges
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
    - apiGroups: ["storage.k8s.io"]
      resources:
        - storageclasses
      verbs: ["get", "list", "watch"]
```

### Developer Role (Namespace-Scoped Work)

```yaml
- name: headlamp-developer
  create: true
  rules:
    # Read access to cluster resources
    - apiGroups: [""]
      resources: ["namespaces", "nodes"]
      verbs: ["get", "list", "watch"]
    # Full access to workload resources
    - apiGroups: [""]
      resources:
        - pods
        - pods/log
        - pods/exec
        - pods/portforward
        - services
        - configmaps
        - secrets
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
    - apiGroups: ["apps"]
      resources:
        - deployments
        - replicasets
        - statefulsets
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
    - apiGroups: ["batch"]
      resources: ["jobs", "cronjobs"]
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

### Operations Role (Cluster Management)

```yaml
- name: headlamp-ops
  create: true
  rules:
    # Full read access
    - apiGroups: ["*"]
      resources: ["*"]
      verbs: ["get", "list", "watch"]
    # Node management
    - apiGroups: [""]
      resources: ["nodes"]
      verbs: ["patch", "update"]
    # Pod eviction
    - apiGroups: [""]
      resources: ["pods/eviction"]
      verbs: ["create"]
    # Scaling
    - apiGroups: ["apps"]
      resources: ["deployments/scale", "replicasets/scale", "statefulsets/scale"]
      verbs: ["patch", "update"]
```

---

## Permission Capabilities Reference

| Capability | Read-Only | Developer | Ops | Admin |
|------------|-----------|-----------|-----|-------|
| View pods, services, configmaps | Yes | Yes | Yes | Yes |
| View deployments, statefulsets | Yes | Yes | Yes | Yes |
| View events, namespaces, nodes | Yes | Yes | Yes | Yes |
| View secrets | No | Yes | Yes | Yes |
| Create/update workloads | No | Yes | Yes | Yes |
| Delete resources | No | Yes | Yes | Yes |
| Scale deployments | No | No | Yes | Yes |
| Manage cluster resources | No | No | Limited | Yes |
| RBAC management | No | No | No | Yes |

---

## Troubleshooting

### User can't see any resources

**Check 1**: Verify the ClusterRoleBinding exists
```bash
kubectl get clusterrolebindings | grep headlamp
```

**Check 2**: Verify the user's group membership
```bash
# Simulate RBAC check for a group
kubectl auth can-i list pods --as-group=headlamp-readers
```

**Check 3**: Verify kube-apiserver OIDC configuration
```bash
# On control plane node
ps aux | grep kube-apiserver | grep oidc-groups-claim
```

### User sees some resources but not others

Check that the ClusterRole includes the necessary resources and verbs:
```bash
kubectl describe clusterrole headlamp-readonly
```

### SSO works but RBAC doesn't apply

This usually means the kube-apiserver is not configured with OIDC or the group claim is not being extracted. Verify:
1. `--oidc-issuer-url` matches Keycloak realm URL
2. `--oidc-groups-claim=groups` is set
3. Keycloak token actually contains the groups claim

### Testing RBAC

```bash
# Test what a specific group can do
kubectl auth can-i list pods --as-group=headlamp-readers
kubectl auth can-i delete pods --as-group=headlamp-readers
kubectl auth can-i create deployments --as-group=headlamp-developers

# List all permissions for a subject
kubectl auth can-i --list --as-group=headlamp-readers
```

---

## Notes

- The RBAC configuration can be easily extended or narrowed via `values.yaml`
- For namespace-scoped permissions, consider using `Role` and `RoleBinding` instead of cluster-scoped resources
- Always follow the principle of least privilege - grant only the permissions users need
- For complete Keycloak SSO setup instructions, see [docs/keycloak.md](keycloak.md)
