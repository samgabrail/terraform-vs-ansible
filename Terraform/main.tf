terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.19.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical https://ubuntu.com/server/docs/cloud-images/amazon-ec2
}

resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "mykey" {
  key_name   = var.my_aws_key
  public_key = tls_private_key.mykey.public_key_openssh
}

resource "aws_instance" "webserver" {
  count                  = var.webserver_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.my_instance_type
  vpc_security_group_ids = [aws_security_group.security_group1.id]
  subnet_id              = aws_subnet.terraform-vs-ansible.id
  key_name               = aws_key_pair.mykey.key_name
  private_ip             = var.private_ips[count.index]

  tags = local.mytags
}


resource "aws_vpc" "terraform-vs-ansible" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = local.mytags
}

resource "aws_subnet" "terraform-vs-ansible" {
  vpc_id                  = aws_vpc.terraform-vs-ansible.id
  cidr_block              = var.subnet_prefix
  map_public_ip_on_launch = var.allow_public_ips
  
  tags                    = local.mytags
}

resource "aws_security_group" "security_group1" {
  name = "${var.project_name}-security-group"

  vpc_id = aws_vpc.terraform-vs-ansible.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP Ingress"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.mytags
}

