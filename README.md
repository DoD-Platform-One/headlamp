<!-- Warning: Do not manually edit this file. See notes on gluon + helm-docs at the end of this file for more information. -->
# headlamp

![Version: 0.32.1-bb.2](https://img.shields.io/badge/Version-0.32.1--bb.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.32.1](https://img.shields.io/badge/AppVersion-0.32.1-informational?style=flat-square) ![Maintenance Track: unknown](https://img.shields.io/badge/Maintenance_Track-unknown-red?style=flat-square)

Headlamp is an easy-to-use and extensible Kubernetes web UI.

## Upstream References

- <https://headlamp.dev/>
- <https://github.com/headlamp-k8s/headlamp/tree/main/charts/headlamp>
- <https://github.com/headlamp-k8s/headlamp>

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
| replicaCount | int | `1` | Number of desired pods |
| image.registry | string | `"registry1.dso.mil"` | Container image registry |
| image.repository | string | `"ironbank/opensource/headlamp-k8s/headlamp"` | Container image name |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. One of Always, Never, IfNotPresent |
| image.tag | string | `"v0.32.0"` | Container image tag, If "" uses appVersion in Chart.yaml |
| image.pullSecrets[0] | string | `"private-registry"` |  |
| imagePullSecrets | list | `[{"name":"private-registry"}]` | An optional list of references to secrets in the same namespace to use for pulling any of the images used |
| nameOverride | string | `""` | Overrides the name of the chart |
| fullnameOverride | string | `""` | Overrides the full name of the chart |
| initContainers | list | `[]` | An optional list of init containers to be run before the main containers. |
| config.inCluster | bool | `true` |  |
| config.baseURL | string | `""` | base url path at which headlamp should run |
| config.oidc.secret.create | bool | `false` | Generate OIDC secret. If true, will generate a secret using .config.oidc. |
| config.oidc.secret.name | string | `"oidc"` | Name of the OIDC secret. |
| config.oidc.clientID | string | `""` | OIDC client ID Change to your respective IDP endpoints  |
| config.oidc.clientSecret | string | `""` | OIDC client secret |
| config.oidc.issuerURL | string | `""` | OIDC issuer URL |
| config.oidc.scopes | string | `""` | OIDC scopes to be used |
| config.oidc.validatorClientID | string | `""` | OIDC client to be used during token validation |
| config.oidc.validatorIssuerURL | string | `""` | OIDC Issuer URL to be used during token validation |
| config.oidc.useAccessToken | bool | `false` | Use 'access_token' instead of 'id_token' when authenticating using OIDC |
| config.oidc.externalSecret.enabled | bool | `false` |  |
| config.oidc.externalSecret.name | string | `""` |  |
| config.pluginsDir | string | `"/headlamp/plugins"` | directory to look for plugins |
| config.extraArgs | list | `[]` |  |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | An optional list of environment variables env:   - name: KUBERNETES_SERVICE_HOST     value: "localhost"   - name: KUBERNETES_SERVICE_PORT     value: "6443" |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.name | string | `""` | The name of the service account to use.(If not set and create is true, a name is generated using the fullname template) |
| clusterRoleBinding.create | bool | `true` | Specified whether a cluster role binding should be created |
| clusterRoleBinding.clusterRoleName | string | `"cluster-admin"` | Set name of the Cluster Role with limited permissions from you cluster for example - clusterRoleName: user-ro |
| clusterRoleBinding.annotations | object | `{}` | Annotations to add to the cluster role binding |
| deploymentAnnotations | object | `{}` | Annotations to add to the deployment |
| podAnnotations | object | `{}` | Annotations to add to the pod |
| podSecurityContext | object | `{}` | Headlamp pod's Security Context |
| securityContext | object | `{"privileged":false,"runAsGroup":101,"runAsNonRoot":true,"runAsUser":100}` | Headlamp containers Security Context |
| service.type | string | `"ClusterIP"` | Kubernetes Service type |
| service.port | int | `4466` | Kubernetes Service port |
| service.clusterIP | string | `""` | Kubernetes Service clusterIP |
| service.loadBalancerIP | string | `""` | Kubernetes Service loadBalancerIP |
| service.loadBalancerSourceRanges | list | `[]` | Kubernetes Service loadBalancerSourceRanges |
| service.nodePort | string | `nil` | Kubernetes Service Nodeport |
| volumeMounts | list | `[]` | Headlamp containers volume mounts |
| volumes | list | `[]` | Headlamp pod's volumes |
| persistentVolumeClaim.enabled | bool | `false` | Enable Persistent Volume Claim |
| persistentVolumeClaim.annotations | object | `{}` | Annotations to add to the persistent volume claim (if enabled) |
| persistentVolumeClaim.accessModes | list | `[]` | accessModes for the persistent volume claim, eg: ReadWriteOnce, ReadOnlyMany, ReadWriteMany etc. |
| persistentVolumeClaim.size | string | `""` | size of the persistent volume claim, eg: 10Gi. Required if enabled is true. |
| persistentVolumeClaim.storageClassName | string | `""` | storageClassName for the persistent volume claim. |
| persistentVolumeClaim.selector | object | `{}` | selector for the persistent volume claim. |
| persistentVolumeClaim.volumeMode | string | `""` | volumeMode for the persistent volume claim, eg: Filesystem, Block. |
| ingress.enabled | bool | `false` | Enable ingress controller resource |
| ingress.annotations | object | `{}` | Annotations for Ingress resource |
| ingress.labels | object | `{}` | Additional labels to add to the Ingress resource |
| ingress.ingressClassName | string | `""` | Ingress class name. replacement for the deprecated "kubernetes.io/ingress.class" annotation |
| ingress.hosts | list | `[]` | Hostname(s) for the Ingress resource Please refer to https://kubernetes.io/docs/reference/kubernetes-api/service-resources/ingress-v1/#IngressSpec for more information. |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| resources | object | `{}` | CPU/Memory resource requests/limits |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| tolerations | list | `[]` | Toleration labels for pod assignment |
| affinity | object | `{}` | Affinity settings for pod assignment |
| pluginsManager.enabled | bool | `false` | Enable plugin manager |
| pluginsManager.configFile | string | `"plugin.yaml"` | Plugin configuration file name |
| pluginsManager.configContent | string | `""` | Plugin configuration content in YAML format. This is required if plugins.enabled is true. |
| pluginsManager.baseImage | string | `"node:lts-alpine"` | Base node image to use |
| pluginsManager.version | string | `"latest"` | Headlamp plugin package version to install |
| extraManifests | list | `[]` | Additional Kubernetes manifests to be deployed. Include the manifest as nested YAML. |
| waitJob.enabled | bool | `true` |  |
| waitJob.scripts.image | string | `"registry1.dso.mil/ironbank/opensource/kubernetes/kubectl:v1.32.7"` |  |
| waitJob.permissions.apiGroups[0] | string | `"apps"` |  |
| waitJob.permissions.resources[0] | string | `"deployments"` |  |
| waitJob.permissions.verbs[0] | string | `"get"` |  |
| waitJob.permissions.verbs[1] | string | `"list"` |  |
| waitJob.permissions.verbs[2] | string | `"watch"` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.

---

_This file is programatically generated using `helm-docs` and some BigBang-specific templates. The `gluon` repository has [instructions for regenerating package READMEs](https://repo1.dso.mil/big-bang/product/packages/gluon/-/blob/master/docs/bb-package-readme.md)._

