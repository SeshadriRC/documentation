- First of all nginx controller is deprecated, which means we won't get any security updates from them. Now companies are slowly migrating to Kubernetes gateway API. Only nginx ingress controller is deprecated, remaining controllers like Trafeik and Ha-proxy is available.

<img width="1140" height="665" alt="image" src="https://github.com/user-attachments/assets/aece231e-e83c-4a29-9c8c-68635f4aac50" />

- Assume we want to access frontend and backend pod , in realtime we won't use NodePort, its only for testing purposes.
- In realtime we will be using LB type service , through that we can access the respective pods.
- So whenever we are creating a service of type load balancer, automatically aws will create the LB.
- so we can access LB --> Service --> Pods
- But LB is expensive, if there is one service then fine, but for multiple services its too expensive, so to address this issue we need to use Ingress.
- user will access the loadbalancer --> Ingress --> Service --> Pods. So how ingress its routing to the Service ? by using the ingress rules.

<img width="1177" height="611" alt="image" src="https://github.com/user-attachments/assets/d2dc9cd3-1b6d-46fe-b3a4-479fec65769b" />


**Path Based Routing**

/frontend -> go to frontend pod
/backend -> route traffic to backend pod


```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx      # here we need to mention whether its a ingress/trafiek/haproxy
  tls:                         # we are doing SSL termination
    - hosts:               
        - simplybyte.com       # mention the hostname for which we need to do ssl termination
      secretName: app-tls      # ssl termination requires key, so we need to pass the key as a secret
  defaultBackend:
    service:
      name: simplybyte-frontend
      port:
        number: 80
  rules:
    - host: simplybyte.com
      http:
        paths:
          - path: /backend             # it will forward to the backend service pod
            pathType: Prefix
            backend:
              service:
                name: simplybyte-backend
                port:
                  number: 8090
          - path: /frontend             # it will forward to the frontend service pod
            pathType: Prefix
            backend:
              service:
                name: simplybyte-frontend
                port:
                  number: 80
```

- pathType: Prefix, if incase url is simplybyte.com/backend/api/user --> it will still route
- pathType: Exact, it will route only if the pathh is simplybyte.com/backend

**Host based routing**

- if domain is `simplybyte.com` then route it to this service. it can also use subdomain like `api.simplybyte.com`

- But in realtime they will combine both host and path based routing and write the rule like below. so it needs to satisfy the condition `simplybyte.com/backend`

<img width="638" height="270" alt="image" src="https://github.com/user-attachments/assets/be325799-caca-4035-b008-2aa5a0f92ad2" />

**Default Backend**
- If none of the rule is matching, then it should use Default backend.

---

- For production grade application SSL termination is mandatory.

<img width="715" height="188" alt="image" src="https://github.com/user-attachments/assets/3bc317be-ddd1-40dd-8d58-e2dc38dfbc6d" />

<img width="730" height="370" alt="image" src="https://github.com/user-attachments/assets/faae1cf8-7d4c-4363-85a8-92831be9e5d5" />

- All this work is done by the Nginx ingress controller

<img width="1132" height="642" alt="image" src="https://github.com/user-attachments/assets/b165dfc5-c942-481b-a494-72f4d0d4b3b8" />

<img width="1127" height="607" alt="image" src="https://github.com/user-attachments/assets/542d2b9e-6694-4adc-aadf-81044a7e8267" />

- Nginx ingress controller will do the work as per the mentioned Nginx ingress resource.
- Other alternative tools are below

<img width="1143" height="642" alt="image" src="https://github.com/user-attachments/assets/25cf160c-ac5a-4695-9ac6-6c277e62e04c" />
