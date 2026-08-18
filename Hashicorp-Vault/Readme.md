
- write the vault vaules, but don't apply. after applying storage class, you can install below vaules.

```bash
helm install vault hashicorp/vault -n vault -f vault-values.yml
```

**vault-values.yml**

```yaml
server:
  ha:
    enabled: true
    replicas: 3

    raft:
      enabled: true
      config: |
        ui = true

        listener "tcp" {
          address         = "0.0.0.0:8200"
          cluster_address = "0.0.0.0:8201"
          tls_disable     = 1
        }

        storage "raft" {
          path = "/vault/data"

          retry_join {
            leader_api_addr = "http://vault-0.vault-internal:8200"
          }

          retry_join {
            leader_api_addr = "http://vault-1.vault-internal:8200"
          }

          retry_join {
            leader_api_addr = "http://vault-2.vault-internal:8200"
          }
        }

        service_registration "kubernetes" {}

  dataStorage:
    enabled: true
    size: 10Gi
    storageClass: "ebs-sc"   # or ebs-sc

  extraEnvironmentVars:
    VAULT_LOG_LEVEL: "debug"

injector:
  enabled: true

ui:
  enabled: true
```

- write the sc yaml and apply it.

**sc.yaml**

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc

provisioner: ebs.csi.aws.com

parameters:
  type: gp3
  fsType: ext4

reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```

- After apply, we can see pods are not running. so initially it will bee in sealed state. we need to unseal the pods

<img width="1201" height="515" alt="image" src="https://github.com/user-attachments/assets/fa187b1c-20f4-4b76-9077-15b7d496575b" />

- Before that create a loadbalancer service to access vault ui. apply it.

**svc.yml**

```yaml

apiVersion: v1
kind: Service
metadata:
  name: vault
  namespace: vault
spec:
  type: LoadBalancer
  ports:
    - port: 8200
      targetPort: 8200
  selector:
    app.kubernetes.io/name: vault

```

- Run the below command to unseal the pods. totally 6 tokens will get generated. root token to access the cluster. so its a type of shamir sealed

```bash
kubectl exec -n vault -it vault-0 --vault operator init
```

<img width="1203" height="603" alt="image" src="https://github.com/user-attachments/assets/3f9dde95-2da8-4d56-b2ca-ba3d92a96b68" />

- you need to use each token and see whether its getting unsealed or not. now vault-0 is unsealed, same follow for other 2 pods

```bash
kubectl exec -n vault -it vault-0 --vault operator unseal <token>
```

<img width="649" height="311" alt="image" src="https://github.com/user-attachments/assets/f8f708ba-2b1e-4a07-a1b8-4295d0fdf62e" />

<img width="970" height="290" alt="image" src="https://github.com/user-attachments/assets/79a1cca5-f929-4030-9007-c8acaea95083" />

- Now all pods are up and running fine.

<img width="920" height="169" alt="image" src="https://github.com/user-attachments/assets/0ea251af-52d2-4993-9fc0-716ea9365c7e" />

- Login to the vault using root token.

```bash
kubectl exec -n vault -it vault-0 --vault login <token>
```

- To access the vault ui, take the load balancer service name and paste in the browser with port `8200`

<img width="1291" height="313" alt="image" src="https://github.com/user-attachments/assets/8e8221b6-2d5e-4ed4-945d-dddd6f5b0b85" />

- Paste the root token and sign in.

<img width="1395" height="546" alt="image" src="https://github.com/user-attachments/assets/b635b243-7f5e-424b-9938-3c6f5d50967d" />

- In secret engines only we need to store the creds.

<img width="1458" height="689" alt="image" src="https://github.com/user-attachments/assets/c687aebd-7d0b-4ec9-a049-71a1fab9663b" />

### Enable kubernetes authentication

<img width="1162" height="466" alt="image" src="https://github.com/user-attachments/assets/c60d4dad-a2a9-4a84-b3ac-4e17980bf228" />


- Enable the kubernetes authentication

```bash
kubectl exec -n vault -it vault-0 -- vault auth enable kubernetes
```

- Create a service account for App pods

```bash
kubectl create ns webapps
kubectl create serviceaccount vault-auth -n webapps 
```

- Extract required info and execute in the Server where EKS is set.

```bash
SERVICE_ACCOUNT_NAME=vault-auth
NAMESPACE=webapps

