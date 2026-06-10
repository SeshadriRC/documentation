- Per port one application only we can able to run.
<img width="997" height="592" alt="image" src="https://github.com/user-attachments/assets/6f884804-3cc4-42ed-b8a6-6a8f6610f289" />


```bash
docker run -p hostport:container-port <docker-image-name>
```

- We can't directly access the application running in the container. so first we are accessing it through host port. first traffic will go to host port then from host port it will go to container port.

<img width="983" height="645" alt="image" src="https://github.com/user-attachments/assets/a0b807f3-200b-4e64-af9d-e2b23012ede4" />

- we can mention any available host port, but for container port we need to mention same as application port(while designing application developer will be assigning port to this application)
