- Configmap and secrets are used to pass environment variables to the application.
- What is Environment varible --> passing the value dynamically during the runtime of the application.

<img width="1136" height="555" alt="image" src="https://github.com/user-attachments/assets/bbb0c822-f2e0-4a8d-b614-a2a938995e87" />

- Java springboot needs to connect to the database1, so we asked developer to hardcode the DB_URL, DB_USERNAME, DB_PASSWORD in the application. then developer will modify it.
- Now again we are telling database1 not required, need to use database2. so kindly edit the values again. so it will be very difficult for developers and its not a good practices.

<img width="1082" height="548" alt="image" src="https://github.com/user-attachments/assets/931d83d0-641c-4d46-8f1f-c012a973ec63" />

- Instead of doing like this , we are telling developers that. in future we will passing those values. you just mention the variables.

<img width="1082" height="623" alt="image" src="https://github.com/user-attachments/assets/f6f184c6-f8b6-4371-8220-a1dd9e5b426b" />

<img width="1027" height="442" alt="image" src="https://github.com/user-attachments/assets/0228e882-bc7f-44be-bb26-aca6e10d7321" />

- so same like this way, we are passing environment variables to the pod which is running the application using configmaps and secrets. Then pod will pass those values to the application.

- Here we are passing env variable one by one in configmap

<img width="1162" height="475" alt="image" src="https://github.com/user-attachments/assets/68b994fb-80c4-4a73-9b2b-09bc959a3aa0" />

- What if we have 50+ env variables, then we need to use configmap as a file

```bash
kubectl create configmap simplybyte-configmap-from-file --from-file=application.yml
```
