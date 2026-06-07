<img width="1090" height="615" alt="image" src="https://github.com/user-attachments/assets/d5e6c4b2-cfac-480d-ad6b-4ade6f85e98c" />

- It contains master node and worker node.
- The applications that we are deploying it will get deployed in the worker node only.

**API Server**

- Every communication is done through the API server. It is a heart of the kubernetes

**Controller Manager**

<img width="1060" height="602" alt="image" src="https://github.com/user-attachments/assets/6cbde509-53ec-409c-8749-ed35d0af192a" />

- It will maintain the state of the containers.
- how this is checking ---> By use of desired state and actual state
- If in case 2 is desired but 1 is missing, then it will inform to API server that 1 container is missing
- How the controller manager kknow the desired count ? --> by use of ETCD

**ETCD**

<img width="1060" height="631" alt="image" src="https://github.com/user-attachments/assets/84df3ff0-d979-4d1c-8906-17ea94172633" />


- It is a database, stores all the information
- It is a brain of the kubernetes

**Scheduler**

<img width="1098" height="666" alt="image" src="https://github.com/user-attachments/assets/726c5534-1050-40d1-8073-d79dddc3901e" />


- Decides in which node the pod should be created
- It will check all the node resource usage details and schedule the pod in the correct node
- But who will create the pod/container ? -> Kubelet


**Kubelet**

- API server will inform the details about container to kubelet --> then kubelet will inform those to CRI
- CRI will be responsible to pull the image and create the container
- if incase any container is crashed, then kubelet will tell to CRI to remove the container and kublet will inform this to API server, then API server will ask the controller
- manager to check the state , so controller will checke desired vs actual. then it will inform to api server that 1 container is missing
- now api will go to scheduler -> then schheduler will look thhe node freee status and decides in this node we can create that container
- then api server will give the details about container image to the kubelet to create a container in node which selected by scheduler, then this kubelet will go to cri and ask to create a container
