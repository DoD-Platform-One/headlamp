# Headlamp

## Overview

Headlamp is a user friendly, extensible Kubernetes web UI designed to simplify cluster management across platforms. It provides a simple and secure graphical interface for interacting with cluster resources. It allows users to view workloads, nodes, namespaces, RBAC policies, and custom resources directly from the browser without requiring direct `kubectl` access.

## Dependencies

This chart has no hard dependencies, but when deployed via Big Bang it integrates with Istio for ingress and supports SSO via Keycloak.

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

This chart uses `bb-common` for Istio resource rendering. When Istio is enabled with a restrictive outbound traffic policy, network access from the Headlamp namespace is restricted by default. This ensures that Headlamp communicates only with approved internal endpoints, such as the Kubernetes API server or identity provider.

If Headlamp requires access to specific external hosts (for example, plugins hosted externally), custom ServiceEntries can be defined in the `values.yaml` file to explicitly allow that egress traffic.

Example Configuration:

```yaml
istio:
  enabled: true
  sidecar:
    enabled: true
    outboundTrafficPolicyMode: REGISTRY_ONLY
  serviceEntries:
    custom:
      - name: allow-headlamp-api
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

See the [bb-common Istio documentation](https://repo1.dso.mil/big-bang/product/packages/bb-common/-/tree/main/docs/istio) for full configuration options.
