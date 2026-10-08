```bash
minikube start --vm-driver docker --cpus=4 --memory=8192
kubectl get secret elasticsearch-master-credentials -o jsonpath="{.data.password}" | base64 --decode ; echo
```

## 1. Using kubernetes minikube.

[Sending slack alerts](https://github.com/SeshadriRC/documentation/blob/main/Observability/ELK/Practicals/minikube-slack-ELK-steps.md)

```
https://www.youtube.com/watch?v=vOvbEmKAPHA&list=PLACmqyggUd8M&index=1&t=584s
https://www.fosstechnix.com/kubernetes-logging-using-elk-stack-and-filebeat/

t3.xtralarge - 30GB disk size
```

## 2. Using docker compose

```
https://www.youtube.com/watch?v=25LjNCzjVzk&list=PLACmqyggUd8M&index=7
https://www.fosstechnix.com/send-alerts-to-slack-using-elastic-stack/
```
