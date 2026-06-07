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
