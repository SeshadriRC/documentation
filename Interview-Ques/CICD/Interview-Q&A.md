1. Sample pipeline

[link](https://github.com/SeshadriRC/Jenkins-Zero-To-Hero/blob/main/my-first-pipeline/Jenkinsfile)

```groovy
pipeline {
  agent {
    docker { image 'node:16-alpine' }
  }
  stages {
    stage('Test') {
      steps {
        sh 'node --version'
      }
    }
  }
}
```
