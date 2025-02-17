# Upgrading to a new version

The below details the steps required to update to a new version of the Headlamp package.

1. Review the [upstream release notes](https://github.com/headlamp-k8s/headlamp/releases/) for the update you are going to, as well as any versions skipped over between the last BB release and this one. Note any breaking changes and new features.

2. Use `kpt` to pull the upstream chart via the latest tag that corresponds to the application version. From the root of the repo run `kpt pkg update chart@headlamp-0.26.0 --strategy alpha-git-patch` replacing `headlamp-0.26.0` with the version tag you got in step 1.

3. Based on the upstream changelog review from earlier, make any changes required to resolve breaking changes and reconcile the Big Bang modifications.

4. Modify the `version` in `Chart.yaml`. Also modify the `appVersion` and the `bigbang.dev/applicationVersions` to the new upstream version of Headlamp.
    ```yaml
    dependencies:
    - name: headlamp
      version: X.X.X
      repository: https://headlamp-k8s.github.io/headlamp/
    - name: gluon
      repository: oci://registry1.dso.mil/bigbang
      version: X.X.X
    ```

5. Update helm dependencies to latest library versions.
    ```
    helm dependency update ./chart
    ```

6. Update `CHANGELOG.md` adding an entry for the new version and noting all changes (at minimum should include `Updated Headlamp to x.x.x`).

7. Generate the `README.md` updates by following the [guide in gluon](https://repo1.dso.mil/platform-one/big-bang/apps/library-charts/gluon/-/blob/master/docs/bb-package-readme.md).

8. Open an MR in "Draft" status and validate that CI passes. This will perform a number of smoke tests against the package, but it is good to manually deploy to test some things that CI doesn't. Follow the steps below for manual testing.

9. Once all manual testing is complete take your MR out of "Draft" status and add the review label.

# Testing for updates

NOTE: For these testing steps it is good to do them on both a clean install and an upgrade. For clean install, point headlamp to your branch. For an upgrade do an install with headlamp pointing to the latest tag, then perform a helm upgrade with headlamp pointing to your branch.

To install Headlamp as a community package in a Big Bang Kubernetes Cluster, save the following YAML to a file (eg, headlamp.yaml):

See https://docs-bigbang.dso.mil/latest/docs/guides/deployment-scenarios/extra-package-deployment/#Wrapper-Deployment for more details.

```yaml
grafana:
  enabled: false
kiali:
  enabled: false
kyverno:
  enabled: false
kyvernoPolicies:
  enabled: false
kyvernoReporter:
  enabled: false
promtail:
  enabled: false
loki:
  enabled: false
neuvector:
  enabled: false
tempo:
  enabled: false
monitoring:
  enabled: false
istio:
  enabled: true

packages:
  headlamp:
    enabled: true
    wrapper:
      enabled: false
    git:
      repo: https://repo1.dso.mil/big-bang/apps/sandbox/headlamp.git
      #path: chart
      tag: null #0.9.18-bb.4
      branch: "11-spike-deploy-headlamp-using-wrapper"
      #branch: "test-istio-enable2"
    istio:
      enabled: true
    values:
      istio:
        enabled: true
        hardened:
          enabled: true
      networkPolicies:
        enabled: true
```

Then install/update bigbang via the standard `helm upgrade` command, adding `-f <YAML file location>` to the end. This will install Headlamp into the named namespace.

Example:
  ```shell
  helm upgrade -i bigbang ./chart -n bigbang --create-namespace --set registryCredentials.username=<registry1.username> --set registryCredentials.password=<registry1.password> -f ./tests/test-values.yaml -f ../bigbang/chart/ingress-certs.yaml -f <YAML file location>/headlamp.yaml
  ```

This method is recommended because it will also take care of creating private registry credentials, the istio virtual service, and network policies. Once the installation is complete, the Headlamp UI will be reachable via `https://headlamp.<your bigbang domain>`

Testing Steps:
- Ensure all resources have reconciled and are healthy
- Ensure the application is resolvable at `headlamp.dev.bigbang.mil`
- Run the cypress tests to confirm functionality of adding and deleting an application via the UI
    ```shell
    cd ./chart/tests
    cp .example.cypress.config.js cypress.config.js
    export cypress_url=https://headlamp.dev.bigbang.mil/
    npx cypress run
    ```
- NOTE: the install can take 10+ minutes

When in doubt with any testing or upgrade steps ask one of the CODEOWNERS for assistance.

# Big Bang Integration Testing

### Files that require integration testing
* `chart/templates/bigbang/*`
* `chart/values.yaml` (If it changes anything in:)
  * Monitoring
  * Istio hardening
  * Network policies
  * Kyverno policies
  * Service definition
  * TLS settings

As part of your MR that modifies bigbang packages, you should modify the bigbang  [bigbang/tests/test-values.yaml](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/tests/test-values.yaml?ref_type=heads) against your branch for the CI/CD MR testing by enabling your packages.

    - To do this, at a minimum, you will need to follow the instructions at [bigbang/docs/developer/test-package-against-bb.md](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/developer/test-package-against-bb.md?ref_type=heads) with changes for Headlamp enabled (the below is a reference, actual changes could be more depending on what changes where made to Headlamp in the pakcage MR).

```
packages:
  headlamp:
    enabled: true
    wrapper:
      enabled: true
    git:
      repo: https://repo1.dso.mil/big-bang/product/community/headlamp
      tag: Null
      branch: <Insert-branch-being-tested>
      path: chart
    istio:
      enabled: true
      hardened:
        enabled: true
      hosts:
        - names:
            - "headlamp"
          gateways:
            - "public"
          destination:
            port: 8080
    values:
      headlamp:
        service:
          port: 8080
```


### automountServiceAccountToken
The mutating Kyverno policy named `update-automountserviceaccounttokens` is leveraged to harden all ServiceAccounts in this package with `automountServiceAccountToken: false`. This policy is configured by namespace in the Big Bang umbrella chart repository at [chart/templates/kyverno-policies/values.yaml](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/chart/templates/kyverno-policies/values.yaml?ref_type=heads).

This policy revokes access to the K8s API for Pods utilizing said ServiceAccounts. If a Pod truly requires access to the K8s API (for app functionality), the Pod is added to the `pods:` array of the same mutating policy. This grants the Pod access to the API, and creates a Kyverno PolicyException to prevent an alert.
