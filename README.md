# Overview
A demo to show the differences between Ansible and Terraform


## Instructions

### Install the AWS python boto library dependencies

```bash
pip install botocore boto3
```

### Export the environment variables for AWS

export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

## Differences to Notice

In Ansible:

1. Order matters
If you put the launch of the EC2 instance before creating the key pair, it will fail to create the EC2 instance

2. Can't add tags after the EC2 instance is Created
Since there is no state file, you can't 

3. Creation outside of Ansible is Considered
If you create an EC2 instance from the AWS console, Ansible is configured for a certain number of EC2 instances and will count the one created from the console. This can have strange and unpredictable effects.

4. Need to Create a Separate Playbook To Destroy
In Ansible, you can't just destroy the infrastructure with the same playbook you used to create because there is no saved state. So you need to create another playbook to destroy the resources created. You also need to delete things in order.