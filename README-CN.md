阿里云应用日志数据归档解决方案 Terraform 模块

# terraform-alicloud-oss-nginx-log-archiving

[English](https://github.com/alibabacloud-automation/terraform-alicloud-oss-nginx-log-archiving/blob/main/README.md) | 简体中文

用于在阿里云上创建完整应用日志数据归档解决方案的 Terraform 模块。该模块实现了[应用日志数据归档](https://www.aliyun.com/solution/tech-solution/oss-nginx)解决方案，涉及专有网络（VPC）、交换机（VSwitch）、云服务器（ECS）、日志服务（SLS）项目和对象存储服务（OSS）存储桶等资源的创建和部署，用于自动化日志收集、处理和归档。

## 使用方法

该模块建立了一个综合的日志归档基础设施，包括 nginx 日志生成、通过 SLS logtail 收集以及自动归档到 OSS 存储。

```terraform
data "alicloud_zones" "default" {
  available_disk_category     = "cloud_essd"
  available_resource_creation = "VSwitch"
  available_instance_type     = "ecs.t6-c1m2.large"
}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_x64_20G_alibase_.*"
  most_recent = true
  owners      = "system"
}

module "oss_nginx_log_archiving" {
  source = "alibabacloud-automation/oss-nginx-log-archiving/alicloud"

  vpc_config = {
    cidr_block = "192.168.0.0/16"
  }

  vswitch_config = {
    cidr_block = "192.168.0.0/24"
    zone_id    = data.alicloud_zones.default.zones[0].id
  }

  instance_config = {
    image_id             = data.alicloud_images.default.images[0].id
    instance_type        = "ecs.t6-c1m2.large"
    system_disk_category = "cloud_essd"
    password             = "YourSecurePassword123!"
  }
}
```

## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-oss-nginx-log-archiving/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.212.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | >= 1.212.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_ecs_command.nginx_setup_command](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_invocation.nginx_setup_invocation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_instance.ecs_instance](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_log_machine_group.machine_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_machine_group) | resource |
| [alicloud_log_project.sls_project](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_project) | resource |
| [alicloud_log_store.sls_log_store](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_store) | resource |
| [alicloud_log_store_index.sls_index](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_store_index) | resource |
| [alicloud_logtail_attachment.logtail_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/logtail_attachment) | resource |
| [alicloud_logtail_config.logtail_config](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/logtail_config) | resource |
| [alicloud_oss_bucket.oss_bucket](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/oss_bucket) | resource |
| [alicloud_ram_role.log_default_role](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_role) | resource |
| [alicloud_ram_role_policy_attachment.attach_policy_to_role](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_role_policy_attachment) | resource |
| [alicloud_security_group.security_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.rules](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_sls_oss_export_sink.oss_export_sink](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sls_oss_export_sink) | resource |
| [alicloud_vpc.vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.vswitch](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_regions.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/regions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_name"></a> [common\_name](#input\_common\_name) | Common name suffix for resource naming | `string` | `"oss-nginx-log"` | no |
| <a name="input_custom_nginx_setup_script"></a> [custom\_nginx\_setup\_script](#input\_custom\_nginx\_setup\_script) | Custom nginx setup script content (base64 encoded). If not provided, the default script will be used. | `string` | `null` | no |
| <a name="input_ecs_command_config"></a> [ecs\_command\_config](#input\_ecs\_command\_config) | Configuration for ECS command | <pre>object({<br/>    name        = optional(string, "command-run-nginx-loongcollector")<br/>    working_dir = optional(string, "/root")<br/>    type        = optional(string, "RunShellScript")<br/>    timeout     = optional(number, 3600)<br/>  })</pre> | `{}` | no |
| <a name="input_ecs_invocation_config"></a> [ecs\_invocation\_config](#input\_ecs\_invocation\_config) | Configuration for ECS command invocation | <pre>object({<br/>    create_timeout = optional(string, "15m")<br/>  })</pre> | `{}` | no |
| <a name="input_instance_config"></a> [instance\_config](#input\_instance\_config) | Configuration for ECS instance. The attributes 'image\_id', 'instance\_type', 'system\_disk\_category', and 'password' are required. | <pre>object({<br/>    instance_name              = optional(string, "ecs")<br/>    image_id                   = string<br/>    instance_type              = string<br/>    system_disk_category       = string<br/>    password                   = string<br/>    internet_max_bandwidth_out = optional(number, 5)<br/>  })</pre> | n/a | yes |
| <a name="input_log_machine_group_config"></a> [log\_machine\_group\_config](#input\_log\_machine\_group\_config) | Configuration for SLS log machine group | <pre>object({<br/>    name          = optional(string, "lmg")<br/>    identify_type = optional(string, "ip")<br/>  })</pre> | `{}` | no |
| <a name="input_log_project_config"></a> [log\_project\_config](#input\_log\_project\_config) | Configuration for SLS log project | <pre>object({<br/>    project_name = optional(string, "sls-project")<br/>  })</pre> | `{}` | no |
| <a name="input_log_store_config"></a> [log\_store\_config](#input\_log\_store\_config) | Configuration for SLS log store | <pre>object({<br/>    logstore_name = optional(string, "sls-logstore")<br/>  })</pre> | `{}` | no |
| <a name="input_log_store_index_config"></a> [log\_store\_index\_config](#input\_log\_store\_index\_config) | Configuration for log store index | <pre>object({<br/>    full_text_token = optional(string, " :#$^*\r\n\t")<br/>    field_search = object({<br/>      name  = optional(string, "content")<br/>      type  = optional(string, "text")<br/>      token = optional(string, " :#$^*\r\n\t")<br/>    })<br/>  })</pre> | <pre>{<br/>  "field_search": {}<br/>}</pre> | no |
| <a name="input_logtail_config_config"></a> [logtail\_config\_config](#input\_logtail\_config\_config) | Configuration for logtail configuration | <pre>object({<br/>    input_type  = optional(string, "file")<br/>    name        = optional(string, "lc")<br/>    output_type = optional(string, "LogService")<br/>  })</pre> | `{}` | no |
| <a name="input_nginx_logtail_config"></a> [nginx\_logtail\_config](#input\_nginx\_logtail\_config) | Logtail configuration for nginx access log collection in JSON format | <pre>object({<br/>    discardUnmatch = optional(bool, false)<br/>    enableRawLog   = optional(bool, true)<br/>    fileEncoding   = optional(string, "utf8")<br/>    filePattern    = optional(string, "access.log")<br/>    logPath        = optional(string, "/var/log/nginx/")<br/>    logType        = optional(string, "common_reg_log")<br/>    maxDepth       = optional(number, 10)<br/>    topicFormat    = optional(string, "none")<br/>  })</pre> | `{}` | no |
| <a name="input_oss_bucket_config"></a> [oss\_bucket\_config](#input\_oss\_bucket\_config) | Configuration for OSS bucket | <pre>object({<br/>    bucket        = optional(string, "bucket")<br/>    storage_class = optional(string, "IA")<br/>    force_destroy = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_oss_export_content_detail"></a> [oss\_export\_content\_detail](#input\_oss\_export\_content\_detail) | OSS export sink content detail configuration | <pre>object({<br/>    enableTag = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_oss_export_sink_config"></a> [oss\_export\_sink\_config](#input\_oss\_export\_sink\_config) | Configuration for SLS OSS export sink | <pre>object({<br/>    display_name = optional(string, "display")<br/>    job_name     = optional(string, "export")<br/>    from_time    = optional(number, 1)<br/>    to_time      = optional(number, 0)<br/>    sink = object({<br/>      buffer_interval  = optional(string, "300")<br/>      buffer_size      = optional(string, "250")<br/>      compression_type = optional(string, "gzip")<br/>      content_type     = optional(string, "json")<br/>      time_zone        = optional(string, "+0800")<br/>      prefix           = optional(string, "app01")<br/>      suffix           = optional(string, "")<br/>      path_format      = optional(string, "%Y/%m/%d/%H/%M")<br/>    })<br/>  })</pre> | <pre>{<br/>  "sink": {}<br/>}</pre> | no |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | Configuration for security group | <pre>object({<br/>    security_group_name = optional(string, "sg")<br/>  })</pre> | `{}` | no |
| <a name="input_security_group_rules_config"></a> [security\_group\_rules\_config](#input\_security\_group\_rules\_config) | Configuration for security group rules | <pre>map(object({<br/>    type        = string<br/>    ip_protocol = string<br/>    nic_type    = optional(string, "intranet")<br/>    policy      = optional(string, "accept")<br/>    port_range  = string<br/>    priority    = optional(number, 1)<br/>    cidr_ip     = optional(string, "0.0.0.0/0")<br/>  }))</pre> | <pre>{<br/>  "db": {<br/>    "ip_protocol": "tcp",<br/>    "port_range": "3306/3306",<br/>    "type": "ingress"<br/>  },<br/>  "http": {<br/>    "ip_protocol": "tcp",<br/>    "port_range": "80/80",<br/>    "type": "ingress"<br/>  },<br/>  "ssh": {<br/>    "ip_protocol": "tcp",<br/>    "port_range": "22/22",<br/>    "type": "ingress"<br/>  }<br/>}</pre> | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | Configuration for VPC. The attribute 'cidr\_block' is required. | <pre>object({<br/>    vpc_name   = optional(string, "vpc")<br/>    cidr_block = string<br/>  })</pre> | n/a | yes |
| <a name="input_vswitch_config"></a> [vswitch\_config](#input\_vswitch\_config) | Configuration for VSwitch. The attributes 'cidr\_block' and 'zone\_id' are required. | <pre>object({<br/>    vswitch_name = optional(string, "vswitch")<br/>    cidr_block   = string<br/>    zone_id      = string<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_command_id"></a> [ecs\_command\_id](#output\_ecs\_command\_id) | The ID of the ECS command for nginx setup |
| <a name="output_ecs_instance_id"></a> [ecs\_instance\_id](#output\_ecs\_instance\_id) | The ID of the ECS instance |
| <a name="output_ecs_instance_private_ip"></a> [ecs\_instance\_private\_ip](#output\_ecs\_instance\_private\_ip) | The private IP address of the ECS instance |
| <a name="output_ecs_instance_public_ip"></a> [ecs\_instance\_public\_ip](#output\_ecs\_instance\_public\_ip) | The public IP address of the ECS instance |
| <a name="output_ecs_invocation_id"></a> [ecs\_invocation\_id](#output\_ecs\_invocation\_id) | The ID of the ECS command invocation |
| <a name="output_ecs_login_address"></a> [ecs\_login\_address](#output\_ecs\_login\_address) | The ECS workbench login address for accessing the instance that generates logs. Use 'tail -f /var/log/nginx/access.log' to view the generated log files after login. |
| <a name="output_log_machine_group_name"></a> [log\_machine\_group\_name](#output\_log\_machine\_group\_name) | The name of the log machine group |
| <a name="output_log_project_name"></a> [log\_project\_name](#output\_log\_project\_name) | The name of the SLS log project |
| <a name="output_log_store_name"></a> [log\_store\_name](#output\_log\_store\_name) | The name of the SLS log store |
| <a name="output_logtail_config_name"></a> [logtail\_config\_name](#output\_logtail\_config\_name) | The name of the logtail configuration |
| <a name="output_oss_bucket_endpoint"></a> [oss\_bucket\_endpoint](#output\_oss\_bucket\_endpoint) | The extranet endpoint of the OSS bucket |
| <a name="output_oss_bucket_name"></a> [oss\_bucket\_name](#output\_oss\_bucket\_name) | The name of the OSS bucket for log archiving |
| <a name="output_oss_export_sink_job_name"></a> [oss\_export\_sink\_job\_name](#output\_oss\_export\_sink\_job\_name) | The job name of the SLS OSS export sink |
| <a name="output_oss_export_sink_status"></a> [oss\_export\_sink\_status](#output\_oss\_export\_sink\_status) | The status of the SLS OSS export sink |
| <a name="output_ram_role_arn"></a> [ram\_role\_arn](#output\_ram\_role\_arn) | The ARN of the RAM role for SLS |
| <a name="output_ram_role_name"></a> [ram\_role\_name](#output\_ram\_role\_name) | The name of the RAM role for SLS |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vswitch_id"></a> [vswitch\_id](#output\_vswitch\_id) | The ID of the VSwitch |
<!-- END_TF_DOCS -->

## 提交问题

如果您在使用此模块时遇到任何问题，请提交一个 [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) 并告知我们。

**注意：** 不建议在此仓库中提交问题。

## 作者

由阿里云 Terraform 团队创建和维护(terraform@alibabacloud.com)。

## 许可证

MIT 许可。有关完整详细信息，请参阅 LICENSE。

## 参考

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)