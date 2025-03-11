terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

  cloud { 
    organization = "vadym_sodolynskyi_inc" 

    workspaces { 
      name = "IIT-Lab-Workspace" 
    } 
  }
}

provider "aws" {
  region  = "eu-north-1"
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_security_group"
  description = "Security Group for EC2"

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ubuntu_ec2" {
  ami = "ami-09a9858973b288bdd"
  instance_type = "t3.micro"
  key_name = "simpleWebKey"
  security_groups = [aws_security_group.ec2_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d -p 80:80 --name watchtower -v /var/run/docker.sock:/var/run/docker.sock vadimalvaro/lab-4-5:latest
              EOF

  tags = {
    Name = "UbuntuEC2"
  }
}