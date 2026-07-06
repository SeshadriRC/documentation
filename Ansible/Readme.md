# Topics

- [Ansible templates](https://spacelift.io/blog/ansible-template)
   - eg: install nginx using jinja2 tempalte

---

- [Ansible Handlers](https://spacelift.io/blog/ansible-handlers#example-restarting-apache-servers-with-ansible-handlers)
   - eg: Apache configuration using ansible

---

- [Ansible gather Facts](https://spacelift.io/blog/ansible-facts)

module: debug, assert, group_by, setup, set_fact
parameters: fail_msg

debug:
Ansible module used to display information

| Module        | Common Parameters                 |
| ------------- | --------------------------------- |
| `debug`       | `msg`, `var`, `verbosity`         |
| `copy`        | `src`, `dest`, `owner`, `mode`    |
| `file`        | `path`, `state`, `mode`           |
| `service`     | `name`, `state`, `enabled`        |
| `yum` / `apt` | `name`, `state`                   |
| `assert`      | `that`, `fail_msg`, `success_msg` |
| `group_by`    | `key`                             |


The key parameter is used by the group_by module to specify the name of the group that Ansible should create.

- set_fact is an Ansible module. Its job is to create a new variable (fact) during playbook execution.

---
