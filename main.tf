terraform {
  required_version = "~> 1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
 
# Configure the AWS Provider
provider "aws" {
  region = var.myregion
  access_key = var.myaccess_key
  secret_key = var.secret_key
}
resource "aws_instance" "myec2" {
  ami           = var.ami_id
  instance_type = lookup(var.ins_type, terraform.workspace)
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "tf-key-pair"
tags = {
    Name = "myinstance"
}
}
 
resource "aws_security_group" "mysg" {
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
 
resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
 
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
 
resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}
