# Provider configuration
provider "alicloud" {
  region = var.region
}

provider "random" {}

# Generate random suffix for resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# Data sources for getting available resources
data "alicloud_zones" "default" {
  available_disk_category     = "cloud_essd"
  available_resource_creation = "VSwitch"
  available_instance_type     = var.instance_type
}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_x64_20G_alibase_.*"
  most_recent = true
  owners      = "system"
}

# Call the oss-nginx module
module "oss_nginx" {
  source = "../../"

  # VPC configuration
  vpc_config = {
    vpc_name   = var.vpc_name
    cidr_block = var.vpc_cidr_block
  }

  # VSwitch configuration
  vswitch_config = {
    vswitch_name = var.vswitch_name
    cidr_block   = var.vswitch_cidr_block
    zone_id      = data.alicloud_zones.default.zones[0].id
  }

  # Security group configuration
  security_group_config = {
    security_group_name = var.security_group_name
  }

  # Security group rules configuration - using VPC CIDR block for ingress rules
  security_group_rules_config = var.security_group_rules

  # ECS instance configuration
  instance_config = {
    instance_name              = var.instance_name
    image_id                   = data.alicloud_images.default.images[0].id
    instance_type              = var.instance_type
    system_disk_category       = var.system_disk_category
    password                   = var.ecs_instance_password
    internet_max_bandwidth_out = var.internet_max_bandwidth_out
  }

  # SLS log project configuration
  log_project_config = {
    project_name = "${var.sls_project_name}-${random_id.suffix.hex}"
  }

  # SLS log store configuration
  log_store_config = {
    logstore_name = "${var.sls_logstore_name}-${random_id.suffix.hex}"
  }

  # OSS bucket configuration
  oss_bucket_config = {
    bucket        = "${var.oss_bucket_name}-${random_id.suffix.hex}"
    storage_class = var.oss_storage_class
    force_destroy = true
  }
}