
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
