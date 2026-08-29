- You got a opportunity in MNC , they already using microservice architecture and its already containerized. Through docker compose they are deploying their microservices on to their VM's
- Customer Access those applications using LB.

---

## Level 0: Requirement Gathering

<img width="1795" height="797" alt="image" src="https://github.com/user-attachments/assets/a7658185-e4d4-44e2-931a-4fdd1e2fd965" />


- Take amazon ecommerce application, which has multiple microservices.
- First i will gather the **list of microservices.**
- What are the teams which are involved on building the application. Assume there are multiple microservices related to payments, then they will group them and call it has a payment team.
- So this will help us to defining the namespaces.
- Assume there are 300 microservices, we need to seggregate as per the **low/medium/critical** microservices. We won't onboard all the microservices to kubernetes as once, first do low, then medium and at last critical.
- **Identifying the resources**, since we would be already having prometheus or some other monitoring setup for the components which are running on VM's or even Amazon billing dashboard. So we need to take the details from there ( cpu, memory, disk  ) and calculate how much compute is required atleast for the lower environment and create a kubernetes cluster in later level, not now.
- **Cost** , it is the most important thing. Performance is greater, but Cost will be higher, then also they won't agree. Always its a balance between both cost and performance.
- Consolidate all the details in a excel sheet, attached in the github. Then discuss with your management with the document. Need to discuss the plan that what we are going to achieve in next 3 or 6 months.

---

## Level 1: Proof of Concept

<img width="1793" height="640" alt="image" src="https://github.com/user-attachments/assets/704b4529-ea5d-423f-a8b5-01ddb4e2360e" />


- How would we know whether this application will work in kubernetes cluster, so before that we need to do a POC with the microservices
- No need to do POC on all microservices, just take 5 mic.services from critical, low and medium and deploy it on small kubernetes cluster.
- Small kubernetes cluster --> 3 control plane nodes, 3 master plane nodes, with 8 CPU and 8 GB Ram.
- Start creating the deployment, service, statefulset, ingress controller (ALB).
- Now access the application and ask testing team to test it. If incase any microservice is not working properly, then we need to focus on fixing that like adding liveness, readiness probe etc.,
- This phase will typically take 30 days.

---

## Level 2: Dev K8s cluster

<img width="1327" height="813" alt="image" src="https://github.com/user-attachments/assets/a4e4c79f-fa89-42db-be0f-277f233f546a" />


- Here only we start the actual implementation, create the **Dev kubernetes cluster.**
- Assume requirement of application is 60GB Ram, 40 CPU. Create a cluster with 3 nodes each has 16 cpu and 24 GB Ram. Make sure its having extra and we always need to create a 3 master nodes.
- Note that kubernetes can scaled upto 5k nodes as well, each node can handle 110 pods. so mandatory data plane is 3 and worker node also 3 --> it can scaled upto 10k later. we should not provision extra nodes, as it will add additional overhead during cluster upgrades we need to patch each node.
- We can start creating the **namespaces** as per Teams (payment , cart , UI etc.,). It is used for logical isolation and also used for **RBAC** --> UI team need to access only UI namespace and Payment team need to access only payment namespace.
- so we can achieve this by  integrating RBAC with IAM that is using OIDC provider. 
- Next we will implement **Resource quota and Limit Ranges**. Resource quota --> Maximum amount of resources that a namespace can utilize, Limit Ranges --> Restrict pods from using the resources ( All pod in the namespace should use defined cpu and memory, as mentioned in resource requests and limits, it should not exceed this )

<img width="836" height="552" alt="image" src="https://github.com/user-attachments/assets/a7e07841-5f99-4377-a8fb-85f43d52a872" />


---

## Level 3: Onboarding Staging environment

- Replicate the Dev environment and create the Stage cluster.
- Dev cluster is not similar to prod cluster thats the reason we are creating stage cluster. Stage cluster is used to test out the production related scenarios.
- So create the stage cluster with increased size of resources, which should be similar to prod.

---

## Level 4: Onboarding Prod

- Main difference here is we need to setup prod cluster with **Multi AZ and Multi Region** feature.
- AZ --> Its a datacenter ( us-east-1a, us-east-1b, us-east-1c ). so one zone goes down, another will be available. So multi AZ is 100% required. one node in us-east-1 and other in us-east-1b ... etc.,
- Here we can use autoscaling like cluster autoscaler/karpenter to scale up the nodes
- Nodes we placed in AZ, but pod also should be in multiple AZs. For example if there is a 3 replica, each replica should be in each AZ. This is achieved by **Pod topology spread contraint**.
- we need to setup good observability stack such as prometheus, grafana, datadog etc.,
---

## Level 5: Scaling Production

`End goal: HA, Multi zone, Multi Region`

<img width="1247" height="593" alt="image" src="https://github.com/user-attachments/assets/c6a5b71c-9737-4ffc-b8e9-1ea88b4b08af" />

- Deploy kubernetes in every region ( ap-south, us-east, us-west )
- Deploy the pod in all 3 kubernetes cluster, for each of the services we will create a ingress and front face the ingress with ALB
- Also you can use DNS based (route 53) load balancing. using this we can see from where the request is originated.
- Consider user is accessing from US-east region, then DNS will route the traffic to ingress which is present in the us-east and this ingress will route the traffic to the kubernetes cluste which is present in the east.

---

## Note: 

- There are more levels , it won't end up in 5. we also can setup helm chart, service mesh, gitOps etc.,

---
