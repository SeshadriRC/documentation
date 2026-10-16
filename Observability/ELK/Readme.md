```bash
minikube start --vm-driver docker --cpus=4 --memory=8192
kubectl get secret elasticsearch-master-credentials -o jsonpath="{.data.password}" | base64 --decode ; echo
```

## Practicals

1. [Grafana-Slack-Integration](https://github.com/SeshadriRC/documentation/blob/main/Observability/ELK/Practicals/grafana-slack-integration.md)
2. [Grafana-Slack-Alert](https://github.com/SeshadriRC/documentation/blob/main/Observability/ELK/Practicals/grafana-slack-alert.md)
3. [ELK-setup-and-Sending slack alerts](https://github.com/SeshadriRC/documentation/blob/main/Observability/ELK/Practicals/minikube-slack-ELK-steps.md)
4. [Sending ELK - email alerts](https://github.com/SeshadriRC/documentation/blob/main/Observability/ELK/Practicals/Email-alert.md)

---

## 1. [Observability-Repo](https://github.com/SeshadriRC/observability-zero-to-hero/tree/main)

  - About prometheus/grafana stack installation,  Also EKS cluster provisioning - Day 2
  - About prometheus/grafana explanation - Day 3
  - Instrumentation - Day 4
  - EFK Setup - Day 5 ( EC2 kind cluster )

## 2. Using kubernetes minikube.


```
https://www.youtube.com/watch?v=vOvbEmKAPHA&list=PLACmqyggUd8M&index=1&t=584s
https://www.fosstechnix.com/kubernetes-logging-using-elk-stack-and-filebeat/

t3.xtralarge - 30GB disk size
```

## 3. Using docker compose

```
https://www.youtube.com/watch?v=25LjNCzjVzk&list=PLACmqyggUd8M&index=7
https://www.fosstechnix.com/send-alerts-to-slack-using-elastic-stack/
```

## 4. Opentelemetry Docs and Repo

```
https://opentelemetry.io/docs/demo/kubernetes-deployment/
https://github.com/open-telemetry/opentelemetry-demo
```
