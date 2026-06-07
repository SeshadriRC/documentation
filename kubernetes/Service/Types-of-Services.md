## Cluster IP service

- It can be accessed only internally within the cluster
- For example assume there is a application ( angular, java, database). User should able to access only the frontend. Backend(java) and Database they should not access.
- Frontend shud talk to Backend and then Backend should talk to Database then vice versa.

<img width="1137" height="590" alt="image" src="https://github.com/user-attachments/assets/bbaa9387-9f7b-4037-b213-da3c418461df" />

- so we can create clusterIP service type to backend and database pod.

 ```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
```
