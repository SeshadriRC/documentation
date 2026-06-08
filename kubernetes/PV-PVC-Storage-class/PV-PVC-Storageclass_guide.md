## Persistent Volume

- spring boot application stores a log, its very important. since we know that pod is ephemeral, whenever pod got deleted then those logs also will get deleted.
- To address this there is a kubernetes resource called Persistent Volumt- PV
- Assume PV is like a pendrive, we will mount pendrive to the computer. same like that we will mount PV to a POD
<img width="1062" height="456" alt="image" src="https://github.com/user-attachments/assets/086d78ab-8466-4a97-b61c-5b130b3f2a2e" />

- so now logs will be stored in a PV , even if pod deleted PV will have the logs
- As per application requirement, we will mention the PV size

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-persistent-volume
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce           # pod can read and write
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/my-pv        #  Stores data on the node at /data/my-pv.
```

**Access Modes types**

- ReadWriteOnce
- ReadOnlyMany
- ReadWriteMany
- ReadWriteOncePod

**Static provisioning**

- Above we are applying the PV manually, this process is called static provisioning

## PersistentVolumeClaim

- We can mount the PV to the Pod using PVC.

<img width="1137" height="552" alt="image" src="https://github.com/user-attachments/assets/3d9a93c1-0a19-4f0e-a18e-225bae6375ab" />


```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-persistent-volume-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```
