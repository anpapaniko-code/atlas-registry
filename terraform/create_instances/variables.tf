variable "aws_region" {
  description = "AWS region where the runtime infrastructure will be created"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the runtime infrastructure will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the load balancer"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Subnet IDs for the three application instances"
  type        = list(string)
}

variable "db_subnet_id" {
  description = "Subnet ID for the database instance"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2 instances"
  type        = string
}

variable "app_instance_type" {
  description = "EC2 instance type for the Spring Boot application instances"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_type" {
  description = "EC2 instance type for the database instance"
  type        = string
  default     = "t2.micro"
}

variable "app_ami_id" {
  description = "AMI ID for the Spring Boot application image"
  type        = string
}

variable "db_ami_id" {
  description = "AMI ID for the database image"
  type        = string
}

variable "app_port" {
  description = "Port exposed by the Spring Boot application"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Port exposed by the database server"
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "Database name used by the application"
  type        = string
}

variable "db_username" {
  description = "Database username used by the application"
  type        = string
}

variable "db_password" {
  description = "Database password used by the application"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "Git repository URL of the project"
  type        = string
}

variable "github_branch" {
  description = "Git branch to clone"
  type        = string
  default     = "main"
}