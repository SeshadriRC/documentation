A very common interview scenario is:

> "Create a user who can only view pods in a namespace."

Let's do it step by step.

---

# Step 1: Create a Role

This Role allows a user to:

* get pods
* list pods
* watch pods

in a namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role

metadata:
  name: pod-reader
  namespace: default

rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs:
      - get
      - list
      - watch
```

---

# Step 2: Create a User

Kubernetes doesn't have a direct command like:

```bash
kubectl create user sesha
```

Usually users come from:

* Certificates
* LDAP
* Active Directory
* OIDC
* IAM (EKS)

For learning, assume a user named:

```text
sesha
```

already exists.

---

# Step 3: Create a RoleBinding

Bind the Role to the user.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding

metadata:
  name: pod-reader-binding
  namespace: default

subjects:
  - kind: User
    name: sesha
    apiGroup: rbac.authorization.k8s.io

roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

---

# Result

User:

```text
sesha
```

can execute:

```bash
kubectl get pods
```

```bash
kubectl describe pod nginx
```

But cannot:

```bash
kubectl delete pod nginx
```

Error:

```text
Forbidden
User "sesha" cannot delete resource "pods"
```

---

# Another Example: Developer User

Allow full access to Deployments.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role

metadata:
  name: deployment-admin
  namespace: default

rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete
```

RoleBinding:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding

metadata:
  name: deployment-admin-binding
  namespace: default

subjects:
  - kind: User
    name: developer
    apiGroup: rbac.authorization.k8s.io

roleRef:
  kind: Role
  name: deployment-admin
  apiGroup: rbac.authorization.k8s.io
```

---

# Namespace Scope

Role + RoleBinding works only in one namespace.

```text
default
```

User can:

```bash
kubectl get pods -n default
```

But cannot:

```bash
kubectl get pods -n prod
```

---

# Cluster-Wide Access

For all namespaces:

```text
ClusterRole
+
ClusterRoleBinding
```

Example:

```yaml
kind: ClusterRole
```

```yaml
kind: ClusterRoleBinding
```

---

# Easy Way to Verify Permissions

Check whether a user can perform an action:

```bash
kubectl auth can-i get pods --as=sesha
```

Output:

```text
yes
```

Check delete permission:

```bash
kubectl auth can-i delete pods --as=sesha
```

Output:

```text
no
```

---

### Interview Answer

> A Role defines permissions within a namespace, such as the ability to get, list, or create resources. A RoleBinding assigns that Role to a user, group, or service account. For example, a `pod-reader` Role can allow a user named `sesha` to view pods in the `default` namespace, while a RoleBinding connects that Role to the user. For cluster-wide permissions, we use ClusterRole and ClusterRoleBinding.


---

# Scenario

1. give the edit access to user sesha in namespace called "pireport-dev"

If you want user **`sesha`** to have **edit access** in the namespace **`pireport-dev`**, you can use Kubernetes' built-in **`edit`** ClusterRole and bind it to the user with a RoleBinding.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding

metadata:
  name: sesha-edit-access
  namespace: pireport-dev

subjects:
  - kind: User
    name: sesha
    apiGroup: rbac.authorization.k8s.io

roleRef:
  kind: ClusterRole
  name: edit
  apiGroup: rbac.authorization.k8s.io
```

Apply it:

```bash
kubectl apply -f rolebinding.yaml
```

Verify:

```bash
kubectl auth can-i create deployment \
  --as=sesha \
  -n pireport-dev
```

Expected:

```text
yes
```

Check delete pods:

```bash
kubectl auth can-i delete pod \
  --as=sesha \
  -n pireport-dev
```

Expected:

```text
yes
```

Check another namespace:

```bash
kubectl auth can-i create deployment \
  --as=sesha \
  -n prod
```

Expected:

```text
no
```

### What does the built-in `edit` role allow?

Generally:

* Create, update, patch, delete Deployments
* Manage Pods, Services, ConfigMaps, Secrets, PVCs
* View logs
* Scale applications

But it does **not** allow:

* Managing RBAC (Roles, RoleBindings)
* Namespace administration
* Cluster-wide administration

This is a common approach in enterprises: developers get `edit` access only in their own namespace (e.g., `pireport-dev`) while platform teams retain cluster-admin privileges.
