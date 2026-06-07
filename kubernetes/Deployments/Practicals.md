## Deploy using replicaset first

[yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/Deployments/replica-service.yml)

```bash
k apply -f rep.yml
```
<img width="1043" height="321" alt="image" src="https://github.com/user-attachments/assets/5294a5d1-a119-4e15-bd9e-15df9d89ec76" />

- Now access the application in port: 30080

<img width="1692" height="832" alt="image" src="https://github.com/user-attachments/assets/a17b3e50-c397-4043-b07b-d28a9d2776ae" />

- Now delete the RS and edit the yaml file to version 2.0

```bash
k get pods --watch

vi rep.yml    # edit from simplebyte/simplybyte-calculator:1.0 to simplebyte/simplybyte-calculator:2.0

k delete rs <rs-name>

# create the rs again
k apply -f rep.yml
```
<img width="797" height="212" alt="image" src="https://github.com/user-attachments/assets/44082bb6-392e-41ce-a582-9d40d3255b1c" />
<img width="767" height="452" alt="image" src="https://github.com/user-attachments/assets/1430c8da-54f1-42ed-a61f-a3472da1095f" />
<img width="1530" height="357" alt="image" src="https://github.com/user-attachments/assets/a76e292e-39dd-48eb-ac46-3048fd584399" />
<img width="525" height="147" alt="image" src="https://github.com/user-attachments/assets/a001e3bf-2cae-4eca-9fa0-d05d9bb548e1" />
<img width="882" height="230" alt="image" src="https://github.com/user-attachments/assets/67b8c130-7639-433e-a718-d9bd84061940" />

- Able to access the application

<img width="1511" height="880" alt="image" src="https://github.com/user-attachments/assets/4508d808-2657-46d9-887f-89e72725b037" />

- Now we will use the Deployment yaml

[yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/Deployments/deploy-service.yml)

<img width="608" height="135" alt="image" src="https://github.com/user-attachments/assets/9f9de457-a59f-465a-afe5-b4d8b499ac33" />
<img width="1570" height="905" alt="image" src="https://github.com/user-attachments/assets/13f58e19-9b39-4241-b968-f43a90d9bdb1" />

- Now edit the dep.yml from version 1.0 to 2.0 and kubectl apply.

<img width="658" height="143" alt="image" src="https://github.com/user-attachments/assets/021e2ad9-a2fc-4b25-bced-b1c44827abbc" />

- We can see application is deployed

<img width="1541" height="872" alt="image" src="https://github.com/user-attachments/assets/acabdb3a-e6c6-4420-9486-8e5f536c4586" />

- Now check the rollout history

<img width="750" height="168" alt="image" src="https://github.com/user-attachments/assets/42d4ed3e-7a01-4bef-b974-7072d2e74950" />

- Here we can see 2 RS

<img width="811" height="162" alt="image" src="https://github.com/user-attachments/assets/967e3d53-1a06-4c36-b965-8e270776905c" />

- Now we will rollback it.

<img width="916" height="282" alt="image" src="https://github.com/user-attachments/assets/99f8cd4e-be81-4242-9cad-49d9f03cf078" />
<img width="941" height="532" alt="image" src="https://github.com/user-attachments/assets/328e858f-4ba8-44e8-9c12-116784a1881b" />

- app got reverted.

<img width="1528" height="810" alt="image" src="https://github.com/user-attachments/assets/f78f6acc-df37-4799-bf00-f288bb604526" />
