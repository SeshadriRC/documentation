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

- in pod yaml we will mention service port(eg: port:80) to reach the service and target port ( eg- target port:8080) to reach the application
<img width="1092" height="501" alt="image" src="https://github.com/user-attachments/assets/392410cb-a6c5-4824-a6b1-b1b4f8eba5aa" />

## NodePort service

- Here we will use 3 ports
- whoever outside the cluster can access the application using node ip and nodeport number
- it will open a specific port (eg: 30007) on all the nodes.
- NodePort type is not used in the production environments, it will be used only for testing purposes.
- Range of NodePort is 30000-32767

<img width="1117" height="612" alt="image" src="https://github.com/user-attachments/assets/064b7e2d-4564-43ac-9662-c719d05c7d20" />

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service

spec:
  type: NodePort
  selector:
    app: my-app

  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30007
```

<img width="1175" height="502" alt="image" src="https://github.com/user-attachments/assets/fc7d2062-0fd3-4aa9-b2da-8233fb13e134" />

## LoadBalancer Service

- This service is used for both internal communication and outside user also can able to access it using LB endpoint.
- If we create this service, then automatically LB will get created in the AWS cloudprovider.
- it will be used in the production environments.
<img width="1116" height="497" alt="image" src="https://github.com/user-attachments/assets/4d200df8-9d73-4cdc-8017-ce15e87c27ba" />

## HeadLess Service

<img width="1130" height="627" alt="image" src="https://github.com/user-attachments/assets/3263b81f-6279-4854-94ff-2bafc2ac60d6" />

- User logged in facebook and cretaed new user using frontend
- now backend will process this and it will store the details in the database.
- Now if user logged in again, then it will go to backend and then database, then user able to access succesfully.

<img width="1176" height="607" alt="image" src="https://github.com/user-attachments/assets/5bbe9fe6-e7b7-400c-a436-424e23648ed5" />

- This is the name of Client server architecture.
- Request --> each time frontend talking to backend
- Response --> backend will check the database and provide response to frontend
- API --> combination of both request and response


<img width="1145" height="647" alt="image" src="https://github.com/user-attachments/assets/90b846b0-b896-4d5b-b0ab-e4b4f138702c" />

- Assume if database is having multiple replicas. ( DB-1 and DB-2 )
- Now user doing same process, as he is creating user. This time details is stored in one of the (DB-1).
