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

- Assume if database is having multiple pod replicas. ( DB-1 and DB-2 ), mysql is installed on both the pods
- Now user doing same process, as he is creating user. This time details is stored in one of the (DB-1).
- Again user trying to access the facebook login page with creds. But this time service routed the traffic to second pod (DB-2). But there creds are not there. so to address this issue we are using Headless service type.
- So whenever we are sending request, it should go to only one pod. In that scenario we will use headless type service

<img width="1176" height="647" alt="image" src="https://github.com/user-attachments/assets/d72bdced-8407-4390-8b0b-a4f3ba8bbb0e" />

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-headless-service

spec: 
  clusterIP: None   # ClusterIP as none, so headless will get created.
  selector:
    app: my-app

  ports:
    - port: 80
      targetPort: 8080
```

## External Service

- we saw the scenarios where we are accessing the cluster from outside.
- here we will see how to access the resource outside from the inside.

<img width="1106" height="582" alt="image" src="https://github.com/user-attachments/assets/15312b0b-bc10-4b74-b181-b0e75fa01d72" />

- suppose we need to use weather api where it has details of weather. But it is present outiside the cluster, in that scenario we will use external name service.

<img width="1072" height="546" alt="image" src="https://github.com/user-attachments/assets/a3974da5-6f0c-48c0-a3df-b624f8aaf001" />

```yml
apiVersion: v1
kind: Service
metadata:
  name: my-external-service

spec:
  type: ExternalName
  externalName: api.weather.com

  ports:
    - port: 80
```
---

# Chatgpt summarize

Your notes are mostly good. The main correction is the **Headless Service section**. A Headless Service is **not used to ensure all requests go to one pod**. It is used to expose individual pod IPs/DNS names, commonly for StatefulSets (MySQL, PostgreSQL, Kafka, etc.).

Here's a cleaned-up and corrected version:

# Kubernetes Services

## ClusterIP Service

* It can be accessed only from within the cluster.
* For example, assume there is an application consisting of Angular, Java, and Database components.
* Users should only access the Angular frontend.
* The frontend should communicate with the Java backend, and the backend should communicate with the database.
* The Java backend and Database should not be directly accessible from outside the cluster.
* In such cases, we create **ClusterIP Services** for the backend and database pods.

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

### Ports Explanation

* `port` → Service port.
* `targetPort` → Application port inside the pod.

Example:

```text
Client --> Service:80 --> Pod:8080
```

---

## NodePort Service

* NodePort exposes the application outside the cluster.
* External users can access the application using:

```text
<Node-IP>:<NodePort>
```

* It opens a specific port on all worker nodes.
* Typically used for testing, demos, or learning environments.
* Not commonly used in production.
* NodePort range:

```text
30000 - 32767
```

### Three Ports Involved

1. Service Port (`port`)
2. Target Port (`targetPort`)
3. Node Port (`nodePort`)

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

### Traffic Flow

```text
User
  |
NodeIP:30007
  |
Service:80
  |
Pod:8080
```

---

## LoadBalancer Service

* Used to expose applications externally in cloud environments.
* Accessible both internally and externally.
* When created in cloud providers such as AWS, Azure, or GCP, a cloud load balancer is automatically provisioned.
* Commonly used in production environments.

### Traffic Flow

```text
User
  |
Load Balancer
  |
Service
  |
Pods
```

---

## Headless Service

### Why Headless Service?

Normally, a Service provides load balancing.

```text
Client
  |
Service
  |
Pod-1 / Pod-2 / Pod-3
```

The Service decides which pod receives the request.

Sometimes applications need to communicate with a specific pod rather than using load balancing.

Examples:

* MySQL Replication
* PostgreSQL Replication
* Kafka
* Cassandra
* StatefulSets

In these cases, each pod must have its own identity and DNS name.

### Example

Assume we have:

```text
mysql-0
mysql-1
mysql-2
```

A Headless Service provides DNS entries such as:

```text
mysql-0.mysql-headless
mysql-1.mysql-headless
mysql-2.mysql-headless
```

Applications can directly connect to a specific database pod.

### Important Note

A Headless Service:

* Does **not perform load balancing**.
* Does **not guarantee all requests go to one pod**.
* Returns the IP addresses of all matching pods.
* The client application decides which pod to connect to.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-headless-service

spec:
  clusterIP: None

  selector:
    app: my-app

  ports:
    - port: 80
      targetPort: 8080
```

---

## ExternalName Service

* So far, we have seen how external users access resources inside the cluster.
* ExternalName Service is used when applications inside the cluster need to access services outside the cluster.

### Example

Suppose your application needs to call an external weather API:

```text
api.weather.com
```

Instead of hardcoding the external hostname in the application, Kubernetes can create a Service that maps to it.

The application can then access:

```text
my-external-service
```

and Kubernetes resolves it to:

```text
api.weather.com
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-external-service

spec:
  type: ExternalName
  externalName: api.weather.com

  ports:
    - port: 80
```

### Traffic Flow

```text
Pod
  |
ExternalName Service
  |
api.weather.com
```

### Interview Summary

| Service Type | Access                                                 |
| ------------ | ------------------------------------------------------ |
| ClusterIP    | Internal only                                          |
| NodePort     | Internal + External using NodeIP:NodePort              |
| LoadBalancer | Internal + External through Cloud Load Balancer        |
| Headless     | No load balancing, exposes individual pod DNS/IPs      |
| ExternalName | Maps a Kubernetes Service name to an external DNS name |

---
