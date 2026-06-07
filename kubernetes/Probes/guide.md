- There are 3 types of probes liveness, readiness and startup

- You can explain it like this:

- By default, the kubelet monitors only the **container status**, not the actual health of the application running inside it. If the application becomes unresponsive or gets stuck while the container process is still running, the kubelet considers the container healthy.
- To address this, we configure **health probes** (such as liveness, readiness, and startup probes) that call an application endpoint like `/health`, allowing the kubelet to verify the application's real health instead of just the container's status.


## Liveness probe

- Determines if an application in a container is healthy
```yaml
# Liveness Probe
# Checks whether the application is still alive.
# If this probe fails 3 consecutive times, Kubernetes restarts the container.

livenessProbe:
  httpGet:
    path: /health          # Endpoint used to verify application health
    port: 80              # Container port on which the application listens

  initialDelaySeconds: 10 # Wait 10 seconds after container start before first check
  periodSeconds: 5        # Run the probe every 5 seconds
  failureThreshold: 3     # Restart container after 3 consecutive failures
```

### Meaning

```text
Container Starts
       ↓
Wait 10 seconds
       ↓
Check /health every 5 seconds
       ↓
Fails 3 times in a row?
       ↓
Yes → Restart Container
No  → Continue Running
```

## Readiness probe

- It will check whether application is in the container is ready to accept the traffic.

```yaml
readinessProbe:
  httpGet:
    path: /health          # Endpoint used to verify application health
    port: 80              # Container port on which the application listens

  initialDelaySeconds: 10 # Wait 10 seconds after container start before first check
  periodSeconds: 5        # Run the probe every 5 seconds
```
<img width="1146" height="590" alt="image" src="https://github.com/user-attachments/assets/1d4a8707-baa3-4e93-b6d7-9fe6ed0613e7" />

Here's a cleaner interview-friendly explanation:

### Readiness Probe

> A container may be running, but the application inside it may still be initializing (for example, loading configurations, establishing database connections, or warming up caches). During this time, if user requests are sent to the application, they may fail. To solve this problem, Kubernetes provides a **Readiness Probe**.
>
> The kubelet continuously checks the application's readiness by calling a configured endpoint such as `/health`. Until the probe succeeds, Kubernetes marks the pod as **Not Ready** and does not route traffic to it through a Service. Once the application reports that it is ready, the pod is added to the Service endpoints and starts receiving user requests.

```yaml id="f4cmag"
readinessProbe:
  httpGet:
    path: /health          # Endpoint used to verify application readiness
    port: 80              # Application listening port

  initialDelaySeconds: 10 # Wait 10 seconds before the first check
  periodSeconds: 5        # Check readiness every 5 seconds
```

### Flow

```text id="55nbwe"
Pod Created
     ↓
Container Started
     ↓
Application Initializing
     ↓
Readiness Probe Checks /health
     ↓
Not Ready
     ↓
No User Traffic Sent
     ↓
Application Ready
     ↓
Readiness Probe Succeeds
     ↓
Pod Added to Service Endpoints
     ↓
Starts Receiving User Requests
```

### One-Line Interview Answer

> Readiness Probe determines whether an application is ready to serve traffic; until it succeeds, Kubernetes keeps the pod out of the Service endpoints and does not send user requests to it.

---

### Startup Probe

<img width="1116" height="557" alt="image" src="https://github.com/user-attachments/assets/d0fde7f5-0bc7-4c91-978c-bbc25edf4a24" />


> Some applications take a long time to start. For example, a Java application may take 1 minute or more to initialize, load dependencies, and establish database connections. If a liveness probe starts checking the application before it has finished starting, the probe may fail repeatedly, causing Kubernetes to restart the container continuously even though the application is still starting normally.
>
> To solve this problem, Kubernetes provides a **Startup Probe**. When a startup probe is configured, Kubernetes runs only the startup probe during application startup. The liveness and readiness probes are disabled until the startup probe succeeds.
>
> Once the application starts successfully and the startup probe passes, Kubernetes stops running the startup probe. After that, the readiness probe and liveness probe begin their normal operation.

```yaml id="k5g1ji"
startupProbe:
  httpGet:
    path: /health          # Endpoint used to verify application startup
    port: 80              # Application listening port

  failureThreshold: 30    # Maximum failed attempts before container restart
  periodSeconds: 5        # Check every 5 seconds
```

### How this works

```text id="h8eqyj"
Application Starts
       ↓
Startup Probe Runs
       ↓
Application Ready?
   ├─ No → Keep Checking
   └─ Yes
       ↓
Startup Probe Stops
       ↓
Readiness Probe Starts
       ↓
Liveness Probe Starts
       ↓
Normal Operation
```

### Example

```yaml id="y0t38c"
failureThreshold: 30
periodSeconds: 5
```

Maximum startup time allowed:

```text id="0v1e0m"
30 × 5 = 150 seconds
```

Kubernetes will wait up to **150 seconds** for the application to start before restarting the container.

### One-Line Interview Answer

> A Startup Probe is used for slow-starting applications. It delays liveness and readiness checks until the application has started successfully, preventing unnecessary container restarts during startup.

A more accurate way to explain it is:

> For a **Startup Probe**, the `failureThreshold` is usually set higher because some applications take a long time to start. Kubernetes allows the startup probe to fail a certain number of times before deciding that the application startup has failed. If the `failureThreshold` is too low, Kubernetes may restart the container even though the application is still starting normally.
>
> For example:
>
> ```yaml
> startupProbe:
>   httpGet:
>     path: /health
>     port: 80
>   failureThreshold: 30
>   periodSeconds: 5
> ```
>
> Kubernetes will allow:
>
> ```text
> 30 × 5 = 150 seconds
> ```
>
> for the application to start. If the startup probe still fails after 150 seconds, Kubernetes assumes the startup has failed and restarts the container.

### Important clarification

This part is not quite correct:

> "if we don't give failureThreshold, then continuously it will be checking the application status"

Kubernetes will always continue checking according to `periodSeconds`. The purpose of a higher `failureThreshold` is **not to stop continuous checking**, but to **give the application more time before Kubernetes declares startup failure and restarts the container**.

### Interview Answer

> Startup probes typically use a higher `failureThreshold` because some applications require more time to initialize. A higher threshold prevents Kubernetes from restarting the container prematurely while the application is still starting. Once the startup probe succeeds, it stops running and the liveness and readiness probes take over.


---
