# Kubernetes Commands for DevOps Engineers

A comprehensive reference for cluster operations, application deployment, debugging, and production troubleshooting.

---

## 1. Cluster & Kubeconfig Management

```bash
# Display cluster information and control-plane endpoints
kubectl cluster-info
kubectl cluster-info --context kind-demo-cluster

# Inspect kubeconfig configuration
kubectl config view
ls ~/.kube/config

# List all available contexts in kubeconfig
kubectl config get-contexts

# View current active context
kubectl config current-context

# Switch between cluster contexts
kubectl config use-context kind-<cluster-name>
kubectl config use-context kind-basic-mlflow-cluster
kubectl config use-context kind-observability-cluster

# Set default namespace for the current context (avoids typing -n <namespace> on every command)
kubectl config set-context --current --namespace=app1-ns
kubectl config set-context --current --namespace=employee-app

# Inspect default namespace of the active context
kubectl config view --minify --output 'jsonpath={..namespace}'

# Merge multiple kubeconfig files into one
KUBECONFIG=~/.kube/config:~/.kube/eks-config kubectl config view --flatten > ~/.kube/config-merged
```

---

## 2. Local Cluster Provisioning (Kind & Minikube)

### Kind (Kubernetes in Docker)

`kind-config.yaml`
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

# Specify the Kubernetes version by using a specific node image
# Visit https://hub.docker.com/r/kindest/node/tags and https://github.com/kubernetes-sigs/kind/releases for available images
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

Kind Commands:
```bash
# Create cluster with multi-node configuration
kind create cluster --name=basic-mlflow-cluster --config=kind-config.yaml
kind create cluster --name my-second-cluster --config kind-cluster.yaml

# Create simple cluster with default settings
kind create cluster --name=basic-mlflow-cluster

# List active Kind clusters
kind get clusters

# Export kubeconfig from Kind cluster to standard path
kind export kubeconfig --name observability-cluster
kubectl config use-context kind-observability-cluster

# Delete a Kind cluster
kind delete cluster --name my-first-cluster
```

### Minikube

```bash
# Start Minikube with Docker driver and allocated resources
minikube start --vm-driver docker --cpus=4 --memory=8192

# Minikube status and dashboard
minikube status
minikube dashboard

# Stop or delete Minikube cluster
minikube stop
minikube delete
```

---

## 3. Namespaces

```bash
# List all namespaces with their labels
kubectl get namespaces --show-labels

# Create a new namespace
kubectl create namespace staging

# Delete a namespace (warning: deletes all namespaced resources within it)
kubectl delete namespace staging

# Force remove a stuck namespace (clearing finalizers)
kubectl get namespace <terminating-namespace> -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/<terminating-namespace>/finalize -f -
```

---

## 4. Pod Operations & Troubleshooting

```bash
# List pods in current namespace
kubectl get pods

# List pods across all namespaces with wide output (shows Node and Pod IP)
kubectl get pods -A -o wide

# Check container status within a pod using jsonpath
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.containerStatuses[*].state}'
kubectl get pod mlflow-545ff865df-vccp6 -n mlflow -o jsonpath='{.status.containerStatuses[*].state}'

# Check pod tolerations
kubectl get pod monitoring-prometheus-node-exporter-c79mr -n monitoring -o yaml | grep -A10 tolerations

# Describe pod to inspect events, mounts, and lifecycle failures (Essential for CrashLoopBackOff/Pending)
kubectl describe pod <pod-name> -n <namespace>

# View previous terminated container logs (critical for debugging crashed containers)
kubectl logs <pod-name> -c <container-name> --previous -n <namespace>

# Run an ephemeral troubleshooting container in the cluster
kubectl run test-pod --image=busybox -it --rm --restart=Never -- /bin/sh

# Run simulated alert / crash test pod
kubectl run alert-test \
  --image=busybox \
  --restart=Always \
  -- sh -c "echo 'Alert test crashing now'; sleep 5; exit 1"

# Force delete a stuck pod immediately (grace period 0)
kubectl delete pod <pod-name> -n <namespace> --grace-period=0 --force
```

