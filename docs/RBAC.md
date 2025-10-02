# Read-Only User RBAC Implementation for Headlamp

Bigbang Read-Only RBAC manages the resources for Headlamp in a Kubernetes environment using Helm values. It configures a read-only access for specfic users, group, or service accounts that can be override in the values.

## Behavior
```bigbang.rbac``` controls the creation of role access when ```enabled:true```
- items in ```clusterRoles``` render as ```ClusterRole``` objects
- items in ```clusterRoleBingings``` render as ```ClusterRoleBindings`` objects binding roles to subjects.
- Each items supports a ```create``` flag

```
bigbang:
  rbac:
    enabled: true
    clusterRoles: 
      - name: ""
        create: true
```

The default set of rules can be modified or override in each apiGroups to provide access to more resources through the verbs.

```
        rules: 
          - apiGroups:
              - ""
            resources: 
              - pods
              - nodes
              - namespaces
            verbs: 
              - get
              - list
              - watch
```              

|Capability                               |Status                          |
|-----------------------------------------|--------------------------------|
|view pods, services, configmaps          | Read-Only                      |
|view deployments, statefulsets           | Read-Only                      |
|view events, namespaces, nodes           | Read-Only                      |
|view metrics.k8s.io                      | Read-Only                      |
|view secrets                             | Denied                         |
|Edit any resources                       | Denied                         |
|Scale deployments/pods                   | Denied                         |
|View admin settings                      | Denied                         |

- List of ```clusterRole``` created will be binded to the defined roleRef

```
    clusterRoleBindings:
      - name: ""
        roleRef: ""
```

- Toggle between ```ServiceAccount``` and SSO access through OIDC when eith ```User``` or ```Group``` are defined.

```
    clusterRoleBindings:
      - name: ""
        roleRef: ""
        subjects:
          - kind: ServiceAccount
            name:
```

## SSO Integration with Keycloak Groups

To enable read-only access through SSO, bind the newly defined clusterRole to a Keycloak group.

- Create a Keycloak Group
- Expose Groups in the ID token
- Update clusterRoleBinding

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: headlamp-read-only
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: headlamp-read-only
subjects:
  - kind: Group
    name: (Group name)
    apiGroup: rbac.authorization.k8s.io    
```
- Configure Headlamp OIDC (If not already configured)    


## Notes

- The RBAC role can be easily extended or narrowed via `values.yaml`.
- User permissions can be easily narrowed by removing or adding resources and removing or editing the resources verbs in apiGroups of the resources in the ClusterRole templates.

