# Architecture

```
Developer
    │
    ▼
GitHub (Application Code)
    │
    ▼
Webhook
    │
    ▼
Jenkins CI
    │
    ├── Checkout Code
    ├── Compile
    ├── Unit Test
    ├── JaCoCo
    ├── SonarQube
    ├── Quality Gate
    ├── Package JAR
    ├── Upload JAR → JFrog
    ├── Build Docker Image
    ├── Trivy Scan
    ├── Push Image → Harbor
    │
    └── Update Helm values.yaml
            │
            ▼
      GitOps Repository
            │
            ▼
     Git Commit & Push
            │
            ▼
Argo CD detects change
            │
            ▼
Argo CD renders Helm chart
            │
            ▼
Deploy to OpenShift/Kubernetes
            │
            ▼
Verify Deployment
            │
            ▼
Prometheus & Grafana

```

# CI Pipeline

```
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

# ArgoCD

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: product-catalog

spec:

  project: default

  source:

    repoURL: https://github.com/company/gitops.git

    targetRevision: main

    path: product-catalog

    helm:

      valueFiles:

      - values.yaml

  destination:

    server: https://kubernetes.default.svc

    namespace: production

  syncPolicy:

    automated:

      prune: true

      selfHeal: true
```
