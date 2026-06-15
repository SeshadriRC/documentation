<img width="777" height="475" alt="image" src="https://github.com/user-attachments/assets/bc608f14-a202-499a-aa2a-3a094a50178c" />


---

<img width="807" height="478" alt="image" src="https://github.com/user-attachments/assets/4fcb064a-e9b2-4d84-97c6-da1279231d20" />


---

<img width="727" height="503" alt="image" src="https://github.com/user-attachments/assets/86bdad14-bd28-4da5-ac32-bbab3ef7711e" />


---

<img width="822" height="536" alt="image" src="https://github.com/user-attachments/assets/e5dab30f-2bf4-4444-ab32-a89af3ca5595" />


---

<img width="815" height="530" alt="image" src="https://github.com/user-attachments/assets/e84840c9-f233-493e-8608-6258a3aade88" />

---

<img width="753" height="523" alt="image" src="https://github.com/user-attachments/assets/ce98e2b5-48e6-434c-a131-234b8c47a9da" />


---

# Practicals

- We are using 2 or 3 ubunutu servers
- Install ansible on ubuntu

```bash
sudo apt update
sudo apt install ansible -y
```

- Create a user in control node.

```bash
sudo useradd -m ansible
sudo passwd ansible
```

- Provide sudo privilege to the `ansible` user and also use `NOPASSWD ` so that it won't ask any password while using sudo.

```bash
sudo visudo

# Add below root user
ansible ALL=(ALL:ALL) NOPASSWD: ALL  --> This ALL inidicates, user has all the privilege to execute all the commands
```
