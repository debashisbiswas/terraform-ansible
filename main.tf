terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "ssh-public-key" {
  key_name   = "ssh-public-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh_and_http" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "instance" {
  ami             = "ami-08a0d1e16fc3f61ea"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.ssh-public-key.key_name
  security_groups = [aws_security_group.allow_ssh_and_http.name]

  tags = {
    Name = "TerraformAnsibleEC2"
  }
}

output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.instance.public_ip
}
