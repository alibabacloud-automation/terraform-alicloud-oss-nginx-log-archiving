variable "region" {
  description = "The region where resources will be created"
  type        = string
  default     = "cn-shanghai"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "example-vpc"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "vswitch_name" {
  description = "The name of the VSwitch"
  type        = string
  default     = "example-vswitch"
}

variable "vswitch_cidr_block" {
  description = "The CIDR block for the VSwitch"
  type        = string
  default     = "192.168.0.0/24"
}

variable "instance_name" {
  description = "The name of the ECS instance"
  type        = string
  default     = "example-ecs"
}

variable "instance_type" {
  description = "The type of ECS instance"
  type        = string
  default     = "ecs.t6-c1m2.large"
}

variable "system_disk_category" {
  description = "The category of system disk"
  type        = string
  default     = "cloud_essd"
}

variable "ecs_instance_password" {
  description = "The password for ECS instance login. Length 8-30, must contain three items (uppercase letters, lowercase letters, numbers, special symbols in ()`~!@#$%^&*_-+=|{}[]:;'<>,.?/)"
  type        = string
  sensitive   = true
}

variable "internet_max_bandwidth_out" {
  description = "The maximum internet bandwidth out for ECS instance"
  type        = number
  default     = 5
}

variable "sls_project_name" {
  description = "The name of the SLS project (random suffix will be added automatically)"
  type        = string
  default     = "example-sls-project"
}

variable "sls_logstore_name" {
  description = "The name of the SLS logstore (random suffix will be added automatically)"
  type        = string
  default     = "example-logstore"
}

variable "oss_bucket_name" {
  description = "The name of the OSS bucket (random suffix will be added automatically)"
  type        = string
  default     = "example-oss-bucket"
}

variable "oss_storage_class" {
  description = "The storage class of the OSS bucket"
  type        = string
  default     = "IA"
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "example-security-group"
}

variable "security_group_rules" {
  description = "Map of security group rules to create"
  type = map(object({
    type        = string
    ip_protocol = string
    port_range  = string
    priority    = optional(number, 1)
    cidr_ip     = string
  }))
  default = {
    ssh = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "22/22"
      cidr_ip     = "192.168.0.0/16"
    }
    http = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "192.168.0.0/16"
    }
  }
}