**Problems in Replicaset**

- Downtime
- Difficult to rollback, we will face downtime here as well

---

- We are going for deployment because of rolling update and rollback feature.
- We deploy the applications using deployment only
- Suppose assume calculator is running in version 1.0, developers devoloped some features with version 2.0.
- Now we need to deploy it.

<img width="1133" height="645" alt="image" src="https://github.com/user-attachments/assets/e79a57bb-4320-4d8d-851f-5e36b8ded0af" />

- By using Replicaset we can edit, but it will have downtime. where complete pod will go down and it will recreate again.
- Our goal is to have zero downtime

<img width="1182" height="582" alt="image" src="https://github.com/user-attachments/assets/0e2ec625-6e83-4e66-97f0-f8489a6cbf5c" />

- Now new version 2.0 has bug, so developers decided to move to old version 1.0. Difficult to rollback, we will face downtime here as well

<img width="1213" height="618" alt="image" src="https://github.com/user-attachments/assets/4043370d-53a6-469f-8729-d768519d1676" />

- Deployment will solve the problem by using rolling update strategy, it will update the pod with latest version one by one.
- And for rollback its easy, because A Deployment maintains a history of changes that occur at the Pod level.

<img width="985" height="361" alt="image" src="https://github.com/user-attachments/assets/5ee70e43-5bb3-42a5-ac2d-b86d9b247615" />

- Using the below command we can do rollback

```bash
kubectl rollout undo  deployment <deployment-name>
```

- How its achieving this ? because it won't delete the old replicaset. it will be marked as 0, so once we rollback then it will increase the pod in old replicaset and the current replicaset will be deleted.

<img width="1082" height="630" alt="image" src="https://github.com/user-attachments/assets/0eb4c787-3d9e-4a7f-8692-1fc78d098a82" />
<img width="1065" height="602" alt="image" src="https://github.com/user-attachments/assets/0c57acd0-e82a-403d-8ec8-d49bb42138fd" />

---
# Chatgpt Summary

# Deployment

## Problems with ReplicaSet

* ReplicaSet ensures the desired number of pod replicas are running.
* However, it does not provide advanced deployment features such as:

  * Rolling Updates
  * Rollbacks

### Downtime During Updates

* Suppose the calculator application is running with version **1.0**.
* Developers release a new version **2.0** with additional features.
* If we directly update the ReplicaSet, old pods may be terminated before new pods become available.
* This can lead to application downtime.
* Our goal in production environments is to achieve **zero or minimal downtime**.

### Difficult Rollback

* Assume version **2.0** contains a bug.
* Developers decide to move back to version **1.0**.
* ReplicaSet does not maintain deployment history.
* Rolling back to a previous version becomes a manual process and may result in downtime.

---

## Why Deployment?

* Deployment is the most commonly used Kubernetes resource for deploying applications.
* Deployment sits on top of ReplicaSet and provides:

  * Rolling Updates
  * Rollbacks
  * Deployment History
  * Controlled Application Releases

```text
Deployment
    ↓
ReplicaSet
    ↓
Pods
```

---

## Rolling Update

* Deployment uses the **RollingUpdate** strategy by default.
* Instead of updating all pods at once, it updates them gradually.

### Example

Current State:

```text
Pod-1 (v1.0)
Pod-2 (v1.0)
Pod-3 (v1.0)
```

Deployment starts upgrading:

```text
Pod-1 (v2.0)
Pod-2 (v1.0)
Pod-3 (v1.0)
```

Then:

```text
Pod-1 (v2.0)
Pod-2 (v2.0)
Pod-3 (v1.0)
```

Finally:

```text
Pod-1 (v2.0)
Pod-2 (v2.0)
Pod-3 (v2.0)
```

* Since pods are updated one by one, the application remains available during the upgrade.
* This helps achieve **zero downtime deployments**.

---

## Rollback

* Suppose version **2.0** has a bug.
* Deployment allows us to quickly revert to the previous version.

### Rollback Command

```bash
kubectl rollout undo deployment/calculator-app-deployment
```

---

## How Rollback Works Internally

Deployment creates and manages ReplicaSets.

Example:

```text
Deployment
   |
   +-- ReplicaSet-v1 (3 Pods)
```

After upgrading:

```text
Deployment
   |
   +-- ReplicaSet-v1 (0 Pods)
   |
   +-- ReplicaSet-v2 (3 Pods)
```

Notice:

* The old ReplicaSet is **not deleted immediately**.
* Deployment keeps it for revision history.

When rollback is performed:

```text
Deployment
   |
   +-- ReplicaSet-v1 (3 Pods)
   |
   +-- ReplicaSet-v2 (0 Pods)
```

* Kubernetes scales up the old ReplicaSet.
* Kubernetes scales down the current ReplicaSet.
* This makes rollback fast and reliable.

### Interview Answer

> Deployment is preferred over ReplicaSet because it provides rolling updates, rollbacks, and deployment history. During an upgrade, Deployment creates a new ReplicaSet and gradually replaces old pods with new ones, reducing downtime. If the new version has issues, Deployment can quickly roll back by scaling up the previous ReplicaSet and scaling down the current one.


---
