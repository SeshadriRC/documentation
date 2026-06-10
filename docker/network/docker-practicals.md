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

- Create a file inside a container and delete the container

<img width="1128" height="98" alt="image" src="https://github.com/user-attachments/assets/c2ed3271-45ba-4707-9fa2-b391871000d5" />
<img width="523" height="95" alt="image" src="https://github.com/user-attachments/assets/fc909b1b-f672-4bbc-aee2-ee73ac5525dc" />
<img width="1296" height="442" alt="image" src="https://github.com/user-attachments/assets/e16d1145-1a5c-4664-8452-a2d84c8a6d40" />

- file is not there

<img width="567" height="123" alt="image" src="https://github.com/user-attachments/assets/f0eccdf8-e405-4b9e-a401-2cbcfd63b4d6" />


## create a volume and add a file, remove the container and then simulate

<img width="867" height="280" alt="image" src="https://github.com/user-attachments/assets/6773ba5f-bcf9-428d-9caf-344d4376fc98" />
<img width="716" height="276" alt="image" src="https://github.com/user-attachments/assets/cf830aae-0e07-4558-8ca1-a2ee6dbc86e9" />

- file is present
<img width="657" height="167" alt="image" src="https://github.com/user-attachments/assets/5da80290-9cce-470d-b4f0-80c6fb25c5f0" />


## create a bindmount and add a file , then simulate

<img width="1195" height="202" alt="image" src="https://github.com/user-attachments/assets/f4161c5e-6a47-4fdd-8621-ac129f23afda" />

- create some file in `docker-testing` folder and check
- both files are visible now

<img width="557" height="150" alt="image" src="https://github.com/user-attachments/assets/848240b7-eab3-4996-8c33-8d9913cca35b" />

<img width="1238" height="287" alt="image" src="https://github.com/user-attachments/assets/22dbc624-fa50-4489-9efa-5eadc9aeda06" />
