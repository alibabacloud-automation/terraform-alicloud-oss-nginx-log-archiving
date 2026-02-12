variable "common_name" {
  description = "Common name suffix for resource naming"
  type        = string
  default     = "oss-nginx-log"
}

variable "vpc_config" {
  description = "Configuration for VPC. The attribute 'cidr_block' is required."
  type = object({
    vpc_name   = optional(string, "vpc")
    cidr_block = string
  })
}

variable "vswitch_config" {
  description = "Configuration for VSwitch. The attributes 'cidr_block' and 'zone_id' are required."
  type = object({
    vswitch_name = optional(string, "vswitch")
    cidr_block   = string
    zone_id      = string
  })
}

variable "security_group_config" {
  description = "Configuration for security group"
  type = object({
    security_group_name = optional(string, "sg")
  })
  default = {}
}

variable "security_group_rules_config" {
  description = "Configuration for security group rules"
  type = map(object({
    type        = string
    ip_protocol = string
    nic_type    = optional(string, "intranet")
    policy      = optional(string, "accept")
    port_range  = string
    priority    = optional(number, 1)
    cidr_ip     = optional(string, "0.0.0.0/0")
  }))
  default = {
    ssh = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "22/22"
    }
    http = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
    }
    db = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "3306/3306"
    }
  }
}

variable "instance_config" {
  description = "Configuration for ECS instance. The attributes 'image_id', 'instance_type', 'system_disk_category', and 'password' are required."
  type = object({
    instance_name              = optional(string, "ecs")
    image_id                   = string
    instance_type              = string
    system_disk_category       = string
    password                   = string
    internet_max_bandwidth_out = optional(number, 5)
  })
}

variable "ecs_command_config" {
  description = "Configuration for ECS command"
  type = object({
    name        = optional(string, "command-run-nginx-loongcollector")
    working_dir = optional(string, "/root")
    type        = optional(string, "RunShellScript")
    timeout     = optional(number, 3600)
  })
  default = {}
}

variable "custom_nginx_setup_script" {
  description = "Custom nginx setup script content (base64 encoded). If not provided, the default script will be used."
  type        = string
  default     = null
}

variable "ecs_invocation_config" {
  description = "Configuration for ECS command invocation"
  type = object({
    create_timeout = optional(string, "15m")
  })
  default = {}
}

variable "log_project_config" {
  description = "Configuration for SLS log project"
  type = object({
    project_name = optional(string, "sls-project")
  })
  default = {}
}

variable "log_store_config" {
  description = "Configuration for SLS log store"
  type = object({
    logstore_name = optional(string, "sls-logstore")
  })
  default = {}
}

variable "log_machine_group_config" {
  description = "Configuration for SLS log machine group"
  type = object({
    name          = optional(string, "lmg")
    identify_type = optional(string, "ip")
  })
  default = {}
}

variable "logtail_config_config" {
  description = "Configuration for logtail configuration"
  type = object({
    input_type  = optional(string, "file")
    name        = optional(string, "lc")
    output_type = optional(string, "LogService")
  })
  default = {}
}

variable "nginx_logtail_config" {
  description = "Logtail configuration for nginx access log collection in JSON format"
  type = object({
    discardUnmatch = optional(bool, false)
    enableRawLog   = optional(bool, true)
    fileEncoding   = optional(string, "utf8")
    filePattern    = optional(string, "access.log")
    logPath        = optional(string, "/var/log/nginx/")
    logType        = optional(string, "common_reg_log")
    maxDepth       = optional(number, 10)
    topicFormat    = optional(string, "none")
  })
  default = {}
}

variable "log_store_index_config" {
  description = "Configuration for log store index"
  type = object({
    full_text_token = optional(string, " :#$^*\r\n\t")
    field_search = object({
      name  = optional(string, "content")
      type  = optional(string, "text")
      token = optional(string, " :#$^*\r\n\t")
    })
  })
  default = {
    field_search = {}
  }
}

variable "oss_bucket_config" {
  description = "Configuration for OSS bucket"
  type = object({
    bucket        = optional(string, "bucket")
    storage_class = optional(string, "IA")
    force_destroy = optional(bool, true)
  })
  default = {}
}

variable "oss_export_content_detail" {
  description = "OSS export sink content detail configuration"
  type = object({
    enableTag = optional(bool, true)
  })
  default = {}
}

variable "oss_export_sink_config" {
  description = "Configuration for SLS OSS export sink"
  type = object({
    display_name = optional(string, "display")
    job_name     = optional(string, "export")
    from_time    = optional(number, 1)
    to_time      = optional(number, 0)
    sink = object({
      buffer_interval  = optional(string, "300")
      buffer_size      = optional(string, "250")
      compression_type = optional(string, "gzip")
      content_type     = optional(string, "json")
      time_zone        = optional(string, "+0800")
      prefix           = optional(string, "app01")
      suffix           = optional(string, "")
      path_format      = optional(string, "%Y/%m/%d/%H/%M")
    })
  })
  default = {
    sink = {}
  }
}