output "database_instance_id" {
  description = "ID of the database EC2 instance"
  value       = aws_instance.database.id
}

output "database_private_ip" {
  description = "Private IP of the database EC2 instance"
  value       = aws_instance.database.private_ip
}

output "application_instance_ids" {
  description = "IDs of the three application EC2 instances"
  value       = aws_instance.application[*].id
}

output "application_private_ips" {
  description = "Private IPs of the three application EC2 instances"
  value       = aws_instance.application[*].private_ip
}

output "load_balancer_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.app_lb.dns_name
}

output "target_group_arn" {
  description = "ARN of the load balancer target group"
  value       = aws_lb_target_group.app_tg.arn
}