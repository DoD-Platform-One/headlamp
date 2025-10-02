For getting Headlamp to monitor multiple clusters, there are two ways.

# Option 1 - Browser Application

1. If you multiple kubeconfig files, you can merge them together using the ":" separator. You would then export the KUBECONFIG env in a console using this command:

`export KUBECONFIG=~/.kube/config:~/someotherconfig`

To verify the config file, run this command:

`kubectl config view --flatten`

2. Deploy Headlamp as usual and you should be able to switch between clusters within the browser application.

# Option 2 - Desktop Application

1. If possible, the you can download [Headlamp as a desktop application](https://headlamp.dev/docs/latest/installation/desktop/), and from there you can use the UI to add a cluster using a button that says "Add Cluster".
2. You can then upload multiple kubeconfig files for Headlamp to monitor.
