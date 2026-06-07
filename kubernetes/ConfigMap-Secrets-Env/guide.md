- Configmap and secrets are used to pass environment variables to the application.
- What is Environment varible --> passing the value dynamically during the runtime of the application.

<img width="1136" height="555" alt="image" src="https://github.com/user-attachments/assets/bbb0c822-f2e0-4a8d-b614-a2a938995e87" />

- Java springboot needs to connect to the database1, so we asked developer to hardcode the DB_URL, DB_USERNAME, DB_PASSWORD in the application. then developer will modify it.
- Now again we are telling database1 not required, need to use database2. so kindly edit the values again. so it will be very difficult for developers and its not a good practices.

<img width="1082" height="548" alt="image" src="https://github.com/user-attachments/assets/931d83d0-641c-4d46-8f1f-c012a973ec63" />

- Instead of doing like this , we are telling developers that. in future we will passing those values. you just mention the variables.

<img width="1082" height="623" alt="image" src="https://github.com/user-attachments/assets/f6f184c6-f8b6-4371-8220-a1dd9e5b426b" />
