# DevOps & SRE Command Documentation Hub

A centralized, production-grade quick reference and cheat sheet directory covering essential commands, troubleshooting recipes, and operational workflows for DevOps engineers.

---

## Table of Contents

- [Command Reference Directory](#command-reference-directory)
- [Quick Navigation Guidelines](#quick-navigation-guidelines)

---

## Command Reference Directory

| Technology | Documentation File | Core Focus Areas |
| :--- | :--- | :--- |
| **Linux** | [`Linux.md`](Linux.md) | System triage, performance monitoring (CPU/RAM), LVM disk expansion, networking, systemd, process debugging, security, SSH |
| **Kubernetes** | [`kubernetes.md`](kubernetes.md) | Pod troubleshooting (CrashLoopBackOff/Pending/OOM), rollouts, ingress, services, secrets, storage PV/PVC, node maintenance, Kind, RBAC |
| **Docker** | [`docker.md`](docker.md) | Container lifecycle, Docker Compose v2, multi-arch builds (Buildx), logs, volumes, bridge networks, cleanup, security scanning |
| **Helm** | [`Helm.md`](Helm.md) | Package management, atomic deployments, idempotent install/upgrade, values overrides, chart linting, templating, diffing, OCI registries |
| **Terraform** | [`Terraform.md`](Terraform.md) | Infrastructure as Code (IaC), plan/apply, state inspection/manipulation, workspaces, imports, resource replacement, debug logging |
| **AWS CLI** | [`AWS-CLI.md`](AWS-CLI.md) | EKS kubeconfig, EC2 & security groups, EBS volume expansion, S3 sync, ECR login/push, SSM Session Manager, RDS snapshots, CloudWatch |
| **Git** | [`Git.md`](Git.md) | Advanced version control, interactive staging, rebasing, reflog disaster recovery, stashing, cherry-pick, submodules, remote management |
| **Ansible** | [`Ansible.md`](Ansible.md) | Configuration management, ad-hoc execution, check/diff modes, tags/limits, Ansible Vault secret encryption, inventory graphing |
| **HashiCorp Vault** | [`Vault.md`](Vault.md) | Operator unsealing, integrated Raft storage, KV-v2 versioned secrets, policies, Kubernetes pod authentication integration |
| **Argo CD** | [`ArgoCD.md`](ArgoCD.md) | GitOps continuous delivery, drift detection (`diff`), manual/automated sync, self-healing, rollbacks, multi-cluster management |
| **CI/CD Automation** | [`CI-CD.md`](CI-CD.md) | GitHub CLI (`gh`) Actions runs/secrets, Jenkins CLI (`jenkins-cli.jar`) & REST API triggers, GitLab CI (`glab`) |
| **Observability** | [`Observability.md`](Observability.md) | Prometheus API & PromQL formulas, Grafana API/dashboards, Loki LogCLI, OpenTelemetry Collector, Elasticsearch/Kibana health |
| **Networking & SSL** | [`Networking-and-SSL.md`](Networking-and-SSL.md) | OpenSSL certificate expiration/generation, Certbot/Let's Encrypt, Nginx reverse proxy test/reload, tcpdump sniffing, nmap |
| **Database CLI** | [`Database-CLI.md`](Database-CLI.md) | PostgreSQL (`psql`/`pg_dump`), MySQL (`mysqldump`), Redis (`redis-cli`), MongoDB (`mongosh`), query killing, connection triage |
| **Antigravity CLI** | [`Antigravity-cli.md`](Antigravity-cli.md) | AI agent CLI automation (`agy`), non-interactive print mode, permission auto-approvals, MCP management, plugins, slash commands |

[Back to Top ↑](#table-of-contents)

---

## Quick Navigation Guidelines

- **Cluster Emergency / Outage:** Jump straight to [`kubernetes.md`](kubernetes.md) or [`Linux.md`](Linux.md).
- **Deployment & Release:** Refer to [`Helm.md`](Helm.md), [`ArgoCD.md`](ArgoCD.md), or [`CI-CD.md`](CI-CD.md).
- **Infrastructure Provisioning:** Refer to [`Terraform.md`](Terraform.md) and [`AWS-CLI.md`](AWS-CLI.md).
- **Configuration & Secrets:** Refer to [`Ansible.md`](Ansible.md) and [`Vault.md`](Vault.md).
- **SSL Certificate Expiration:** Refer to [`Networking-and-SSL.md`](Networking-and-SSL.md).

[Back to Top ↑](#table-of-contents)
