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


# first without adding i checked below
sudo ls
$ sudo ls
sudo: I'm sorry ansible. I'm afraid I can't do that

# Then after that i added below
ansible ALL=(ALL:ALL) ALL   --> but it asked password
ubuntu@ip-172-31-2-88:~$ sudo su - ansible
$ ls
$ sudo ls
[sudo: authenticate] Password:

$ whoami
ansible
$ sudo whoami
[sudo: authenticate] Password:

# Now add entire line, so that it won't ask password
ubuntu@ip-172-31-2-88:~$ sudo cat /etc/sudoers | grep ansible
ansible ALL=(ALL:ALL) NOPASSWD: ALL
ubuntu@ip-172-31-2-88:~$ sudo su - ansible
$ lss
-sh: 1: lss: not found
$ ls
$ sudo whoami
root

```

- Generate `sshkey pairs`, here im using my owner username `sesha `

```bash
ssh-keygen -t rsa

cd ~/.ssh

# we will see both private and public. we need to deploy only public key in the target servers. why we are using this concept --> due to passwordless, run below command before deploying, it will ask the password

sesha@LAPTOP-QMBUJPPJ:~/.ssh$ ssh ansible@192.168.56.11
ansible@192.168.56.11's password:



```

- There are 2 ways to deploy the public key , one is manually copying the public key from `id_rsa.pub` and another is `ssh-copy-id` command. here we will use `ssh-copy-id`. `ssh-cpy-id` worked for centos but for ubuntu not worked so i manually copied `id_rsa.pub` to `authorized_keys` of ubuntu.

```bash
# first time only it will ask the password, once given key will get added

ssh-copy-id -i id_rsa.pub ansible@<target_host>   -> onprem

sesha@LAPTOP-QMBUJPPJ:~/.ssh$ ssh-copy-id -i id_rsa.pub ansible@192.168.56.11
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansible@192.168.56.11's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'ansible@192.168.56.11'"
and check to make sure that only the key(s) you wanted were added.

# Again test it , you can able to login
ssh ansible@<target_hosts>

sesha@LAPTOP-QMBUJPPJ:~/.ssh$ ssh ansible@192.168.56.11
Last login: Sun Jun 21 08:28:08 2026
[ansible@node1 ~]$

[ansible@node1 .ssh]$ cat authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqP51Orubib+PPillrCWzTq4OSfe39SzFCGiSM41Ky/GtJAtPfdwOib/Lrio1zyuTCa462lhAZHEtFGdS07c81pI3o6ZUVA+ikRmDq+l4M8FCS1buu3xEh7xPB0O8XNO24KCPlGRDDkp9oIA5kXqWYNDtzM5MEKDhDgfcZ9vqQIT51KIcIyEiRfi8Y5drGVXnCJEzTYWZ/MnKC0/U/JSrEpFKWGAUOY9MJcvNX3nsWyf/mqZtAbThOZRFWi2a/ubH94OYdYDnWahP77TIdz4N5BIEF2VmVXVOnUDVIy8JQSeD3i29Pfgew7fwlVP74Yaspb4uLEdTV/joPJJV7mhtFnv8dT+F/OSHfoxrX3k/2XpMOk8CVoYVXkMjFcaMDS0ulYeckAyJFa9+e/ELaJDjRDc2zZzWLRtKFVAanqWgOcWiw+eNBKEvwacLgBlzZOBFIhz2gZL52USQ14gQ9nbiQnMFJdBiJo+UjUdoVeLrT/a3j5jBodQIRmYy3ocJ50L8= sesha@LAPTOP-QMBUJPPJ

## below is for ubuntu
$ ls -ld .ssh
drwx------ 2 ansible ansible 4096 Jun 21 08:58 .ssh
$ cd .ssh
$ ls -lrth
total 4.0K
-rw------- 1 ansible ansible 575 Jun 21 08:58 authorized_keys

```
