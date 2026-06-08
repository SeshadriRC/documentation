<img width="1115" height="383" alt="image" src="https://github.com/user-attachments/assets/9f29b670-fb5c-4724-b684-96d677bbd5d0" />- Statefulset is same like Deployment, howerver it has some difference.
- Deployment has random different pod names. Even if we deleted one pod, then it will create a pod with different name
<img width="1147" height="622" alt="image" src="https://github.com/user-attachments/assets/1d06c334-965a-4bbc-b6aa-ff3840dbb834" />

- Statefulset have consistent name, even if we delete, it will create a pod with same name.
<img width="1133" height="612" alt="image" src="https://github.com/user-attachments/assets/946a4328-0e2d-40d7-9f43-97113b685511" />

## Difference between Stateful app and Stateless app

- Frontend and backend will not store any data, so this is called stateless application.

<img width="1115" height="383" alt="image" src="https://github.com/user-attachments/assets/877b2f3e-8fd3-4ed4-9168-39062f276e44" />

- Database only used to store all the data, this is called stateful application.

<img width="821" height="420" alt="image" src="https://github.com/user-attachments/assets/5d3776d5-a6cd-4b6f-9dd9-7ec25c69d9b8" />

- If incase there is a heavy load in backend app, then we will scaleup one additional pod.

<img width="1183" height="548" alt="image" src="https://github.com/user-attachments/assets/d4b1d4f6-9fd6-4b37-956a-fed71b88f2db" />

- Same like that, if there is a heavy load on database side, then we will scaleup additional DB pod.

<img width="1126" height="513" alt="image" src="https://github.com/user-attachments/assets/fe824b76-9a48-4c71-8b5a-2316f4f78456" />

- Now user is created a new creds in the login page and DB pod 1 processed the request and data is stored in DB pod 1.

<img width="1127" height="501" alt="image" src="https://github.com/user-attachments/assets/d75f0b30-d74f-4678-bcaf-cdf55b5aad6d" />

- Now user is trying to loggin using the creds which they created, but this time traffic is forwareded to DB pod 2, but those creds not stored in DB pod 2 . so it throws a error stating invalid username and password.
- So there is a problem of Data Inconsistency

<img width="782" height="418" alt="image" src="https://github.com/user-attachments/assets/5d5f6ffe-9d2e-44bb-8ddc-f6674fbe821c" />

- To address this issue, we need to use Master/slave method, where Master DB is used for write operation and other 2 DB's will be used for Read purpose

<img width="1041" height="497" alt="image" src="https://github.com/user-attachments/assets/193904d7-7f88-4826-809c-b697cbda2c74" />

- Once the data is received into the master, then slave DB will be receiving those latest details from the master, then data will get synced.

<img width="995" height="592" alt="image" src="https://github.com/user-attachments/assets/863abc58-f328-49ed-ac6c-60400f3cf67c" />

- So for every pod in the statefulset, volume will be there. Every volume has the name of the pod

<img width="1053" height="647" alt="image" src="https://github.com/user-attachments/assets/de54a0dc-b25a-403a-be1c-cbe016dcf95d" />

- Statefulset will assign the DNS name to every pod. even if pod got deleted and created again, IP will change, but DNS name won't change

- So we will be giving the Master pod DNS name to the backend server, so that it can be used for write operation.

<img width="1122" height="653" alt="image" src="https://github.com/user-attachments/assets/ea49dc8f-6688-446e-8f19-ecac82338ced" />

- Statefulset handles the pod creation and deletion carefully, for eg: if we deployed the new statefulset, first it will create one pod, once that created then after that only it will create another.

<img width="912" height="506" alt="image" src="https://github.com/user-attachments/assets/a715bd6d-ee7e-4002-85ee-abf540c8a13b" />

- For deletion also it will follow the same process. (mysql-2, mysql-1 ....)


**Disadvantages of Statefulset**

- We need to program the Datasync manually. for every pod we need to tell you are master and you are slave.
- If incase we scaleup another one new pod, then we need to tell you are slave and this is your master.
