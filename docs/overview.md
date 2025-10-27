# Headlamp

## Overview

Headlamp is a user friendly, extensible Kubernetes web UI designed to simplify cluster management across platforms. It supports dashboard designed to provide a simple and secure graphical interface for interacting with cluster resources. It allows users to view workloads, nodes, namespaces, RBAC policies, and custom resources directly from the browser without requiring direct `kubectl` access.

Please review the Big Bang [Architecture Document](https://repo1.dso.mil/big-bang/-/tree/master) for more information about its role within Big Bang.

## Dependencies

This chart depends on the [Headlamp](https://repo1.dso.mil/platform-one/big-bang/bigbang/-/blob/master/chart/values.yaml) Big Bang package.

## How it works

This chart deploys the Headlamp dashboard as a web UI for Kubernetes management. When deployed within Big Bang, it integrates with Istio and supports Big Bang's SSO model for user authentication and role-based access.

The Headlamp chart provisions a Kubernetes `Deployment`, `Service`, and `VirtualService` to make the dashboard accessible through the Big Bang mesh.
The following summarizes how Headlamp works within the Big Bang ecosystem:

1. Install Headlamp via Helm.
2. The chart creates a web-based dashboard.
3. Authentication and access are handled through Big Bang identity provider or token.
4. Users can view and manage cluster resources based on RBAC permissions granted by their Kubernetes role bindings.

## External Resources

If you would like to learn more about the Headlamp application and its features, see their [official documentation](https://headlamp.dev/docs/).

## Istio Integration

When istio hardening is enabled (`istio.enabled` and `istio.hardened.enabled`), outbound network access from the Headlamp namespace is restricted by default. This ensures that Headlamp communicates only with approved internal endpoints, such as the Kubernetes API server or identity provider.

If Headlamp requires access to specific external hosts (for example, plugins hosted externally), custom ServiceEntries can be defined in the `values.yaml` file to explicitly allow that egress traffic.

Example Configuration:

```yaml
istio:
  enabled: true
  hardened:
    enabled: true
  customServiceEntries:
    - name: allow-headlamp-api
      enabled: true
      spec:
        hosts:
          - "api.external-service.example.com"
        location: MESH_EXTERNAL
        exportTo:
          - "."
        ports:
          - name: https
            number: 443
            protocol: TLS
        resolution: DNS
```
