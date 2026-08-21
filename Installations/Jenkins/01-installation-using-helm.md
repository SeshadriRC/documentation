**Prerequisites**

* Kubernetes cluster running
* `kubectl` and `helm` installed and configured

---

**Step 1: Add Jenkins Helm Repository**

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update

```

---

**Step 2: Create Namespace**

```bash
kubectl create namespace jenkins

```

---

**Step 3: Create Values File (`jenkins-values.yaml`)**

```yaml
controller:
  componentName: "jenkins-controller"
  resources:
    requests:
      cpu: "500m"
      memory: "1024Mi"
    limits:
      cpu: "2000m"
      memory: "2048Mi"
  serviceType: ClusterIP
  servicePort: 8080

persistence:
  enabled: true
  size: 20Gi

agent:
  enabled: true

```

---

**Step 4: Deploy Jenkins with Helm**

```bash
helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins \
  -f jenkins-values.yaml

```

---

**Step 5: Retrieve Initial Admin Password**

```bash
kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
echo

```

---

**Step 6: Port-Forward to Access Dashboard**

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins

```

* Access URL: `http://localhost:8080`
* Username: `admin`
* Password: *(Output from Step 5)*
