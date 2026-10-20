# Helm Commands for DevOps Engineers

A comprehensive reference for Kubernetes package management using Helm 3.

---

## Table of Contents

- [1. Repository Management](#1-repository-management)
- [2. Searching & Discovering Charts](#2-searching--discovering-charts)
- [3. Installing Charts](#3-installing-charts)
- [4. Upgrading Releases (Idempotent Deployments)](#4-upgrading-releases-idempotent-deployments)
- [5. Rollback & Release History](#5-rollback--release-history)
- [6. Inspecting Releases & Values](#6-inspecting-releases--values)
- [7. Chart Development, Linting & Dry-Runs](#7-chart-development-linting--dry-runs)
- [8. Managing Chart Dependencies](#8-managing-chart-dependencies)
- [9. Inspecting Upstream Charts (Without Installing)](#9-inspecting-upstream-charts-without-installing)
- [10. Uninstalling Releases](#10-uninstalling-releases)
- [11. Helm Diff & Useful Plugins](#11-helm-diff--useful-plugins)
- [12. OCI Registry Support (Helm 3.8+)](#12-oci-registry-support-helm-38)

---

## 1. Repository Management

```bash
# Add a chart repository
helm repo add elastic https://helm.elastic.co
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update all repositories to fetch the latest chart metadata
helm repo update

# Update a specific repository
helm repo update elastic

# List configured repositories
helm repo list

# Remove a chart repository
helm repo remove elastic
```

[Back to Top ↑](#table-of-contents)

---

## 2. Searching & Discovering Charts

```bash
# Search within local repositories for charts
helm search repo metricbeat

# List all available versions of a chart in local repositories
helm search repo elastic/metricbeat --versions | head

# Search Artifact Hub across the entire public Helm ecosystem
helm search hub cert-manager
helm search hub prometheus
```

[Back to Top ↑](#table-of-contents)

---

## 3. Installing Charts

```bash
# Basic install
helm install kibana elastic/kibana -f kibana-values.yaml

# Install a specific version into a specific namespace with custom values
helm install metricbeat elastic/metricbeat \
  --version 8.5.1 \
  -n default \
  -f metricbeat-values.yml

# Install and create namespace if it doesn't exist
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f monitoring-values.yaml

# Override values on the fly with --set and --set-string
helm install my-app ./my-app-chart \
  --namespace production \
  --set replicaCount=3 \
  --set image.tag="v1.2.3" \
  --set-string ingress.annotations."nginx\.ingress\.kubernetes\.io/ssl-redirect"="true"

# Wait for all Pods to be ready before marking release successful (with timeout)
helm install redis bitnami/redis \
  --namespace cache \
  --wait \
  --timeout 10m

# Atomic installation (automatically rollback changes if installation fails)
helm install my-app ./chart --atomic --timeout 5m
```

[Back to Top ↑](#table-of-contents)

---

## 4. Upgrading Releases (Idempotent Deployments)

```bash
# Upgrade an existing release with new values
helm upgrade my-release bitnami/nginx -f values.yaml

# Idempotent install or upgrade (industry standard for CI/CD pipelines)
helm upgrade --install my-app ./chart \
  --namespace production \
  --create-namespace \
  -f values.prod.yaml \
  --set image.tag="sha-4f81c9a" \
  --atomic \
  --timeout 5m

# Upgrade and reuse previous values while overriding only specific keys
helm upgrade my-app ./chart --reuse-values --set replicaCount=5

# Upgrade and reset values to the chart's defaults (except those specified in current flags)
helm upgrade my-app ./chart --reset-values -f new-values.yaml
```

[Back to Top ↑](#table-of-contents)

---

## 5. Rollback & Release History

```bash
# View release revision history
helm history my-app -n production

# Roll back to the immediately preceding revision
helm rollback my-app -n production

# Roll back to a specific revision (e.g. revision 2)
helm rollback my-app 2 -n production

# Roll back with atomic validation and timeout
helm rollback my-app 2 -n production --atomic --timeout 5m
```

[Back to Top ↑](#table-of-contents)

---

## 6. Inspecting Releases & Values

```bash
# List all releases across all namespaces
helm list -A

# List releases in a specific namespace (including failed/pending)
helm list -n production --all

# View detailed status and deployment notes of a release
helm status my-app -n production

# Retrieve the user-supplied values used to deploy a release
helm get values my-app -n production

# Retrieve all computed values (defaults merged with user overrides)
helm get values my-app -n production --all

# Retrieve the exact Kubernetes manifests generated and deployed by Helm
helm get manifest my-app -n production

# View chart notes emitted after installation
helm get notes my-app -n production
```

[Back to Top ↑](#table-of-contents)

---

## 7. Chart Development, Linting & Dry-Runs

```bash
# Scaffold a new Helm chart directory structure
helm create my-microservice

# Validate syntax and check chart best practices
helm lint ./my-microservice

# Render chart templates locally without connecting to or touching the Kubernetes cluster
helm template my-release ./my-microservice -f values.dev.yaml

# Render templates and pipe directly into kubectl diff or linters
helm template my-release ./my-microservice -f values.yaml | kubectl diff -f -

# Dry-run against the live Kubernetes cluster to validate schema against API server
helm install my-app ./my-microservice --dry-run --debug -n default

# Package chart into a tarball (.tgz)
helm package ./my-microservice -d ./charts-repo
```

[Back to Top ↑](#table-of-contents)

---

## 8. Managing Chart Dependencies

```bash
# List dependencies declared in Chart.yaml
helm dependency list ./my-chart

# Download and update dependencies based on Chart.lock or Chart.yaml
helm dependency update ./my-chart

# Build dependencies locally into the charts/ directory
helm dependency build ./my-chart
```

[Back to Top ↑](#table-of-contents)

---

## 9. Inspecting Upstream Charts (Without Installing)

```bash
# View default values.yaml of a chart in a remote repository
helm show values elastic/kibana

# View chart metadata (Chart.yaml)
helm show chart bitnami/redis

# View README.md of a chart
helm show readme bitnami/nginx

# View all info (chart, values, readme)
helm show all elastic/metricbeat
```

[Back to Top ↑](#table-of-contents)

---

## 10. Uninstalling Releases

```bash
# Uninstall release and delete all its Kubernetes resources
helm uninstall my-app -n production

# Uninstall release but preserve release history (allows future rollback or audit)
helm uninstall my-app -n production --keep-history

# Uninstall with a grace period / timeout
helm uninstall my-app -n production --timeout 3m
```

[Back to Top ↑](#table-of-contents)

---

## 11. Helm Diff & Useful Plugins

```bash
# List installed plugins
helm plugin list

# Install helm-diff plugin (essential for CI/CD pull request reviews)
helm plugin install https://github.com/databus23/helm-diff

# Preview differences between currently deployed release and new changes
helm diff upgrade my-app ./chart -f values.yaml -n production

# Update plugins
helm plugin update diff

# Uninstall a plugin
helm plugin uninstall diff
```

[Back to Top ↑](#table-of-contents)

---

## 12. OCI Registry Support (Helm 3.8+)

```bash
# Authenticate with an OCI container registry (e.g., ECR, GHCR, Harbor)
helm registry login ghcr.io -u <username> -p <token>

# Package and push chart to OCI registry
helm package ./my-chart
helm push my-chart-0.1.0.tgz oci://ghcr.io/my-org/charts

# Pull chart from OCI registry
helm pull oci://ghcr.io/my-org/charts/my-chart --version 0.1.0 --untar

# Install chart directly from OCI registry
helm install my-app oci://ghcr.io/my-org/charts/my-chart --version 0.1.0 -n production
```

[Back to Top ↑](#table-of-contents)
