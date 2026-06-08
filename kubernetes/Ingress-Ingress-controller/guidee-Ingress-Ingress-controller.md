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
  ingressClassName: nginx
  tls:
    - hosts:
        - simplybyte.com
      secretName: app-tls
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
