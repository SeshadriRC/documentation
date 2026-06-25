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

## Execute for particular database

---

If you want the script to run **only for specific databases at execution time**, don’t hardcode the database list. Pass it dynamically using `--extra-vars`.

### Update `create_user.yml`

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

  - name: Create user only in selected databases
    shell: |
      export ORACLE_HOME={{ oracle_home }}
      export PATH=$ORACLE_HOME/bin:$PATH
      export ORACLE_SID={{ item }}

      sqlplus -s / as sysdba @/tmp/create_user.sql

    loop: "{{ target_databases }}"
```

---

Run for all three:

```bash
ansible-playbook -i inventory.ini create_user.yml \
-e 'target_databases=["NOOSPRD","LDSPRD","NOOSTST3"]'
```

Run only one DB:

```bash
ansible-playbook -i inventory.ini create_user.yml \
-e 'target_databases=["NOOSPRD"]'
```

Run only two:

```bash
ansible-playbook -i inventory.ini create_user.yml \
-e 'target_databases=["LDSPRD","NOOSTST3"]'
```

---

Alternative (keep defaults + override):

### vars.yml

```yaml
oracle_home: /u01/app/oracle/product/19.0.0/dbhome_1

databases:
  - NOOSPRD
  - LDSPRD
  - NOOSTST3
```

### create_user.yml

```yaml
loop: "{{ target_databases | default(databases) }}"
```

Now:

Run without extra vars → executes all:

```bash
ansible-playbook create_user.yml
```

Run selective:

```bash
ansible-playbook create_user.yml \
-e 'target_databases=["NOOSPRD"]'
```

This is usually how interviewers expect selective execution.

You can explain:

> “Initially the playbook supported all databases through looping. To make it reusable, I parameterized the database list using `--extra-vars`, so operators can target specific Oracle SIDs at runtime without modifying the playbook.”

---
# Exclude one particular DB

If your requirement is:

> Run for **all databases except one**, then use a condition instead of passing selected databases.

Suppose:

```yaml
databases:
  - NOOSPRD
  - LDSPRD
  - NOOSTST3
```

You want to **skip `LDSPRD`**.

### Option 1 — `when` condition (clean)

```yaml
- name: Create user in databases except excluded one
  shell: |
    export ORACLE_HOME={{ oracle_home }}
    export PATH=$ORACLE_HOME/bin:$PATH
    export ORACLE_SID={{ item }}

    sqlplus -s / as sysdba @/tmp/create_user.sql

  loop: "{{ databases }}"
  when: item != excluded_db
```

Run:

```bash
ansible-playbook create_user.yml \
-e "excluded_db=LDSPRD"
```

Execution:

```plaintext
NOOSPRD   → executed
LDSPRD    → skipped
NOOSTST3  → executed
```

---

### Option 2 — Filter before looping (more efficient)

```yaml
loop: "{{ databases | difference([excluded_db]) }}"
```

Full:

```yaml
- name: Create user except one DB
  shell: |
    export ORACLE_SID={{ item }}

    sqlplus -s / as sysdba @/tmp/create_user.sql

  loop: "{{ databases | difference([excluded_db]) }}"
```

Run:

```bash
ansible-playbook create_user.yml \
-e "excluded_db=LDSPRD"
```

Result:

```plaintext
Loop runs:
NOOSPRD
NOOSTST3
```

(`LDSPRD` never enters loop.)

---

### Ignore multiple DBs

```bash
ansible-playbook create_user.yml \
-e 'excluded_dbs=["LDSPRD","NOOSTST3"]'
```

Playbook:

```yaml
loop: "{{ databases | difference(excluded_dbs) }}"
```

Result:

```plaintext
NOOSPRD only
```

Interview explanation:

> “I parameterized exclusion using Ansible extra variables and used the `difference` filter to dynamically exclude databases during execution without modifying the playbook.”



---

