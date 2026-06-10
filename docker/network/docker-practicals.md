[application code](https://github.com/SeshadriRC/Simplybyte_calculator/tree/main)

- Above is the nodejs application, first you run the application locally and try to access.

<img width="971" height="275" alt="image" src="https://github.com/user-attachments/assets/8ae8ba54-a3c5-408a-acdf-d9dd6e8248db" />

<img width="1478" height="780" alt="image" src="https://github.com/user-attachments/assets/aff98357-ca8a-4589-a40e-b78652d0a668" />


- Write the docker file, then start the docker desktop and build the image.

<img width="947" height="308" alt="image" src="https://github.com/user-attachments/assets/26c159e4-dcc5-47d0-a2ac-8f3e7b133811" />

- Build the docker image

<img width="1537" height="892" alt="image" src="https://github.com/user-attachments/assets/a732d1b7-216c-4b90-aad4-4bcd705465bc" />

<img width="1515" height="196" alt="image" src="https://github.com/user-attachments/assets/2ddeb417-7a9f-44a3-bce1-3aff82756866" />

- Run the container

```bash
docker run -p 9003:5000 --name=my-calc calculator-new
```

- Able to access

<img width="1662" height="808" alt="image" src="https://github.com/user-attachments/assets/4ef90df6-389d-4b45-9ddd-6e123ffc5b16" />
