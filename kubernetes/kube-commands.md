## Apply

```bash
kubectl apply -f path/file.yml
```

## Curl

```bash
curl <service-clusterip>:port
curl 190.xx.xx.xx:9099

# find the public IP address of the machine from which the request is made.
curl https://checkip.amazonaws.com

# check whether your machine can establish a TCP connection to an RDS PostgreSQL database on port 5432
curl -v telnet://database-1.c5k88omakd8d.ap-south-1.rds.amazonaws.com:5432

```

## Cluster

```bash
kind create cluster --name=basic-mlflow-cluster

kubectl cluster-info --context kind-demo-cluster
kubectl cluster-info
```

## Delete

```bash
kubectl delete -f path/file.yml
```

## Logs

```bash
# To check specific container logs
kubectl logs -n <namespace> <pod-name> --container <container-name>
kubectl logs -n mlflow mlflow-545ff865df-4j4h9 --container mlflow-db-migration
```

## Namespace

```bash
kubectl get namespaces --show-labels
```

## Patch

```bash
 kubectl patch svc bookinfo-gateway-istio \
  -n default \
  -p '{"spec":{"type":"NodePort"}}'
```

## Port-forward

```bash
kubectl port-forward -n <namespace-name> pod/mlflow-community-6d575f4f6b-28cxb 7006:5000 --address 0.0.0.0
```

## Pods

```bash
# To check all container status
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.containerStatuses[*].state}'
kubectl get pod mlflow-545ff865df-vccp6 -n mlflow -o jsonpath='{.status.containerStatuses[*].state}'
```
## Service

```bash
kubectl get svc
```
