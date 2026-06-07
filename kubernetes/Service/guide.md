<img width="1012" height="423" alt="image" src="https://github.com/user-attachments/assets/58a7424e-c039-40c7-b90f-6cb0bc49fa00" />

- Assume angular pod communicating with java pod using IP adress.
- But suddenly java pod went crashing due to some issues, so as usual kubernetes will restart the java pod, but this time IP changes and communication is broken.
- Pods are ephemeral in nature.
- So to address this issue, service is introduced

<img width="1115" height="391" alt="image" src="https://github.com/user-attachments/assets/245bc984-b2da-47f3-9d42-ea2f79b49bf3" />

- This service will have a stable ip, it won't change
- Also service also used to do loadbalance

<img width="1211" height="567" alt="image" src="https://github.com/user-attachments/assets/b7e22570-3332-47dc-84a7-a70459d1814b" />

- By using the selector, service will forward the traffic to the correct pod

<img width="1085" height="620" alt="image" src="https://github.com/user-attachments/assets/8a484529-b1e6-46c4-b4f6-55d7860e246d" />

- how does service knows the ip of the pod ?

<img width="1113" height="607" alt="image" src="https://github.com/user-attachments/assets/7f0d6557-3a12-4dab-9a38-90a9a8e4c135" />

- while creating the service, another component is get created that is called endpoint

<img width="1103" height="637" alt="image" src="https://github.com/user-attachments/assets/5d5f38d3-e189-4086-b347-05cf5dc08498" />

<img width="1147" height="487" alt="image" src="https://github.com/user-attachments/assets/328754d0-644b-4a57-9ffa-787a2b3d9aa9" />

- kube-proxy will maintain both the service and endpoint. kube-proxy will run on all the nodes

<img width="1147" height="487" alt="image" src="https://github.com/user-attachments/assets/15d9eab6-0d78-4e99-893d-e1c965d1f31c" />

<img width="1090" height="612" alt="image" src="https://github.com/user-attachments/assets/ac487368-c02c-4614-bfb1-c9828aa0655a" />

<img width="1012" height="320" alt="image" src="https://github.com/user-attachments/assets/12ba3e5a-fbd9-4373-962f-c2d215967873" />

- kube-proxy will look the ip-tables and forwards the client request to one of the pod

<img width="1112" height="628" alt="image" src="https://github.com/user-attachments/assets/ec6e6b42-acbf-497f-9b3b-3378121d98c4" />

- how the endpoint knows the latest ip's of pod ? its because of endpoint controller which is present in the master node

<img width="1147" height="652" alt="image" src="https://github.com/user-attachments/assets/2ccdf467-d060-46f6-a302-4118e904a26a" />

---
## Chatgpt summary

Your understanding is good. Here is a more polished and technically accurate version for interviews.

# Kubernetes Service

### Why do we need a Service?

* Suppose an Angular application is communicating with a Java application using the Java Pod's IP address.

```text
Angular Pod
     ↓
10.244.1.10
     ↓
Java Pod
```

* If the Java Pod crashes, Kubernetes creates a new Pod.

```text
Old Pod IP : 10.244.1.10
New Pod IP : 10.244.1.25
```

* Since Pods are **ephemeral**, their IP addresses can change when they are recreated.
* The Angular application is still trying to communicate with the old IP, so communication breaks.

To solve this problem, Kubernetes provides **Services**.


## What is a Service?

* A Service provides a **stable IP address and DNS name** for a group of Pods.
* Applications communicate with the Service instead of directly communicating with Pod IPs.
* Even if Pods are recreated, the Service IP remains unchanged.

```text
Angular Pod
      ↓
Service
      ↓
Java Pods
```


## Load Balancing

A Service can distribute traffic across multiple Pods.

```text
                Service
                   ↓
        ┌──────────┼──────────┐
        ↓          ↓          ↓
      Pod1       Pod2       Pod3
```

The Service load-balances requests among the available Pods.


## How does a Service find Pods?

A Service uses a **selector**.

Example:

```yaml id="wgpudq"
selector:
  app: java
```

The Service automatically forwards traffic to Pods that have:

```yaml id="8of5kh"
labels:
  app: java
```


## What are Endpoints?

When a Service is created, Kubernetes automatically creates an **Endpoint** (or EndpointSlice in newer versions).

Example:

```text
Service: java-service

Endpoints:
10.244.1.10
10.244.1.11
10.244.1.12
```

The Endpoint stores the current Pod IP addresses behind the Service.


## Who updates the Endpoints?

The **Endpoint Controller** running in the Control Plane continuously watches:

```text
Services
Pods
```

If a Pod is:

```text
Created
Deleted
Recreated
```

the Endpoint Controller updates the Endpoint object with the latest Pod IPs.


## What is kube-proxy?

* kube-proxy runs on every worker node.
* It watches Services and Endpoints.
* It programs networking rules (iptables, IPVS, or nftables depending on the environment).
* These rules forward traffic from the Service IP to one of the backend Pods.

Flow:

```text
Client
   ↓
Service IP
   ↓
kube-proxy
   ↓
Endpoint
   ↓
Selected Pod
```

---

## Complete Flow

```text
Angular Pod
      ↓
Service IP
      ↓
kube-proxy
      ↓
Endpoint
      ↓
Java Pod
```

If a Java Pod crashes:

```text
Java Pod Crashes
       ↓
New Java Pod Created
       ↓
New Pod Gets New IP
       ↓
Endpoint Controller Updates Endpoints
       ↓
Service Continues Working
```

No changes are required in the Angular application.


## Interview Answer

> A Kubernetes Service provides a stable IP address and DNS name for a group of Pods. Since Pods are ephemeral and their IP addresses can change when they are recreated, applications should communicate through a Service instead of directly using Pod IPs. Services use label selectors to identify Pods, while the Endpoint Controller maintains the list of Pod IPs. kube-proxy uses these endpoints to route and load-balance traffic to the appropriate Pods.


---
