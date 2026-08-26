## Day 45 — Kubernetes/OpenShift + Database Scenario 🔥

### Scenario

You have a Java application running on OpenShift with **6 replicas**.

Suddenly, users report:

> **"The application is intermittently failing. Some requests work, but some return 500."**

You check:

```bash
oc get pods
```

Everything looks healthy:

```text
NAME              READY   STATUS
app-1             1/1     Running
app-2             1/1     Running
app-3             1/1     Running
app-4             1/1     Running
app-5             1/1     Running
app-6             1/1     Running
```

CPU and memory are also normal.

But application logs show:

```text
HikariPool - Connection is not available,
request timed out after 30000ms
```

### Interviewer asks:

> **"Pods are healthy and resource usage is normal. Why could users still be getting intermittent 500 errors, and how would you troubleshoot it?"**

---

## 🎯 My approach

The important clue is:

```text
HikariPool - Connection is not available
```

This points toward **database connection pool exhaustion**, rather than a Kubernetes Pod problem.

The flow could be:

```text
User
 ↓
HAProxy / Route
 ↓
Service
 ↓
Pod
 ↓
HikariCP
 ↓
PostgreSQL
```

The Pods can be:

```text
Running ✅
Ready   ✅
CPU     normal ✅
Memory  normal ✅
```

while the application is unable to obtain a database connection.

---

### 1. Check database connectivity from the Pods

I'd test connectivity from an application Pod:

```bash
oc exec -it <pod> -- sh
```

Then, depending on the available tools:

```bash
nc -zv <postgres-host> 5432
```

This tells me whether the network connection to PostgreSQL is working.

---

### 2. Check Hikari connection pool configuration

I'd inspect the application's configuration:

```text
maximumPoolSize
minimumIdle
connectionTimeout
idleTimeout
maxLifetime
```

For example:

```text
6 Pods
×
maximumPoolSize = 20
=
120 possible DB connections
```

But PostgreSQL might allow only:

```text
max_connections = 100
```

Now we potentially have:

```text
Application → 120 connections
Database    → 100 connections allowed
```

Some requests can start timing out.

---

## 🔥 This is a very common production scenario

Suppose:

```text
Pod 1 → 20 DB connections
Pod 2 → 20
Pod 3 → 20
Pod 4 → 20
Pod 5 → 20
Pod 6 → 20
```

Total:

```text
120 connections
```

But PostgreSQL has capacity for only:

```text
100
```

You could see:

```text
Pod 1 → requests succeed
Pod 2 → requests succeed
...
Some requests → connection timeout ❌
```

The application appears healthy from Kubernetes' perspective.

---

## 3. Check PostgreSQL

I'd check:

```sql
SELECT count(*) FROM pg_stat_activity;
```

And:

```sql
SELECT state, count(*)
FROM pg_stat_activity
GROUP BY state;
```

I'd investigate:

* Active connections
* Idle connections
* Long-running queries
* Waiting queries
* Connection limits
* Connection leaks

For example, if I see many connections stuck in:

```text
idle in transaction
```

I'd investigate the application behavior.

---

## 4. Check for connection leaks

Suppose the application obtains a DB connection but doesn't properly release it.

Over time:

```text
Request 1 → connection acquired → not released
Request 2 → connection acquired → not released
Request 3 → connection acquired → not released
...
```

Eventually:

```text
Hikari Pool
████████████████████ 100%
```

Then:

```text
New request
    ↓
No connection available
    ↓
30-second timeout
    ↓
HTTP 500
```

This can happen even when:

```text
CPU → normal
Memory → normal
Pod → Running
```

---

## 5. Check application logs across ALL replicas ⭐

Don't inspect only one Pod.

For example:

```bash
oc logs <pod-1>
oc logs <pod-2>
...
```

I'm looking for whether the errors are concentrated on a particular replica.

Example:

```text
Pod 1 → 0 errors
Pod 2 → 0 errors
Pod 3 → 0 errors
Pod 4 → 150 errors ❌
Pod 5 → 0 errors
Pod 6 → 0 errors
```

Now I would investigate Pod 4 specifically.

Maybe its configuration differs:

```text
Pod 4 → wrong DB configuration
Pod 4 → stale connection pool
Pod 4 → connection leak
```

---

## 🔥 Interviewer follow-up

### "Would you simply increase Hikari `maximumPoolSize`?"

**No.**

That's a common trap.

