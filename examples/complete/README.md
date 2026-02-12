# Complete Example

This example demonstrates the complete usage of the oss-nginx module, which implements an application log data archiving solution. The solution involves creating resources such as VPC, VSwitch, ECS instances, RAM users, SLS (Simple Log Service) projects, and OSS buckets.

## Architecture

The example creates:

- **VPC and VSwitch**: Network infrastructure for hosting resources
- **Security Group**: Network access control with rules for SSH, HTTP, and database access
- **ECS Instance**: Virtual machine that runs nginx and generates logs
- **RAM User and Access Key**: Identity and access management for log operations
- **SLS Project and Log Store**: Log collection and storage service
- **Log Machine Group and Logtail Config**: Log collection agent configuration
- **RAM Role**: Service role for SLS to access OSS
- **OSS Bucket**: Object storage for log archiving
- **SLS OSS Export Sink**: Automated log export from SLS to OSS

## Usage

1. **Set up provider credentials**: Configure your Alibaba Cloud credentials using environment variables or credential files.

2. **Set required variables**: Create a `terraform.tfvars` file or set variables through other methods:

```hcl
region                     = "cn-hangzhou"
vpc_cidr_block            = "192.168.0.0/16"
vswitch_cidr_block        = "192.168.0.0/24"
ecs_instance_password     = "YourSecurePassword123!"
instance_type             = "ecs.t6-c1m2.large"
```

3. **Initialize and apply**:

```bash
terraform init
terraform plan
terraform apply
```

## Required Variables

- `ecs_instance_password`: The password for ECS instance login. Must be 8-30 characters and contain uppercase letters, lowercase letters, numbers, and special symbols.

## Important Notes

- **Log Generation**: After deployment, the ECS instance will automatically install nginx and set up a cron job to generate sample log entries every minute.

- **Log Collection**: The logtail agent will collect nginx access logs from `/var/log/nginx/access.log` and send them to the SLS log store.

- **Log Archiving**: The SLS OSS export sink will automatically archive logs from the log store to the OSS bucket.

- **Access Instance**: Use the `ecs_login_address` output to access the ECS instance through the Alibaba Cloud console. Once logged in, you can view the generated log files using: `tail -f /var/log/nginx/access.log`

- **Security**: The security group is configured to allow SSH (port 22), HTTP (port 80), and database (port 3306) access within the VPC CIDR range.

## Outputs

The example outputs key information including:

- VPC and ECS instance IDs
- ECS login address for console access
- SLS project and log store names
- OSS bucket name for archived logs
- RAM user credentials for programmatic access

## Clean Up

To destroy the resources:

```bash
terraform destroy
```

**Note**: The OSS bucket is configured with `force_destroy = true` to allow deletion even if it contains objects.