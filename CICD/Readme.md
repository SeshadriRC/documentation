"The developer pushes code to Git, which triggers Jenkins through a webhook. Jenkins checks out the source code, performs the Maven build, executes unit tests, generates code coverage reports, and runs SonarQube analysis. Jenkins waits for the SonarQube Quality Gate result. If the Quality Gate passes, it packages the application, builds the Docker image, optionally performs an image vulnerability scan, pushes the image to Harbor, updates the Helm chart with the new image tag, deploys the application to Kubernetes/OpenShift using Helm, verifies the rollout, performs smoke tests, and finally monitors the application using Prometheus and Grafana."

```
Developer
      │
      ▼
Git Push
      │
      ▼
Webhook triggers Jenkins
      │
      ▼
Checkout Source Code
      │
      ▼
Maven Compile
      │
      ▼
Unit Tests
      │
      ▼
JaCoCo Coverage Report
      │
      ▼
SonarQube Analysis
      │
      ▼
Quality Gate
      │
      ├── FAIL → Pipeline Stops ❌
      │
      └── PASS
            │
            ▼
Package Application (JAR/WAR)
            │
            ▼
Docker Build
            │
            ▼
Trivy Scan
            │
            ▼
Push Image to Harbor
            │
            ▼
Update Helm values.yaml
            │
            ▼
Helm Upgrade
            │
            ▼
Deploy to Kubernetes/OpenShift
            │
            ▼
kubectl rollout status
            │
            ▼
Smoke Test
            │
            ▼
Application Live
            │
            ▼
Prometheus Scrapes Metrics
            │
            ▼
Grafana Dashboards
            │
            ▼
Alertmanager Sends Alerts

```
