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

############################
# SECURITY GROUPS
############################

# Load Balancer SG
resource "aws_security_group" "lb_sg" {
  name   = "${var.project_name}-lb-sg"
  vpc_id = var.vpc_id

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
}

# App SG
resource "aws_security_group" "app_sg" {
  name   = "${var.project_name}-app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB SG
resource "aws_security_group" "db_sg" {
  name   = "${var.project_name}-db-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# DATABASE INSTANCE
############################

resource "aws_instance" "database" {
  ami                         = var.db_ami_id
  instance_type               = var.db_instance_type
  subnet_id                   = var.db_subnet_id
  vpc_security_group_ids      = [aws_security_group.db_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y git

    cd /home/ubuntu
    git clone --branch ${var.github_branch} ${var.github_repo_url} project

    chmod +x project/terraform/scripts/configure_db_runtime.sh

    bash project/terraform/scripts/configure_db_runtime.sh \
      ${var.db_name} \
      ${var.db_username} \
      ${var.db_password}
  EOF

  tags = {
    Name = "${var.project_name}-db"
  }
}

############################
# APPLICATION INSTANCES (3)
############################

resource "aws_instance" "application" {
  count                       = 3
  ami                         = var.app_ami_id
  instance_type               = var.app_instance_type
  subnet_id                   = element(var.app_subnet_ids, count.index)
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y git

    cd /home/ubuntu
    git clone --branch ${var.github_branch} ${var.github_repo_url} project

    chmod +x project/terraform/scripts/configure_app_runtime.sh

    bash project/terraform/scripts/configure_app_runtime.sh \
      ${aws_instance.database.private_ip} \
      ${var.db_port} \
      ${var.db_name} \
      ${var.db_username} \
      ${var.db_password}
  EOF

  tags = {
    Name = "${var.project_name}-app-${count.index}"
  }
}

############################
# LOAD BALANCER
############################

resource "aws_lb" "app_lb" {
  name               = "${var.project_name}-lb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.lb_sg.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    port = var.app_port
  }
}

resource "aws_lb_target_group_attachment" "app_attach" {
  count            = 3
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.application[count.index].id
  port             = var.app_port
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}