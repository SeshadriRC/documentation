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


