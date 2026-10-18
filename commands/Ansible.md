# Ansible Commands for DevOps Engineers

A comprehensive reference for configuration management, ad-hoc server orchestration, playbook execution, inventory inspection, and Ansible Vault encryption.

---

## 1. Ad-Hoc Commands & Remote Execution

```bash
# Ping all managed hosts in inventory to verify SSH connectivity and Python availability
ansible all -m ping -i inventory.ini

# Execute arbitrary shell command across all webservers
ansible webservers -m shell -a "uptime && free -h" -i inventory.ini

# Execute command with root privileges (sudo / --become)
ansible dbservers -m command -a "systemctl status postgresql" --become -i inventory.ini

# Gather all system facts from hosts (OS, IP, CPU, memory, disks)
ansible webservers -m setup -i inventory.ini

# Filter specific facts (e.g. distribution, IP address)
ansible webservers -m setup -a "filter=ansible_distribution*" -i inventory.ini
ansible webservers -m setup -a "filter=ansible_default_ipv4" -i inventory.ini

# Install or update a package via apt module as root
ansible webservers -m apt -a "name=nginx state=latest update_cache=yes" --become -i inventory.ini

# Install package via yum/dnf
ansible webservers -m yum -a "name=httpd state=present" --become -i inventory.ini

# Copy a configuration file with permissions
ansible webservers -m copy -a "src=./nginx.conf dest=/etc/nginx/nginx.conf mode=0644 owner=root group=root" --become -i inventory.ini

# Manage systemd services (start, restart, enable)
ansible webservers -m systemd -a "name=nginx state=restarted enabled=yes" --become -i inventory.ini
```

---

## 2. Playbook Execution & Validation

```bash
# Verify playbook syntax without contacting hosts
ansible-playbook -i inventory.ini deploy.yml --syntax-check

# Dry-run execution (check mode): predicts changes without applying them
ansible-playbook -i inventory.ini deploy.yml --check

# Dry-run with diff output: shows exact line changes that will be made to files
ansible-playbook -i inventory.ini deploy.yml --check --diff

# Standard playbook execution
ansible-playbook -i inventory.ini deploy.yml

# Run playbook with sudo privilege escalation prompt (-K)
ansible-playbook -i inventory.ini deploy.yml --become -K

# Limit execution to a specific host or group
ansible-playbook -i inventory.ini deploy.yml --limit "web-01.prod"
ansible-playbook -i inventory.ini deploy.yml --limit "staging:&webservers"

# Execute tasks with specific tags only
ansible-playbook -i inventory.ini deploy.yml --tags "deploy,config"

# Skip tasks matching specific tags
ansible-playbook -i inventory.ini deploy.yml --skip-tags "database-migration"

# List all available tags in a playbook
ansible-playbook -i inventory.ini deploy.yml --list-tags

# List all tasks that would be executed
ansible-playbook -i inventory.ini deploy.yml --list-tasks

# Pass extra variables from command line or JSON file
ansible-playbook -i inventory.ini deploy.yml -e "app_version=2.4.0 environment=production"
ansible-playbook -i inventory.ini deploy.yml -e "@vars/prod-overrides.json"

# Start execution at a specific task name (resuming failed runs)
ansible-playbook -i inventory.ini deploy.yml --start-at-task="Reload Nginx Service"

# Step-by-step interactive confirmation for each task
ansible-playbook -i inventory.ini deploy.yml --step
```

---

## 3. Ansible Vault (Secret Encryption & Decryption)

```bash
# Create a new encrypted file
ansible-vault create vars/vault-secrets.yml

# Encrypt an existing unencrypted file
ansible-vault encrypt vars/database-passwords.yml

# Decrypt an encrypted file permanently
ansible-vault decrypt vars/database-passwords.yml

# View contents of an encrypted file without decrypting it on disk
ansible-vault view vars/vault-secrets.yml

# Edit an encrypted file in your default terminal editor ($EDITOR)
ansible-vault edit vars/vault-secrets.yml

# Change the encryption password of a vaulted file (Rekey)
ansible-vault rekey vars/vault-secrets.yml

# Run playbook prompting for vault password interactively
ansible-playbook -i inventory.ini deploy.yml --ask-vault-pass

# Run playbook using a password file (ideal for CI/CD runners)
ansible-playbook -i inventory.ini deploy.yml --vault-password-file ~/.vault_pass.txt
```

---

## 4. Inventory Inspection & Validation

```bash
# Display inventory in JSON format (including host and group variables)
ansible-inventory -i inventory.ini --list

# Display inventory as a visual hierarchical tree graph
ansible-inventory -i inventory.ini --graph

# View variables assigned to a specific host
ansible-inventory -i inventory.ini --host web-01.prod
```

---

## 5. Ansible Galaxy (Roles & Collections)

```bash
# Scaffold a new role directory structure conforming to best practices
ansible-galaxy role init roles/my-app

# Install roles listed in requirements.yml
ansible-galaxy install -r requirements.yml

# Install a collection from Ansible Galaxy
ansible-galaxy collection install amazon.aws
ansible-galaxy collection install community.docker
ansible-galaxy collection install kubernetes.core
```
