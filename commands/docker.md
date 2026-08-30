```
# 1. Stop current containers
docker compose down

# 2. Start up with the existing volume attached
docker compose up -d

# 3. Logs of docker compose
docker compose logs -f sonarqube --> sonarqube is a container name

# 4. Start specific containers
docker compose up -d sonarqube-db sonarqube   --> we are starting 2 containers here
```
