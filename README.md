<!-- Warning: Do not manually edit this file. See notes on gluon + helm-docs at the end of this file for more information. -->
# headlamp

![Version: 0.29.0-bb.0](https://img.shields.io/badge/Version-0.29.0--bb.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.29.0](https://img.shields.io/badge/AppVersion-0.29.0-informational?style=flat-square)

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
| image.registry | string | `"ghcr.io"` | Container image registry |
| image.repository | string | `"headlamp-k8s/headlamp"` | Container image name |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. One of Always, Never, IfNotPresent |
| image.tag | string | `"v0.29.0"` | Container image tag, If "" uses appVersion in Chart.yaml |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.

---

_This file is programatically generated using `helm-docs` and some BigBang-specific templates. The `gluon` repository has [instructions for regenerating package READMEs](https://repo1.dso.mil/big-bang/product/packages/gluon/-/blob/master/docs/bb-package-readme.md)._

