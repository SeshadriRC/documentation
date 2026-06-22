Since this is for **interview explanation + lab practice**, I’ll show a **sample Oracle 19c patching automation structure in Ansible** (safe skeleton). You can adapt it to your actual environment.

Assume:

```text
Server: lameprd.server.net
Oracle Home: /u01/app/oracle/product/19.0.0/dbhome_1
Databases:
- NOOSPRD
- LDSPRD
- OCENPRD

Patch Location:
/tmp/34762026
```

Directory:

```text
oracle_patch/
├── inventory.ini
├── vars.yml
├── patch.yml
└── templates
```

---

## inventory.ini

```ini
[oracle]
lameprd.server.net
```

---

## vars.yml

```yaml
oracle_home: /u01/app/oracle/product/19.0.0/dbhome_1

oracle_user: oracle

oracle_dbs:
  - NOOSPRD
  - LDSPRD
  - OCENPRD

patch_dir: /tmp/34762026

patch_id: "34762026"

listener_name: LISTENER
```

---

## patch.yml

```yaml
---
- hosts: oracle
  become: yes
  become_user: "{{ oracle_user }}"

  vars_files:
    - vars.yml

  tasks:

# --------------------------------
# PRECHECK
# --------------------------------

  - name: Verify OPatch
    shell: |
      {{ oracle_home }}/OPatch/opatch version
    register: opatch_version

  - debug:
      var: opatch_version.stdout

  - name: Capture inventory
    shell: |
      {{ oracle_home }}/OPatch/opatch lsinventory
    register: inventory

  - name: Skip if patch exists
    fail:
      msg: Patch already installed
    when:
      - patch_id in inventory.stdout

# --------------------------------
# STOP DATABASES
# --------------------------------

  - name: Shutdown databases
    shell: |
      export ORACLE_HOME={{ oracle_home }}
      export ORACLE_SID={{ item }}

      echo "
      shutdown immediate;
      exit
      " | sqlplus -s / as sysdba

    loop: "{{ oracle_dbs }}"

# --------------------------------
# STOP LISTENER
# --------------------------------

  - name: Stop listener
    shell: |
      export ORACLE_HOME={{ oracle_home }}

      lsnrctl stop {{ listener_name }}

# --------------------------------
# APPLY PATCH
# --------------------------------

  - name: Apply patch
    shell: |
      export ORACLE_HOME={{ oracle_home }}

      cd {{ patch_dir }}

      {{ oracle_home }}/OPatch/opatch apply -silent

    async: 7200
    poll: 30

# --------------------------------
# START LISTENER
# --------------------------------

  - name: Start listener
    shell: |
      export ORACLE_HOME={{ oracle_home }}

      lsnrctl start {{ listener_name }}

# --------------------------------
# START DATABASES
# --------------------------------

  - name: Startup databases
    shell: |
      export ORACLE_HOME={{ oracle_home }}
      export ORACLE_SID={{ item }}

      echo "
      startup;
      exit
      " | sqlplus -s / as sysdba

    loop: "{{ oracle_dbs }}"

# --------------------------------
# VALIDATE
# --------------------------------

  - name: Verify patch
    shell: |
      {{ oracle_home }}/OPatch/opatch lsinventory
    register: patch_check

  - debug:
      var: patch_check.stdout
```

---

## Execute

```bash
ansible-playbook -i inventory.ini patch.yml
```

Flow:

```text
Precheck
↓
Inventory
↓
Stop DBs
↓
Stop Listener
↓
Apply Patch
↓
Start Listener
↓
Start DBs
↓
Validate
```

### Improvements you can mention in interview

* Store credentials in **Ansible Vault**
* Use `block/rescue`
* Generate HTML reports
* Add rollback
* Add email notifications
* Add `changed_when` / `failed_when`
* Run DBs serially if downtime policy requires

This is a **practice/interview skeleton** — in real production patching, exact steps vary depending on RU/CPU patch type, Data Guard/RAC setup, rolling vs non-rolling patching, and organizational controls.



- If in case they asked what are all the challenges faced during patching


This question is very common in interviews.

Don’t answer generically like “downtime issue” or “errors happened”. Structure it as:

**Challenge → Impact → Solution**

For your Oracle 19c + Ansible patching scenario, these are realistic answers.



## 1. Multiple databases sharing same Oracle Home

### Challenge

Multiple databases (`NOOSPRD`, `LDSPRD`, `OCENPRD`) were running under the same 19c Oracle Home.

Applying patch on Oracle Home impacts all databases.

### Impact

If one DB remained active, patch could fail or leave environment inconsistent.

### Solution

Created Ansible workflow:

```text
Identify DBs
→ Shutdown all DBs
→ Validate PMON stopped
→ Apply patch
→ Start all DBs
→ Validate
```

Added validation before patch execution.


## 2. Idempotency (avoid patch reapplication)

### Challenge

Playbook should not apply an already installed patch.

### Impact

Repeated execution could fail or create confusion.

### Solution

Collected inventory before execution:

```bash
opatch lsinventory
```

Added conditional logic:

```yaml
when: patch_id not in inventory.stdout
```


## 3. Long patch execution time

### Challenge

Some patch execution took longer than normal SSH session timeout.

### Impact

Job status became unclear.

### Solution

Used asynchronous execution:

```yaml
async:
poll:
```

And implemented status checks.


## 4. Database startup failure after patch

### Challenge

Patch completed but one DB failed to come back.

### Impact

Application downtime risk.

### Solution

Added post-validation:

```sql
select status from v$instance;
```

If startup failed:

* Collect logs
* Stop execution
* Trigger rollback procedure


## 5. ORACLE_SID switching issue

### Challenge

During loop execution, wrong SID could be picked.

### Impact

Commands executed against wrong database.

### Solution

Explicitly exported:

```bash
export ORACLE_SID={{ item }}
```

Validated before execution.


## 6. Listener dependency

### Challenge

Database and listener sequence matters.

### Impact

Applications could not reconnect.

### Solution

Implemented controlled order:

```text
Stop DB
Stop Listener
Patch
Start Listener
Start DB
Validate
```


## 7. Active application connections

### Challenge

Application sessions remained connected.

### Impact

Shutdown immediate delayed.

### Solution

Added validation:

```sql
select username,status
from v$session;
```

Coordinated maintenance window.


## 8. Disk space shortage

### Challenge

Patch extraction and backup consumed space.

### Impact

Patch failed midway.

### Solution

Added prechecks:

```bash
df -h
```

and cleanup tasks.

## 9. Rollback readiness

### Challenge

Need safe recovery if patch fails.

### Impact

Production outage risk.

### Solution

Created backup before patch:

```text
ORACLE_HOME backup
Inventory backup
```

Implemented `block/rescue`.


## 10. Environment differences

### Challenge

Different servers had different patch paths and configs.

### Impact

Hardcoded automation failed.

### Solution

Moved values into:

```yaml
group_vars
host_vars
```


### Short interview answer (60 seconds)

> “Main challenges were multiple databases sharing the same Oracle Home, ensuring idempotency so patches weren’t reapplied, handling long-running patch execution, validating clean shutdown/startup, managing ORACLE_SID switching, and preparing rollback procedures. We solved these using Ansible prechecks, conditional execution, async execution, validation steps, and structured error handling.”

That answer sounds practical and production-oriented.



---
