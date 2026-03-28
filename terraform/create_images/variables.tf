variable "aws_region" {
  description = "AWS region where temporary builder instances and AMIs will be created"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the temporary builder instances will run"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the temporary builder instances"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the builder instances"
  type        = string
}

variable "app_instance_type" {
  description = "EC2 instance type for the application image builder"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_type" {
  description = "EC2 instance type for the database image builder"
  type        = string
  default     = "t2.micro"
}

variable "github_repo_url" {
  description = "Git repository URL of the Maven project"
  type        = string
}

variable "github_branch" {
  description = "Git branch to clone"
  type        = string
  default     = "main"
}

variable "app_image_name" {
  description = "Name of the application AMI"
  type        = string
}

variable "db_image_name" {
  description = "Name of the database AMI"
  type        = string
}