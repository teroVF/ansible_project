# Ansible Project

This project is a example of how to use Ansible to automate the deployment and configuration of a web application, in this case a simple wordpress site aswell to install updates and create users on different operative systems. 

The project is part of the Ansible module in the Upskill formation for SysAdmins.

It is asked by the trainer (Tiago Bernardo) to use ansible and to: 

- Configure 3 servers (database, web server and windows server) in two distinct environments (production and disaster recovery)
- Install and configure all necessary dependencies and software to put online and in a working state the wordpress site
- Create two main playbooks: One to update all the machines and another to create users and groups

We use terraform to create the infrastructure on azure and on ansible to deploy all the users and configuration needed to comply with the previously mentioned requeriments

We also  stored sensitive data, such as passwords or keys, encrypted in-place.

Playbooks and corresponding Ansible commands that can be used:

- Update all the machines you can use the following command

```bash
cd ansible
ansible-playbook -i inventory/inventory.yml playbook/update_all.yml --vault-id @prompt #password: 123
```

- Configure all the machines in one environment (servers_configuration_prod.yml/servers_configuration_dr.yml)

```bash
cd ansible
ansible-playbook -i inventory/inventory.yml playbook/servers_configuration_prod.yml --vault-id @prompt #password: 123
```

- Create users and groups in one environment (users_groups.yml/users_groups_dr.yml)

```bash
cd ansible
ansible-playbook -i inventory/inventory.yml playbook/users_groups.yml --vault-id @prompt #password:123

```


## Terraform

Essential commands to create the infrastructure on Azure:

- Initialize the working directory containing Terraform configuration files

```bash
terraform init
```

- Create an execution plan

```bash
terraform plan --out=plan
```

- Apply the changes required to reach the desired state of the configuration

```bash
terraform apply plan
```

- Destroy the Terraform-managed infrastructure

```bash
terraform destroy
```

### Authors
Antero
Miguel
Pedro