Increasing:

```text
maximumPoolSize: 20 → 50
```

could make the database problem worse.

If:

```text
6 Pods × 50 = 300 connections
```

and PostgreSQL can support only 100, we've increased the pressure dramatically.

I'd first determine:

> **Why are connections being exhausted?**

Then tune the pool based on the database's capacity and application workload.

---

## 🔥 Follow-up 2

### "How would you prevent this in production?"

I'd consider:

* Proper Hikari pool sizing
* Database connection limits
* Connection leak detection
* Query optimization
* Proper connection closing
* Monitoring DB connections
* Alerts on pool utilization
* Load testing before production
* Horizontal scaling with DB capacity considered

And I'd monitor:

```text
Application
 ├── Hikari active connections
 ├── Hikari idle connections
 └── connection timeout count

PostgreSQL
 ├── active connections
 ├── max connections
 ├── slow queries
 └── locks
```

---

## 🎯 Strong interview answer

> **"Since the Pods are Running, Ready, and resource utilization is normal, I wouldn't immediately investigate Kubernetes resources. The HikariPool timeout indicates the application is unable to obtain a database connection. I'd check Hikari pool utilization and configuration, PostgreSQL connection count and max_connections, long-running or idle-in-transaction sessions, and possible connection leaks. I'd also compare all replicas to see whether the issue is isolated to a particular Pod. I wouldn't simply increase the pool size because that could overload PostgreSQL; I'd first identify the reason for connection exhaustion and then tune the application and database capacity accordingly."**

### 🧠 Interview clue

When you see:

```text
HikariPool
Connection is not available
```

Think:

**Application → Connection Pool → PostgreSQL**

Don't immediately blame:

**Pod CPU / Memory / Kubernetes.**

---
# How would issue is particularly to one pod , bcz all pod have dane configuration right

Exactly — **normally all replicas should have the same configuration**, especially when they're created from the same Deployment. But in production, one Pod can still behave differently even when the YAML/configuration is identical.

The key distinction is:

> **Same configuration ≠ same runtime state.**

### Example

Suppose you have:

```text
Deployment
   |
   +---- Pod 1
   +---- Pod 2
   +---- Pod 3
   +---- Pod 4
   +---- Pod 5
   +---- Pod 6
```

All have the same:

```text
Image
ConfigMap
Secret
Environment variables
Resource limits
Service account
```

But Pod 4 could have a **runtime-specific problem**.

---

### 1. Connection leak in one Pod

Imagine Pod 4 has been running for 10 days:

```text
Pod 1 → 2 days
Pod 2 → 2 days
Pod 3 → 2 days
Pod 4 → 10 days  ← old
Pod 5 → 2 days
Pod 6 → 2 days
```

If the application has a connection leak, Pod 4 may have accumulated connections:

```text
Pod 4
Hikari Pool
████████████████ 100%
```

while other Pods are fine.

Check:

```bash
oc get pods
oc describe pod <pod4>
oc logs <pod4>
```

---

### 2. One Pod may have different runtime state

Even with identical configuration:

```text
Pod 1 → healthy JVM
Pod 2 → healthy JVM
Pod 3 → healthy JVM
Pod 4 → problematic JVM
```

For example:

* Stuck threads
* Connection pool exhausted
* Long-running requests
* Cached bad data
* Application-level memory/GC issue

---

### 3. One Pod could be communicating differently with a dependency

For example:

```text
Pod 1 ──→ DB → ✅
Pod 2 ──→ DB → ✅
Pod 3 ──→ DB → ✅
Pod 4 ──→ DB → ❌
```

Possible causes include a transient network issue or stale connections.

You could test from that Pod:

```bash
oc exec -it <pod4> -- nc -zv <db-host> 5432
```

and compare with another Pod.

---

### 4. The Pods might not actually be identical

This is something I'd verify rather than assume.

Check the image:

```bash
oc get pod <pod> -o jsonpath='{.status.containerStatuses[*].imageID}'
```

You may discover:

```text
Pod 1 → image SHA abc123
Pod 2 → image SHA abc123
Pod 3 → image SHA abc123
Pod 4 → image SHA xyz789  ❌
```

Now you have a potentially significant clue.

Also compare:

```bash
oc describe pod <pod>
```

for:

* Image
* Environment variables
* Mounted ConfigMaps/Secrets
* Volumes
* Node
* Resource limits
* Service account

---

