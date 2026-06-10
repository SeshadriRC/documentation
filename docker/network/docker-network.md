# Docker Network Isolation Demo (Tamil)

 **Docker Networking** video on the **Simply Byte** YouTube channel.

In this demo, we clearly show:

* How containers communicate in the **default bridge network**
* How **network isolation** works using **custom Docker networks**
* Why containers in **different networks cannot talk to each other**


- Docker container will be running in separate namespace and host will be in separate namespace. so to address this issue we will be creating virtual eth, so that both container and host can able to communicate.

<img width="903" height="600" alt="image" src="https://github.com/user-attachments/assets/8f326800-96b3-4435-8352-645b7ddc3647" />

<img width="747" height="585" alt="image" src="https://github.com/user-attachments/assets/6d15e71f-2970-4734-a03f-b145e074633e" />

- If in case we ran another container, then for that also we need to create a veth

<img width="667" height="546" alt="image" src="https://github.com/user-attachments/assets/81a98637-2e7f-43cf-8d84-ee94eb2f177d" />


- So instead of that we can create a bridge. Bridge is almost same like wifi, where wifi will connect all the devices in the same network. so another name of bridge is docker0 , we can call it as `docker0` bridge.
- Same like wifi, where ip's will get assigned to each devices using router. same like that from bridge network, ip's will get assigned  to each containers.

<img width="1018" height="563" alt="image" src="https://github.com/user-attachments/assets/a212702b-c9b2-4963-9ed3-788bd2757c0e" />

- Below is the range of bridge networking

<img width="832" height="572" alt="image" src="https://github.com/user-attachments/assets/269b0fef-7ec4-4a01-8300-1124342d7821" />

- facebook and insta is a different product, both should not get communication. so to address this we will be creating a separate network.

<img width="783" height="546" alt="image" src="https://github.com/user-attachments/assets/d1109a4e-9abe-4d7a-814d-fbdb465e421b" />

- containers got isolated

<img width="752" height="562" alt="image" src="https://github.com/user-attachments/assets/3782cabd-5088-4b5c-8f40-4f81857e338e" />


### Three types of network

**1. Bridge -> It is a default network**

- This is the default bridge type, please refer above for the detailed explanation.
- In most cases, the bridge network is used when deploying applications in Docker.

<img width="1062" height="535" alt="image" src="https://github.com/user-attachments/assets/2ccaa87c-fdce-4214-b6be-196688a0b293" />

**2. Host**

- Directly we can access from the host.
- But here the drawback is port conflict, support instagram runs on 8080, and facebook try to use 8080 then there will be a port conflict.
- In Bridge network it uses a port mapping.

<img width="982" height="582" alt="image" src="https://github.com/user-attachments/assets/91311af6-e3ee-424b-9012-919c8c8ba220" />


**3. None**

- No one can able to connect this container. And container cannot access the outside world. This will be used whenever we want to do testing and no connection from outside.
<img width="827" height="590" alt="image" src="https://github.com/user-attachments/assets/78b45919-b3ac-4191-8e0b-1f5180cb8dcb" />

---

## 📌 Prerequisites

* Docker installed
* Basic Docker knowledge
---

## 🐳 Docker Images Used

The following Docker images are used in this demo:

### 1️⃣ MySQL Database Image

**Image:**
`mysql:8`

- Official MySQL image from Docker Hub
- Used to demonstrate database container
- Environment variables used:
    - `MYSQL_ROOT_PASSWORD`
    - `MYSQL_DATABASE`

---

### 2️⃣ Backend Application Image

**Image:**
`simplybyte/simplybyte-backend:1.0`

- Custom Spring Boot backend image
- Exposes port **8090**
- Connects to MySQL using `SPRING_DATASOURCE_URL`
---

## 🔹 Scenario 1: Default Bridge Network

First, we run both containers in the **default bridge network**.

### Run MySQL Container

```bash
docker run -d \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=simplybyte \
  -e MYSQL_DATABASE=simplybyte \
  mysql:8
```

### Run Backend Container

```bash
`docker inspect mysql-db` and check the IPAddress
```

```bash
docker run -d -p 8090:8090 \
  --name simplybyte_backend \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://172.18.0.2:3306/simplybyte \
  simplybyte/simplybyte-backend:1.0
```

```bash
# by seeing the logs of spring boot container, we can see it got connected with DB
docker logs <springboot-container>
```

<img width="1917" height="712" alt="image" src="https://github.com/user-attachments/assets/5f1c4e22-a817-4db0-a96b-bd08b2f4d0b4" />



✅ Both containers are in the **default bridge network**, so they can communicate using IP address.

---

## 🔹 Scenario 2: Create Custom Docker Networks

Now we create **two separate Docker networks** to demonstrate isolation.

```bash
docker network create A
docker network create B
```

Check available networks:

```bash
docker network ls
```

---

## 🔹 Scenario 3: Containers in Different Networks (Isolation Demo)

### Run MySQL in Network A

```bash
docker run -d \
  --name mysql-db \
  --network A \
  -e MYSQL_ROOT_PASSWORD=simplybyte \
  -e MYSQL_DATABASE=simplybyte \
  mysql:8
```

### Run Backend in Network B

```bash
docker run -d -p 8090:8090 \
  --name simplybyte_backend \
  --network B \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://172.18.0.2:3306/simplybyte \
  simplybyte/simplybyte-backend:1.0
```

❌ Backend **cannot connect** to MySQL because:

* MySQL is in **Network A**
* Backend is in **Network B** , so both are in different subnets
* Docker networks are **isolated by default**

👉 This proves **Docker network isolation**.

---

## 🔹 Scenario 4: Both Containers in Same Network

Now we connect **both containers to Network A**.

```bash
docker run -d \
  --name mysql-db \
  --network A \
  -e MYSQL_ROOT_PASSWORD=simplybyte \
  -e MYSQL_DATABASE=simplybyte \
  mysql:8
```

```bash
docker run -d -p 8090:8090 \
  --name simplybyte_backend \
  --network A \
  -e SPRING_DATASOURCE_URL=jdbc:mysql:<container-name>:3306/simplybyte \
  simplybyte/simplybyte-backend:1.0
```

✅ Now the backend can successfully communicate with MySQL.

---

## 🔍 Useful Docker Commands Used

### Inspect Docker Network

```bash
docker network inspect A
docker network inspect B
```

### Inspect Container Details

```bash
docker inspect mysql-db
docker inspect simplybyte_backend
```

### View Container Logs

```bash
docker logs mysql-db
docker logs simplybyte_backend
```

### Follow Logs in Real-Time

```bash
docker logs -f simplybyte_backend
```

---

## 🎯 Key Takeaways

* Containers in **same network** can communicate
* Containers in **different networks are isolated**
* Docker bridge networks provide **security and separation**
* Network isolation is critical in **real-world microservices**

---

## 📺 YouTube Channel

👉 **Simply Byte** – DevOps & Cloud Explained in Tamil

If you found this helpful, please **Like, Share & Subscribe** ❤️

Happy Learning 🚀
