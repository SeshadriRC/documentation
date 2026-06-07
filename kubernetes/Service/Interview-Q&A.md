**1.Why do we need a service while pod has its own ip for communication?**

- Pods are ephemeral
- We get stable IP for a service and also it act as LB.

---

**2. How does a Service know which pod to forward the traffic to?**

- Using selectors

```yaml
selector:
  app: backend
```