### 5. Node-specific issue

This is another good production scenario.

```text
Pod 1 → Worker Node A
Pod 2 → Worker Node A
Pod 3 → Worker Node B
Pod 4 → Worker Node C  ← problem
```

If multiple workloads on Node C have networking or resource problems, investigate the node:

```bash
oc describe node <node>
oc adm top node
```

---

## 🔥 So in an interview, I'd say:

> **"Yes, the Pods are normally created from the same Deployment and should have identical configuration. But configuration consistency doesn't guarantee identical runtime state. If errors appear concentrated on one Pod, I'd compare its image digest, environment, mounted configuration, node placement, restart history, application logs, connection pool state, and dependency connectivity against a healthy Pod. If everything is identical, I'd investigate transient runtime or node-level issues."**

And this is an important **senior-level troubleshooting principle**:

```text
Same Deployment
      ↓
Same Configuration
      ≠
Same Runtime State
```

That distinction is exactly why we compare a **bad Pod against a healthy Pod** rather than assuming the configuration is the problem.

---

# How that pod will fetch different image digest, all should have same rit

Yes — **you're right**. Under normal Kubernetes/OpenShift deployment, all Pods created by the **same ReplicaSet/Deployment revision should use the same image reference**, and typically the same image digest.

My previous example needs an important clarification.

### Normal case

Suppose your Deployment has:

```yaml
containers:
- name: employee
  image: myrepo/employee:v10
```

The Deployment creates a ReplicaSet, and that ReplicaSet creates the Pods:

```text
Deployment
    ↓
ReplicaSet
    ↓
Pod 1 → employee:v10
Pod 2 → employee:v10
Pod 3 → employee:v10
```

They should resolve to the **same image digest**.

You can verify:

```bash
oc get pods -o wide
```

and:

```bash
oc get pod <pod-name> \
  -o jsonpath='{.status.containerStatuses[0].imageID}'
```

---

## Then how could different image digests happen?

There are some **specific scenarios**, not the normal case.

### Scenario 1 — `:latest` or a mutable tag

Suppose you use:

```yaml
image: myrepo/employee:latest
```

You push a new image to the same tag:

```text
latest
 ↓
Digest A
```

Later:

```text
latest
 ↓
Digest B
```

If different Pods are created/recreated at different times and the platform pulls the mutable tag again, you can potentially end up with different image content.

That's why production deployments should preferably use **immutable tags/digests**, for example:

```yaml
image: myrepo/employee:2026.08.26
```

or:

```yaml
image: myrepo/employee@sha256:abc123...
```

---

### Scenario 2 — Different ReplicaSets

This is much more common during a rollout.

For example:

```text
Deployment
   |
   +── ReplicaSet-old
   |      ├── Pod 1 → SHA-A
   |      └── Pod 2 → SHA-A
   |
   +── ReplicaSet-new
          ├── Pod 3 → SHA-B
          └── Pod 4 → SHA-B
```

During a rolling deployment, **old and new ReplicaSets can temporarily coexist**.

So you'd see different image digests, but not because Pods from the same ReplicaSet randomly chose different images.

---

### Scenario 3 — Someone manually changed a Pod

If someone manually modifies/deletes/recreates workloads outside the normal Deployment process, you need to investigate the resulting state. But a Pod's container image isn't normally something you'd change independently and expect the Deployment to preserve.

---

## For your original troubleshooting question

If you have:

```text
Pod 1 → SHA-A
Pod 2 → SHA-A
Pod 3 → SHA-A
Pod 4 → SHA-A
Pod 5 → SHA-A
Pod 6 → SHA-A
```

and **Pod 4 alone is having database connection issues**, then **image difference is NOT a reasonable first suspect**.

I'd investigate:

```text
Pod 4
 ├── Application logs
 ├── Hikari connection pool
 ├── Threads
 ├── Network connectivity
 ├── DB connections
 ├── Node
 └── Runtime state
```

And compare Pod 4 against a healthy Pod.

### 🎯 Interview-quality answer

> **"If all Pods belong to the same ReplicaSet, I would expect them to use the same image and digest. Different digests would usually indicate different rollout revisions, a mutable image tag, or an unusual deployment issue. I wouldn't assume a single Pod has a different image. If all six Pods have the same digest but one is failing, I'd investigate runtime state, application behavior, node-level issues, or dependency connectivity."**

Good catch — **your understanding is correct.**


---