---

## 5. Pod Logs

```bash
# Follow logs of a pod in real time
kubectl logs -f <pod-name> -n <namespace>

# Tail latest 100 lines of logs
kubectl logs --tail=100 -f <pod-name> -n <namespace>

# Check logs of a specific container in a multi-container pod
kubectl logs <pod-name> -c <container-name> -n <namespace>
kubectl logs -n mlflow mlflow-545ff865df-4j4h9 --container mlflow-db-migration

# Follow logs across all pods matching a label selector
kubectl logs -f -l app=my-app -n production --max-log-requests=10

# Show timestamps in logs
kubectl logs --timestamps <pod-name> -n <namespace>
```

---

## 6. Interactive Exec & Debugging

```bash
# Open interactive bash shell inside a container
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash

# Open sh shell if bash is not available
kubectl exec -it <pod-name> -c <container-name> -n <namespace> -- /bin/sh

# Run a non-interactive command inside a pod
kubectl exec <pod-name> -n <namespace> -- env
kubectl exec <pod-name> -n <namespace> -- netstat -tulpn

# Attach an ephemeral debug container to a running pod (Kubernetes 1.23+)
kubectl debug -it <pod-name> -n <namespace> --image=nicolaka/netshoot --target=<container-name>
```

---

## 7. Deployments, Rollouts & Scaling

```bash
# List deployments
kubectl get deployments -A

# Update environment variable in a deployment
kubectl set env deployment/service-b-deployment -n dev OTEL_EXPORTER_JAEGER_ENDPOINT=http://jaeger.tracing:14268/api/traces

# Update container image in a deployment
kubectl set image deployment/my-deployment web=nginx:1.25.3 -n production

# Restart all pods in a deployment with zero downtime (rolling restart)
kubectl rollout restart deployment/service-b-deployment -n dev

# Monitor rollout status
kubectl rollout status deployment/service-b-deployment -n dev

# View rollout revision history
kubectl rollout history deployment/my-deployment -n production

# Roll back to the previous deployment revision
kubectl rollout undo deployment/my-deployment -n production

# Roll back to a specific revision (e.g., revision 2)
kubectl rollout undo deployment/my-deployment -n production --to-revision=2

# Pause and resume rollouts
kubectl rollout pause deployment/my-deployment -n production
kubectl rollout resume deployment/my-deployment -n production

# Scale deployment replicas
kubectl scale deployment/my-deployment --replicas=5 -n production
```

---

## 8. Services, Networking & Ingress

```bash
# List services in current namespace
kubectl get svc

# List services across all namespaces with wide output
kubectl get svc -A -o wide

# Inspect Service Endpoints (checks if pod IPs are correctly registered to the service)
kubectl get endpoints <service-name> -n <namespace>
kubectl get endpointslices -n <namespace>

# Patch service type (e.g. change ClusterIP to NodePort)
kubectl patch svc bookinfo-gateway-istio \
  -n default \
  -p '{"spec":{"type":"NodePort"}}'

# Port-forward a pod port to localhost
kubectl port-forward -n <namespace-name> pod/mlflow-community-6d575f4f6b-28cxb 7006:5000 --address 0.0.0.0

# Port-forward a service directly
kubectl port-forward svc/my-service 8080:80 -n production

# List Ingress resources
kubectl get ingress -A
kubectl describe ingress <ingress-name> -n <namespace>

# Test network and DNS connectivity from inside cluster using curl
curl <service-clusterip>:port
curl 190.xx.xx.xx:9099

# Find public IP address of the machine from which the request is made
curl https://checkip.amazonaws.com

# Check whether machine can establish TCP connection to an RDS PostgreSQL database on port 5432
curl -v telnet://database-1.c5k88omakd8d.ap-south-1.rds.amazonaws.com:5432
```

---

## 9. Nodes & Cluster Administration

