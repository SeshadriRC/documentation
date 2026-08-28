- You got a opportunity in MNC , they already using microservice architecture and its already containerized. Through docker compose they are deploying their microservices on to their VM's
- Customer Access those applications using LB.

**Level 0: Requirement Gathering**

- Take amazon ecommerce application, which has multiple microservices.
- First i will gather the list of microservices.
- What are the teams which are involved on building the application. Assume there are multiple microservices related to payments, then they will group them and call it has a payment team.
- So this will help us to defining the namespaces.
- Assume there are 300 microservices, we need to seggregate as per the low/medium/critical microservices. We won't onboard all the microservices to kubernetes as once, first do low, then medium and at last critical.
- Identifying the resources, since we would be already having prometheus or some other monitoring setup for the components which are running on VM's. So we need to take the details from there ( cpu, memory, disk  ) and calculate how much compute is required atleast for the lower environment. 
