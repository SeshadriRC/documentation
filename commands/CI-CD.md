# CI/CD Commands for DevOps Engineers

A comprehensive reference for automating, inspecting, and triggering continuous integration and deployment pipelines using GitHub CLI (`gh`), Jenkins CLI/API, and GitLab CLI (`glab`).

---

## 1. GitHub CLI (`gh`) for GitHub Actions

```bash
# Authenticate with GitHub
gh auth login
gh auth status

# List recent workflow runs across the repository
gh run list
gh run list --workflow=deploy.yml --limit 10

# View detailed progress and logs of a specific workflow run
gh run view <run-id>
gh run view <run-id> --log
gh run view <run-id> --log-failed

# Watch a running workflow in real time until completion
gh run watch <run-id>

# Re-run a failed workflow run
gh run rerun <run-id> --failed

# Manually trigger a workflow with input parameters (workflow_dispatch)
gh workflow run deploy.yml \
  -f environment=production \
  -f app_version=v2.1.0 \
  -f deploy_database_migrations=true

# List and manage GitHub Actions repository secrets
gh secret list
gh secret set AWS_ACCESS_KEY_ID --body "AKIA..."
gh secret set DOCKER_PASSWORD < ~/.docker_token
gh secret delete DEPLOY_KEY

# Manage environment-specific variables
gh variable list
gh variable set ENVIRONMENT --body "production"

# Create a release with release notes and binary assets
gh release create v1.2.0 ./dist/* --title "Release v1.2.0" --notes "Production deployment"

# Pull request automation
gh pr list
gh pr create --title "feat: upgrade helm chart" --body "Automated update" --base main
gh pr checkout 42
gh pr merge 42 --squash --auto --delete-branch
```

---

## 2. Jenkins CLI & REST API Automation

### Jenkins CLI (`jenkins-cli.jar`)

```bash
# Download the Jenkins CLI jar from your Jenkins controller
curl -O http://<jenkins-host>:8080/jnlpJars/jenkins-cli.jar

# Run a build with parameters and stream console output (-s: synchronous, -v: verbose console)
java -jar jenkins-cli.jar -s http://<jenkins-host>:8080/ \
  -auth <username>:<api-token> \
  build "deploy-microservice" \
  -p ENVIRONMENT=production \
  -p DOCKER_TAG=1.2.3 \
  -s -v

# List all Jenkins jobs
java -jar jenkins-cli.jar -s http://<jenkins-host>:8080/ -auth <username>:<api-token> list-jobs

# Check current build status of a job
java -jar jenkins-cli.jar -s http://<jenkins-host>:8080/ -auth <username>:<api-token> console "deploy-microservice"

# Safely restart Jenkins controller (waits for running builds to finish)
java -jar jenkins-cli.jar -s http://<jenkins-host>:8080/ -auth <username>:<api-token> safe-restart
```

### Jenkins REST API via cURL

```bash
# Retrieve CSRF Crumb (required when CSRF protection is enabled)
CRUMB=$(curl -u "<username>:<api-token>" -s 'http://<jenkins-host>:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')

# Trigger build without parameters
curl -X POST -u "<username>:<api-token>" -H "$CRUMB" \
  http://<jenkins-host>:8080/job/build-and-test/build

# Trigger build with parameters
curl -X POST -u "<username>:<api-token>" -H "$CRUMB" \
  "http://<jenkins-host>:8080/job/deploy-app/buildWithParameters?ENVIRONMENT=staging&BRANCH=main"

# Tail live console text of the last build
curl -s -u "<username>:<api-token>" \
  http://<jenkins-host>:8080/job/deploy-app/lastBuild/consoleText

# Inspect build status JSON (SUCCESS, FAILURE, BUILDING)
curl -s -u "<username>:<api-token>" \
  http://<jenkins-host>:8080/job/deploy-app/lastBuild/api/json | jq -r '{result: .result, building: .building, duration: .duration}'

# Reload Jenkins configuration from disk
curl -X POST -u "<username>:<api-token>" -H "$CRUMB" \
  http://<jenkins-host>:8080/reload
```

---

## 3. GitLab CLI (`glab`) for GitLab CI/CD

```bash
# Authenticate with GitLab
glab auth login

# List recent pipeline runs
glab ci list

# View current pipeline status and stages
glab ci view

# Stream logs of a specific pipeline job in real time
glab ci trace <job-id>

# Trigger a pipeline on current branch with variables
glab ci run --variables "DEPLOY_ENV:production" --variables "VERSION:v1.0.0"

# Retry a failed pipeline or job
glab ci retry <job-id>

# Cancel a running pipeline
glab ci cancel
```
