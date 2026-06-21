# Topics convered

- Inventory without username
- Inventory with username
- Inventory file with different name


- we will be creating a each directory for activity. for patching create a separate directory called patching. Then in that specific directory create a inventory.

## Static Inventory

**Inventory without username**

```bash
sesha@LAPTOP-QMBUJPPJ:~/ansible$ cat inventory.ini
[redhat]
192.168.56.11

[ubuntu]
192.168.56.12

ansible all -i inventory.ini -m ping -u ansible
```
<img width="1907" height="481" alt="image" src="https://github.com/user-attachments/assets/bbaf7482-780f-48d1-9098-f3d9bc484d18" />

**Inventory with username**

- Here we are using variable concept

```bash
sesha@LAPTOP-QMBUJPPJ:~/ansible$ cat inventory.ini
[redhat]
192.168.56.11 ansible_user=ansible

[ubuntu]
192.168.56.12 ansible_user=sesha
```

```bash
ansible all -i inventory.ini -m ping
```
<img width="1918" height="498" alt="image" src="https://github.com/user-attachments/assets/0e6313ba-1904-48b8-9d66-b619942cf7b0" />


**Inventory file with different name**

```bash
sesha@LAPTOP-QMBUJPPJ:~/ansible$ cat invent.txt
[redhat]
192.168.56.11 ansible_user=ansible

[ubuntu]
192.168.56.12 ansible_user=ansible
```

```bash
ansible all -i invent.txt -m ping
```

<img width="1911" height="482" alt="image" src="https://github.com/user-attachments/assets/ebca4f66-b4a5-4ee0-861a-61326f7056f2" />



---

## Dynamic Inventory


- AWS cli access should get enabled.
- Provision 2 ec2 instances and tag it according to the env
