# Overview
A demo to show the differences between Ansible and Terraform

## Instructions

### Export the environment variables for AWS

```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

### Ansible Demo

#### Run the Playbook
Change directory to the Ansible folder.

```bash
cd Ansible
ansible-playbook playbook_create.yml
```

Go to the EC2 instance and check the output.

#### Destroy the Environment

```bash
ansible-playbook playbook_destroy.yml
```

### Terraform Demo

#### Run the Terraform

Change directory to the Terraform folder.

```bash
cd Terraform
terraform init
terraform plan
terraform apply
```

#### Destroy the Environment

```bash
terraform destroy
```

## Differences to Notice

In Ansible:

1. Order matters
If you put the launch of the EC2 instance before creating the key pair, it will fail to create the EC2 instance

2. Can't add tags after the EC2 instance is Created
Since there is no state file, you can't make that change. Ansible doesn't detect the change.

3. Creation outside of Ansible is Considered
If you create an EC2 instance from the AWS console in the same region, VPC, availability zone, and with a public IP. Basically it needs to have very similar config to the instance that Ansible created. Ansible is configured for a certain number of EC2 instances and will count the one created from the console. This can have strange and unpredictable effects. 

Example: If you had a count of 2 and then create a 3rd instance outside of Ansible via the console, then run Ansible again with the same count of 2, Ansible will delete the latest instance it created. So it will take into account the instance created outside of Ansible.

4. Need to Create a Separate Playbook To Destroy
In Ansible, you can't just destroy the infrastructure with the same playbook you used to create because there is no saved state. So you need to create another playbook to destroy the resources created. You also need to delete things in reverse order to how you created them.
