The developer pushes code to Git, which triggers Jenkins through a webhook. Jenkins checks out the source code, performs the Maven build, executes unit tests, generates code coverage reports, and runs SonarQube analysis. Jenkins waits for the SonarQube Quality Gate result. If the Quality Gate passes, it packages the application, builds the Docker image, optionally performs an image vulnerability scan, pushes the image to Harbor, updates the Helm chart with the new image tag, deploys the application to Kubernetes/OpenShift using Helm, verifies the rollout, performs smoke tests, and finally monitors the application using Prometheus and Grafana.

<img width="1918" height="828" alt="image" src="https://github.com/user-attachments/assets/f7000a92-b1d0-424c-8ca7-82b7e07045aa" />

- The payload URL is the webhook endpoint exposed by the receiving application. For Jenkins, it's typically https://<jenkins-url>/github-webhook/, and for Argo CD it's https://<argocd-url>/api/webhook. The webhook secret is not provided by GitHub; we generate a secure random string ourselves, configure it in the GitHub webhook settings, and configure the same secret in Jenkins or Argo CD so incoming webhook requests can be authenticated and verified.

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

---

**Plugins**

| **Plugin**                    | **Purpose**                                                    | **Mandatory?** |
| ----------------------------- | -------------------------------------------------------------- | -------------- |
| Pipeline                      | Executes the Jenkinsfile (Declarative Pipeline)                | ✅ Yes          |
| Git Plugin                    | Clones source code from GitHub                                 | ✅ Yes          |
| GitHub Plugin                 | Integrates GitHub and supports webhooks                        | ✅ Yes          |
| Credentials Plugin            | Stores GitHub, Harbor, JFrog, SonarQube credentials securely   | ✅ Yes          |
| Credentials Binding Plugin    | Injects credentials into the pipeline as environment variables | ✅ Yes          |
| JUnit Plugin                  | Publishes unit test reports                                    | ✅ Yes          |
| JaCoCo Plugin                 | Publishes code coverage reports                                | ✅ Yes          |
| SonarQube Scanner Plugin      | Runs SonarQube analysis and checks Quality Gate                | ✅ Yes          |
| Workspace Cleanup Plugin      | Cleans the Jenkins workspace after the build                   | ✅ Yes          |
| Pipeline Utility Steps Plugin | Reads/writes YAML, JSON, properties files                      | ⭐ Recommended  |
| SSH Agent Plugin              | Accesses Git repositories over SSH (e.g., GitOps repo)         | ⭐ Recommended  |
| Email Extension Plugin        | Sends build success/failure email notifications                | Optional       |
| Slack Notification Plugin     | Sends Slack notifications                                      | Optional       |
| ANSI Color Plugin             | Adds colored console logs                                      | Optional       |
| Timestamper Plugin            | Adds timestamps to console logs                                | Optional       |
| Build Timeout Plugin          | Stops long-running builds automatically                        | Optional       |
| Blue Ocean Plugin             | Modern pipeline visualization UI                               | Optional       |
| JFrog Artifactory Plugin      | Integrates Jenkins with JFrog (not needed if using JFrog CLI)  | Optional       |

---

**Tools**

| **Plugin**                    | **Purpose**                                                    | **Mandatory?** |
| ----------------------------- | -------------------------------------------------------------- | -------------- |
| Pipeline                      | Executes the Jenkinsfile (Declarative Pipeline)                | ✅ Yes          |
| Git Plugin                    | Clones source code from GitHub                                 | ✅ Yes          |
| GitHub Plugin                 | Integrates GitHub and supports webhooks                        | ✅ Yes          |
| Credentials Plugin            | Stores GitHub, Harbor, JFrog, SonarQube credentials securely   | ✅ Yes          |
| Credentials Binding Plugin    | Injects credentials into the pipeline as environment variables | ✅ Yes          |
| JUnit Plugin                  | Publishes unit test reports                                    | ✅ Yes          |
| JaCoCo Plugin                 | Publishes code coverage reports                                | ✅ Yes          |
| SonarQube Scanner Plugin      | Runs SonarQube analysis and checks Quality Gate                | ✅ Yes          |
| Workspace Cleanup Plugin      | Cleans the Jenkins workspace after the build                   | ✅ Yes          |
| Pipeline Utility Steps Plugin | Reads/writes YAML, JSON, properties files                      | ⭐ Recommended  |
| SSH Agent Plugin              | Accesses Git repositories over SSH (e.g., GitOps repo)         | ⭐ Recommended  |
| Email Extension Plugin        | Sends build success/failure email notifications                | Optional       |
| Slack Notification Plugin     | Sends Slack notifications                                      | Optional       |
| ANSI Color Plugin             | Adds colored console logs                                      | Optional       |
| Timestamper Plugin            | Adds timestamps to console logs                                | Optional       |
| Build Timeout Plugin          | Stops long-running builds automatically                        | Optional       |
| Blue Ocean Plugin             | Modern pipeline visualization UI                               | Optional       |
| JFrog Artifactory Plugin      | Integrates Jenkins with JFrog (not needed if using JFrog CLI)  | Optional       |

### Tools to install on the Jenkins Agent (Not Plugins)

| **Tool**  | **Purpose**                                   |
| --------- | --------------------------------------------- |
| Git       | Source code checkout                          |
| JDK 17    | Java runtime for Maven builds                 |
| Maven     | Build Spring Boot application                 |
| Docker    | Build Docker images                           |
| Trivy     | Scan Docker images for vulnerabilities        |
| Helm      | Package and manage Kubernetes deployments     |
| kubectl   | Interact with Kubernetes/OpenShift cluster    |
| JFrog CLI | Upload JAR/WAR artifacts to JFrog Artifactory |

---



