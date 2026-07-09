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

        IMAGE = "harbor.company.com/dev/${APP_NAME}:${IMAGE_TAG}"

        GITOPS_REPO = "git@github.com:company/gitops.git"

    }

    tools {

        maven "Maven-3.9"

        jdk "JDK-17"

    }

    stages {

        stage('Checkout Source') {

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

        stage('Unit Test') {

            steps {

                sh 'mvn test'

            }

            post {

                always {

                    junit '**/target/surefire-reports/*.xml'

                }

            }

        }

        stage('JaCoCo Coverage') {

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

        stage('Package') {

            steps {

                sh 'mvn package -DskipTests'

            }

        }

        stage('Upload Artifact to JFrog') {

            steps {

                sh '''

                jf rt upload target/*.jar \
                libs-release-local/

                '''

            }

        }

        stage('Build Docker Image') {

            steps {

                sh """

                docker build \
                -t ${IMAGE} .

                """

            }

        }

        stage('Trivy Scan') {

            steps {

                sh """

                trivy image \
                --severity HIGH,CRITICAL \
                ${IMAGE}

                """

            }

        }

        stage('Push Image to Harbor') {

            steps {

                withCredentials([

                    usernamePassword(

                        credentialsId: 'harbor-creds',

                        usernameVariable: 'USERNAME',

                        passwordVariable: 'PASSWORD'

                    )

                ]) {

                    sh """

                    docker login harbor.company.com \
                    -u $USERNAME \
                    -p $PASSWORD

                    docker push ${IMAGE}

                    """

                }

            }

        }

        stage('Update GitOps Repository') {

            steps {

                dir('gitops') {

                    git branch: 'main',
                        url: "${GITOPS_REPO}"

                    sh """

                    sed -i 's/tag:.*/tag: ${IMAGE_TAG}/' \
                    product-catalog/values.yaml

                    git config user.name Jenkins

                    git config user.email jenkins@company.com

                    git add .

                    git commit -m "Updated image tag to ${IMAGE_TAG}"

                    git push origin main

                    """

                }

            }

        }

    }

    post {

        success {

            echo "CI Pipeline Completed"

        }

        failure {

            echo "Pipeline Failed"

        }

        always {

            cleanWs()

        }

    }

}

```

