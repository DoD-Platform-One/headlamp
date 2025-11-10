<!-- Warning: Do not manually edit this file. See notes on gluon + helm-docs at the end of this file for more information. -->
# headlamp

![Version: 0.37.0-bb.0](https://img.shields.io/badge/Version-0.37.0--bb.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.37.0](https://img.shields.io/badge/AppVersion-0.37.0-informational?style=flat-square) ![Maintenance Track: unknown](https://img.shields.io/badge/Maintenance_Track-unknown-red?style=flat-square)

Headlamp is an easy-to-use and extensible Kubernetes web UI.

## Upstream References

- <https://headlamp.dev/>
- <https://github.com/kubernetes-sigs/headlamp/tree/main/charts/headlamp>
- <https://github.com/kubernetes-sigs/headlamp>

## Upstream Release Notes

- [Find upstream chart's release notes and CHANGELOG here](https://github.com/headlamp-k8s/headlamp/releases/)
- [Find upstream applications's release notes and CHANGELOG here](https://github.com/headlamp-k8s/headlamp/releases/)

## Learn More

- [Application Overview](docs/overview.md)
- [Other Documentation](docs/)

## Pre-Requisites

- Kubernetes Cluster deployed
- Kubernetes config installed in `~/.kube/config`
- Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

- Clone down the repository
- cd into directory

```bash
helm install headlamp chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| domain | string | `"dev.bigbang.mil"` | Domain used for BigBang created exposed services |
| global.imagePullSecrets[0].name | string | `"private-registry"` |  |
| istio.enabled | bool | `false` |  |
| istio.hardened | object | `{"customAuthorizationPolicies":[],"customServiceEntries":[],"enabled":false,"outboundTrafficPolicyMode":"REGISTRY_ONLY"}` | Default peer authentication values |
| istio.mtls.mode | string | `"STRICT"` | STRICT = Allow only mutual TLS traffic, PERMISSIVE = Allow both plain text and mutual TLS traffic |
| istio.headlamp | object | `{"annotations":{},"enabled":true,"gateways":["istio-system/public"],"hosts":["headlamp.{{ .Values.domain }}"],"labels":{}}` | Headlamp UI specific VirtualService values |
| istio.headlamp.enabled | bool | `true` | Toggle VirtualService creation |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` |  |
| networkPolicies.vpcCidr | string | `"0.0.0.0/0"` |  |
| networkPolicies.ingressLabels.app | string | `"public-ingressgateway"` |  |
| networkPolicies.ingressLabels.istio | string | `"ingressgateway"` |  |
| networkPolicies.additionalPolicies | list | `[]` |  |
| openshift | bool | `false` |  |
| monitoring | object | `{"enabled":false,"serviceMonitor":{"scheme":"","tlsConfig":{}}}` | Monitoring toggle, affects servicemonitor and networkPolicies |
| metrics.enabled | bool | `false` | Toggle Prometheus Blackbox Exporter Installation |
| metrics.port | int | `9115` |  |
| metrics.global | object | `{"imagePullSecrets":[{"name":"private-registry"}]}` | Exporter imagePullSecrets |
| metrics.image.registry | string | `"registry1.dso.mil"` |  |
| metrics.image.repository | string | `"ironbank/opensource/prometheus/blackbox_exporter"` |  |
| metrics.image.tag | string | `"v0.27.0"` |  |
| metrics.image.pullSecret | string | `"private-registry"` |  |
| metrics.podSecurityContext | object | `{"runAsGroup":1000}` | Pod securityContext |
| metrics.securityContext | object | `{"runAsGroup":1000,"runAsUser":1000}` | Container securityContext |
| metrics.config.modules.http_2xx.prober | string | `"http"` |  |
| metrics.config.modules.http_2xx.timeout | string | `"5s"` |  |
| metrics.config.modules.http_2xx.http.method | string | `"GET"` |  |
| bbtests.enabled | bool | `false` |  |
| bbtests.cypress.artifacts | bool | `true` |  |
| bbtests.cypress.envs.cypress_url | string | `"http://headlamp.headlamp.svc.cluster.local:4466"` |  |
| bbtests.cypress.resources.requests.cpu | string | `"1"` |  |
| bbtests.cypress.resources.requests.memory | string | `"2Gi"` |  |
| bbtests.cypress.resources.limits.cpu | string | `"1"` |  |
| bbtests.cypress.resources.limits.memory | string | `"2Gi"` |  |
| waitJob.enabled | bool | `true` |  |
| waitJob.permissions.apiGroups[0] | string | `"apps"` |  |
| waitJob.permissions.resources[0] | string | `"deployments"` |  |
| waitJob.permissions.verbs[0] | string | `"get"` |  |
| waitJob.permissions.verbs[1] | string | `"list"` |  |
| waitJob.permissions.verbs[2] | string | `"watch"` |  |
| bigbang.rbac.enabled | bool | `false` |  |
| bigbang.rbac.clusterRoles[0].name | string | `"read-1"` |  |
| bigbang.rbac.clusterRoles[0].create | bool | `true` |  |
| bigbang.rbac.clusterRoles[0].rules[0].apiGroups[0] | string | `""` |  |
| bigbang.rbac.clusterRoles[0].rules[0].resources[0] | string | `"namespaces"` |  |
| bigbang.rbac.clusterRoles[0].rules[0].resources[1] | string | `"pods"` |  |
| bigbang.rbac.clusterRoles[0].rules[0].resources[2] | string | `"nodes"` |  |
| bigbang.rbac.clusterRoles[0].rules[0].verbs[0] | string | `"get"` |  |
| bigbang.rbac.clusterRoles[0].rules[0].verbs[1] | string | `"list"` |  |
| bigbang.rbac.clusterRoles[0].rules[0].verbs[2] | string | `"watch"` |  |
| bigbang.rbac.clusterRoleBindings[0].name | string | `"read-1"` |  |
| bigbang.rbac.clusterRoleBindings[0].roleRef | string | `"read-1"` |  |
| bigbang.rbac.clusterRoleBindings[0].subjects[0].kind | string | `"ServiceAccount"` |  |
| bigbang.rbac.clusterRoleBindings[0].subjects[0].name | string | `"dev-sa"` |  |
| bigbang.rbac.clusterRoleBindings[0].subjects[0].namespace | string | `nil` |  |
| upstream.image.registry | string | `"registry1.dso.mil"` |  |
| upstream.image.repository | string | `"ironbank/opensource/headlamp-k8s/headlamp"` |  |
| upstream.image.pullPolicy | string | `"Always"` |  |
| upstream.image.tag | string | `"v0.37.0"` |  |
| upstream.image.pullSecrets[0] | string | `"private-registry"` |  |
| upstream.imagePullSecrets[0].name | string | `"private-registry"` |  |
| upstream.nameOverride | string | `"headlamp"` |  |
| upstream.config.baseURL | string | `""` |  |
| upstream.config.oidc.clientID | string | `""` |  |
| upstream.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.service.port | int | `4466` |  |
| upstream.clusterRoleBinding.create | bool | `true` | Specified whether a cluster role binding should be created |
| upstream.clusterRoleBinding.clusterRoleName | string | `"cluster-admin"` | Set name of the Cluster Role with limited permissions from you cluster for example - clusterRoleName: user-ro |
| upstream.clusterRoleBinding.annotations | object | `{}` | Annotations to add to the cluster role binding |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.

---

_This file is programatically generated using `helm-docs` and some BigBang-specific templates. The `gluon` repository has [instructions for regenerating package READMEs](https://repo1.dso.mil/big-bang/product/packages/gluon/-/blob/master/docs/bb-package-readme.md)._

