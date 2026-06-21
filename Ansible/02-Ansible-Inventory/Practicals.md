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





---

## Dynamic Inventory
