**Create the PVC**

[yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/PV-PVC-Storage-class/PVC.yml)

<img width="1040" height="177" alt="image" src="https://github.com/user-attachments/assets/76472c6d-11fb-4cd6-b416-e254ea2c650a" />

- Status is pending because no PV is available
- Now create a 1G PV

[yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/PV-PVC-Storage-class/PV-1G.yml)

- it got bounded

<img width="1356" height="197" alt="image" src="https://github.com/user-attachments/assets/9b0f2719-7e79-4409-837e-9c0dd2cf1aa7" />

- Now delete the PVC and check PV deleted or not as we given Reclaimpolicy as Delete.

<img width="1473" height="180" alt="image" src="https://github.com/user-attachments/assets/da778c29-af41-42e1-a944-2a677b485f5f" />

- Due to below reason it not failed, but no problem we can ignore . so its better to create hostpath at /tmp location for testing purposes

<img width="1473" height="180" alt="image" src="https://github.com/user-attachments/assets/cbf62f93-ed04-4bdf-b76e-875634048b97" />

- Now we created 1Gi PVC and 500 Mi PV. so its in pending status, as required PV not available

<img width="1327" height="172" alt="image" src="https://github.com/user-attachments/assets/c3c360f2-6779-4b92-8f75-176f3972e2cd" />

- Now create the storage class. [yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/PV-PVC-Storage-class/storageclass.yml)

<img width="1291" height="540" alt="image" src="https://github.com/user-attachments/assets/c656d60a-9764-4bf8-9b5b-4ead17347aa1" />

- Now apply the pvc, make sure storage class name is mentioned in the PVC yaml.
- We can see it got bounded now.

<img width="1860" height="307" alt="image" src="https://github.com/user-attachments/assets/d5a3b9f0-5e3c-45e7-b3f8-8d4a78e55560" />

- Deleted PVC, then automatically it deleted PV.
- In realtime, we won't be creating PV in nodes, instead we need to create in aws distribuuted storage like EFS. Because POD will able to access the PV only on the particular node, if pod landedd on differnet node, then it can't use the PV.

