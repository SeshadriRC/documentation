**1. What is the use of Replicaset?**

A ReplicaSet ensures a specified number of identical pod replicas are running at all times.

---

**2. What happens if you manually delete a pod managed by a ReplicaSet?**

Ans: The ReplicaSet automatically creates a new pod to maintain the desired count.

---
**3. How will you increase or decrease the replica count of a ReplicaSet?**

**Declarative**
- Update the manifest file and apply the changes

**Imperative**

- Run this command
```bash
kubectl scale replicaset my-replicaset -- replicas=5
```

---
