- Assume below calc application have some feature, where developer able to view the history of calculations that made.

<img width="1447" height="731" alt="image" src="https://github.com/user-attachments/assets/9e00039d-cbc4-446d-9ef9-9671fb4c64b2" />


- But suddenly container crashed, and developer not able to view the files. Because along with the container, those stored data also got flushed before. So to address this issue docker has volume.

- Docker volume is the storage for docker, even if container got deleted, data will not lost. It will be there, once we start the new container we can able to see the data using volume.

<img width="1357" height="707" alt="image" src="https://github.com/user-attachments/assets/36d570e5-01cc-4e70-94a3-31ef0c8f6627" />


- We can't see the files inside the volume as its logical, only if its mount to the container we can able to see.

<img width="1410" height="773" alt="image" src="https://github.com/user-attachments/assets/c139d4ec-36d6-4fd0-b7dd-365c3666069d" />

- Files are stored inside our system only, by using the below command we can check the location.

```bash
docker volume inspect mycalcvolume
```

- If incase container is running, we can't able to mount the docker volume to the existing running container. we need to delete and recreate the container in such case.

<img width="1271" height="821" alt="image" src="https://github.com/user-attachments/assets/1d4634be-350e-40bb-b10a-3d7b74ac2a99" />

```bash
docker run -p 80:8080 -v mycalculatorvolume:/data calculator:latest
```
