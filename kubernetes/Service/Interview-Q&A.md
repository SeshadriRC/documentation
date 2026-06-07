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

---

**3. What is the role of kube-proxy in Kubernetes networking**

- kube-proxy will run on every node
- It manages the iptables on every nodes
- When a request comes to a Service IP, kube-proxy forwards it to one of the backing Pod IPs, doing load balancing.

---

**4. What is an Endpoint in Kubernetes, and how is it managed?**

- An Endpoint is a Kubernetes object that maps a Service to its actual Pod IPs.
- It's automatically updated by the Endpoint Controller.

---
**5. What happens when a Pod behind a Service is deleted and recreated? How does the traffic still reach it?**

- Once the existing pod is deleted and the new one got created the new IP will be updated in the Endpoints with a help of Endpoint controller (Managed by Controller Manager), so when Service receives a new request Kube-proxy will check the endpoints and route the traffic accordingly..
- endpoint controller will use the pods selectors lables constantly to check if there any new ip created ,if it found then 
Once the existing pod is deleted and the new one got created the
---
