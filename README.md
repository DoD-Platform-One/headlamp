<!-- Warning: Do not manually edit this file. See notes on gluon + helm-docs at the end of this file for more information. -->
# headlamp

![Version: 0.40.0-bb.0](https://img.shields.io/badge/Version-0.40.0--bb.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.40.0](https://img.shields.io/badge/AppVersion-0.40.0-informational?style=flat-square) ![Maintenance Track: unknown](https://img.shields.io/badge/Maintenance_Track-unknown-red?style=flat-square)

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
| istio | object | Istio disabled | Istio configuration; see bb-common istio docs for details: https://repo1.dso.mil/big-bang/product/packages/bb-common/-/tree/main/docs/istio?ref_type=heads |
| networkPolicies | object | Basic configuration necessary for headlamp to function standalone. | Network Policy configuration; see bb-common network policy docs for details: https://repo1.dso.mil/big-bang/product/packages/bb-common/-/tree/main/docs/network-policies?ref_type=heads |
| routes | object | Routes disabled, Big Bang umbrella chart configures these when deployed with Istio | Routes configuration; see bb-common routes docs for details: https://repo1.dso.mil/big-bang/product/packages/bb-common/-/tree/main/docs/routes?ref_type=heads |
| routes.outbound | object | `{"sso":{"enabled":false,"hosts":[]}}` | Outbound routes for external service access (e.g., SSO/Keycloak) Big Bang umbrella chart configures these when SSO is enabled |
| domain | string | `"dev.bigbang.mil"` | Domain used for BigBang created exposed services |
| global.imagePullSecrets[0].name | string | `"private-registry"` |  |
| openshift | bool | `false` |  |
| monitoring | object | `{"enabled":false,"serviceMonitor":{"scheme":"","tlsConfig":{}}}` | Monitoring toggle, affects servicemonitor and networkPolicies |
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
| bigbang | object | RBAC disabled, uses upstream chart's default cluster-admin binding | BigBang RBAC configuration for Headlamp This section creates ClusterRoles and ClusterRoleBindings for controlling access. For SSO/Keycloak integration, bind to Groups that match Keycloak group names. See docs/keycloak.md and docs/RBAC.md for detailed configuration instructions. |
| bigbang.rbac.enabled | bool | `false` | Enable BigBang RBAC management |
| bigbang.rbac.clusterRoles | list | `[{"create":true,"name":"headlamp-readonly","rules":[{"apiGroups":[""],"resources":["namespaces","pods","pods/log","services","configmaps","events","nodes","persistentvolumeclaims","persistentvolumes"],"verbs":["get","list","watch"]},{"apiGroups":["apps"],"resources":["deployments","daemonsets","replicasets","statefulsets"],"verbs":["get","list","watch"]},{"apiGroups":["batch"],"resources":["jobs","cronjobs"],"verbs":["get","list","watch"]},{"apiGroups":["networking.k8s.io"],"resources":["ingresses","networkpolicies"],"verbs":["get","list","watch"]}]}]` | ClusterRoles to create Each role defines a set of permissions that can be bound to users, groups, or service accounts |
| bigbang.rbac.clusterRoleBindings | list | `[{"name":"headlamp-sa-readonly","roleRef":"headlamp-readonly","subjects":[{"kind":"ServiceAccount","name":"dev-sa","namespace":"headlamp"}]}]` | ClusterRoleBindings to create Binds ClusterRoles to subjects (Users, Groups, or ServiceAccounts) For Keycloak SSO, use kind: Group with the Keycloak group name |
| upstream.image.registry | string | `"registry1.dso.mil"` |  |
| upstream.image.repository | string | `"ironbank/opensource/headlamp-k8s/headlamp"` |  |
| upstream.image.pullPolicy | string | `"Always"` |  |
| upstream.image.tag | string | `"v0.40.0"` |  |
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

