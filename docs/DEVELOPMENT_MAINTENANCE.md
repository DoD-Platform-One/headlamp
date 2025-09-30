# Notices
This section should include information about what updates need to be made to the package. This includes breaking changes from new upgrades, additional configurations needed.


# How to upgrade the Headlamp Package chart

The below details the steps required to update to a new version of the Headlamp package.

1. To update headlamp's helm chart, navigate to [upstream](https://github.com/kubernetes-sigs/headlamp) and find the latest tag. Next, update the dependency within `chart/Chart.yaml` and run `helm dependencies update ./chart` to pull in the new chart. Make sure the old helm chart has been removed and the new one has been added within chart/charts.

2. Update version references for the Chart. `version` should be `<version>-bb.x` (ex: `0.30.1-bb.x`) and `appVersion` should be `<version>` (ex: `0.30.1`). Also validate that the BB annotation for confluence is updated.

3. Review the [upstream release notes](https://github.com/headlamp-k8s/headlamp/releases/) for the update you are going to, as well as any versions skipped over between the last BB release and this one. Note any breaking changes and new features.

4. Based on the upstream changelog review from earlier, make any changes required to resolve breaking changes and reconcile the Big Bang modifications.

5. Modify the `version` in `Chart.yaml`. Also modify the `appVersion` and the `bigbang.dev/applicationVersions` to the new upstream version of Headlamp.
    ```yaml
    dependencies:
    - name: headlamp
      alias: upstream
      version: X.X.X
      repository: https://headlamp-k8s.github.io/headlamp/
    - name: gluon
      repository: oci://registry1.dso.mil/bigbang
      version: X.X.X
    ```
6. Update helm dependencies to latest library versions.
    ```
    helm dependency update ./chart
    ```

7. Add a changelog entry for the update. At minimum mention updating the image versions, `Updated Headlamp to x.x.x`.

8. Update the readme following the [steps in Gluon](https://repo1.dso.mil/platform-one/big-bang/apps/library-charts/gluon/-/blob/master/docs/bb-package-readme.md).

9. Open MR (or check the one that Renovate created for you) and validate that the pipeline is successful. Also follow the testing steps below for some manual confirmations.

10. Once all manual testing is complete take your MR out of "Draft" status and add the review label.

# Testing new Headlamp version

NOTE: For these testing steps it is good to do them on both a clean install and an upgrade. For clean install, point headlamp to your branch. For an upgrade do an install with headlamp pointing to the latest tag, then perform a helm upgrade with headlamp pointing to your branch.

## Cluster setup

Always make sure your local bigbang repo is current before deploying.

1. Export your Ironbank/Harbor credentials (this can be done in your ~/.bashrc or ~/.zshrc file if desired). These specific variables are expected by the k3d-dev.sh script when deploying metallb, and are referenced in other commands for consistency:

```
export REGISTRY_USERNAME='<your_username>'
export REGISTRY_PASSWORD='<your_password>'
```
2. xport the path to your local bigbang repo (without a trailing /):
 Note that wrapping your file path in quotes when exporting will break expansion of ~.

 ```
 export BIGBANG_REPO_DIR=<absolute_path_to_local_bigbang_repo>
 ```
 e.g.

 ```
 export BIGBANG_REPO_DIR=~/repos/bigbang
 ```

 3. Run the k3d_dev.sh script to deploy a dev cluster :
 
 ```
 "${BIGBANG_REPO_DIR}/docs/assets/scripts/developer/k3d-dev.sh"
 ```

 4. Export your kubeconfig:

 ```
 export KUBECONFIG=~/.kube/<your_kubeconfig_file>
 ```
e.g.

```
export KUBECONFIG=~/.kube/Sam.Sarnowski-dev-config
```
5. Deploy flux to your cluster:

```
"${BIGBANG_REPO_DIR}/scripts/install_flux.sh -u ${REGISTRY_USERNAME} -p ${REGISTRY_PASSWORD}"
```

## Deploy BigBang

From the root of this repo, run one of the following deploy commands:

```
helm upgrade -i bigbang ${BIGBANG_REPO_DIR}/chart/ -n bigbang --create-namespace \
--set registryCredentials.username=${REGISTRY_USERNAME} --set registryCredentials.password=${REGISTRY_PASSWORD} \
-f https://repo1.dso.mil/big-bang/bigbang/-/raw/master/tests/test-values.yaml \
-f https://repo1.dso.mil/big-bang/bigbang/-/raw/master/chart/ingress-certs.yaml \
-f https://repo1.dso.mil/big-bang/bigbang/-/raw/master/docs/assets/configs/example/dev-sso-values.yaml \
-f docs/dev-overrides/minimal.yaml \
-f docs/dev-overrides/headlamp-testing.yaml
```
This will deploy the headlamp for testing.

## Accessing Headlamp UI

To access Headlamp UI dashboard a token is needed for access. Run this command to generate a token for access.
```
kubectl create token headlamp -n headlamp
```

## Test Values Yaml / Validation

To install Headlamp as a community package in a Big Bang Kubernetes Cluster, save the following YAML to a file (eg, headlamp.yaml):

See https://docs-bigbang.dso.mil/latest/docs/guides/deployment-scenarios/extra-package-deployment/#Wrapper-Deployment for more details.

After deployment in K3D:
- Ensure all resources have reconciled and are healthy
- Ensure all pods are running as expected. 
- Exposed your app, and make sure you can access the headlamp ui.
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

## Files that require integration testing
* `chart/templates/bigbang/*`
* `chart/values.yaml` (If it changes anything in:)
  * Monitoring
  * Istio hardening
  * Network policies
  * Kyverno policies
  * Service definition
  * TLS settings

As part of your MR that modifies bigbang packages, you should modify the bigbang  [bigbang/tests/test-values.yaml](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/tests/test-values.yaml?ref_type=heads) against your branch for the CI/CD MR testing by enabling your packages.

    - To do this, at a minimum, you will need to follow the instructions at [bigbang/docs/developer/test-package-against-bb.md](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/docs/developer/test-package-against-bb.md?ref_type=heads) with changes for Headlamp enabled (reference check the code above (Branch/Tag Config step), actual changes could be more depending on what changes where made to Headlamp in the pakcage MR).

### automountServiceAccountToken
The mutating Kyverno policy named `update-automountserviceaccounttokens` is leveraged to harden all ServiceAccounts in this package with `automountServiceAccountToken: false`. This policy is configured by namespace in the Big Bang umbrella chart repository at [chart/templates/kyverno-policies/values.yaml](https://repo1.dso.mil/big-bang/bigbang/-/blob/master/chart/templates/kyverno-policies/values.yaml?ref_type=heads).

This policy revokes access to the K8s API for Pods utilizing said ServiceAccounts. If a Pod truly requires access to the K8s API (for app functionality), the Pod is added to the `pods:` array of the same mutating policy. This grants the Pod access to the API, and creates a Kyverno PolicyException to prevent an alert.
