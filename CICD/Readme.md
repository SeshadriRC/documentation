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

---

**Pipeline**

```bash
pipeline {
    agent any

    environment {
        APP_NAME = "product-catalog"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_IMAGE = "harbor.company.com/dev/${APP_NAME}:${IMAGE_TAG}"
    }

    tools {
        maven "Maven-3.9"
        jdk "JDK-17"
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/company/product-catalog.git'
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Code Coverage') {
            steps {
                sh 'mvn jacoco:report'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Package Application') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${DOCKER_IMAGE} .
                """
            }
        }

        stage('Image Security Scan') {
            steps {
                sh """
                trivy image ${DOCKER_IMAGE}
                """
            }
        }

        stage('Push Image to Harbor') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'harbor-creds',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {

                    sh """
                    docker login harbor.company.com \
                      -u $USERNAME \
                      -p $PASSWORD

                    docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Update Helm Values') {
            steps {
                sh """
                sed -i 's/tag:.*/tag: ${IMAGE_TAG}/' helm/values.yaml
                """
            }
        }

        stage('Deploy to Kubernetes/OpenShift') {
            steps {
                sh """
                helm upgrade --install product-catalog \
                    helm/ \
                    --namespace production
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh """
                kubectl rollout status deployment/product-catalog \
                -n production
                """
            }
        }

        stage('Smoke Test') {
            steps {
                sh """
                curl -f http://product-catalog.company.com/actuator/health
                """
            }
        }

    }

    post {

        success {
            echo "Deployment Successful."
        }

        failure {
            echo "Deployment Failed."
        }

        always {
            cleanWs()
        }
    }
}

```