# JWT Token
TOKEN_REVIEW_JWT=$(kubectl get secret $(kubectl get serviceaccount
$SERVICE_ACCOUNT_NAME -n $NAMESPACE -o jsonpath="{.secrets[0].name}") -n
$NAMESPACE -o jsonpath="{.data.token}" | base64 --decode)

# Kubernetes API Host
KUBE_HOST=$(kubectl config view --raw -o=jsonpath='{.clusters[0].cluster.server}')

# Kubernetes CA Cert
KUBE_CA_CERT=$(kubectl get secret $(kubectl get serviceaccount $SERVICE_ACCOUNT_NAME
-n $NAMESPACE -o jsonpath="{.secrets[0].name}") -n $NAMESPACE -o
jsonpath="{.data['ca.crt']}" | base64 --decode)
```

- Execute below command inside the vault

```bash
kubectl exec -n vault -it vault-0 -- vault write auth/kubernetes/config \
token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
kubernetes_host="$KUBE_HOST" \
kubernetes_ca_cert="$KUBE_CA_CERT"
```

### Create a vault policy

- create a file `myapp-policy.hcl`

```bash
# Access to read/write secret data

path "secret/data/mysql" {
  capabilities = ["create", "update", "read", "delete", "list"]
}

path "secret/data/frontend" {
  capabilities = ["create", "update", "read", "delete", "list"]
}

# Access to list secrets under the path
path "secret/metadata/mysql" {
  capabilities = ["list"]
}

path "secret/metadata/frontend" {
  capabilities = ["list"]
}

```

- upload and apply

```bash
kubectl cp myapp-policy.hcl vault/vault-0:/tmp/myapp-policy.hcl
kubectl exec -n vault -it vault-0 -- vault policy write myapp-policy /tmp/myapp-policy.hcl
```

### Create a Role in vault to Map Pod to Policy


```bash
kubectl exec -n vault -it vault-0 -- vault write auth/kubernetes/role/vault-role \
  bound_service_account_names=vault-auth \
  bound_service_account_namespaces="webapps" \
  policies=myapp-policy \
  ttl=24h
```

### Store secrets in vault

```bash
kubectl exec -n vault -it vault-0 -- vault secrets enable -path=secret -version=2 kv

## Store mysql secrets
kubectl exec -n vault -it vault-0 -- \
  vault kv put secret/mysql \
  MYSQL_DATABASE=bankappdb \
  MYSQL_ROOT_PASSWORD='Test@123'

## Store frontend secrets
kubectl exec -n vault -it vault-0 -- \
  vault kv put secret/frontend \
  MYSQL_ROOT_PASSWORD='Test@123'
```

- In vault UI its updated

<img width="1347" height="562" alt="image" src="https://github.com/user-attachments/assets/92902654-3e27-4773-85a9-e8db6da69acb" />

- we can create secret in UI as well

<img width="1415" height="509" alt="image" src="https://github.com/user-attachments/assets/679a84a1-8f35-482a-990e-6ce7a44de1e3" />

### Use the secrets in deployment

- We need to mention annotations, example below

```yaml
annotations:
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/role: "vault-role"
vault.hashicorp.com/agent-inject-secret-MYSQL_ROOT_PASSWORD: "secret/mysql"

vault.hashicorp.com/agent-inject-template-MYSQL_ROOT_PASSWORD: |
{{-with secret "secret/mysql" -}}
export MYSQL_ROOT_PASSWORD="{{.Data.data.MYSQL ROOT PASSWORD }}"
{{-end }}
```

- Below is the application yml

**manifest.yml**
```yml
---
# Create Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: webapps

---
# Service Account for Vault Authentication
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: webapps

---
# StorageClass
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  fsType: ext4
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer

---
# PersistentVolumeClaim for MySQL
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
  namespace: webapps
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: ebs-sc

