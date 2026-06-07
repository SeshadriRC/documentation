<img width="1090" height="615" alt="image" src="https://github.com/user-attachments/assets/d5e6c4b2-cfac-480d-ad6b-4ade6f85e98c" />

- It contains master node and worker node.
- The applications that we are deploying it will get deployed in the worker node only.

**API Server**

- Every communication is done through the API server. It is a heart of the kubernetes

**Controller Manager**

<img width="1060" height="602" alt="image" src="https://github.com/user-attachments/assets/6cbde509-53ec-409c-8749-ed35d0af192a" />

- It will maintain the state of the containers.
- how this is checking ---> By use of desired state and actual state
- If in case 2 is desired but 1 is missing, then it will inform to API server that 1 container is missing
- How the controller manager kknow the desired count ? --> by use of ETCD

**ETCD**

<img width="1060" height="631" alt="image" src="https://github.com/user-attachments/assets/84df3ff0-d979-4d1c-8906-17ea94172633" />


- It is a database, stores all the information
- It is a brain of the kubernetes

**Scheduler**

<img width="1098" height="666" alt="image" src="https://github.com/user-attachments/assets/726c5534-1050-40d1-8073-d79dddc3901e" />


- Decides in which node the pod should be created
- It will check all the node resource usage details and schedule the pod in the correct node
- But who will create the pod/container ? -> Kubelet


**Kubelet**

- API server will inform the details about container to kubelet --> then kubelet will inform those to CRI
- CRI will be responsible to pull the image and create the container
- if incase any container is crashed, then kubelet will tell to CRI to remove the container and kublet will inform this to API server, then API server will ask the controller
- manager to check the state , so controller will checke desired vs actual. then it will inform to api server that 1 container is missing
- now api will go to scheduler -> then schheduler will look thhe node freee status and decides in this node we can create that container
- then api server will give the details about container image to the kubelet to create a container in node which selected by scheduler, then this kubelet will go to cri and ask to create a container

---

# Chatgpt summarize

Your explanation is mostly correct. Here is a cleaner and more interview-ready version with a few corrections.

# Kubernetes Architecture

## Overview

* A Kubernetes cluster consists of **Control Plane (Master Node)** and **Worker Nodes**.
* Applications are deployed as Pods on the **Worker Nodes**.
* The Control Plane manages and monitors the cluster.

---

## API Server

* The **API Server** is the entry point to Kubernetes.
* All components communicate with each other through the API Server.
* It receives requests from users, `kubectl`, controllers, and other cluster components.

**Interview Line:**

> API Server is the heart of Kubernetes because every communication within the cluster goes through it.

---

## ETCD

* ETCD is a distributed key-value database.
* It stores all cluster information such as:

  * Pods
  * Deployments
  * Services
  * ConfigMaps
  * Secrets
  * Node information
* Whenever a resource is created or modified, the information is stored in ETCD.

**Interview Line:**

> ETCD is the brain of Kubernetes because it stores the entire cluster state.

---

## Controller Manager

* Controller Manager continuously compares:

  * **Desired State** (stored in ETCD)
  * **Actual State** (current cluster status)
* If there is a mismatch, it takes corrective action.

Example:

```text
Desired Replicas = 2
Actual Replicas  = 1
```

Controller Manager detects:

```text
1 Pod is missing
```

and requests Kubernetes to create another Pod.

**Interview Line:**

> Controller Manager maintains the desired state of the cluster by continuously comparing the desired state with the actual state.

---

## Scheduler

* Scheduler decides **which worker node** should run a Pod.
* It checks:

  * Available CPU
  * Available Memory
  * Taints and Tolerations
  * Affinity and Anti-Affinity
  * Resource requests
  * Other scheduling constraints

**Important:**

* Scheduler **does not create Pods**.
* Scheduler only selects the most suitable node.

**Interview Line:**

> Scheduler decides where a Pod should run, but it does not create the Pod.

---

## Kubelet

* Kubelet runs on every worker node.
* It communicates with the API Server.
* It ensures that containers are running as specified.

Workflow:

```text
API Server
      ↓
Kubelet
      ↓
Container Runtime (CRI)
      ↓
Container Created
```

The kubelet:

* Receives Pod specifications from the API Server.
* Instructs the container runtime to pull images and create containers.
* Monitors container health.
* Reports Pod status back to the API Server.

---

## Container Runtime (CRI)

Examples:

* containerd
* CRI-O

Responsibilities:

* Pull container images.
* Create containers.
* Start containers.
* Stop containers.
* Remove containers.

**Interview Line:**

> The container runtime is responsible for the actual container lifecycle operations.

---

# What Happens When a Container Crashes?

Suppose:

```text
Deployment replicas = 2
```

Current status:

```text
Pod1 Running
Pod2 Crashed
```

### Step 1

Kubelet detects that the container has stopped.

### Step 2

Kubelet reports the status to the API Server.

### Step 3

Controller Manager compares:

```text
Desired State = 2 Pods
Actual State  = 1 Pod
```

and identifies that one Pod is missing.

### Step 4

Controller Manager asks the API Server to create a replacement Pod.

### Step 5

Scheduler selects the most suitable worker node.

### Step 6

API Server sends the Pod specification to the Kubelet on the selected node.

### Step 7

Kubelet instructs the container runtime:

```text
Pull Image
Create Container
Start Container
```

### Step 8

New Pod becomes Running.

---

# Simple Interview Summary

```text
User
 ↓
API Server
 ↓
ETCD stores desired state
 ↓
Controller Manager checks desired vs actual state
 ↓
Scheduler selects the best node
 ↓
Kubelet receives instructions
 ↓
Container Runtime pulls image and creates container
 ↓
Pod Running
```

One correction to your notes:

> "If a container crashes, kubelet will remove the container"

Not always. Usually the **container runtime** handles the container termination, and the **kubelet detects and reports the state**. The important point is that the **Controller Manager** notices the desired vs actual mismatch and ensures a replacement Pod is created if required by the workload definition.

---
