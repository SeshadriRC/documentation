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
  name: my-ebs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: aws-ebs-sc
  resources:
    requests:
      storage: 10Gi
```

- So once PVC got created, it will find the PV and it will bind to it. This process is called volume binding.
- Now we need to bind the PVC to a pod, so automatically PV will get binded.
- Suppose assume we created a PVC to claim 1GB, but available volume is of 2GB. It will bind in this case, however 2GB is higher than the requested one.

  <img width="882" height="360" alt="image" src="https://github.com/user-attachments/assets/4d2905b9-3637-4039-92b1-413d9a451a46" />

- Suppose assume we created a PVC to claim 1GB, but volume available is 500 MB. Then nothing will happen PV will not get binded

 <img width="1083" height="443" alt="image" src="https://github.com/user-attachments/assets/de0dc6ac-3249-4342-99d7-7342c2f3d463" />

- So to solve this problem kubernetes has another resource which is called StorageClass. PV will get created automatically  by the StorageClass as per the requirement by PVC, This is called Dynamic Provisioning.

<img width="1077" height="501" alt="image" src="https://github.com/user-attachments/assets/894031af-3f63-48ee-b814-225031adeaa5" />

- While creating Stroage class , we need to tell whether PV should created in AWS or Host. then it will take care

```yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs-sc
provisioner: kubernetes.io/ebs.csi.aws.com
parameters:
  type: gp3
reclaimPolicy: Delete                  # It will delete the PV if we delete PVC
# reclaimPolicy: Retain                # It will retain the PV if we delete PVC 
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

**What is Reclaim Policy**

- Assume PV and PVC got bounded. if we delete the PVC then it should delete PV or not, thats decided by reclaim policy

<img width="930" height="426" alt="image" src="https://github.com/user-attachments/assets/37417382-3c5c-400d-a198-dfdda03b5e7d" />