```bash
# List cluster nodes with status and roles
kubectl get nodes -o wide

# Check node taints
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Describe node (capacity, allocatable resources, system conditions)
kubectl describe node <node-name>

# Cordon a node (mark as unschedulable to prevent new pods from landing on it)
kubectl cordon <node-name>

# Uncordon a node (mark as schedulable again)
kubectl uncordon <node-name>

# Drain a node safely for maintenance / upgrade (evicts all pods to other nodes)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data --force

# Add a taint to a node
kubectl taint nodes <node-name> dedicated=infra:NoSchedule

# Remove a taint from a node (append minus sign at the end)
kubectl taint nodes <node-name> dedicated=infra:NoSchedule-

# Label and unlabel nodes
kubectl label nodes <node-name> disktype=ssd
kubectl label nodes <node-name> disktype-
```

---

## 10. Resource Metrics & Cluster Health

```bash
# View node resource utilization (CPU & Memory)
kubectl top nodes

# View pod resource utilization across all namespaces sorted by memory/cpu
kubectl top pods -A --sort-by=memory
kubectl top pods -A --sort-by=cpu

# List cluster events sorted by creation timestamp (Essential for cluster incident triage)
kubectl get events -A --sort-by=.metadata.creationTimestamp

# Filter warning events only
kubectl get events -A --field-selector type=Warning --sort-by=.metadata.creationTimestamp
```

---

## 11. ConfigMaps & Secrets

```bash
# Create ConfigMap from literal values
kubectl create configmap app-config --from-literal=ENVIRONMENT=production --from-literal=LOG_LEVEL=info -n production

# Create ConfigMap from a file or folder
kubectl create configmap app-config --from-file=config.yaml -n production

# Create Secret from literal values
kubectl create secret generic db-credentials \
  --from-literal=username=dbadmin \
  --from-literal=password='SuperSecret123!' \
  -n production

# Create TLS Secret from certificate and private key files
kubectl create secret tls my-tls-cert \
  --cert=tls.crt \
  --key=tls.key \
  -n production

# View Secret data decoded from Base64
kubectl get secret db-credentials -n production -o jsonpath='{.data.password}' | base64 -d
echo ""

# Extract all keys and decoded values from a secret
kubectl get secret db-credentials -n production -o json | jq '.data | map_values(@base64d)'
```

---

## 12. Storage: PV, PVC & StorageClass

```bash
# List Persistent Volumes (PVs)
kubectl get pv

# List Persistent Volume Claims (PVCs) across all namespaces
kubectl get pvc -A

# Inspect StorageClasses
kubectl get storageclass

# Check why a PVC is Pending
kubectl describe pvc <pvc-name> -n <namespace>

# Clear finalizers on a PVC stuck in Terminating status
kubectl patch pvc <pvc-name> -n <namespace> -p '{"metadata":{"finalizers":null}}'
```

---

## 13. Apply, Delete & Dry-Run Manifest Generation

```bash
# Apply a configuration file or directory
kubectl apply -f path/file.yml
kubectl apply -f ./manifests/

# Delete resources defined in a YAML file
kubectl delete -f path/file.yml

# Preview changes before applying (server-side diff)
kubectl diff -f path/file.yml

# Generate YAML boilerplate without creating the resource (--dry-run=client)
kubectl create deployment my-app --image=nginx:alpine --replicas=3 --dry-run=client -o yaml > deployment.yaml
kubectl create service clusterip my-app --tcp=80:80 --dry-run=client -o yaml > service.yaml
kubectl create configmap app-cfg --from-file=app.properties --dry-run=client -o yaml > configmap.yaml
```

---

## 14. RBAC, Service Accounts & Security

```bash
# Check if the current user has permission to perform an action
kubectl auth can-i create deployments
kubectl auth can-i delete pods --all-namespaces

# Impersonate a ServiceAccount to verify its effective RBAC permissions
kubectl auth can-i get secrets --as=system:serviceaccount:default:my-sa -n default

# List ServiceAccounts, Roles, and RoleBindings
kubectl get serviceaccounts -n <namespace>
kubectl get roles,rolebindings -n <namespace>
kubectl get clusterroles,clusterrolebindings
```