---
# MySQL Deployment with Vault Injection
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: webapps
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "vault-role"

        vault.hashicorp.com/agent-inject-secret-MYSQL_ROOT_PASSWORD: "secret/data/mysql"
        vault.hashicorp.com/agent-inject-template-MYSQL_ROOT_PASSWORD: |
          {{- with secret "secret/data/mysql" -}}
          export MYSQL_ROOT_PASSWORD="{{ .Data.data.MYSQL_ROOT_PASSWORD }}"
          {{- end }}

        vault.hashicorp.com/agent-inject-secret-MYSQL_DATABASE: "secret/data/mysql"
        vault.hashicorp.com/agent-inject-template-MYSQL_DATABASE: |
          {{- with secret "secret/data/mysql" -}}
          export MYSQL_DATABASE="{{ .Data.data.MYSQL_DATABASE }}"
          {{- end }}

    spec:
      serviceAccountName: vault-auth

      containers:
        - name: mysql
          image: mysql:8

          command:
            - /bin/sh
            - -c

          args:
            - |
              while [ ! -f /vault/secrets/MYSQL_ROOT_PASSWORD ]; do
                echo "Waiting for Vault secrets..."
                sleep 2
              done

              source /vault/secrets/MYSQL_ROOT_PASSWORD
              source /vault/secrets/MYSQL_DATABASE

              export MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
              export MYSQL_DATABASE=$MYSQL_DATABASE

              exec docker-entrypoint.sh mysqld

          ports:
            - containerPort: 3306
              name: mysql

          volumeMounts:
            - name: mysql-data
              mountPath: /var/lib/mysql

          livenessProbe:
            exec:
              command:
                - mysqladmin
                - ping
                - -h
                - 127.0.0.1
            initialDelaySeconds: 30
            periodSeconds: 10
            failureThreshold: 5

          readinessProbe:
            exec:
              command:
                - mysqladmin
                - ping
                - -h
                - 127.0.0.1
            initialDelaySeconds: 30
            periodSeconds: 10
            failureThreshold: 5

      volumes:
        - name: mysql-data
          persistentVolumeClaim:
            claimName: mysql-pvc

---
# MySQL Service
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: webapps
spec:
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306

---
# BankApp Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bankapp
  namespace: webapps
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bankapp

  template:
    metadata:
      labels:
        app: bankapp
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "vault-role"

        vault.hashicorp.com/agent-inject-secret-SPRING_DATASOURCE_PASSWORD: "secret/data/frontend"

        vault.hashicorp.com/agent-inject-template-SPRING_DATASOURCE_PASSWORD: |
          {{- with secret "secret/data/frontend" -}}
          export SPRING_DATASOURCE_PASSWORD="{{ .Data.data.MYSQL_ROOT_PASSWORD }}"
          {{- end }}

    spec:
      serviceAccountName: vault-auth

      containers:
        - name: bankapp
          image: adijaiswal/bankapp:v20

          ports:
            - containerPort: 8080

          env:
            - name: SPRING_DATASOURCE_URL
              value: "jdbc:mysql://mysql-service:3306/bankappdb?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"

            - name: SPRING_DATASOURCE_USERNAME
              value: "root"

          livenessProbe:
            httpGet:
              path: /login
              port: 8080
            initialDelaySeconds: 30
            timeoutSeconds: 5
            periodSeconds: 10
            failureThreshold: 5

          readinessProbe:
            httpGet:
              path: /login
              port: 8080
            initialDelaySeconds: 30
            timeoutSeconds: 5
            periodSeconds: 10
            failureThreshold: 5

---
# BankApp Service
apiVersion: v1
kind: Service
metadata:
  name: bankapp-service
  namespace: webapps

spec:
  type: LoadBalancer
  selector:
    app: bankapp

  ports:
    - port: 80
      targetPort: 8080
```

```
kubectl apply -f manifest.yml -n webapps
```

- Check the pods and its logs

<img width="1269" height="477" alt="image" src="https://github.com/user-attachments/assets/d5493faa-1fbc-4640-9da7-10ce374dec9e" />

- Now access the app using service load balancer url.

<img width="1453" height="639" alt="image" src="https://github.com/user-attachments/assets/d0c625a0-b978-4b8c-a7b7-0b226128385e" />
