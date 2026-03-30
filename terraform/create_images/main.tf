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

  tags = {
    Name    = "${var.project_name}-image-builders-sg"
    Project = var.project_name
    Phase   = "create-images"
  }
}

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
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get install -y git

    cd /home/ubuntu
    rm -rf project
    git clone --branch ${var.github_branch} ${var.github_repo_url} project

    chmod +x /home/ubuntu/project/terraform/scripts/install_db_image.sh
    bash /home/ubuntu/project/terraform/scripts/install_db_image.sh
  EOF

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '[INFO] Waiting for cloud-init to finish on DB builder...'",
      "sudo cloud-init status --wait",
      "echo '[INFO] cloud-init finished on DB builder.'"
    ]
  }

  tags = {
    Name    = "${var.project_name}-db-builder"
    Project = var.project_name
    Phase   = "create-images"
    Role    = "db-builder"
  }
}

resource "aws_ami_from_instance" "db_image" {
  name               = var.db_image_name
  source_instance_id = aws_instance.db_builder.id

  depends_on = [aws_instance.db_builder]

  tags = {
    Name    = var.db_image_name
    Project = var.project_name
    Phase   = "create-images"
    Role    = "db-image"
  }
}

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
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get install -y git

    cd /home/ubuntu
    rm -rf project
    git clone --branch ${var.github_branch} ${var.github_repo_url} project

    chmod +x /home/ubuntu/project/terraform/scripts/install_app_image.sh
    bash /home/ubuntu/project/terraform/scripts/install_app_image.sh
  EOF

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '[INFO] Waiting for cloud-init to finish on APP builder...'",
      "sudo cloud-init status --wait",
      "echo '[INFO] cloud-init finished on APP builder.'",
      "sudo ls -la /opt || true",
      "sudo ls -la /home/ubuntu/project || true",
      "sudo ls -la /home/ubuntu/project/citizen-registry-service/target || true"
    ]
  }

  tags = {
    Name    = "${var.project_name}-app-builder"
    Project = var.project_name
    Phase   = "create-images"
    Role    = "app-builder"
  }
}

resource "aws_ami_from_instance" "app_image" {
  name               = var.app_image_name
  source_instance_id = aws_instance.app_builder.id

  depends_on = [aws_instance.app_builder]

  tags = {
    Name    = var.app_image_name
    Project = var.project_name
    Phase   = "create-images"
    Role    = "app-image"
  }
}