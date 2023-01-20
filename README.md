**Kustomize configuration files for deployment to DO DOKS**
- Config files for [clj-app](https://github.com/Lisa-Stats/clj-app)
- Infrastructure for DOKS cluster created with `terraform` here:
  - [tf-do-k8s](https://github.com/Lisa-Stats/tf-do-k8s)
<!DOCTYPE html>
<html>
<head>
<body>
	<h1>Structure</h1><p>
	├── <a href="/base/">base</a><br>
	│   ├── <a href="/base/clj-deployment.yaml">clj-deployment.yaml</a><br>
	│   ├── <a href="/base/clj-service.yaml">clj-service.yaml</a><br>
	│   ├── <a href="/base/kustomization.yaml">kustomization.yaml</a><br>
	│   └── <a href="/base/migration-job.yaml">migration-job.yaml</a><br>
	├── <a href="/overlays/">overlays</a><br>
	&nbsp;&nbsp;&nbsp; ├── <a href="/overlays/dev/">dev</a><br>
	&nbsp;&nbsp;&nbsp; │   ├── <a href="/overlays/dev/add-node-affinity.yaml">add-node-affinity.yaml</a><br>
	&nbsp;&nbsp;&nbsp; │   ├── <a href="/overlays/dev/environment.txt">environment.txt</a><br>
	&nbsp;&nbsp;&nbsp; │   └── <a href="/overlays/dev/kustomization.yaml">kustomization.yaml</a><br>
        &nbsp;&nbsp;&nbsp; │   └── <a href="/overlays/dev/namespace.yaml">namespace.yaml</a><br>
	&nbsp;&nbsp;&nbsp; └── <a href="/overlays/testing/">testing</a><br>
	&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; ├── <a href="/overlays/testing/add-node-affinity.yaml">add-node-affinity.yaml</a><br>
        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; ├── <a href="/overlays/testing/kustomization.yaml">kustomization.yaml</a><br>
	&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; └── <a href="/overlays/testing/namespace.yaml">namespace.yaml</a><br>
        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; └── <a href="/overlays/testing/test-config-map.yaml">test-config-map.yaml</a><br>
        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; └── <a href="/overlays/testing/testing.env">testing.env</a><br>
<br><br><p>
</body>
</html>

**Getting Started**
1. After creating infra with `terraform` for DOKS here: [DOKS](https://github.com/Lisa-Stats/tf-do-k8s)
   - We need to first login to docker using: ```doctl registry login```
   - Then upload the credentials of the container registry to the k8s cluster:
      ```
      doctl registry kubernetes-manifest | kubectl apply -f -
      ```
   - Reference the secret as an `imagePullSecrets` by setting the default serviceaccount to always use it:
       ```
       kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "registry-<my-registry>"}]}'
       ```
2. Use `Kustomize build` to see resources that will be created

3. To apply dev overlay: ```k apply -k overlays/dev```
   - To apply testing overlay: ```k apply -k overlays/testing```

4. Imperatively add ArgoCD to the cluster
   - First make sure the ArgoCD CLI is downloaded: ```brew install argocd```
   - Create a namespace in your cluster called ArgoCD: ```kubectl create namespace argocd```
   - Apply the install manifest
     ```
     kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
     ```
   - Use port-forwarding to connect to the API server without exposing the service
     ```
     kubectl port-forward svc/argocd-server -n argocd 8080:443
     ```
   - The ArgoCD UI should now be accessible at `localhost:8080`
5. Login using the CLI
   - The initial password is stored in a secret and can be retrieved via kubectl
     ```
     kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
     ```
   - With the username `admin` and the password that was retrieved, login to ArgoCD's hostname
     ```
     argocd login <ARGOCD_SERVER>
     ```
   - Change the password using the command: ```argocd account update-password```
   - Delete the initial secret that was stored in the argocd namespace once the password has been changed
6. Create an app from a git repo
   - Set the current namespace to argocd: ```kubectl config set-context --current --namespace=argocd```
   - Create an app with:
     ```
     argocd app create <APP_NAME> --repo <GIT_REPO> --path <PATH_TO_CONFIG_FILES> --dest-server https://kubernetes.default.svc --dest-namespace dev --self-heal --set-finalizer
     ```

**TODO**
- Create persistent volumes, persistent volume claims
- Add monitoring with Prometheus, Grafana
- Look at options of adding ArgoCD declaratively
