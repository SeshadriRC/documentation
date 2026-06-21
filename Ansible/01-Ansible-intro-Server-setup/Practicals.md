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
