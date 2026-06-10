- We can't access the files directly which stored in the docker volume.

<img width="1097" height="581" alt="image" src="https://github.com/user-attachments/assets/f3f92e9a-a84f-4af0-bcaf-8d7dc3a4311f" />

- So by using bind mount we can solve this problem. It will directly store the files in local system directory.
- Below is the command where we will give the local system directory and mount with container directory.

```bash
docker run -p 80:8080 -v C:\Downloads:/data calculatorapp:latest
```

<img width="1050" height="627" alt="image" src="https://github.com/user-attachments/assets/7c932f64-41ad-41d9-88cb-20fa5d92b1ed" />
