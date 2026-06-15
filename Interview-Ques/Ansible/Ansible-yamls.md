1. Install nginx on a ubuntu.

---
- name: Install and start nginx
  hosts: all
  become: yes

  tasks:

    - name: Install nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes
---
```bash
Explanation:

apt → package manager for Ubuntu
update_cache: yes → runs apt update
state: present → install package
service → manage service
state: started → start service
enabled: yes → start automatically after reboot
```
---
