- all container will be running inside the container
- pod will provide the required network, storage to container, so that container can run

<img width="767" height="532" alt="image" src="https://github.com/user-attachments/assets/a969bd1e-316d-4916-b722-d63108a6cd47" />

- if container in the pod A needs to talk to container in the Pod B. then container in Pod A should know the ip of Pod B. So all pods are isolated in nature.

<img width="1067" height="510" alt="image" src="https://github.com/user-attachments/assets/2f640735-367f-4f65-9f64-531fffcfbf00" />

- Pods can have multiple containers
- Containers in the pod will share network, storage. So containers inside a pod can communicate with a pod without IP address
- in most of the scenarios only one contianer will be created inside the pod, because assume if out of 2 containers one container is crashed, then kubernetes will remove the whole pod and create a new one. so the container ran properly also got terminated.
- however for some tightly coupled applications, we can create two containers. Eg: one app will work only if another works


---
## Chatgpt summarize


Your understanding is mostly correct. Here is a refined version with a few important corrections.

# Pod

* A **Pod** is the smallest deployable unit in Kubernetes.
* One or more containers run inside a Pod.
* A Pod provides the required **network** and **storage** environment for containers.
* Every Pod gets its own IP address.
* Pods are isolated from each other and communicate over the network using Pod IPs, Services, or DNS names.

---

## Communication Between Pods

Suppose:

```text
Pod A
  └── Container A

Pod B
  └── Container B
```

If Container A wants to communicate with Container B:

```text
Container A
      ↓
Pod B IP / Service
      ↓
Container B
```

Container A cannot directly access Container B without using the Pod IP, Service, or DNS name.

---

## Multiple Containers in a Pod

A Pod can contain multiple containers.

Example:

```text
Pod
├── Application Container
└── Sidecar Container
```

All containers within the same Pod share:

* Network namespace
* Pod IP address
* Storage volumes

Because they share the same network:

```text
Container A
     ↓
localhost
     ↓
Container B
```

Containers inside the same Pod can communicate using:

```text
localhost
127.0.0.1
```

No Pod IP is required.

---

## Why Usually One Container Per Pod?

In most real-world scenarios:

```text
1 Pod = 1 Container
```

because each application is managed independently.

Example:

```text
Pod
 └── Java Application
```

This makes scaling, monitoring, and troubleshooting easier.

---

## What Happens if One Container Crashes?

Your statement needs a small correction.

You wrote:

> if out of 2 containers one container is crashed, then kubernetes will remove the whole pod and create a new one

This is not always true.

Normally:

```text
Pod
├── Container A
└── Container B
```

If Container A crashes:

```text
Container A -> Restarted
Container B -> Continues Running
```

The kubelet typically restarts only the failed container according to the Pod's restart policy.

The entire Pod is recreated only in certain scenarios, such as when a Deployment replaces the Pod or the Pod itself becomes unavailable.

---

## When Do We Use Multiple Containers?

When containers are tightly coupled.

Example:

```text
Pod
├── Java Application
└── Log Forwarder (Fluent Bit)
```

or

```text
Pod
├── Application Container
└── Sidecar Proxy (Service Mesh)
```

The sidecar supports the main application and both are expected to run together.

---

## Your Pod Manifest (Formatted)

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: my-simplybyte-calculator-pod-2
  labels:
    project: calculator

spec:
  containers:
  - name: simply-byte-calculator
    image: simplebyte/simplybyte-calculator
    ports:
    - containerPort: 5000
```

### Explanation

* `apiVersion: v1` → Core Kubernetes API version.
* `kind: Pod` → Creates a Pod.
* `metadata` → Pod name and labels.
* `spec` → Desired state of the Pod.
* `containers` → List of containers inside the Pod.
* `image` → Container image to run.
* `containerPort: 5000` → Application listens on port 5000 inside the container.

### Interview Answer

> A Pod is the smallest deployable unit in Kubernetes and can contain one or more containers. Containers within the same Pod share the same network namespace and storage volumes, allowing them to communicate using localhost. Although a Pod can have multiple containers, most applications use one container per Pod, while multi-container Pods are typically used for tightly coupled sidecar patterns.

---
