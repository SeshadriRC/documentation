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

- We are using 2 managed servers ( centos and ubuntu )
- Install ansible on ubuntu controller node

```bash
sudo apt update
sudo apt install ansible -y
```

- Create a `ansible` user in target nodes ( centos and ubuntu )

```bash
sudo useradd -m ansible
sudo passwd ansible
```

- Provide sudo privilege to the `ansible` user and also use `NOPASSWD ` so that it won't ask any password while using sudo.

```bash
sudo visudo

# Add below root user
ansible ALL=(ALL:ALL) NOPASSWD: ALL  --> This ALL indicates, user has all the privilege to execute all the commands
```

- Generate `sshkey pairs`, here im using my owner username `sesha `

```bash
ssh-keygen -t rsa

cd ~/.ssh

# we will see both private and public. we need to deploy only public key in the target servers. why we are using this concept --> due to passwordless, run below command before deploying, it will ask the password

ssh ansible@<target_host>

```

- There are 2 ways to deploy the public key , one is manually copying the public key from `id_rsa.pub` and another is `ssh-copy-id` command. here we will use `ssh-copy-id`

```bash
# first time only it will ask the password, once given key will get added

ssh-copy-id -i id_rsa.pub ansible@<target_host>

# Again test it , you can able to login
ssh ansible@<target_hosts>
```
