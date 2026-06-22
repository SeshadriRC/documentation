Yes — this is a good Ansible automation use case.

Your scenario:

* Server: `lmaeprod.server.net`
* Oracle Home: one **19c Oracle Home**
* Multiple databases running on same server:

  * `NOOSPRD`
  * `LDSPRD`
  * `NOOSTST3`
* Requirement:

  * Create the **same Oracle user** in all databases automatically.

Typical approach:

1. SSH to server
2. Switch to oracle OS user
3. Set correct `ORACLE_HOME`
4. Loop through database SIDs
5. Connect using `sqlplus`
6. Execute `CREATE USER`

Example structure:

### inventory.ini

```ini
[oracle]
lmaeprod.server.net
```

---

### vars.yml

```yaml
oracle_home: /u01/app/oracle/product/19.0.0/dbhome_1

databases:
  - NOOSPRD
  - LDSPRD
  - NOOSTST3

db_user: app_user
db_password: Welcome@123
```

---

### create_user.sql.j2

```sql
WHENEVER SQLERROR EXIT FAILURE

DECLARE
v_count NUMBER;
BEGIN

SELECT COUNT(*)
INTO v_count
FROM dba_users
WHERE username=UPPER('{{ db_user }}');

IF v_count=0 THEN
EXECUTE IMMEDIATE
'CREATE USER {{ db_user }}
IDENTIFIED BY "{{ db_password }}"';

EXECUTE IMMEDIATE
'GRANT CONNECT TO {{ db_user }}';

END IF;

END;
/

EXIT
```

---

### create_user.yml

```yaml
---
- hosts: oracle
  become: yes
  become_user: oracle

  vars_files:
    - vars.yml

  tasks:

  - name: Create temp SQL
    template:
      src: create_user.sql.j2
      dest: /tmp/create_user.sql

  - name: Create user in all databases
    shell: |
      export ORACLE_HOME={{ oracle_home }}
      export PATH=$ORACLE_HOME/bin:$PATH
      export ORACLE_SID={{ item }}

      sqlplus -s / as sysdba @/tmp/create_user.sql

    loop: "{{ databases }}"
```

Run:

```bash
ansible-playbook -i inventory.ini create_user.yml
```

What happens:

```text
NOOSPRD   → create user
LDSPRD    → create user
NOOSTST3  → create user
```

### Better production improvements (interview level)

* Store password in **Ansible Vault**
* Capture SQL output into logs
* Use `failed_when`
* Validate DB open mode before execution:

```sql
select open_mode from v$database;
```

* Use `changed_when`
* Use roles:

```text
roles/
  oracle_user/
```

Since you work in enterprise environments, another pattern is to keep:

```yaml
databases:
  PROD:
    - NOOSPRD
    - LDSPRD
  TEST:
    - NOOSTST3
```

Then run selectively:

```bash
ansible-playbook create_user.yml --extra-vars env=PROD
```

This is the kind of automation story that interviews like because it shows **looping + idempotency + Oracle + Ansible integration**.
