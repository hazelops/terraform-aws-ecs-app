# Terraform AWS ECS App Module
[![e2e tests](https://github.com/hazelops/terraform-aws-ecs-app/actions/workflows/run.e2e-tests.yml/badge.svg)](/actions/workflows/run.e2e-tests.yml)

Create and manage AWS ECS application in a clean abstracted way.

This module is actively maintained and is covered by multiple end-to-end [tests](./test/examples_complete-web_test.go) to prevent regressions.

## Features
_This module is feature-rich, with sane [defaults](./variables.tf). Some of the features are:_
- [Web application](./examples/complete-web/main.tf) (ALB + ACM + R53) 
- [Worker application to Fargate](./examples/complete-worker/main.tf) and [Worker application to EC2](./examples/complete-worker-ec2/main.tf) (no ALB)
- [TCP application](./examples/complete-tcp-app/main.tf) (no ALB)
- [Environment variables](#input_environment) (SSM parameters)
- [ECR repo Management](#input_ecr_repo_create) 
- [Standardized naming convention for all resources](#input_name)
- [Deployment via Terraform & via external tool](#input_ecs_service_deployed) (ecs-deploy or ize)
- [Datadog integration](#input_datadog_enabled)
- [Autoscale](#input_autoscale_enabled) ([scheduled](#input_autoscale_scheduled_up) or [target-based](#input_autoscale_target_value_cpu))
- [ECS Launch Type (EC2 or Fargate)](#input_ecs_launch_type)
- [EIP assignment](#input_ec2_eip_enabled)
- Resource configuration ([CPU](#input_cpu)/[MEM](#input_mem))
- EFS ([mount](#input_efs_mount_point) and/or [share management](#input_efs_share_create))
- [GPU-based instance](#input_gpu)
- [Multiple ECS network modes](#input_ecs_network_mode)
- Root block device configuration ([size](#input_root_block_device_size), [type](#input_root_block_device_type))
- [Automatic Nginx Proxy for Web Applications](#inputs_web_proxy_enabled)
- [Firelens / Datadog log driver](#input_firelens_ecs_log_enabled)
- [ECS Exec](#input_ecs_exec_enabled) (console into the container)
- [tmpfs configuration](#input_tmpfs_enabled)

## Usage
This is a minimal example which demostrates simplicity of the module:
```hcl
module "api" {
  source     = "registry.terraform.io/hazelops/ecs-app/aws"
  version    = "~>2.0.0"
  name             = "api"
  
  env              = "prod"
  ecs_cluster_name = "prod-cluster"
  vpc_id           = "vpc-00000000000000000"
  public_subnets   = ["subnet-00000000000000000", "subnet-11111111111111111", "subnet-22222222222222222"]
  private_subnets  = ["subnet-33333333333333333", "subnet-44444444444444444", "subnet-55555555555555555"]
  security_groups  = ["sg-00000000000000000"]
  
  root_domain_name = "example.com"
  zone_id          = "Z00000000000000000000"

  environment = {
    API_KEY   = "00000000000000000000000000000000"
    JWT_TOKEN = "99999999999999999999999999999999"
  }
}
```

See [examples](./examples) for more usage options.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.47.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | registry.terraform.io/terraform-aws-modules/alb/aws | ~> 7.0 |
| <a name="module_autoscaling"></a> [autoscaling](#module\_autoscaling) | terraform-aws-modules/autoscaling/aws | ~> 6.0 |
| <a name="module_datadog"></a> [datadog](#module\_datadog) | registry.terraform.io/hazelops/ecs-datadog-agent/aws | ~> 3.3 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | registry.terraform.io/hazelops/ecr/aws | ~> 1.1 |
| <a name="module_efs"></a> [efs](#module\_efs) | registry.terraform.io/cloudposse/efs/aws | ~> 0.36 |
| <a name="module_nginx"></a> [nginx](#module\_nginx) | registry.terraform.io/hazelops/ecs-nginx-proxy/aws | ~> 1.0 |
| <a name="module_route_53_health_check"></a> [route\_53\_health\_check](#module\_route\_53\_health\_check) | registry.terraform.io/hazelops/route53-healthcheck/aws | ~> 1.0 |
| <a name="module_service"></a> [service](#module\_service) | ./modules/ecs-service | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_role_policy.ec2_auto_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_route53_record.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.asg_ecs_ec2_user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_container_definition_parameters"></a> [additional\_container\_definition\_parameters](#input\_additional\_container\_definition\_parameters) | Additional parameters passed straight to the container definition, eg. tmpfs config | `any` | `{}` | no |
| <a name="input_alb_access_logs_enabled"></a> [alb\_access\_logs\_enabled](#input\_alb\_access\_logs\_enabled) | If true, ALB access logs will be written to S3 | `bool` | `false` | no |
| <a name="input_alb_access_logs_s3bucket_name"></a> [alb\_access\_logs\_s3bucket\_name](#input\_alb\_access\_logs\_s3bucket\_name) | S3 bucket name for ALB access logs | `string` | `""` | no |
| <a name="input_alb_deregistration_delay"></a> [alb\_deregistration\_delay](#input\_alb\_deregistration\_delay) | The amount of time, in seconds, for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused | `number` | `5` | no |
| <a name="input_alb_health_check_healthy_threshold"></a> [alb\_health\_check\_healthy\_threshold](#input\_alb\_health\_check\_healthy\_threshold) | The number of consecutive health checks successes required before considering an unhealthy target healthy | `number` | `3` | no |
| <a name="input_alb_health_check_interval"></a> [alb\_health\_check\_interval](#input\_alb\_health\_check\_interval) | The approximate amount of time, in seconds, between health checks of an individual target | `number` | `30` | no |
| <a name="input_alb_health_check_path"></a> [alb\_health\_check\_path](#input\_alb\_health\_check\_path) | ALB health check path | `string` | `"/health"` | no |
| <a name="input_alb_health_check_timeout"></a> [alb\_health\_check\_timeout](#input\_alb\_health\_check\_timeout) | The amount of time, in seconds, during which no response means a failed health check | `number` | `6` | no |
| <a name="input_alb_health_check_unhealthy_threshold"></a> [alb\_health\_check\_unhealthy\_threshold](#input\_alb\_health\_check\_unhealthy\_threshold) | The number of consecutive health check failures required before considering the target unhealthy | `number` | `3` | no |
| <a name="input_alb_health_check_valid_response_codes"></a> [alb\_health\_check\_valid\_response\_codes](#input\_alb\_health\_check\_valid\_response\_codes) | The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, "200,202") or a range of values (for example, "200-299"). | `string` | `"200-399"` | no |
| <a name="input_alb_idle_timeout"></a> [alb\_idle\_timeout](#input\_alb\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| <a name="input_alb_security_groups"></a> [alb\_security\_groups](#input\_alb\_security\_groups) | Security groups to assign to ALB | `list(any)` | `[]` | no |
| <a name="input_app_secrets"></a> [app\_secrets](#input\_app\_secrets) | List of SSM ParameterStore secret parameters - by default, /$var.env/$var.name/* | `list(any)` | `[]` | no |
| <a name="input_app_type"></a> [app\_type](#input\_app\_type) | ECS application type. Valid values: web (with ALB), worker (without ALB). | `string` | `"web"` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | ECS service network configuration - assign public IP | `bool` | `false` | no |
| <a name="input_autoscale_enabled"></a> [autoscale\_enabled](#input\_autoscale\_enabled) | ECS Autoscaling enabled | `bool` | `false` | no |
| <a name="input_autoscale_scheduled_down"></a> [autoscale\_scheduled\_down](#input\_autoscale\_scheduled\_down) | List of Cron-like expressions for scheduled ecs autoscale DOWN | `list(string)` | `[]` | no |
| <a name="input_autoscale_scheduled_timezone"></a> [autoscale\_scheduled\_timezone](#input\_autoscale\_scheduled\_timezone) | Time Zone for the scheduled event | `string` | `"UTC"` | no |
| <a name="input_autoscale_scheduled_up"></a> [autoscale\_scheduled\_up](#input\_autoscale\_scheduled\_up) | List of Cron-like expressions for scheduled ecs autoscale UP | `list(string)` | `[]` | no |
| <a name="input_autoscale_target_value_cpu"></a> [autoscale\_target\_value\_cpu](#input\_autoscale\_target\_value\_cpu) | ECS Service Average CPU Utilization threshold. Integer value for percentage - IE 80 | `number` | `50` | no |
| <a name="input_autoscale_target_value_memory"></a> [autoscale\_target\_value\_memory](#input\_autoscale\_target\_value\_memory) | ECS Service Average Memory Utilization threshold. Integer value for percentage. IE 60 | `number` | `50` | no |
| <a name="input_autoscaling_health_check_type"></a> [autoscaling\_health\_check\_type](#input\_autoscaling\_health\_check\_type) | ECS 'EC2' or 'ELB' health check type | `string` | `"EC2"` | no |
| <a name="input_autoscaling_max_size"></a> [autoscaling\_max\_size](#input\_autoscaling\_max\_size) | Maximum number of running ECS tasks during scheduled-up-autoscaling action | `number` | `2` | no |
| <a name="input_autoscaling_min_size"></a> [autoscaling\_min\_size](#input\_autoscaling\_min\_size) | Minimum number of running ECS tasks during scheduled-up-autoscaling action | `number` | `2` | no |
| <a name="input_aws_service_discovery_private_dns_namespace"></a> [aws\_service\_discovery\_private\_dns\_namespace](#input\_aws\_service\_discovery\_private\_dns\_namespace) | Amazon ECS Service Discovery private DNS namespace | `string` | `""` | no |
| <a name="input_cloudwatch_schedule_expressions"></a> [cloudwatch\_schedule\_expressions](#input\_cloudwatch\_schedule\_expressions) | List of Cron-like Cloudwatch Event Rule schedule expressions (UTC time zone) | `list(any)` | `[]` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Fargate CPU value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) | `number` | `256` | no |
| <a name="input_cpu_architecture"></a> [cpu\_architecture](#input\_cpu\_architecture) | When you register a task definition, you specify the CPU architecture. The valid values are X86\_64 and ARM64 | `string` | `"X86_64"` | no |
| <a name="input_create_iam_instance_profile"></a> [create\_iam\_instance\_profile](#input\_create\_iam\_instance\_profile) | Determines whether an IAM instance profile is created or to use an existing IAM instance profile | `bool` | `true` | no |
| <a name="input_create_schedule"></a> [create\_schedule](#input\_create\_schedule) | Determines whether to create autoscaling group schedule or not | `bool` | `false` | no |
| <a name="input_datadog_enabled"></a> [datadog\_enabled](#input\_datadog\_enabled) | Datadog agent is enabled | `bool` | `false` | no |
| <a name="input_datadog_jmx_enabled"></a> [datadog\_jmx\_enabled](#input\_datadog\_jmx\_enabled) | Enables / Disables jmx monitor via the datadog agent | `bool` | `false` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Lower limit on the number of running tasks | `number` | `100` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | Desired number (capacity) of running ECS tasks | `number` | `1` | no |
| <a name="input_docker_container_command"></a> [docker\_container\_command](#input\_docker\_container\_command) | Docker container command | `list(string)` | `[]` | no |
| <a name="input_docker_container_entrypoint"></a> [docker\_container\_entrypoint](#input\_docker\_container\_entrypoint) | Docker container entrypoint | `list(string)` | `[]` | no |
| <a name="input_docker_container_port"></a> [docker\_container\_port](#input\_docker\_container\_port) | Docker container port | `number` | `3000` | no |
| <a name="input_docker_host_port"></a> [docker\_host\_port](#input\_docker\_host\_port) | Docker host port. 0 means Auto-assign. | `number` | `0` | no |
| <a name="input_docker_image_name"></a> [docker\_image\_name](#input\_docker\_image\_name) | Docker image name | `string` | `""` | no |
| <a name="input_docker_image_tag"></a> [docker\_image\_tag](#input\_docker\_image\_tag) | Docker image tag | `string` | `"latest"` | no |
| <a name="input_docker_labels"></a> [docker\_labels](#input\_docker\_labels) | Labels to be added to the docker. Used for auto-configuration, for instance of JMX discovery | `map(any)` | `null` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | ECR or any other docker registry | `string` | `"docker.io"` | no |
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | Domain names for AWS Route53 A records | `list(any)` | `[]` | no |
| <a name="input_ec2_eip_count"></a> [ec2\_eip\_count](#input\_ec2\_eip\_count) | Count of EIPs to create | `number` | `0` | no |
| <a name="input_ec2_eip_dns_enabled"></a> [ec2\_eip\_dns\_enabled](#input\_ec2\_eip\_dns\_enabled) | Whether to manage DNS records to be attached to the EIP | `bool` | `false` | no |
| <a name="input_ec2_eip_enabled"></a> [ec2\_eip\_enabled](#input\_ec2\_eip\_enabled) | Enable EC2 ASG Auto Assign EIP mode | `bool` | `false` | no |
| <a name="input_ec2_service_group"></a> [ec2\_service\_group](#input\_ec2\_service\_group) | Service group name, e.g. app, service name etc. | `string` | `"app"` | no |
| <a name="input_ecr_force_delete"></a> [ecr\_force\_delete](#input\_ecr\_force\_delete) | If true, will delete the ECR repository even if it contains images on destroy | `bool` | `false` | no |
| <a name="input_ecr_repo_create"></a> [ecr\_repo\_create](#input\_ecr\_repo\_create) | Creation of a ECR repo | `bool` | `false` | no |
| <a name="input_ecr_repo_name"></a> [ecr\_repo\_name](#input\_ecr\_repo\_name) | ECR repository name | `string` | `""` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ECS cluster arn. Should be specified to avoid data query by cluster name | `string` | `""` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | ECS cluster name | `string` | n/a | yes |
| <a name="input_ecs_exec_custom_prompt_enabled"></a> [ecs\_exec\_custom\_prompt\_enabled](#input\_ecs\_exec\_custom\_prompt\_enabled) | Enable Custom shell prompt on ECS Exec | `bool` | `false` | no |
| <a name="input_ecs_exec_enabled"></a> [ecs\_exec\_enabled](#input\_ecs\_exec\_enabled) | Turns on the Amazon ECS Exec for the task | `bool` | `true` | no |
| <a name="input_ecs_exec_prompt_string"></a> [ecs\_exec\_prompt\_string](#input\_ecs\_exec\_prompt\_string) | Shell prompt that contains ENV and APP\_NAME is enabled | `string` | `"\\e[1;35m★\\e[0m $ENV-$APP_NAME:$(wget -qO- $ECS_CONTAINER_METADATA_URI_V4 | sed -n 's/.*\"com.amazonaws.ecs.task-definition-version\":\"\\([^\"]*\\).*/\\1/p') \\e[1;36m★\\e[0m $(wget -qO- $ECS_CONTAINER_METADATA_URI_V4 | sed -n 's/.*\"Image\":\"\\([^\"]*\\).*/\\1/p' | awk -F\\: '{print $2}' )\\n\\e[1;33m\\e[0m \\w \\e[1;34m❯\\e[0m "` | no |
| <a name="input_ecs_launch_type"></a> [ecs\_launch\_type](#input\_ecs\_launch\_type) | ECS launch type: FARGATE or EC2 | `string` | `"FARGATE"` | no |
| <a name="input_ecs_network_mode"></a> [ecs\_network\_mode](#input\_ecs\_network\_mode) | Corresponds to networkMode in an ECS task definition. Supported values are none, bridge, host, or awsvpc | `string` | `"awsvpc"` | no |
| <a name="input_ecs_platform_version"></a> [ecs\_platform\_version](#input\_ecs\_platform\_version) | The platform version on which to run your service. Only applicable when using Fargate launch type | `string` | `"LATEST"` | no |
| <a name="input_ecs_service_deployed"></a> [ecs\_service\_deployed](#input\_ecs\_service\_deployed) | This service resource doesn't have task definition lifecycle policy, so terraform is used to deploy it (instead of ecs cli or ize) | `bool` | `false` | no |
| <a name="input_ecs_service_discovery_enabled"></a> [ecs\_service\_discovery\_enabled](#input\_ecs\_service\_discovery\_enabled) | ECS service can optionally be configured to use Amazon ECS Service Discovery | `bool` | `false` | no |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | The ECS service name | `string` | `""` | no |
| <a name="input_ecs_task_health_check_command"></a> [ecs\_task\_health\_check\_command](#input\_ecs\_task\_health\_check\_command) | Command to check for the health of the container | `string` | `""` | no |
| <a name="input_ecs_volumes_from"></a> [ecs\_volumes\_from](#input\_ecs\_volumes\_from) | The VolumeFrom property specifies details on a data volume from another container in the same task definition | `list(any)` | `[]` | no |
| <a name="input_efs_enabled"></a> [efs\_enabled](#input\_efs\_enabled) | Whether to enable EFS mount for ECS task | `bool` | `false` | no |
| <a name="input_efs_file_system_id"></a> [efs\_file\_system\_id](#input\_efs\_file\_system\_id) | EFS file system ID | `string` | `""` | no |
| <a name="input_efs_mount_point"></a> [efs\_mount\_point](#input\_efs\_mount\_point) | EFS mount point in the container | `string` | `"/mnt/efs"` | no |
| <a name="input_efs_root_directory"></a> [efs\_root\_directory](#input\_efs\_root\_directory) | EFS root directory | `string` | `"/"` | no |
| <a name="input_efs_share_create"></a> [efs\_share\_create](#input\_efs\_share\_create) | Whether to create EFS share or not | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | Target environment name of the infrastructure | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Map of parameters to be set in SSM and then exposed into a Task Definition as environment variables. | `map(string)` | n/a | yes |
| <a name="input_firelens_ecs_log_enabled"></a> [firelens\_ecs\_log\_enabled](#input\_firelens\_ecs\_log\_enabled) | AWS Firelens ECS logs enabled (used by FluentBit, Datadog, etc) | `bool` | `false` | no |
| <a name="input_global_secrets"></a> [global\_secrets](#input\_global\_secrets) | List of SSM ParameterStore global secrets - by default, /$var.env/global/* | `list(any)` | `[]` | no |
| <a name="input_gpu"></a> [gpu](#input\_gpu) | GPU-enabled container instances | `number` | `0` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | Port that is used for HTTP protocol | `number` | `80` | no |
| <a name="input_https_enabled"></a> [https\_enabled](#input\_https\_enabled) | Whether enable https or not (still needs tls\_cert\_arn) | `bool` | `true` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM Instance Profile | `string` | `null` | no |
| <a name="input_iam_role_policy_statement"></a> [iam\_role\_policy\_statement](#input\_iam\_role\_policy\_statement) | ECS Service IAM Role policy statement | `list(any)` | `[]` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | EC2 AMI id | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for ECS | `string` | `"t3.small"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | EC2 key name | `string` | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of running ECS tasks | `number` | `1` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Fargate Memory value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) | `number` | `512` | no |
| <a name="input_memory_reservation"></a> [memory\_reservation](#input\_memory\_reservation) | The soft limit (in MiB) of memory to reserve for the container | `number` | `256` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of running ECS tasks | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | ECS app name including all required namespaces | `string` | n/a | yes |
| <a name="input_operating_system_family"></a> [operating\_system\_family](#input\_operating\_system\_family) | Platform to be used with ECS. The valid values for Amazon ECS tasks hosted on Fargate are LINUX, WINDOWS\_SERVER\_2019\_FULL, and WINDOWS\_SERVER\_2019\_CORE. The valid values for Amazon ECS tasks hosted on EC2 are LINUX, WINDOWS\_SERVER\_2022\_CORE, WINDOWS\_SERVER\_2022\_FULL, WINDOWS\_SERVER\_2019\_FULL, and WINDOWS\_SERVER\_2019\_CORE, WINDOWS\_SERVER\_2016\_FULL, WINDOWS\_SERVER\_2004\_CORE, and WINDOWS\_SERVER\_20H2\_CORE. | `string` | `"LINUX"` | no |
| <a name="input_port_mappings"></a> [port\_mappings](#input\_port\_mappings) | List of ports to open from a service | `any` | `[]` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | VPC Private subnets to place ECS resources | `list(any)` | `[]` | no |
| <a name="input_proxy_docker_container_command"></a> [proxy\_docker\_container\_command](#input\_proxy\_docker\_container\_command) | Proxy docker container CMD | `list(string)` | <pre>[<br>  "nginx",<br>  "-g",<br>  "daemon off;"<br>]</pre> | no |
| <a name="input_proxy_docker_entrypoint"></a> [proxy\_docker\_entrypoint](#input\_proxy\_docker\_entrypoint) | Proxy docker container entrypoint | `list(string)` | <pre>[<br>  "/docker-entrypoint.sh"<br>]</pre> | no |
| <a name="input_proxy_docker_image_name"></a> [proxy\_docker\_image\_name](#input\_proxy\_docker\_image\_name) | Nginx proxy docker image name | `string` | `"nginx"` | no |
| <a name="input_public"></a> [public](#input\_public) | It's publicity accessible application | `bool` | `true` | no |
| <a name="input_public_ecs_service"></a> [public\_ecs\_service](#input\_public\_ecs\_service) | It's publicity accessible service | `bool` | `false` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | VPC Public subnets to place ECS resources | `list(any)` | `[]` | no |
| <a name="input_resource_requirements"></a> [resource\_requirements](#input\_resource\_requirements) | The ResourceRequirement property specifies the type and amount of a resource to assign to a container. The only supported resource is a GPU | `list(any)` | `[]` | no |
| <a name="input_root_block_device_size"></a> [root\_block\_device\_size](#input\_root\_block\_device\_size) | EBS root block device size in GB | `number` | `"50"` | no |
| <a name="input_root_block_device_type"></a> [root\_block\_device\_type](#input\_root\_block\_device\_type) | EBS root block device type | `string` | `"gp2"` | no |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | Domain name of AWS Route53 Zone | `string` | `""` | no |
| <a name="input_route53_health_check_enabled"></a> [route53\_health\_check\_enabled](#input\_route53\_health\_check\_enabled) | AWS Route53 health check is enabled | `bool` | `false` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | Map of autoscaling group schedule to create | `map(any)` | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security groups to assign to ECS Fargate task/ECS EC2 | `list(any)` | `[]` | no |
| <a name="input_shared_memory_size"></a> [shared\_memory\_size](#input\_shared\_memory\_size) | Size of the /dev/shm shared memory in MB | `number` | `0` | no |
| <a name="input_sidecar_container_definitions"></a> [sidecar\_container\_definitions](#input\_sidecar\_container\_definitions) | Sidecar container definitions for ECS task | `any` | `[]` | no |
| <a name="input_sns_service_subscription_endpoint"></a> [sns\_service\_subscription\_endpoint](#input\_sns\_service\_subscription\_endpoint) | You can use different endpoints, such as email, Pagerduty, Slack, etc. | `string` | `"exmple@example.com"` | no |
| <a name="input_sns_service_subscription_endpoint_protocol"></a> [sns\_service\_subscription\_endpoint\_protocol](#input\_sns\_service\_subscription\_endpoint\_protocol) | See valid protocols here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#protocol-support | `string` | `"email"` | no |
| <a name="input_ssm_global_secret_path"></a> [ssm\_global\_secret\_path](#input\_ssm\_global\_secret\_path) | AWS SSM root path to global environment secrets like /dev/global | `string` | `null` | no |
| <a name="input_ssm_secret_path"></a> [ssm\_secret\_path](#input\_ssm\_secret\_path) | AWS SSM root path to environment secrets of an app like /dev/app1 | `string` | `null` | no |
| <a name="input_tls_cert_arn"></a> [tls\_cert\_arn](#input\_tls\_cert\_arn) | TLS certificate ARN | `string` | `null` | no |
| <a name="input_tmpfs_container_path"></a> [tmpfs\_container\_path](#input\_tmpfs\_container\_path) | Path where tmpfs shm would be mounted | `string` | `"/tmp/"` | no |
| <a name="input_tmpfs_enabled"></a> [tmpfs\_enabled](#input\_tmpfs\_enabled) | TMPFS support for non-Fargate deployments | `bool` | `false` | no |
| <a name="input_tmpfs_mount_options"></a> [tmpfs\_mount\_options](#input\_tmpfs\_mount\_options) | Options for the mount of the ram disk. noatime by default to speed up access | `list(string)` | <pre>[<br>  "noatime"<br>]</pre> | no |
| <a name="input_tmpfs_size"></a> [tmpfs\_size](#input\_tmpfs\_size) | Size of the tmpfs in MB | `number` | `1024` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Amazon data volumes for ECS Task (efs/FSx/Docker volume/Bind mounts) | `list(any)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | AWS VPC ID | `string` | n/a | yes |
| <a name="input_web_proxy_docker_container_port"></a> [web\_proxy\_docker\_container\_port](#input\_web\_proxy\_docker\_container\_port) | Proxy docker container port | `number` | `80` | no |
| <a name="input_web_proxy_docker_image_tag"></a> [web\_proxy\_docker\_image\_tag](#input\_web\_proxy\_docker\_image\_tag) | Nginx proxy docker image tag | `string` | `"1.19.2-alpine"` | no |
| <a name="input_web_proxy_enabled"></a> [web\_proxy\_enabled](#input\_web\_proxy\_enabled) | Nginx proxy enabled | `bool` | `false` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | AWS Route53 Zone ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN of the ALB (if ALB is created) |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | Name of the ALB DNS record (if ALB is created) |
| <a name="output_alb_dns_zone"></a> [alb\_dns\_zone](#output\_alb\_dns\_zone) | Zone ID of the ALB DNS record (if ALB is created) |
| <a name="output_cloudwatch_event_rule_id"></a> [cloudwatch\_event\_rule\_id](#output\_cloudwatch\_event\_rule\_id) | ID of the Cloudwatch event rule for ECS Scheduled Task |
| <a name="output_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#output\_cloudwatch\_log\_group) | n/a |
| <a name="output_ec2_dns_name"></a> [ec2\_dns\_name](#output\_ec2\_dns\_name) | Public DNS name of the EC2 instance (if EC2 is used) |
| <a name="output_efs_mount_target"></a> [efs\_mount\_target](#output\_efs\_mount\_target) | DNS name of the EFS mount target (if EFS is created) |
| <a name="output_eips"></a> [eips](#output\_eips) | List of EIPs associated with the EC2 instances (if EC2 is used) |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP of the EC2 instance (if EC2 is used) |
| <a name="output_r53_lb_dns_name"></a> [r53\_lb\_dns\_name](#output\_r53\_lb\_dns\_name) | DNS name of the record that is attached to the ALB (if app type is web or tcp-ap) |
| <a name="output_this_target_group_arn"></a> [this\_target\_group\_arn](#output\_this\_target\_group\_arn) | n/a |
| <a name="output_this_task_definition_arn"></a> [this\_task\_definition\_arn](#output\_this\_task\_definition\_arn) | n/a |
<!-- END_TF_DOCS -->
