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
