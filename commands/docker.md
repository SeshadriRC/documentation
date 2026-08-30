```bash
# Stop all containers
docker compose down

# Start up with the existing volume attached
docker compose up -d

# Logs of docker compose
docker compose logs -f sonarqube --> sonarqube is a container name

# Start specific containers
docker compose up -d sonarqube-db sonarqube   --> we are starting 2 containers here

# Stop specific containers
docker stop sonarqube sonarqube-db
```
