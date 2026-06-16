# 1. Variable precedence in Ansible

**Ansible Variable Precedence** means:

> If the same variable is defined in multiple places, **Ansible decides which value wins** based on priority.

Higher precedence → overrides lower precedence.

Think:

```plaintext
Default value
    ↓
Inventory
    ↓
Playbook
    ↓
Extra vars (Highest)
```

---

## Example Scenario

Suppose same variable `env` is defined in multiple places.

### 1. Inventory variable (lower priority)

**inventory.ini**

```ini
[web]
server1

[web:vars]
env=dev
```

---

### 2. Playbook variable (higher than inventory)

```yaml
---
- hosts: web

  vars:
    env: test

  tasks:
  - debug:
      msg: "{{ env }}"
```

Run:

```bash
ansible-playbook app.yml
```

Output:

```plaintext
test
```

Why?

```plaintext
Inventory → dev
Playbook → test

Playbook wins
```

---

### 3. Extra vars (highest priority)

Run:

```bash
ansible-playbook app.yml -e "env=prod"
```

Output:

```plaintext
prod
```

Why?

```plaintext
Inventory → dev
Playbook → test
Extra vars → prod

Extra vars wins
```

---

## Common precedence order (low → high)

| Priority | Variable Source   |
| -------- | ----------------- |
| 1        | Role defaults     |
| 2        | Inventory vars    |
| 3        | Playbook vars     |
| 4        | Task vars         |
| 5        | Include vars      |
| 6        | Extra vars (`-e`) |

Example:

```plaintext
defaults → inventory → playbook → task → extra vars
```

If:

```plaintext
env=dev       (inventory)
env=test      (playbook)
env=stage     (task)
env=prod      (-e)
```

Final value:

```plaintext
prod
```

because **extra vars has highest precedence**.

---

Interview short answer:

> Variable precedence in Ansible decides which variable value is used when the same variable exists in multiple places. Higher precedence variables override lower precedence ones, and `extra vars (-e)` has the highest priority.

---
