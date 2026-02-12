# Application log data archiving solution main configuration
# This module creates a complete infrastructure for collecting, storing, and archiving application logs

# Get current region information
data "alicloud_regions" "current" {
  current = true
}

locals {
  # Common name for resource naming
  common_name = var.common_name

  # Default ECS command script for installing and configuring nginx with loongcollector
  default_nginx_setup_script = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx

wget http://aliyun-observability-release-${data.alicloud_regions.current.regions[0].id}.oss-${data.alicloud_regions.current.regions[0].id}.aliyuncs.com/loongcollector/linux64/latest/loongcollector.sh -O loongcollector.sh
chmod +x loongcollector.sh
./loongcollector.sh install ${data.alicloud_regions.current.regions[0].id}-internet

cat << EOJ >> genlog.sh
echo "127.0.0.1 - - [\\$(date +'%d/%b/%Y:%H:%M:%S %z')] \\"GET /HTTP/1.1\\" 200 4897 \\"-\\" \\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36\\"" >> /var/log/nginx/access.log
EOJ
chmod +x genlog.sh

cat << EOT >> crontest.cron
* * * * * ./genlog.sh
EOT

crontab crontest.cron
EOF
  )
}

# Create VPC for the infrastructure
resource "alicloud_vpc" "vpc" {
  vpc_name   = var.vpc_config.vpc_name
  cidr_block = var.vpc_config.cidr_block
}

# Create VSwitch in the VPC
resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  vswitch_name = var.vswitch_config.vswitch_name
  cidr_block   = var.vswitch_config.cidr_block
  zone_id      = var.vswitch_config.zone_id
}

# Create security group for ECS instances
resource "alicloud_security_group" "security_group" {
  vpc_id              = alicloud_vpc.vpc.id
  security_group_name = var.security_group_config.security_group_name
}

# Security group rules using for_each for aggregation
resource "alicloud_security_group_rule" "rules" {
  for_each = var.security_group_rules_config

  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  nic_type          = each.value.nic_type
  policy            = each.value.policy
  port_range        = each.value.port_range
  priority          = each.value.priority
  security_group_id = alicloud_security_group.security_group.id
  cidr_ip           = each.value.cidr_ip
}

# Create ECS instance for log generation
resource "alicloud_instance" "ecs_instance" {
  instance_name              = var.instance_config.instance_name
  image_id                   = var.instance_config.image_id
  instance_type              = var.instance_config.instance_type
  system_disk_category       = var.instance_config.system_disk_category
  security_groups            = [alicloud_security_group.security_group.id]
  vswitch_id                 = alicloud_vswitch.vswitch.id
  password                   = var.instance_config.password
  internet_max_bandwidth_out = var.instance_config.internet_max_bandwidth_out
}

# Create ECS command for nginx and loongcollector setup
resource "alicloud_ecs_command" "nginx_setup_command" {
  name            = var.ecs_command_config.name
  command_content = var.custom_nginx_setup_script != null ? var.custom_nginx_setup_script : local.default_nginx_setup_script
  working_dir     = var.ecs_command_config.working_dir
  type            = var.ecs_command_config.type
  timeout         = var.ecs_command_config.timeout
}

# Execute the nginx setup command on ECS instance
resource "alicloud_ecs_invocation" "nginx_setup_invocation" {
  instance_id = [alicloud_instance.ecs_instance.id]
  command_id  = alicloud_ecs_command.nginx_setup_command.id
  timeouts {
    create = var.ecs_invocation_config.create_timeout
  }
  depends_on = [alicloud_instance.ecs_instance]
}

# Create SLS project for log storage
resource "alicloud_log_project" "sls_project" {
  project_name = var.log_project_config.project_name
}

# Create log store within the project
resource "alicloud_log_store" "sls_log_store" {
  logstore_name = var.log_store_config.logstore_name
  project_name  = alicloud_log_project.sls_project.project_name
  depends_on    = [alicloud_log_project.sls_project]
}

