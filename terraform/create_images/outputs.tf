output "db_builder_instance_id" {
  description = "ID of the temporary database builder instance"
  value       = aws_instance.db_builder.id
}

output "app_builder_instance_id" {
  description = "ID of the temporary application builder instance"
  value       = aws_instance.app_builder.id
}

output "db_image_id" {
  description = "AMI ID created for the database image"
  value       = aws_ami_from_instance.db_image.id
}

output "app_image_id" {
  description = "AMI ID created for the application image"
  value       = aws_ami_from_instance.app_image.id
}