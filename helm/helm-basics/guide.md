# Helm Guide – Kubernetes Deploy, Upgrade & Rollback

## Introduction
Helm is a package manager for Kubernetes that helps you define, install, upgrade,
and rollback applications in a simple and reliable way.

Instead of managing multiple Kubernetes YAML files manually, Helm bundles them
into a single package called a **Helm Chart**.

---

## Problems with Traditional Kubernetes Deployments

When deploying applications using `kubectl apply`, teams often face these issues:

- Multiple YAML files (Deployment, Service, ConfigMap, Secret, PVC)
- Correct apply order is required (Namespace → ConfigMap → Deployment)
- Separate YAML files needed for different environments (dev, prod)
- No easy way to track changes
- Rollbacks are manual and error-prone

---

## What is Helm?

Helm is a Kubernetes package manager that:
- Uses **charts** to define applications
- Uses **templates** with placeholders
- Uses **values.yaml** for configuration
- Maintains **release history**
- Supports **easy rollback**

---

## What is a Helm Chart?

A Helm Chart is a collection of files that describe a Kubernetes application.

A typical chart structure:

```
my-chart/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── _helpers.tpl
```

### Chart Components
- **Chart.yaml** – Chart metadata (name, version, description)
- **values.yaml** – Default configuration values
- **templates/** – Kubernetes resource templates

**templates/deployments.yml**

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment                # Release.Name ( it will pickup the name from helm install <releass-name>
spec:
  replicas: {{ .Values.replicas }}                    # it will pick the values from values.yml file
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: {{ .Release.Name }}
          image: {{ .Values.image }}
          ports:
            - containerPort: {{ .Values.port }}
```

**values.yml**
```yml
replicas: 10
image: simplebyte/simplybyte-calculator:2.0
port: 5000

simplybyteService:         # nothing but a alias name for Service
   type: NodePort
   port: 80
   targetPort: 5000
   nodePort: 30081
```
---

## Helm Templates

Helm templates are Kubernetes YAML files with placeholders.
Values are injected from `values.yaml`.

Example snippet:
```
replicas: {{ .Values.replicaCount }}
image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
```

---

## Helm Install

To install an application using Helm:

```bash
helm install my-app ./my-chart

helm upgrade --install myapp ./mychart -n dev
```

Helm will:
- Render templates
- Apply correct resource order
- Create all Kubernetes resources
- Store release history

---

## Helm Upgrade

To apply changes (image, replicas, configmap, etc.):

```
helm upgrade my-app ./my-chart
```

Helm automatically:
- Detects changes
- Applies updates
- Stores a new revision

---

## Helm List

To view all Helm releases:

```
helm list
```

---

## Helm Rollback

If something goes wrong, rollback to a previous version:

```
helm rollback my-app 1
```

This restores the application to the specified revision instantly.

---

## Release History

Helm stores every install and upgrade as a **revision**.
You can view history using:

```
helm history my-app
```

---

## Public Helm Charts

Many tools provide public Helm charts, such as:

- Prometheus
- Grafana
- Alertmanager
- Loki
- Jaeger / Tempo

Using Helm charts, complex systems can be installed with a single command.

---

## Benefits of Helm

- Simplified deployments
- Environment-specific configuration
- Built-in versioning
- Fast rollbacks
- Standardized application packaging

---

## Conclusion

Helm makes Kubernetes application management easier, safer, and more scalable.
It is an essential tool for DevOps engineers working with Kubernetes.


---
# Practicals

```bash
# Below are the commands used
helm install my-app .            # you need to be in the location where templates directory is there
helm ls
helm upgrade my-app .  --values values.yaml
helm history my-app
```

**Install helm app**

<img width="862" height="557" alt="image" src="https://github.com/user-attachments/assets/d39fd0bf-3e71-4092-a478-454c7db88cb9" />


<img width="1297" height="635" alt="image" src="https://github.com/user-attachments/assets/d648b99b-bf52-4df4-89a3-4262b315a209" />


- able to access the application

<img width="1792" height="912" alt="image" src="https://github.com/user-attachments/assets/a2a8a74d-ee32-4066-8f92-8b9cd37abab8" />

**Now upgrade the replica values to 3 from 5**

<img width="1380" height="356" alt="image" src="https://github.com/user-attachments/assets/863bf2c1-5a84-4f0d-a3ba-e1016ce019aa" />

<img width="982" height="532" alt="image" src="https://github.com/user-attachments/assets/fd90b7c8-8fde-4746-a801-11a939d9cd74" />

<img width="1362" height="497" alt="image" src="https://github.com/user-attachments/assets/95abe3bb-321e-432e-97be-387c1a6ce96b" />

**Now use the wrong image, so that it won't work and we can rollback**

<img width="1021" height="603" alt="image" src="https://github.com/user-attachments/assets/88297326-e7d8-4f3f-b4e2-5b4032d22f0a" />

<img width="1208" height="333" alt="image" src="https://github.com/user-attachments/assets/3fdc2229-e363-4497-a3f7-d9c31e514112" />

**Rollback to Revision 1**

<img width="1228" height="517" alt="image" src="https://github.com/user-attachments/assets/1f5bbe32-090a-49ab-a963-b4afb0df35d4" />

