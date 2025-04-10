# Keycloak OIDC Headlamp Config

## Keycloak Client Setup

The Keycloak client can be set up by following [this tutorial](https://headlamp.dev/docs/latest/installation/in-cluster/keycloak/). A summary is provided below, but if there are any issues refer to the source linked.

Create client:
- client id - you pick, "headlamp"
- enabled - on
- client protocol - openid-connect
- access type - confidential
- standard flow enabled - on
- valid redirect URIs - "{headlampurl}/c/main/

Under the mappers tab, create a new mapper:
- name - headlampId
- mapper type - user attribute
- user attribute - headlampId
- token claim name - id
- claim JSON type - long
- add to userinfo - on

Create username mapper:
- name - username
- mapper type - user property
- property - username
- token claim name - username
- claim JSON type - string
- add to userinfo - on
- all other sliders off

Create email mapper:
- name - email
- mapper type - user property
- property - email
- token claim name - email
- claim JSON type - string
- add to userinfo - on
- all other sliders off

Add headlampid to existing user:
- Login to keycloak Admin Console with the master realm user
- Go to your realm
- Go to the users section and edit the user
- Go to the Attributes tab
- In the bottom row type `headlampId` in the key and a random number in the `value` field.
- Click Add.

This headlampid needs to be unique per user, so it's a bad idea to generate these by hand.  This process is just a way to edit test/existing users.

## Helm Values

First get the values you need for your Keycloak:
- client_id: This is the client id you created and picked earlier
- client_secret: This is under the credential tab for your client, you can click regenerate and then copy it
- endpoints: Go to your realm settings and then open the "OpenID Endpoint Configuration". There should be values for authorization_endpoint, token_endpoint, and userinfo_endpoint which correspond to the auth, token, and user_api endpoints in the values.

Modify your values.yaml according to these example values to enable Gitlab Auth provider for SSO. If you have a licensed version of Mattermost that supports OIDC the Mattermost OIDC client backend will obtain the endpoints automatically from the [well-known OIDC endpoint](https://login.dso.mil/auth/realms/baby-yoda/.well-known/openid-configuration).
```
# OIDC Config Additions
config:
  oidc:
    enabled: false
    clientID: dev_00eb8904-5b88-4c68-ad67-cec0d2e07aa6_headlamp
    clientSecret: "no-secret"
    issuerURL: https://keycloak.dev.bigbang.mil/auth/realms/baby-yoda
    scopes: "email,profile"
```

Example install:
```
helm upgrade -i headlamp chart -n headlamp --create-namespace -f my-values.yml
```


## OIDC Custom CA

Headlamp can be configured to point to specific files to trust with an OIDC auth connection, here is an example when using Big Bang to deploy headlamp, assuming you are populating a secret named "ca-cert" in the same namespace, with a key of cert.pem and value of a single PEM encoded certificate (an easy way to make this secret is included below as well):

```yaml
addons:
  headlamp:
    values:
      volumes:
        - name: ca-cert
          secret:
            secretName: ca-secret
            defaultMode: 0644
      volumeMounts:
        - name: ca-cert
          mountPath: /etc/ssl/certs
          readOnly: true
```

For secret creation with this example and a pem file at `/path/to/cert.pem`:
```bash
kubectl create secret generic ca-secret --from-file=cert.pem=/path/to/cert.pem -n headlamp
```
