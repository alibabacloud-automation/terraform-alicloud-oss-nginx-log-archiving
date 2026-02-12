# VPC and networking outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.vpc.id
}

output "vswitch_id" {
  description = "The ID of the VSwitch"
  value       = alicloud_vswitch.vswitch.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = alicloud_security_group.security_group.id
}

# ECS instance outputs
output "ecs_instance_id" {
  description = "The ID of the ECS instance"
  value       = alicloud_instance.ecs_instance.id
}

output "ecs_instance_private_ip" {
  description = "The private IP address of the ECS instance"
  value       = alicloud_instance.ecs_instance.primary_ip_address
}

output "ecs_instance_public_ip" {
  description = "The public IP address of the ECS instance"
  value       = alicloud_instance.ecs_instance.public_ip
}

output "ecs_login_address" {
  description = "The ECS workbench login address for accessing the instance that generates logs. Use 'tail -f /var/log/nginx/access.log' to view the generated log files after login."
  value       = format("https://ecs-workbench.aliyun.com/?from=ecs&instanceType=ecs&regionId=%s&instanceId=%s&resourceGroupId=", data.alicloud_regions.current.regions[0].id, alicloud_instance.ecs_instance.id)
}

# SLS project and log store outputs
output "log_project_name" {
  description = "The name of the SLS log project"
  value       = alicloud_log_project.sls_project.project_name
}

output "log_store_name" {
  description = "The name of the SLS log store"
  value       = alicloud_log_store.sls_log_store.logstore_name
}

output "log_machine_group_name" {
  description = "The name of the log machine group"
  value       = alicloud_log_machine_group.machine_group.name
}

output "logtail_config_name" {
  description = "The name of the logtail configuration"
  value       = alicloud_logtail_config.logtail_config.name
}

# RAM role outputs
output "ram_role_name" {
  description = "The name of the RAM role for SLS"
  value       = alicloud_ram_role.log_default_role.role_name
}

output "ram_role_arn" {
  description = "The ARN of the RAM role for SLS"
  value       = alicloud_ram_role.log_default_role.arn
}

# OSS bucket outputs
output "oss_bucket_name" {
  description = "The name of the OSS bucket for log archiving"
  value       = alicloud_oss_bucket.oss_bucket.bucket
}

output "oss_bucket_endpoint" {
  description = "The extranet endpoint of the OSS bucket"
  value       = alicloud_oss_bucket.oss_bucket.extranet_endpoint
}

# SLS OSS export sink outputs
output "oss_export_sink_job_name" {
  description = "The job name of the SLS OSS export sink"
  value       = alicloud_sls_oss_export_sink.oss_export_sink.job_name
}

output "oss_export_sink_status" {
  description = "The status of the SLS OSS export sink"
  value       = alicloud_sls_oss_export_sink.oss_export_sink.status
}

# ECS command outputs
output "ecs_command_id" {
  description = "The ID of the ECS command for nginx setup"
  value       = alicloud_ecs_command.nginx_setup_command.id
}

output "ecs_invocation_id" {
  description = "The ID of the ECS command invocation"
  value       = alicloud_ecs_invocation.nginx_setup_invocation.id
}