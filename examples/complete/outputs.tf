# Output the key information from the module
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.oss_nginx.vpc_id
}

output "ecs_instance_id" {
  description = "The ID of the ECS instance"
  value       = module.oss_nginx.ecs_instance_id
}

output "ecs_login_address" {
  description = "The ECS workbench login address for accessing the instance that generates logs"
  value       = module.oss_nginx.ecs_login_address
}

output "log_project_name" {
  description = "The name of the SLS log project"
  value       = module.oss_nginx.log_project_name
}

output "log_store_name" {
  description = "The name of the SLS log store"
  value       = module.oss_nginx.log_store_name
}

output "oss_bucket_name" {
  description = "The name of the OSS bucket for log archiving"
  value       = module.oss_nginx.oss_bucket_name
}