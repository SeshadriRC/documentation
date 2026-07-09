```
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
