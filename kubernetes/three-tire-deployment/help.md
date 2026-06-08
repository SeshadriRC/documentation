# Three Tier Application Deployment – Kubernetes (Local)

<img width="1060" height="423" alt="image" src="https://github.com/user-attachments/assets/450d4bda-71c4-4f6d-b848-a0973367fd8b" />

- frontend depends on backend, then backend depends on database

## Architecture
- MySQL Database (StatefulSet + Headless Service)
- Spring Boot java Backend (Deployment + NodePort)
- Frontend UI (Deployment + NodePort)

---

## Deployment Order
1. Database
2. Backend
3. Frontend

---

## Docker Images Used

The following container images are used in this three-tier Kubernetes deployment.

### Database (MySQL)

- Image: `mysql:8.0`
- Used in: `database/stateful-set.yml`
- Purpose: Stores application data using StatefulSet for stable identity and storage

---

### Backend (Spring Boot Application)

- Image: `simplybyte/simplybyte-backend:1.0`
- Used in: `backend/deployment.yml`
- Purpose: Handles business logic and communicates with MySQL database

---

### Frontend (UI Application)

- Image: `simplybyte/simplybyte-ui:latest`
- Used in: `frontend/deployment.yml`
- Purpose: Provides user interface and communicates with backend service
---


## Step 1: Database Deployment

    cd database
    kubectl apply -f secret.yml
    kubectl apply -f headless-service.yml
    kubectl apply -f stateful-set.yml

Verify:

    kubectl get pods


<img width="1907" height="523" alt="image" src="https://github.com/user-attachments/assets/b3a73006-4014-4567-9595-f5a2a1d7eea9" />

---

## Step 2: Verify MySQL

    kubectl exec -it simplybyte-mysql-0 -- sh
    mysql -u root -p

Password:

    simplybyte

Check:

    SHOW DATABASES;

To Select Database:

    USE simplybyte;

To view all tables:
    
    SHOW TABLES;

---

## MySQL DNS Used by Backend

    simplybyte-mysql-0.mysql                   # simplybyte-mysql-0 --> pod name, mysql - headless service name

JDBC URL:

    jdbc:mysql://simplybyte-mysql-0.mysql:3306/simplybyte             # simplybyte - name of the database

## MySQL JDBC URL Explanation

The backend Spring Boot application connects to MySQL using the following JDBC URL:

    jdbc:mysql://simplybyte-mysql-0.mysql:3306/simplybyte

Let’s break this down part by part.

---

### `jdbc:mysql://`

- `jdbc`  
  Java Database Connectivity API used by Java/Spring Boot applications.

- `mysql`  
  Specifies that the database type is **MySQL**.

---

### `simplybyte-mysql-0.mysql`

This is the **Kubernetes DNS name** of the MySQL pod.

- `simplybyte-mysql-0`  
  First pod created by the MySQL StatefulSet.

- `mysql`  
  Headless Service name.

Because this is a StatefulSet with a Headless Service, Kubernetes provides
**stable DNS names** for each pod.

Kubernetes automatically resolves this internally, so no IP address is required.

| Part | Meaning |
|----|----|
| jdbc | Java database connection |
| mysql | Database type |
| simplybyte-mysql-0 | StatefulSet pod name |
| mysql | Headless service name |
| 3306 | MySQL port |
| simplybyte | Database name |

This approach is **recommended for databases in Kubernetes**.


---

## Step 3: Backend Deployment

    cd ../backend
    kubectl apply -f deployment.yml
    kubectl apply -f service.yml


<img width="1410" height="562" alt="image" src="https://github.com/user-attachments/assets/698a3be3-25e8-4e1b-817e-eb6d5864ddfb" />

To Access Backend through Node Port:

    http://localhost:30080
    
<img width="922" height="331" alt="image" src="https://github.com/user-attachments/assets/e9ef2370-7e3a-4d48-90e9-42b7bfba26c0" />


To Check if the service is alive:

    http://localhost:30080/health
<img width="862" height="186" alt="image" src="https://github.com/user-attachments/assets/1ccf4cef-2c67-40d1-a7c0-27ee35cb9ecc" />


Check logs:

    kubectl logs <backend-pod-name>

<img width="1917" height="280" alt="image" src="https://github.com/user-attachments/assets/413b5910-c669-4de4-a1e5-f5a6fd8c5ce2" />

- we can see added connection, so it sucessfully established connection with mysql
- Also after deploying backend, automatically table is created by springboot, so this confirms it established connection successfully.

<img width="462" height="281" alt="image" src="https://github.com/user-attachments/assets/aed88fe2-b5b8-4e53-aa65-0bb9c892c78b" />

---

## Step 4: Frontend Deployment

    cd ../frontend
    kubectl apply -f config.yml
    kubectl apply -f deployment.yml
    kubectl apply -f service-nodeport.yml

---

## Step 5: Verify Frontend ConfigMap Mount

    kubectl exec -it <frontend-pod-name> -- sh

    cat /usr/share/nginx/html/config.json

---

## Access Application

Frontend URL:

    http://localhost:30081

---

## Kubernetes Concepts Covered
- StatefulSet
- Headless Service
- ConfigMap
- Secret
- NodePort
- Pod DNS
- Volume Mounts
- kubectl exec
- kubectl logs
