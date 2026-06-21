**Topics Covered**

- Authentication
- OpenIDconnect
- Callback URL
- Authorization
- OAuth


---

## Authentication/OpenID Connect

- Authentication is the process of checking if a user is really who they claim to be.
- Normally if  a user logs in , then backend server will receive the creds and it will validate the details with database.
- To authenticate users, we should store user details in our database. Also, it is important to store passwords securely.
- So we are giving the authentication process to a trusted third-party provider like google.
- If you already logged into google account then automatically with that creds it will login to the application and also google will ask to us whether can we allow google to provide the details about us to that application, then we need to click allow.
- Then google will send the token to our application. Inside that token only all user details will be there, in our application just we need to store those details, no need to store password and authenticate. This is called OpenID Connect
- Using a third-party provider for authentication is commonly done using **OpenID Connect**.
- **Call back URL** --> After the above mentioned authentication process, Assume again you are trying to login, now our application needs to send the url(`https://api.simplify`) which has details about token to the google, so that google will be authenticating , now google needs to callback us right, thats the reason we are calling it has a **callback URL**.

<img width="1907" height="737" alt="image" src="https://github.com/user-attachments/assets/afa2d0dc-d98e-4270-8150-ef26c9c6b04e" />


<img width="1586" height="911" alt="image" src="https://github.com/user-attachments/assets/b4e9568f-3693-4ea9-b9c6-46463750396b" />

<img width="1177" height="603" alt="image" src="https://github.com/user-attachments/assets/dc2fa8ef-fcdb-402d-aae0-e16d5e08b123" />

<img width="1201" height="716" alt="image" src="https://github.com/user-attachments/assets/8117398b-1851-46c4-90f6-200160d5f679" />

---

**Token**
<img width="1675" height="701" alt="image" src="https://github.com/user-attachments/assets/963d12f8-dee8-4304-80ab-45d00bfec236" />
<img width="1668" height="605" alt="image" src="https://github.com/user-attachments/assets/49852bb6-df68-4260-87c5-6a1371c4657e" />

---

**Call back URL**

<img width="1092" height="515" alt="image" src="https://github.com/user-attachments/assets/d8fd7f44-4bc5-4863-ab95-7c6e2905f194" />


---
