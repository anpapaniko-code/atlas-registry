terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############################
# SG
############################

resource "aws_security_group" "image_builders_sg" {
  name        = "${var.project_name}-image-builders-sg"
  description = "Security group for temporary image builder instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# DB BUILDER
############################

resource "aws_instance" "db_builder" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.db_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.image_builders_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    apt-get update -y
    apt-get install -y git

    cd /home/ubuntu
    git clone --branch ${var.github_branch} ${var.github_repo_url} project

    chmod +x project/terraform/scripts/install_db_image.sh
    bash project/terraform/scripts/install_db_image.sh

    echo "READY" > /home/ubuntu/READY
  EOF

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /home/ubuntu/READY ]; do sleep 5; done"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

resource "aws_ami_from_instance" "db_image" {
  name               = var.db_image_name
  source_instance_id = aws_instance.db_builder.id

  depends_on = [aws_instance.db_builder]
}

############################
# APP BUILDER (FIXED)
############################

resource "aws_instance" "app_builder" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.app_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.image_builders_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    apt-get update -y
    apt-get install -y git

    cd /home/ubuntu
    git clone --branch ${var.github_branch} ${var.github_repo_url} project

    chmod +x project/terraform/scripts/install_app_image.sh
    bash project/terraform/scripts/install_app_image.sh

    echo "READY" > /home/ubuntu/READY
  EOF

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /home/ubuntu/READY ]; do sleep 5; done"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

resource "aws_ami_from_instance" "app_image" {
  name               = var.app_image_name
  source_instance_id = aws_instance.app_builder.id

  depends_on = [aws_instance.app_builder]
}