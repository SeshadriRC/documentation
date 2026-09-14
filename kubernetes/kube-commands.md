## Apply

```bash
kubectl apply -f path/file.yml
```

## Curl

```bash
curl <service-clusterip>:port
curl 190.xx.xx.xx:9099

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
## Service

```bash
kubectl get svc
```
