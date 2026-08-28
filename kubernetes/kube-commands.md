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

## Service

```bash
kubectl get svc
```
