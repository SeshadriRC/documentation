# Docker Commands for DevOps Engineers

A comprehensive reference for Docker container operations, image lifecycle management, networking, storage, and Docker Compose workflows.

---

## Table of Contents

- [1. Container Lifecycle & Execution](#1-container-lifecycle--execution)
- [2. Container Inspection, Troubleshooting & Logs](#2-container-inspection-troubleshooting--logs)
- [3. Executing Commands Inside Containers](#3-executing-commands-inside-containers)
- [4. File Copy & Artifact Transfer](#4-file-copy--artifact-transfer)
- [5. Image Management & Building](#5-image-management--building)
- [6. Multi-Architecture Builds (Docker Buildx)](#6-multi-architecture-builds-docker-buildx)
- [7. Volume & Persistent Storage Management](#7-volume--persistent-storage-management)
- [8. Network Management](#8-network-management)
- [9. Docker Compose (v2) Workflows](#9-docker-compose-v2-workflows)
- [10. System Maintenance & Cleanup](#10-system-maintenance--cleanup)
- [11. Security & Vulnerability Scanning](#11-security--vulnerability-scanning)

---

## 1. Container Lifecycle & Execution

```bash
# Run a container in detached mode with port mapping, restart policy, and environment variables
docker run -d \
  --name web-app \
  -p 8080:80 \
  --restart=unless-stopped \
  -e ENV=production \
  -e DB_HOST=postgres-db \
  nginx:alpine

# Run container with resource limits (CPU and Memory)
docker run -d \
  --name memory-capped-app \
  --cpus="1.5" \
  --memory="512m" \
  --memory-swap="1g" \
  nginx:alpine

# Run a temporary interactive container that cleans up after exit (--rm)
docker run -it --rm ubuntu:22.04 /bin/bash
docker run -it --rm busybox sh

# Start stopped containers
docker start web-app
docker start sonarqube-db sonarqube

# Gracefully stop containers (sends SIGTERM, then SIGKILL after grace period)
docker stop sonarqube sonarqube-db
docker stop -t 30 web-app    # Wait 30 seconds before SIGKILL

# Forcefully kill running container immediately (SIGKILL)
docker kill web-app

# Restart containers
docker restart web-app

# Pause and unpause container processes (using cgroups freezer)
docker pause web-app
docker unpause web-app

# Remove a stopped container
docker rm web-app

# Force remove a running container
docker rm -f web-app
```

[Back to Top ↑](#table-of-contents)

---

## 2. Container Inspection, Troubleshooting & Logs

```bash
# List all running containers
docker ps

# List all containers (running, stopped, exited)
docker ps -a

# View container resource utilization (CPU, Memory, Network I/O, Block I/O) in real-time
docker stats

# Get single snapshot of stats without continuous streaming
docker stats --no-stream

# View logs with follow (-f) and timestamps
docker logs -f --tail=100 --timestamps web-app

# View logs of a specific container (e.g., sonarqube)
docker logs -f sonarqube

# Inspect container metadata (JSON format: IP address, mounts, env vars, health check)
docker inspect web-app

# Extract specific JSON field using Go template (e.g., IP address)
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web-app

# Extract container restart count and health status
docker inspect -f '{{.State.Status}} (Health: {{.State.Health.Status}})' web-app

# View processes running inside the container
docker top web-app

# View changes made to container's filesystem since it started
docker diff web-app

# View port mappings for a container
docker port web-app
```

[Back to Top ↑](#table-of-contents)

---

## 3. Executing Commands Inside Containers

```bash
# Open an interactive Bash shell inside a running container
docker exec -it web-app /bin/bash

# Open shell in alpine / scratch containers lacking bash
docker exec -it web-app /bin/sh

# Execute command inside container as root user (useful for troubleshooting non-root containers)
docker exec -u 0 -it web-app whoami

# Run a one-off command without interactive terminal
docker exec web-app env
docker exec web-app nginx -t
```

[Back to Top ↑](#table-of-contents)

---

## 4. File Copy & Artifact Transfer

```bash
# Copy file from host machine into container
docker cp ./config.json web-app:/etc/app/config.json

# Copy file or directory from container to host machine
docker cp web-app:/var/log/nginx/error.log ./error.log
docker cp sonarqube:/opt/sonarqube/logs/ ./sonar-logs/
```

[Back to Top ↑](#table-of-contents)

---

## 5. Image Management & Building

```bash
# Build an image from Dockerfile in current directory
docker build -t my-org/app:v1.0.0 .

# Build with custom Dockerfile, build arguments, and target stage (multi-stage)
docker build \
  -f Dockerfile.prod \
  --build-arg NODE_ENV=production \
  --target release \
  -t my-org/app:v1.0.0 .

# Build without using cache
docker build --no-cache -t my-org/app:v1.0.0 .

# List all local images
docker images

# Filter images by reference or dangling state
docker images -f "dangling=true"

# Tag an image for a remote registry
docker tag my-org/app:v1.0.0 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-org/app:v1.0.0

# Log in to a container registry
docker login
docker login ghcr.io -u <username> -p <token>

# Push and pull images
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-org/app:v1.0.0
docker pull nginx:alpine

# Remove local image
docker rmi my-org/app:v1.0.0

# Inspect image layers and history
docker history --no-trunc my-org/app:v1.0.0

# Save image to tarball (air-gapped environments)
docker save -o app-v1.0.0.tar my-org/app:v1.0.0

# Load image from tarball
docker load -i app-v1.0.0.tar
```

[Back to Top ↑](#table-of-contents)

---

## 6. Multi-Architecture Builds (Docker Buildx)

```bash
# Create and activate a buildx builder instance
docker buildx create --name multiarch-builder --use
docker buildx inspect --bootstrap

# Build and push multi-architecture image (AMD64 & ARM64) to registry
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t my-org/app:v1.0.0 \
  --push .
```

[Back to Top ↑](#table-of-contents)

---

## 7. Volume & Persistent Storage Management

```bash
# List Docker volumes
docker volume ls

# Create a named volume
docker volume create app-data

# Inspect volume metadata and host mount location
docker volume inspect app-data

# Mount volume to container
docker run -d -v app-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=secret mysql:8

# Backup volume data to host tarball
docker run --rm \
  -v app-data:/volume-data \
  -v $(pwd):/backup \
  ubuntu tar -czvf /backup/app-data-backup.tar.gz -C /volume-data .

# Restore volume data from host tarball
docker run --rm \
  -v app-data:/volume-data \
  -v $(pwd):/backup \
  ubuntu tar -xzvf /backup/app-data-backup.tar.gz -C /volume-data

# Remove an unused volume
docker volume rm app-data

# Remove all unused local volumes
docker volume prune -f
```

[Back to Top ↑](#table-of-contents)

---

## 8. Network Management

```bash
# List all Docker networks
docker network ls

# Create a custom bridge network
docker network create --driver bridge app-network

# Create network with custom subnet
docker network create --subnet=172.28.0.0/16 custom-network

# Inspect network configuration and connected containers
docker network inspect app-network

# Connect a running container to a network
docker network connect app-network web-app

# Disconnect a container from a network
docker network disconnect app-network web-app

# Remove a network
docker network rm app-network
```

[Back to Top ↑](#table-of-contents)

---

## 9. Docker Compose (v2) Workflows

```bash
# Validate and render Compose file configuration
docker compose config

# Build or rebuild services
docker compose build
docker compose build --no-cache

# Pull service images
docker compose pull

# Start up all containers in background with existing volumes attached
docker compose up -d

# Start up and force rebuild images before starting
docker compose up -d --build

# Start specific containers only (e.g. starting sonarqube database and sonarqube service)
docker compose up -d sonarqube-db sonarqube

# List running compose services and status
docker compose ps
docker compose ps -a

# View logs of all services in real-time
docker compose logs -f

# View logs of a specific service container (e.g., sonarqube)
docker compose logs -f sonarqube

# Execute command inside a compose service
docker compose exec web-app sh
docker compose exec sonarqube ps aux

# Restart services
docker compose restart sonarqube

# Stop all containers
docker compose stop

# Stop and remove containers, networks created by compose up
docker compose down

# Stop and remove containers, networks, and persistent volumes
docker compose down -v

# Stop and remove containers, networks, volumes, and images built by compose
docker compose down -v --rmi all
```

[Back to Top ↑](#table-of-contents)

---

## 10. System Maintenance & Cleanup

```bash
# View Docker disk space usage across containers, images, volumes, and build cache
docker system df
docker system df -v

# Remove all stopped containers
docker container prune -f

# Remove all unused (dangling) images
docker image prune -f

# Remove ALL unused images (not just dangling ones)
docker image prune -a -f

# Remove unused build cache
docker builder prune -a -f

# Complete cleanup: remove stopped containers, unused networks, dangling images, and build cache
docker system prune -f

# Deep cleanup: remove ALL unused containers, networks, images, and volumes
docker system prune -a --volumes -f
```

[Back to Top ↑](#table-of-contents)

---

## 11. Security & Vulnerability Scanning

```bash
# Scan container image for vulnerabilities using Trivy
trivy image my-org/app:v1.0.0

# Scan image and exit with non-zero code on HIGH / CRITICAL vulnerabilities (CI/CD gate)
trivy image --severity HIGH,CRITICAL --exit-code 1 my-org/app:v1.0.0

# Check container image configuration for security best practices (e.g. running as non-root)
docker inspect --format='{{.Config.User}}' my-org/app:v1.0.0
```

[Back to Top ↑](#table-of-contents)
