## Day 43 — Kubernetes/OpenShift Production Scenario 🔥

### Scenario

You have an OpenShift application with **5 replicas**.

Everything was working normally. Suddenly users report:

> **"The application is very slow, and sometimes requests fail with 504 Gateway Timeout."**

You check:

```bash
oc get pods
```

and all 5 Pods show:

```text
READY   STATUS
1/1     Running
1/1     Running
1/1     Running
1/1     Running
1/1     Running
```

There are **no obvious restarts**.

### Interviewer asks:

> **"All Pods are Running and Ready, but users are getting intermittent 504s. How would you troubleshoot this?"**

---

## 🎯 How I'd approach it

I wouldn't assume the Pods are healthy just because they're `1/1 Running`.

I'd trace:

```text
User
 ↓
External Load Balancer
 ↓
OpenShift HAProxy Router
 ↓
Route
 ↓
Service
 ↓
Pods
 ↓
Application
 ↓
Database / Redis / External APIs
```

The key difference here is **504 Gateway Timeout**.

A 504 generally means a gateway/proxy **didn't receive a timely response from the upstream backend**.

---

### Step 1 — Determine whether all requests are slow or only some

I'd test the endpoint repeatedly:

```bash
for i in {1..20}; do
  curl -s -o /dev/null \
    -w "%{http_code} %{time_total}\n" \
    https://myapp.example.com/api
done
```

Example:

```text
200 0.21
200 0.25
504 30.01
200 0.20
504 30.00
```

This strongly suggests an **intermittent backend problem**.

---

## Step 2 — Check resource utilization

```bash
oc adm top pods
```

or:

```bash
oc adm top pod <pod-name>
```

Look for:

```text
CPU → very high
Memory → very high
```

For example:

```text
Pod 1 → CPU 20%
Pod 2 → CPU 25%
Pod 3 → CPU 95%  ← suspicious
Pod 4 → CPU 20%
Pod 5 → CPU 25%
```

If only one Pod is overloaded, I'd investigate why.

---

## Step 3 — Check application logs

```bash
oc logs <pod>
```

I'm looking for:

```text
Connection timeout
Database timeout
Connection pool exhausted
Thread pool exhausted
Redis timeout
External API timeout
Slow query
```

For a Java application, for example:

```text
HikariPool - Connection is not available
```

could indicate database connection pool exhaustion.

---

## Step 4 — Check database/backend dependencies ⭐

This is where I would go deeper.

The application may be healthy:

```text
Pod → Running ✅
Readiness → Passing ✅
```

but:

```text
Pod
 ↓
PostgreSQL
 ↓
Slow / overloaded
```

Then:

```text
Request
 ↓
Application waits for DB
 ↓
Timeout
 ↓
HAProxy
 ↓
504
```

So I'd check:

* DB CPU/memory
* Connection count
* Slow queries
* Connection pool
* Network latency
* Redis
* External APIs

---

## Step 5 — Check HAProxy/Router timeout

Since you're using OpenShift's HAProxy router, I'd check whether the timeout is occurring at the router layer.

For example:

```text
Client
  ↓
HAProxy
  ↓
Application
  ↓
Database
```

If the application takes longer than the configured timeout to respond:

```text
Request
   ↓
HAProxy waits
   ↓
Timeout ⏱️
   ↓
504
```

I'd inspect the router configuration/logs and determine **which timeout is being hit** rather than blindly increasing the timeout.

---

## 🔥 Interviewer follow-up

### "Suppose you find that the database is occasionally taking 40 seconds to respond. What would you do?"

I wouldn't simply increase the HAProxy timeout from 30 → 60 seconds.

I'd first identify **why the DB request takes 40 seconds**.

I'd investigate:

```text
Slow query?
DB CPU?
Lock contention?
Connection pool exhaustion?
Missing index?
Network issue?
Too many concurrent requests?
```

If the application normally responds in 200 ms, a sudden 40-second DB query is likely the **root cause**, while the 504 is only the symptom.

---

## 🔥 Follow-up 2

### "What if only one of the five Pods is causing the 504?"

I'd test each Pod individually.

Conceptually:

```text
Service
 ├── Pod 1 → 200
 ├── Pod 2 → 200
 ├── Pod 3 → 504 ❌
 ├── Pod 4 → 200
 └── Pod 5 → 200
```

Then I'd inspect Pod 3:

```bash
oc describe pod <pod3>
oc logs <pod3>
oc adm top pod <pod3>
```

I'd compare:

* Environment variables
* ConfigMap/Secret
* Resource usage
* Application logs
* Network connectivity
* Dependency connectivity

If the Pod is genuinely unhealthy, I'd determine why the **readiness probe didn't remove it from service**.

That's a very important follow-up.

---

## 🎯 Strong interview answer

> **"For intermittent 504s, I would first determine whether the timeout occurs at the OpenShift HAProxy router or in the application/backend. I'd test the endpoint repeatedly and compare response times, check Pod resource utilization and application logs, and verify database, Redis, and external dependency latency. I'd also inspect router timeout behavior. If one Pod is responsible, I'd test that Pod individually and investigate why its readiness probe didn't remove it from the Service. I would fix the underlying bottleneck rather than simply increasing the gateway timeout."**

### 🧠 Remember

```text
503 → Backend/service unavailable
504 → Gateway/proxy waited but upstream didn't respond in time
```

For a **504**, think:

> **"Where is the request waiting, and what is it waiting for?"**
