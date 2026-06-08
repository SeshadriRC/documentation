- Create the deployment without any serviceaccount. use this [yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/RBAC/deployment-nosa.yml)

- Run some random pod,use this [yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/three-tire-deployment/frontend/deployment.yml)

<img width="1296" height="240" alt="image" src="https://github.com/user-attachments/assets/fb28d1de-fe53-4e67-ba8b-e2e0f739f1e1" />

- Now login to `pod-kavalan` and try to access another pod, you should get the error.

<img width="1343" height="296" alt="image" src="https://github.com/user-attachments/assets/a73372e3-23c9-4e02-8f6d-5ffd0f388846" />


- Now create the role for `pod-kavalan` [yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/RBAC/pod-role.yml)
- Now create the serviceaccount. [yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/RBAC/service-account.yml)
- create the rolebinding. [yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/RBAC/pod-role-binding.yml)
- use the deployment which has service account. [yaml](https://github.com/SeshadriRC/documentation/blob/main/kubernetes/RBAC/deployment.yml)

<img width="1276" height="743" alt="image" src="https://github.com/user-attachments/assets/1d7c0005-9852-4d45-877a-8767cd76d64b" />

- only able to list the pod, not able to delete

<img width="1337" height="508" alt="image" src="https://github.com/user-attachments/assets/941ca32f-64d8-43dc-a80c-bd1eb0fdd8ae" />
