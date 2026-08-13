
1. What is jenkins
2. Weather
3. Jenkins job
4. Triggers and its types
5. Plugins
6. Master / Slave configuration
    - Multiple Agents
    - Jenkins Executors

7. Pipeline and its Types
---

### 1. Jenkins
- Jenkins is an open-source automation tool used to build, test, and deploy applications as part of a CI/CD pipeline.
- It helps automate the software delivery process, reducing manual effort and enabling faster, reliable releases.

---

### 2. Weather

In Jenkins, Weather is a visual indicator on a job/dashboard that shows the overall health of recent builds.

Example:

☀️ Sunny = Most recent builds are successful.
⛅ Cloudy/🌧️ Rainy = Several recent builds have failed or are unstable.
Interview Answer (2 Lines)

Jenkins Weather is a health metric that represents the stability of a job based on its recent build history. It helps quickly identify whether a project is consistently successful or experiencing frequent build failures.
 
---

### 3. Jenkins Job

Interview Answer (2 Lines)

A Jenkins Job is a configurable task or automation unit that Jenkins executes, such as building code, running tests, or deploying applications.
 Jobs can be triggered manually, on a schedule, or automatically when code changes are pushed to a repository.

Real-Time Example

"In my project, a Jenkins job is triggered whenever developers push code to GitHub. The job builds the application, runs tests, and deploys it to the target environment."

Common Types of Jenkins Jobs
Freestyle Project – Simple, GUI-based job.
Pipeline Job – Defined using a Jenkinsfile (most common in DevOps).
Multibranch Pipeline – Automatically creates pipelines for Git branches.
Folder – Organizes multiple jobs.

Interview Follow-up:
 Q: What is the difference between a Jenkins Job and a Pipeline?
 A: A Job is the execution unit in Jenkins, while a Pipeline is a type of job that defines the CI/CD workflow as code using a Jenkinsfile.

---

### 4. Triggers and its types

Interview Answer (2 Lines)

A Trigger in Jenkins is an event or condition that automatically starts a Jenkins job or pipeline. It eliminates manual execution by running builds based on code changes, schedules, API calls, or other job completions.

Simple Example

When a developer pushes code to GitHub, a Webhook Trigger automatically starts the Jenkins pipeline to build, test, and deploy the application.

One-Liner for Interview

"A trigger is a mechanism that tells Jenkins when to execute a job or pipeline automatically."

**Types of Triggers in Jenkins (Interview Answer)**

1. Webhook Trigger

The source code repository (GitHub, GitLab, Bitbucket, etc.) directly notifies Jenkins when code is pushed.
Enables immediate pipeline execution and is commonly used in CI/CD.

2. Build Periodically Trigger

Runs jobs at predefined times using a cron schedule.
Useful for nightly builds, backups, health checks, and maintenance tasks.

3. Trigger Builds Remotely

Allows a Jenkins job to be triggered through a URL, API call, or external application.
Commonly used for integrations with third-party tools and automation scripts.

4. Upstream/Downstream Trigger

Starts a job automatically after another job completes successfully.
Useful for creating dependent workflows such as Build → Test → Deploy.

Additional Common Trigger 

5. Poll SCM

Jenkins periodically checks the source code repository for changes.
If changes are detected, Jenkins triggers a build.
2-Line Interview Answer

Jenkins supports multiple triggers such as Webhook, Poll SCM, Scheduled (Build Periodically), Remote Trigger, and Upstream/Downstream triggers. These triggers help automate CI/CD pipelines based on code changes, schedules, API calls, or the completion of other jobs.
 
---

### 5. Plugins

Interview Answer (2 Lines)

Plugins in Jenkins are extensions that add new features and integrations to Jenkins. They enable Jenkins to work with tools like Git, Docker, Maven, Kubernetes, SonarQube, and cloud platforms.

Real-Time Example

In a CI/CD pipeline, we use:

Git Plugin → Fetch code from GitHub/GitLab

Maven Plugin → Build Java applications

Docker Plugin → Build Docker images

Kubernetes Plugin → Deploy applications to Kubernetes

SonarQube Plugin → Perform code quality analysis

Pipeline Stage View Plugin → Provides a visual representation of Pipeline stages and their status.

SSH Build Agents Plugin → Allows Jenkins Master/Controller to connect to and execute jobs on remote servers (agents) via SSH.

Role-Based Authorization Strategy Plugin → Controls who can access Jenkins and what actions they can perform.

   - Role creation
   - Pattern matching

One-Line Interview Answer

"Plugins extend Jenkins functionality and integrate it with external tools and services."

---

### 6. Master / Slave configuration

Manage Jenkins --> Nodes -> New node( we created slave EC2 in aws )

<img width="940" height="427" alt="image" src="https://github.com/user-attachments/assets/51087e50-0d60-44bb-bc41-353a71acfe15" />

<img width="940" height="638" alt="image" src="https://github.com/user-attachments/assets/c40f700a-f37d-41bc-bbbd-792eb356e681" />

<img width="940" height="528" alt="image" src="https://github.com/user-attachments/assets/b09de55f-bd6e-45e8-abc6-34df8594ca36" />

**Add new creds**

<img width="940" height="545" alt="image" src="https://github.com/user-attachments/assets/57c105d3-7fd1-4d66-9db2-3f4b6425e0c6" />

**Private key add**

<img width="940" height="554" alt="image" src="https://github.com/user-attachments/assets/1a530809-c536-44e3-b784-fdf548677302" />

<img width="940" height="664" alt="image" src="https://github.com/user-attachments/assets/5f476147-17ce-4194-8894-39b8bb4293c5" />

<img width="940" height="270" alt="image" src="https://github.com/user-attachments/assets/5c642e85-58c9-410d-bd53-25a97531e93c" />

**To run only on the slave**

<img width="940" height="547" alt="image" src="https://github.com/user-attachments/assets/30f9c841-d82a-48f2-bd7e-3c60f76f5162" />


**[Multiple agents](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-multiple-agents)**

#### Jenkins Executors

An Executor is a slot available on a Jenkins node (master/controller or agent) that allows Jenkins to run a build/job.
The number of executors determines how many builds can run concurrently on a node. If all executors are busy, additional jobs are placed in the Jenkins queue until an executor becomes available.

Q: What happens if a node has only 1 executor?

A: Only one build can run at a time on that node. Any additional builds will wait in the queue until the running job completes.


Suppose an agent has: Executors: 3
Jenkins can run: 
Job-A
Job-B
Job-C


---

### 7. Pipeline

- A Jenkins Pipeline is CI/CD as code, defining the stages required to build, test, and deploy an application automatically

- In my project, whenever code is pushed to GitHub, the Jenkins pipeline automatically builds the application, runs unit tests, performs SonarQube and security scans, creates a Docker image, and deploys it to Kubernetes.

Types of Pipelines

**Declarative Pipeline**

- Uses a structured syntax.
- Easier to read and maintain.
- Most commonly used and its recently introduced ( before 9 years )

**Scripted Pipeline**

- Written using Groovy scripting.
- More flexible for complex workflows. Scripted pipeline is old way, its very complex. we will use this pipeline for more logic, we can build our own custom solutions

**Declarative Pipeline**

```
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
```

**Scripted Pipeline**

```
node {
    stage('Build') {
        echo 'Building....'
    }
    stage('Test') {
        echo 'Testing....'
    }
    stage('Deploy') {
        echo 'Deploying....'
    }
}
```
---