# Create machine group for logtail
resource "alicloud_log_machine_group" "machine_group" {
  identify_list = alicloud_instance.ecs_instance[*].primary_ip_address
  name          = var.log_machine_group_config.name
  project       = alicloud_log_project.sls_project.project_name
  identify_type = var.log_machine_group_config.identify_type
}

# Create logtail configuration for nginx log collection
resource "alicloud_logtail_config" "logtail_config" {
  project      = alicloud_log_project.sls_project.project_name
  input_detail = jsonencode(var.nginx_logtail_config)
  input_type   = var.logtail_config_config.input_type
  logstore     = alicloud_log_store.sls_log_store.logstore_name
  name         = var.logtail_config_config.name
  output_type  = var.logtail_config_config.output_type
}

# Attach logtail configuration to machine group
resource "alicloud_logtail_attachment" "logtail_attachment" {
  project             = alicloud_log_project.sls_project.project_name
  logtail_config_name = alicloud_logtail_config.logtail_config.name
  machine_group_name  = alicloud_log_machine_group.machine_group.name
}

# Create log store index for search functionality
resource "alicloud_log_store_index" "sls_index" {
  project  = alicloud_log_project.sls_project.project_name
  logstore = alicloud_log_store.sls_log_store.logstore_name
  full_text {
    token = var.log_store_index_config.full_text_token
  }
  field_search {
    name  = var.log_store_index_config.field_search.name
    type  = var.log_store_index_config.field_search.type
    token = var.log_store_index_config.field_search.token
  }
  depends_on = [alicloud_log_store.sls_log_store]
}

# Create RAM role for SLS OSS export
resource "alicloud_ram_role" "log_default_role" {
  role_name                   = "log-default-role-${local.common_name}"
  assume_role_policy_document = <<EOF
  {
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "log.aliyuncs.com"
        ]
      }
    }
  ],
  "Version": "1"
  }
  EOF
}

# Attach policy to RAM role
resource "alicloud_ram_role_policy_attachment" "attach_policy_to_role" {
  role_name   = alicloud_ram_role.log_default_role.role_name
  policy_type = "System"
  policy_name = "AliyunLogRolePolicy"
}

# Create OSS bucket for log archiving
resource "alicloud_oss_bucket" "oss_bucket" {
  bucket        = var.oss_bucket_config.bucket
  storage_class = var.oss_bucket_config.storage_class
  force_destroy = var.oss_bucket_config.force_destroy
}

# Create SLS OSS export sink for log archiving
resource "alicloud_sls_oss_export_sink" "oss_export_sink" {
  project      = alicloud_log_project.sls_project.project_name
  display_name = "${var.oss_export_sink_config.display_name}-${local.common_name}"
  job_name     = "${var.oss_export_sink_config.job_name}-${local.common_name}"
  configuration {
    logstore  = alicloud_log_store.sls_log_store.logstore_name
    role_arn  = alicloud_ram_role.log_default_role.arn
    from_time = var.oss_export_sink_config.from_time
    to_time   = var.oss_export_sink_config.to_time
    sink {
      bucket           = alicloud_oss_bucket.oss_bucket.bucket
      buffer_interval  = var.oss_export_sink_config.sink.buffer_interval
      buffer_size      = var.oss_export_sink_config.sink.buffer_size
      compression_type = var.oss_export_sink_config.sink.compression_type
      content_type     = var.oss_export_sink_config.sink.content_type
      content_detail   = jsonencode(var.oss_export_content_detail)
      endpoint         = "https://oss-${data.alicloud_regions.current.regions[0].id}-internal.aliyuncs.com"
      time_zone        = var.oss_export_sink_config.sink.time_zone
      role_arn         = alicloud_ram_role.log_default_role.arn
      prefix           = var.oss_export_sink_config.sink.prefix
      suffix           = var.oss_export_sink_config.sink.suffix
      path_format      = var.oss_export_sink_config.sink.path_format
    }
  }
}